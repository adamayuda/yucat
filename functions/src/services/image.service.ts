import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {config} from "../config";
import {IMAGE_VALIDATION, IMAGE_OPTIMIZATION} from "../constants";
import {validateImageData} from "../utils/validation";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let sharpModule: any = null;
async function loadSharp() {
  if (!sharpModule) {
    try {
      const sharpImport = await import("sharp");
      sharpModule = sharpImport.default;
      return sharpModule;
    } catch (error) {
      logger.warn("Sharp not available, image optimization disabled", {
        error: error instanceof Error ? error.message : String(error),
        structuredData: true,
      });
      return null;
    }
  }
  return sharpModule;
}

/**
 * Tests if an image URL is accessible and has an image content-type.
 */
export async function isImageUrlValid(imageUrl: string): Promise<boolean> {
  try {
    const response = await fetch(imageUrl, {
      method: "HEAD",
      headers: IMAGE_VALIDATION.HEADERS,
    });

    if (!response.ok) {
      return false;
    }

    const contentType = response.headers.get("content-type") || "";
    if (!contentType.startsWith("image/")) {
      logger.warn("URL does not point to an image", {
        imageUrl,
        contentType,
        structuredData: true,
      });
      return false;
    }

    return true;
  } catch (error) {
    logger.warn("Image URL validation failed", {
      imageUrl,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return false;
  }
}

async function downloadImage(
  imageUrl: string
): Promise<{buffer: Buffer; contentType: string}> {
  const imageResponse = await fetch(imageUrl, {
    headers: IMAGE_VALIDATION.HEADERS,
  });

  if (!imageResponse.ok) {
    throw new Error(`Failed to download image: ${imageResponse.statusText}`);
  }

  const imageBuffer = await imageResponse.arrayBuffer();
  const imageData = Buffer.from(imageBuffer);
  const contentType = imageResponse.headers.get("content-type") || "image/jpeg";

  validateImageData(imageData, IMAGE_VALIDATION.MIN_SIZE_BYTES);

  return {buffer: imageData, contentType};
}

async function optimizeImageForMobile(
  imageBuffer: Buffer,
  barcode: string
): Promise<{buffer: Buffer; format: string}> {
  const originalSize = imageBuffer.length;

  logger.info("Starting image optimization", {
    barcode,
    originalSize,
    structuredData: true,
  });

  const sharpLib = await loadSharp();
  if (!sharpLib) {
    return {buffer: imageBuffer, format: "jpg"};
  }

  try {
    let sharpInstance = sharpLib(imageBuffer)
      .resize({
        width: IMAGE_OPTIMIZATION.MAX_WIDTH,
        height: IMAGE_OPTIMIZATION.MAX_HEIGHT,
        fit: IMAGE_OPTIMIZATION.FIT,
        withoutEnlargement: true,
      });

    let optimizedBuffer: Buffer;
    const format = IMAGE_OPTIMIZATION.OUTPUT_FORMAT;

    if (format === "webp") {
      sharpInstance = sharpInstance.webp({
        quality: IMAGE_OPTIMIZATION.WEBP_QUALITY,
      });
      optimizedBuffer = await sharpInstance.toBuffer();
    } else if (format === "jpeg") {
      sharpInstance = sharpInstance.jpeg({
        quality: IMAGE_OPTIMIZATION.JPEG_QUALITY,
        progressive: true,
      });
      optimizedBuffer = await sharpInstance.toBuffer();
    } else {
      sharpInstance = sharpInstance.png({
        compressionLevel: IMAGE_OPTIMIZATION.PNG_COMPRESSION,
      });
      optimizedBuffer = await sharpInstance.toBuffer();
    }

    const optimizedSize = optimizedBuffer.length;
    const savings = ((1 - optimizedSize / originalSize) * 100).toFixed(1);

    logger.info("Image optimization complete", {
      barcode,
      originalSize,
      optimizedSize,
      savings: `${savings}%`,
      format,
      structuredData: true,
    });

    return {buffer: optimizedBuffer, format};
  } catch (error) {
    logger.warn("Image optimization failed, using original", {
      barcode,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return {buffer: imageBuffer, format: "jpg"};
  }
}

async function uploadToStorage(
  imageData: Buffer,
  fileName: string,
  contentType: string,
  barcode: string,
  productName: string
): Promise<string> {
  const bucket = admin.storage().bucket(config.storage.bucketName);
  const file = bucket.file(fileName);

  await file.save(imageData, {
    contentType: contentType,
    metadata: {
      metadata: {
        barcode: barcode,
        productName: productName,
      },
    },
  });

  await file.makePublic();

  return `https://storage.googleapis.com/${bucket.name}/${fileName}`;
}

/**
 * Downloads, optimizes, and uploads an image from a URL to Firebase Storage.
 * Returns the public Firebase Storage URL.
 */
export async function uploadImageToFirebaseStorage(
  imageUrl: string,
  barcode: string,
  productName: string
): Promise<string> {
  logger.info("Downloading image from URL", {
    barcode,
    imageUrl,
    structuredData: true,
  });

  const {buffer: imageData} = await downloadImage(imageUrl);

  const {buffer: optimizedImage, format} = await optimizeImageForMobile(
    imageData,
    barcode
  );

  const contentType = `image/${format}`;
  const fileName = `${config.storage.productsFolder}${barcode}.${format}`;

  const publicUrl = await uploadToStorage(
    optimizedImage,
    fileName,
    contentType,
    barcode,
    productName
  );

  logger.info("Image uploaded to Firebase Storage", {
    barcode,
    fileName,
    publicUrl,
    structuredData: true,
  });

  return publicUrl;
}
