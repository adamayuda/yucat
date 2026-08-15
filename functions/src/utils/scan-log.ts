import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

/**
 * Logs an image scan request to the Firestore /scans collection.
 * Failures are swallowed — logging is best-effort and must not affect
 * the user-facing response.
 */
export async function logScanRequest(data: {
  requestId: string;
  userId: string | null;
  userPhotoUrl: string;
  /**
   * What the identify step read off the packaging. `category` distinguishes a
   * food scan from a litter scan; absent on rows written before litter support.
   */
  identification:
    | {brand: string; name: string; foodType?: string; category?: string}
    | null;
  cachedMatch: boolean;
  /** The analyzed record — a `Product` on a food scan, a `Litter` on a litter scan. */
  product: object | null;
  timestamp: Date;
}): Promise<void> {
  try {
    await admin.firestore().collection("scans").doc(data.requestId).set(data);
  } catch (error) {
    logger.warn("Failed to log scan to Firestore", {
      requestId: data.requestId,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
  }
}
