/* eslint-disable max-len */
import {onCall} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {config} from "./config";
import {
  identifyProductFromImage,
  analyzeProductImage,
  analyzeProductImageParallel,
  findProductImageUrl,
  verifyMatchWithLLM,
  generateCatNarrative as buildCatNarrative,
  analyzeBrand as runAnalyzeBrand,
} from "./services/anthropic.service";
import {CatNarrativeInput} from "./prompts/cat-narrative";
import {BrandVerdictInput} from "./prompts/brand-verdict";
import {
  cacheProduct,
  fetchCandidatesByName,
  searchProductByNameV2,
} from "./services/algolia.service";
import {processProductImage, uploadUserPhoto} from "./utils/image-helpers";
import {logScanRequest} from "./utils/scan-log";
import {createTimer} from "./utils/timing";
import {Product} from "./models/product";

admin.initializeApp();

const VALID_MIME_TYPES = ["image/jpeg", "image/png", "image/webp", "image/heic"];

// Self-healing cache: a cached entry can be re-attempted at most once per window.
const REANALYZE_AFTER_MS = 14 * 24 * 60 * 60 * 1000; // 14 days

// A genuinely analyzed product always scores > 0; the force-submit fallback
// (no guaranteed analysis found) is the only path that yields score 0.
const hasNutritionData = (p: Product): boolean => p.score > 0;
const hasImage = (p: Product): boolean => !!p.imageUrl;
const isStale = (ts?: number): boolean =>
  !ts || Date.now() - ts > REANALYZE_AFTER_MS;

