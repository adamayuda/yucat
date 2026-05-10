import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {config} from "../config";
import {
  isImageUrlValid,
  uploadImageToFirebaseStorage,
} from "../services/image.service";

/**
 * Uploads the user's scan photo to Firebase Storage in the background.
 * Returns the public URL or empty string on failure.
 */
export async function uploadUserPhoto(
  base64Image: string,
  mimeType: string,
  requestId: string
): Promise<string> {
  try {
    const extension = mimeType.split("/")[1] || "jpeg";
    const fileName = `scans/${requestId}.${extension}`;
    const bucket = admin.storage().bucket(config.storage.bucketName);
    const file = bucket.file(fileName);

    const buffer = Buffer.from(base64Image, "base64");

    await file.save(buffer, {
      contentType: mimeType,
      metadata: {
        metadata: {requestId},
      },
    });

    await file.makePublic();

    return `https://storage.googleapis.com/${bucket.name}/${fileName}`;
  } catch (error) {
    logger.warn("Failed to upload user photo", {
      requestId,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return "";
  }
}

/**
 * Validates and uploads the LLM-supplied product image URL to Firebase Storage.
 * Returns the public Storage URL, or empty string if no valid image is found.
 *
 * The Flutter UI tolerates an empty `imageUrl` (renders a placeholder), so
 * unlike the Gemini-era pipeline, there is no SerpAPI/search fallback here.
 */
export async function processProductImage(
  imageUrl: string,
  cacheKey: string,
  productName: string,
  brand: string
): Promise<string> {
  if (!imageUrl || imageUrl.trim() === "") {
    logger.warn("No image URL provided by Haiku", {
      cacheKey,
      brand,
      productName,
      structuredData: true,
    });
    return "";
  }

  const isValid = await isImageUrlValid(imageUrl);
  if (!isValid) {
    logger.warn("Image URL validation failed - no fallback configured", {
      cacheKey,
      imageUrl,
      structuredData: true,
    });
    return "";
  }

  try {
    const uploadedUrl = await uploadImageToFirebaseStorage(
      imageUrl,
      cacheKey,
      productName
    );
    logger.info("Image uploaded to Firebase Storage", {
      cacheKey,
      originalUrl: imageUrl,
      uploadedUrl,
      structuredData: true,
    });
    return uploadedUrl;
  } catch (error) {
    logger.warn("Failed to upload image - returning empty string", {
      cacheKey,
      originalUrl: imageUrl,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return "";
  }
}
