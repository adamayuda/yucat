import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

function stripTranslations(
  record: Record<string, unknown>
): Record<string, unknown> {
  const rest = {...record};
  delete rest.translations;
  return rest;
}

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
  /** Wire `outcome` (see index.ts `ScanResponse`); absent on pre-Phase-1 rows. */
  outcome?: string;
  /** Identify-step rejection reason on a not-identified scan. */
  reason?: string | null;
  /** The `path` logged in "scan timings" — joins the doc to the log line. */
  path?: string;
  /** Normalised GTIN the client read off the pack, when any. */
  gtin?: string | null;
  /** `scan` (front photo, default) or `label` (back-label rescue). */
  kind?: "scan" | "label";
}): Promise<void> {
  try {
    // The cached translations are six languages of copy per row and add nothing
    // to the log; dropping them also keeps the doc well under Firestore's 1 MiB.
    // `undefined` fields (e.g. a product with no `translations` yet) used to
    // make Firestore reject the write outright — 16% of scans were never
    // logged — which `ignoreUndefinedProperties` (index.ts) now tolerates.
    const product = data.product ?
      stripTranslations(data.product as Record<string, unknown>) :
      null;
    await admin
      .firestore()
      .collection("scans")
      .doc(data.requestId)
      .set({...data, product});
  } catch (error) {
    logger.warn("Failed to log scan to Firestore", {
      requestId: data.requestId,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
  }
}
