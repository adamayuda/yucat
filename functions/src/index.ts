/* eslint-disable max-len */
import {onCall} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {config} from "./config";
import {CANONICAL_LANGUAGE, normalizeLanguage} from "./prompts/languages";
import {
  identifyProductFromImage,
  analyzeProductImage,
  analyzeProductImageParallel,
  findProductImageUrl,
  verifyMatchWithLLM,
  translateProductText,
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
import {
  processProductImage,
  processUserPhotoImage,
  uploadUserPhoto,
} from "./utils/image-helpers";
import {logScanRequest} from "./utils/scan-log";
import {createTimer} from "./utils/timing";
import {Product, ProductText} from "./models/product";

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

/** The canonical (English) renderable text of a product record. */
const canonicalText = (p: Product): ProductText => ({
  format: p.format ?? "",
  packageSize: p.packageSize ?? "",
  description: p.description ?? "",
  pros: p.pros ?? [],
  cons: p.cons ?? [],
});

/**
 * Returns the product's text in [language], translating and attaching it to
 * `product.translations` on a miss.
 *
 * The stored record stays canonical English — the Flutter client keyword-scans
 * `pros`/`cons` in English to drive its per-cat rules engine, so translating in
 * place would silently break the per-cat verdict.
 *
 * Mutates `product` but does NOT persist; `added` tells the caller whether a
 * write-back is needed. Best-effort throughout: any failure yields
 * `{text: null}` and the client falls back to English.
 */
async function ensureTranslation(
  product: Product,
  language: string | undefined
): Promise<{text: ProductText | null; added: boolean}> {
  if (!language || language === CANONICAL_LANGUAGE) {
    return {text: null, added: false};
  }

  const cached = product.translations?.[language];
  if (cached) return {text: cached, added: false};

  const source = canonicalText(product);
  const hasSomethingToTranslate =
    !!source.description ||
    !!source.format ||
    source.pros.length > 0 ||
    source.cons.length > 0;
  if (!hasSomethingToTranslate) return {text: null, added: false};

  const translated = await translateProductText(source, language);
  if (!translated) return {text: null, added: false};

  product.translations = {
    ...(product.translations ?? {}),
    [language]: translated,
  };
  return {text: translated, added: true};
}

/**
 * Per-user image fallback: when no product image could be found on the web,
 * host a display-sized copy of the user's own scan photo and return it to
 * *that* user only.
 *
 * ⚠️ The result must never be assigned to `product.imageUrl` — `product` is the
 * same object handed to `cacheProduct`, so that would publish one user's photo
 * as the shared catalog image for everyone. It is returned as its own response
 * field instead, which makes the leak impossible by construction rather than by
 * write ordering. Leaving the record's `imageUrl` empty also keeps the 14-day
 * self-heal and `backfill-images.ts` hunting for a real product shot.
 *
 * Returns null when the product already has an image, when the scan upload
 * failed, or when hosting failed — the client then keeps its placeholder.
 */
async function resolveUserPhotoFallback(
  product: Product | null,
  userPhotoUrl: string,
  requestId: string,
  path: string
): Promise<string | null> {
  if (!product || hasImage(product) || !userPhotoUrl) return null;

  const hosted = await processUserPhotoImage(userPhotoUrl, requestId);
  if (!hosted) return null;

  logger.info("user photo fallback used", {
    requestId,
    path,
    brand: product.brand,
    name: product.name,
    structuredData: true,
  });
  return hosted;
}

export const fetchProductByImageV2 = onCall(
  {
    cors: config.functions.corsEnabled,
    timeoutSeconds: config.functions.timeoutSeconds,
    secrets: ["ANTHROPIC_API_KEY", "ALGOLIA_API_KEY", "SERPAPI_API_KEY"],
  },
  async (request) => {
    const {image, mimeType, userId, countryCode, locale} = request.data;

    if (!image || typeof image !== "string") {
      throw new Error("Missing required field: image (base64-encoded string)");
    }

    // Optional ISO 3166-1 alpha-2 device country (e.g. "ES"); biases web_search
    // toward the user's market. Absent → no biasing (older clients, no regression).
    const resolvedCountry =
      typeof countryCode === "string" && countryCode.trim() ?
        countryCode.trim() :
        undefined;

    // Optional app language (e.g. "fr"). Drives the translated copy returned in
    // `localizedText`; unsupported or absent → English only (older clients, no
    // regression). Distinct from countryCode, which is a region, not a language.
    const resolvedLanguage = normalizeLanguage(locale);

    const resolvedMimeType = VALID_MIME_TYPES.includes(mimeType) ? mimeType : "image/jpeg";

    logger.info("Image endpoint called", {
      userId,
      mimeType: resolvedMimeType,
      imageSize: image.length,
      language: resolvedLanguage ?? CANONICAL_LANGUAGE,
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
          localizedText: null,
          userPhotoFallbackUrl: null,
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

          // Lazy translation fill: the first requester of a language pays one
          // small Haiku call, everyone after reads it off the record.
          const localized = await ensureTranslation(
            cachedProduct,
            resolvedLanguage
          );
          if (localized.added) {
            await cacheProduct(cachedProduct.barcode, cachedProduct);
          }
          timer.mark("translate");

          // Every cache write for this product is done above, so nothing can
          // carry the fallback into the shared record.
          const cachedFallback = await resolveUserPhotoFallback(
            cachedProduct,
            userPhotoUrl,
            requestId,
            "cache-hit"
          );
          timer.mark("userPhotoFallback");

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
            localizedText: localized.text,
            userPhotoFallbackUrl: cachedFallback,
          };
        }
      }

      // Step 3 — full analysis with Haiku + web_search.
      logger.info("No cache match, running full analysis", {
        brand: identification.brand,
        name: identification.name,
        structuredData: true,
      });

      // Look up AND host the SerpAPI product image IN PARALLEL with the slow
      // analyze step. Claude almost never returns a hostable image URL, so we
      // need SerpAPI on essentially every cache miss anyway — doing the full
      // download/optimize/upload concurrently takes it off the critical path.
      // The filename uses a provisional key derived from the identification
      // (the analyzed brand/name are near-identical, so it matches the final
      // cache key in practice; a rare mismatch only changes the stored filename,
      // not the URL's validity). overwriteKey wins when re-analyzing in place.
      const provisionalKey =
        overwriteKey ??
        `img-${identification.brand}-${identification.name}`
          .toLowerCase()
          .replace(/\s+/g, "-");
      // Guarded so a rejection on the unawaited promise can never go unhandled.
      const serpApiHostedPromise = (async () => {
        const url = await findProductImageUrl(
          identification.brand,
          identification.name
        );
        if (!url) return "";
        return processProductImage(
          url,
          provisionalKey,
          identification.name,
          identification.brand
        );
      })().catch(() => "");

      const {product, rawResponse} = config.anthropic.useParallelAnalysis ?
        await analyzeProductImageParallel(
          image,
          resolvedMimeType,
          identification,
          resolvedCountry
        ) :
        await analyzeProductImage(
          image,
          resolvedMimeType,
          identification,
          resolvedCountry
        );
      timer.mark("analyze");

      let localizedText: ProductText | null = null;
      let userPhotoFallbackUrl: string | null = null;

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

        // Host the analyze-provided image first (most exact). If that yields
        // nothing — empty, or a non-image page URL that fails validation — use
        // the SerpAPI image already hosted in parallel during analyze (await
        // here usually resolves instantly, since it overlapped analyze).
        let hostedImage = await processProductImage(
          product.imageUrl,
          cacheKey,
          product.name,
          product.brand
        );
        if (!hostedImage) {
          hostedImage = await serpApiHostedPromise;
        }
        product.imageUrl = hostedImage;
        timer.mark("imageHost");

        // Timestamps throttle the next self-heal attempt (see REANALYZE_AFTER_MS).
        product.lastAnalysisAttempt = Date.now();
        product.lastImageAttempt = Date.now();

        // Translate before the cache write below so the translation lands in the
        // same Algolia round-trip rather than costing a second write.
        localizedText = (await ensureTranslation(product, resolvedLanguage)).text;
        timer.mark("translate");

        logger.info("Image product processing complete", {
          productName: product.name,
          brand: product.brand,
          hasImage: !!product.imageUrl,
          cacheKey,
          structuredData: true,
        });
        // Cache write and scan-log are independent — run concurrently. (Product
        // is fully built above and not mutated after this, so both read the same
        // final state with no race.)
        await Promise.all([
          cacheProduct(cacheKey, product),
          logScanRequest({
            requestId,
            userId: userId || null,
            userPhotoUrl,
            identification,
            cachedMatch: false,
            product,
            timestamp: new Date(),
          }),
        ]);
        timer.mark("finalize");

        // After the cache write, so the fallback cannot reach the shared record.
        userPhotoFallbackUrl = await resolveUserPhotoFallback(
          product,
          userPhotoUrl,
          requestId,
          "full-analysis"
        );
        timer.mark("userPhotoFallback");
      } else {
        await logScanRequest({
          requestId,
          userId: userId || null,
          userPhotoUrl,
          identification,
          cachedMatch: false,
          product: null,
          timestamp: new Date(),
        });
        timer.mark("finalize");
      }

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
        localizedText,
        userPhotoFallbackUrl,
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