export const fetchProductByImageV2 = onCall(
  {
    cors: config.functions.corsEnabled,
    timeoutSeconds: config.functions.timeoutSeconds,
    secrets: ["ANTHROPIC_API_KEY", "ALGOLIA_API_KEY", "SERPAPI_API_KEY"],
  },
  async (request) => {
    const {image, mimeType, userId} = request.data;

    if (!image || typeof image !== "string") {
      throw new Error("Missing required field: image (base64-encoded string)");
    }

    const resolvedMimeType = VALID_MIME_TYPES.includes(mimeType) ? mimeType : "image/jpeg";

    logger.info("Image endpoint called", {
      userId,
      mimeType: resolvedMimeType,
      imageSize: image.length,
      structuredData: true,
    });

    const requestId = `scan-${Date.now()}-${Math.random().toString(36).substring(2, 8)}`;

    // Per-step latency instrumentation (measurement only — see utils/timing.ts).
    const timer = createTimer();

    try {
      // Background: upload the user's scan photo to Storage.
      const userPhotoPromise = uploadUserPhoto(image, resolvedMimeType, requestId);

      // Step 1 — fast identification (Haiku vision, no web_search).
      const identification = await identifyProductFromImage(image, resolvedMimeType);
      timer.mark("identify");

      const userPhotoUrl = await userPhotoPromise;
      timer.mark("userPhotoUpload");

      if (!identification) {
        await logScanRequest({
          requestId,
          userId: userId || null,
          userPhotoUrl,
          identification: null,
          cachedMatch: false,
          product: null,
          timestamp: new Date(),
        });
        timer.mark("scanLog");

        logger.info("scan timings", {
          requestId,
          path: "not-identified",
          ...timer.summary(),
          structuredData: true,
        });

        return {
          message: "Could not identify a cat food product in the image",
          userId: userId || null,
          geminiResponse: "",
          product: null,
        };
      }

      // Step 2 — Algolia cache lookup with V2 string matching.
      let cachedProduct = await searchProductByNameV2(
        identification.brand,
        identification.name,
        identification.foodType
      );
      timer.mark("cacheLookup");

      // Step 2b — optional LLM verification when string match misses.
      if (!cachedProduct && config.algolia.useLLMVerification) {
        const candidates = await fetchCandidatesByName(
          identification.brand,
          identification.name,
          identification.foodType
        );
        if (candidates.length > 0) {
          cachedProduct = await verifyMatchWithLLM(identification, candidates);
        }
        timer.mark("llmVerify");
      }

      // When the cache hit is a stale no-data entry, fall through to a full
      // re-analysis and overwrite it in place (under this object id).
      let overwriteKey: string | undefined;

      if (cachedProduct) {
        const staleJunk =
          !hasNutritionData(cachedProduct) &&
          isStale(cachedProduct.lastAnalysisAttempt);

        if (staleJunk) {
          overwriteKey = cachedProduct.barcode;
          logger.info("Cache hit is a stale no-data entry — re-analyzing", {
            brand: cachedProduct.brand,
            name: cachedProduct.name,
            lastAnalysisAttempt: cachedProduct.lastAnalysisAttempt ?? null,
            structuredData: true,
          });
        } else {
          // Image-only backfill: the entry has nutrition data but no image and
          // hasn't been attempted recently. Cheaper than a full re-analysis.
          if (
            hasNutritionData(cachedProduct) &&
            !hasImage(cachedProduct) &&
            isStale(cachedProduct.lastImageAttempt)
          ) {
            logger.info("Cache hit missing image — attempting image backfill", {
              brand: cachedProduct.brand,
              name: cachedProduct.name,
              structuredData: true,
            });
            const foundUrl = await findProductImageUrl(
              cachedProduct.brand,
              cachedProduct.name
            );
            cachedProduct.imageUrl = await processProductImage(
              foundUrl,
              cachedProduct.barcode,
              cachedProduct.name,
              cachedProduct.brand
            );
            cachedProduct.lastImageAttempt = Date.now();
            await cacheProduct(cachedProduct.barcode, cachedProduct);
            timer.mark("imageBackfill");
          }

          logger.info("Cache hit, skipping full analysis", {
            brand: cachedProduct.brand,
            name: cachedProduct.name,
            structuredData: true,
          });

          await logScanRequest({
            requestId,
            userId: userId || null,
            userPhotoUrl,
            identification,
            cachedMatch: true,
            product: cachedProduct,
            timestamp: new Date(),
          });
          timer.mark("scanLog");

          logger.info("scan timings", {
            requestId,
            path: "cache-hit",
            ...timer.summary(),
            structuredData: true,
          });

          return {
            message: "Product found in cache",
            userId: userId || null,
            geminiResponse: "",
            product: cachedProduct,
          };
        }
      }

      // Step 3 — full analysis with Haiku + web_search.
      logger.info("No cache match, running full analysis", {
        brand: identification.brand,
        name: identification.name,
        structuredData: true,
      });

      // Kick off the SerpAPI product-image lookup IN PARALLEL with the slow
      // analyze step. Claude's web_search almost never returns a hostable image
      // URL (it returns page URLs), so we need SerpAPI on essentially every cache
      // miss anyway — running it concurrently overlaps its ~6-7s with analyze and
      // takes it off the critical path. Uses the identification brand/name (the
      // analyzed product.brand/name aren't available yet, and are near-identical).
      // findProductImageUrl swallows its own errors (returns ""), but guard the
      // unawaited promise so a rejection can never go unhandled.
      const serpApiImageUrlPromise = findProductImageUrl(
        identification.brand,
        identification.name
      ).catch(() => "");

      const {product, rawResponse} = config.anthropic.useParallelAnalysis ?
        await analyzeProductImageParallel(
          image,
          resolvedMimeType,
          identification
        ) :
        await analyzeProductImage(image, resolvedMimeType, identification);
      timer.mark("analyze");

      if (product && product.name) {
        // Image-flow products are always AI-identified.
        product.isAiIdentified = true;

        const derivedKey = `img-${product.brand}-${product.name}`
          .toLowerCase()
          .replace(/\s+/g, "-");
        // Reuse the existing object id when re-analyzing a stale entry so we
        // overwrite it in place rather than create a near-duplicate sibling.
        const cacheKey = overwriteKey ?? derivedKey;
        product.barcode = cacheKey;

        // Host the analyze-provided image first. If that yields nothing —
        // empty, or a non-image page URL that fails validation — fall back to the
        // SerpAPI lookup that's been running in parallel since before analyze
        // (await here usually resolves instantly, since it overlapped analyze).
        let hostedImage = await processProductImage(
          product.imageUrl,
          cacheKey,
          product.name,
          product.brand
        );
        timer.mark("imageHostPrimary");
        let imageLookupRan = false;
        if (!hostedImage) {
          const foundUrl = await serpApiImageUrlPromise;
          timer.mark("imageSearchSerpapi");
          imageLookupRan = true;
          if (foundUrl) {
            hostedImage = await processProductImage(
              foundUrl,
              cacheKey,
              product.name,
              product.brand
            );
            timer.mark("imageHostFallback");
          }
        }
        product.imageUrl = hostedImage;

        // Timestamps throttle the next self-heal attempt (see REANALYZE_AFTER_MS).
        product.lastAnalysisAttempt = Date.now();
        if (imageLookupRan) {
          product.lastImageAttempt = Date.now();
        }

        await cacheProduct(cacheKey, product);
        timer.mark("cacheWrite");

        logger.info("Image product processing complete", {
          productName: product.name,
          brand: product.brand,
          hasImage: !!product.imageUrl,
          cacheKey,
          structuredData: true,
        });
      }

      await logScanRequest({
        requestId,
        userId: userId || null,
        userPhotoUrl,
        identification,
        cachedMatch: false,
        product: product || null,
        timestamp: new Date(),
      });
      timer.mark("scanLog");

      logger.info("scan timings", {
        requestId,
        path: "full-analysis",
        ...timer.summary(),
        structuredData: true,
      });

      return {
        message: "Image processed successfully",
        userId: userId || null,
        geminiResponse: rawResponse,
        product,
      };
    } catch (error) {
      logger.error("Error processing product image", {
        error: error instanceof Error ? error.message : String(error),
        structuredData: true,
      });
      throw new Error(
        `Error processing product image: ${
          error instanceof Error ? error.message : String(error)
        }`
      );
    }
  }
);

