/* eslint-disable max-len */
import {onCall} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {config} from "./config";
import {
  identifyProductFromImage,
  analyzeProductImage,
  verifyMatchWithLLM,
} from "./services/anthropic.service";
import {
  cacheProduct,
  fetchCandidatesByName,
  searchProductByNameV2,
} from "./services/algolia.service";
import {processProductImage, uploadUserPhoto} from "./utils/image-helpers";
import {logScanRequest} from "./utils/scan-log";

admin.initializeApp();

const VALID_MIME_TYPES = ["image/jpeg", "image/png", "image/webp", "image/heic"];

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

      if (cachedProduct) {
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

      // Step 3 — full analysis with Haiku + web_search.
      logger.info("No cache match, running full analysis", {
        brand: identification.brand,
        name: identification.name,
        structuredData: true,
      });

      const {product, rawResponse} = await analyzeProductImage(image, resolvedMimeType);

      if (product && product.name) {
        // Image-flow products are always AI-identified.
        product.isAiIdentified = true;

        const cacheKey = `img-${product.brand}-${product.name}`
          .toLowerCase()
          .replace(/\s+/g, "-");
        product.barcode = cacheKey;

        product.imageUrl = await processProductImage(
          product.imageUrl,
          cacheKey,
          product.name,
          product.brand
        );

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
