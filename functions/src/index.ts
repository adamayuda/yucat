/* eslint-disable max-len */
import {onCall} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {config} from "./config";
import {
  identifyProductFromImage,
  analyzeProductImage,
  findProductImageUrl,
  verifyMatchWithLLM,
} from "./services/anthropic.service";
import {
  cacheProduct,
  fetchCandidatesByName,
  searchProductByNameV2,
} from "./services/algolia.service";
import {processProductImage, uploadUserPhoto} from "./utils/image-helpers";
import {logScanRequest} from "./utils/scan-log";
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
    secrets: ["ANTHROPIC_API_KEY"],
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

    try {
      // Background: upload the user's scan photo to Storage.
      const userPhotoPromise = uploadUserPhoto(image, resolvedMimeType, requestId);

      // Step 1 — fast identification (Haiku vision, no web_search).
      const identification = await identifyProductFromImage(image, resolvedMimeType);

      const userPhotoUrl = await userPhotoPromise;

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

      const {product, rawResponse} = await analyzeProductImage(
        image,
        resolvedMimeType,
        identification
      );

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
        // empty, or a non-image page URL that fails validation — fall back to a
        // dedicated image search and host whatever it finds.
        let hostedImage = await processProductImage(
          product.imageUrl,
          cacheKey,
          product.name,
          product.brand
        );
        let imageLookupRan = false;
        if (!hostedImage) {
          const foundUrl = await findProductImageUrl(
            product.brand,
            product.name
          );
          imageLookupRan = true;
          if (foundUrl) {
            hostedImage = await processProductImage(
              foundUrl,
              cacheKey,
              product.name,
              product.brand
            );
          }
        }
        product.imageUrl = hostedImage;

        // Timestamps throttle the next self-heal attempt (see REANALYZE_AFTER_MS).
        product.lastAnalysisAttempt = Date.now();
        if (imageLookupRan) {
          product.lastImageAttempt = Date.now();
        }

        await cacheProduct(cacheKey, product);

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