/**
 * Onboarding personalized narrative. Takes a freshly created cat profile plus
 * the structured dietary tips computed on-device and returns a short, warm note
 * written by Haiku in the requested locale. Returns `{narrative: null}` on
 * failure so the client falls back to its local template (never throws for a
 * missing narrative — it's a non-critical enhancement).
 */
export const generateCatNarrative = onCall(
  {
    cors: config.functions.corsEnabled,
    timeoutSeconds: 60,
    secrets: ["ANTHROPIC_API_KEY"],
  },
  async (request) => {
    const data = request.data as Partial<CatNarrativeInput>;

    if (!data?.name || typeof data.name !== "string") {
      throw new Error("Missing required field: name");
    }

    const input: CatNarrativeInput = {
      name: data.name,
      lifeStage: data.lifeStage,
      breed: data.breed,
      gender: data.gender,
      bodyCondition: data.bodyCondition,
      activityLevel: data.activityLevel,
      neuteredStatus: data.neuteredStatus,
      coatType: data.coatType,
      healthConditions: Array.isArray(data.healthConditions) ?
        data.healthConditions :
        [],
      tips: Array.isArray(data.tips) ? data.tips : [],
      locale: data.locale,
    };

    const result = await buildCatNarrative(input);
    return {
      narrative: result?.narrative ?? null,
      outlook: result?.outlook ?? null,
    };
  }
);

/**
 * Onboarding brand critique. Returns a short quality verdict for the brand the
 * owner currently feeds, grounded by the supplied catalog context when present.
 * Returns `{verdict: null}` on failure so the client degrades gracefully.
 */
export const analyzeBrand = onCall(
  {
    cors: config.functions.corsEnabled,
    timeoutSeconds: 60,
    secrets: ["ANTHROPIC_API_KEY"],
  },
  async (request) => {
    const data = request.data as Partial<BrandVerdictInput>;
    if (!data?.brand || typeof data.brand !== "string") {
      throw new Error("Missing required field: brand");
    }
    const verdict = await runAnalyzeBrand({
      brand: data.brand,
      catName: data.catName,
      locale: data.locale,
      catalogContext: data.catalogContext,
    });
    return {verdict};
  }
);
