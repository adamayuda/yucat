/* eslint-disable max-len */
import {HttpsError, onCall} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {
  config,
  identifyModelParam,
  identifyRolloutPctParam,
  labelModelParam,
} from "./config";
import {CANONICAL_LANGUAGE, normalizeLanguage} from "./prompts/languages";
import {
  LitterIdentification,
  ProductIdentification,
  ScanSubject,
  identifyScanSubject,
  analyzeLitterImage,
  analyzeProductImage,
  analyzeProductLabelImage,
  analyzeProductImageParallel,
  findProductImageUrl,
  verifyLitterMatchWithLLM,
  verifyMatchWithLLM,
  translateProductText,
  generateCatNarrative as buildCatNarrative,
  analyzeBrand as runAnalyzeBrand,
} from "./services/anthropic.service";
import {CatNarrativeInput} from "./prompts/cat-narrative";
import {BrandVerdictInput} from "./prompts/brand-verdict";
import {
  attachGtin,
  cacheLitter,
  cacheProduct,
  findLitterByGtin,
  findProductByGtin,
  getCachedProduct,
  lookupLitterByNameV2,
  lookupProductByNameV2,
} from "./services/algolia.service";
import {mergeLabelIntoProduct} from "./utils/merge-label";
import {resolveIdentityFromGtin} from "./services/gtin-resolver.service";
import {normalizeGtin} from "./utils/gtin";
import {
  processProductImage,
  processUserPhotoImage,
  uploadUserPhoto,
} from "./utils/image-helpers";
import {logScanRequest} from "./utils/scan-log";
import {sniffMediaType} from "./utils/media-type";
import {createTimer, Timer} from "./utils/timing";
import {Product, ProductText} from "./models/product";
import {Litter, LitterText} from "./models/litter";

admin.initializeApp();
// A product with no `translations` yet (every fresh analysis) serialises the
// field as `undefined`, which Firestore rejects outright — 16% of scans were
// never logged. Tolerate it globally rather than scrubbing every write site.
admin.firestore().settings({ignoreUndefinedProperties: true});

// Self-healing cache: a cached entry can be re-attempted at most once per
// window. Image backfill no longer happens on the request path at all — the
// nightly job (jobs/self-heal.ts) does it; only the "stale junk" re-analysis
// of a score-0 hit is still inline, since the user is waiting for that data.
const REANALYZE_AFTER_MS = config.selfHeal.reanalyzeAfterMs;

// Re-exported so `firebase deploy` discovers the scheduled function.
export {nightlySelfHeal} from "./jobs/self-heal";

/**
 * Identify-step model for this request (Phase 3 A/B). A deterministic bucket
 * from the request id keeps a scan's model stable across retries and lets the
 * share be tuned by redeploying `IDENTIFY_MODEL_ROLLOUT_PCT`.
 */
function pickIdentifyModel(requestId: string): string {
  const pct = identifyRolloutPctParam.value();
  if (pct <= 0) return config.anthropic.model;
  let hash = 0;
  for (const ch of requestId) hash = (hash * 31 + ch.charCodeAt(0)) >>> 0;
  return hash % 100 < pct ? identifyModelParam.value() : config.anthropic.model;
}

/**
 * Picks the object id to write under. `??` alone treated a cached row whose key
 * was the empty string as "present" and wrote to objectID "" / `products/.jpeg`.
 */
function resolveKey(overwriteKey: string | undefined, derived: string): string {
  return overwriteKey && overwriteKey.trim() ? overwriteKey : derived;
}

/**
 * Maps a pipeline failure to a typed callable error so the client can tell a
 * timeout from an exhausted API balance from a crash. Everything used to be a
 * plain `Error`, which the SDK masks as `INTERNAL` with no message.
 */
function toHttpsError(error: unknown, requestId: string): HttpsError {
  if (error instanceof HttpsError) return error;
  const message = error instanceof Error ? error.message : String(error);
  if (/credit balance/i.test(message)) {
    // The one outage mode with no fallback — this exact line feeds the GCP
    // log-based alert (see functions/CLAUDE.md §12).
    logger.error("anthropic credit exhausted", {requestId, structuredData: true});
    return new HttpsError(
      "resource-exhausted",
      "Analysis service temporarily unavailable"
    );
  }
  return new HttpsError("internal", `Error processing product image: ${message}`);
}

/**
 * The parts of a cached record the pipeline machinery (self-heal, translation,
 * user-photo fallback) touches. Both `Product` and `Litter` satisfy it, which is
 * what lets food and litter share one set of helpers instead of drifting apart.
 */
interface ScannedRecord {
  brand: string;
  name: string;
  imageUrl: string;
  score: number;
  pros: string[];
  cons: string[];
  format?: string;
  packageSize?: string;
  description?: string;
  lastAnalysisAttempt?: number;
  lastImageAttempt?: number;
  translations?: Record<string, ProductText>;
}

// A genuinely analyzed record always scores > 0; the force-submit fallback
// (no data found) is the only path that yields score 0.
const hasAnalysisData = (r: ScannedRecord): boolean => r.score > 0;
const hasImage = (r: ScannedRecord): boolean => !!r.imageUrl;
const isStale = (ts?: number): boolean =>
  !ts || Date.now() - ts > REANALYZE_AFTER_MS;

/** The canonical (English) renderable text of a cached record. */
const canonicalText = (r: ScannedRecord): ProductText => ({
  format: r.format ?? "",
  packageSize: r.packageSize ?? "",
  description: r.description ?? "",
  pros: r.pros ?? [],
  cons: r.cons ?? [],
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
  product: ScannedRecord,
  language: string | undefined,
  requestId?: string
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

  const translated = await translateProductText(source, language, requestId);
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
  product: ScannedRecord | null,
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

/**
 * How the scan ended, for the client's error copy and its exits. `product` and
 * `litter` are the two successes; the rest are distinct failures that used to
 * all collapse into `product: null` → "Product not found".
 */
type ScanOutcome =
  | "product"
  | "litter"
  | "not_cat_product"
  | "unreadable"
  | "analysis_failed"
  | "litter_analysis_failed"
  // Back-label rescue only (§3c): the panel was read but held no analysis.
  | "label_no_data";

/** Where identity came from — logged, so the barcode paths are measurable. */
type IdentitySource = "photo" | "gtin-cache" | "gtin-opff" | "gtin-search";

/** The response shape shared by every exit of the scan pipeline. */
interface ScanResponse {
  message: string;
  userId: string | null;
  geminiResponse: string;
  /**
   * What the scan turned out to be. Null when nothing was identified. Clients
   * shipped before litter support ignore this and read `product` as before.
   */
  category: "food" | "litter" | null;
  product: Product | null;
  localizedText: ProductText | null;
  litter: Litter | null;
  litterLocalizedText: LitterText | null;
  userPhotoFallbackUrl: string | null;
  // --- Phase 1 additions (additive; older clients ignore them) ---
  outcome: ScanOutcome;
  /** Identify-step rejection reason on `not_cat_product` / `unreadable`. */
  reason: string | null;
  /** The same string logged in "scan timings" — joins the response to its log. */
  path: string;
  requestId: string;
  /** Normalised GTIN the client sent, when it was valid. */
  gtin: string | null;
  identification: {brand: string; name: string; foodType?: string} | null;
  /** The Algolia objectID the record lives under (== `product.barcode` / `litter.id`). */
  productKey: string | null;
  /** Phase 3's A/B reads these; today both are the one configured model. */
  models: {identify: string; analyze: string};
}

/** Fills the Phase-1 response fields with their defaults. */
function scanMeta(
  requestId: string,
  gtin: string | null,
  overrides: Partial<Pick<
    ScanResponse,
    "outcome" | "reason" | "path" | "identification" | "productKey"
  >> & {outcome: ScanOutcome; path: string},
  models: {identify?: string; analyze?: string} = {}
): Pick<
  ScanResponse,
  "outcome" | "reason" | "path" | "requestId" | "gtin" | "identification" |
  "productKey" | "models"
> {
  return {
    reason: null,
    identification: null,
    productKey: null,
    ...overrides,
    requestId,
    gtin,
    models: {
      identify: models.identify ?? config.anthropic.model,
      analyze: models.analyze ?? config.anthropic.model,
    },
  };
}

/** `unreadable` is the half of not-identified the UX can do something about. */
function outcomeForRejection(reason: string): ScanOutcome {
  return ["unreadable", "no_product", "no_tool"].includes(reason) ?
    "unreadable" :
    "not_cat_product";
}

/**
 * The litter half of the scan pipeline — the mirror of the food path below,
 * with one meaningful simplification: analysis is a single web_search call
 * rather than a source fan-out (see {@link analyzeLitterImage}).
 *
 * Everything else is deliberately identical: same cache-then-analyze order,
 * same 14-day self-heal predicates, same lazy translation, same user-photo
 * fallback ordering (always AFTER the cache write, so one user's photo can
 * never become the shared catalog image).
 */
async function handleLitterScan(opts: {
  image: string;
  mimeType: string;
  identification: LitterIdentification;
  requestId: string;
  userId: string | null;
  userPhotoUrl: string;
  countryCode?: string;
  language?: string;
  timer: Timer;
  /** Normalised barcode from the client, when any. */
  gtin: string | null;
  /** A row already matched by gtin before identify — skips the name lookup. */
  preMatched?: Litter | null;
  identitySource: IdentitySource;
}): Promise<ScanResponse> {
  const {
    image, mimeType, identification, requestId, userId, userPhotoUrl,
    countryCode, language, timer, gtin, preMatched, identitySource,
  } = opts;

  const emptyFood = {product: null, localizedText: null};
  const wireIdentification = {
    brand: identification.brand, name: identification.name,
  };

  // Step 2 — cache lookup, with the LLM verifier as the tie-breaker. The
  // verifier picks from the same hits the lookup returned — it used to re-run
  // the identical query. A gtin hit skips all of it.
  let cached: Litter | null = preMatched ?? null;
  if (!cached) {
    const lookup = await lookupLitterByNameV2(
      identification.brand,
      identification.name
    );
    cached = lookup.match;
    timer.mark("cacheLookup");

    if (
      !cached && config.algolia.useLLMVerification && lookup.hits.length > 0
    ) {
      cached = await verifyLitterMatchWithLLM(
        identification, lookup.hits, requestId
      );
      timer.mark("llmVerify");
    }

    // A name match with a barcode in hand: stamp it so the next scan of this
    // pack takes the gtin fast path. Fire-and-forget — the result doesn't
    // depend on it — but set it locally so any write below carries it too.
    if (cached && gtin && !cached.gtin) {
      cached.gtin = gtin;
      cached.gtinSource = "scan";
      void attachGtin(config.algolia.litterIndexName, cached.id, gtin);
    }
  }
  const hitPath = preMatched ? "litter-gtin-hit" : "litter-cache-hit";

  // Set when a stale no-data entry is re-analyzed, so the row is overwritten in
  // place rather than duplicated under a near-identical key.
  let overwriteKey: string | undefined;

  if (cached) {
    const staleJunk =
      !hasAnalysisData(cached) && isStale(cached.lastAnalysisAttempt);

    if (staleJunk) {
      overwriteKey = cached.id;
      logger.info("Litter cache hit is a stale no-data entry — re-analyzing", {
        brand: cached.brand,
        name: cached.name,
        structuredData: true,
      });
    } else {
      // An imageless hit is served as-is; the nightly job backfills images.
      const localized = await ensureTranslation(cached, language, requestId);
      if (localized.added) {
        await cacheLitter(cached.id, cached);
      }
      timer.mark("translate");

      const cachedFallback = await resolveUserPhotoFallback(
        cached,
        userPhotoUrl,
        requestId,
        hitPath
      );
      timer.mark("userPhotoFallback");

      await logScanRequest({
        requestId,
        userId,
        userPhotoUrl,
        identification: {...identification, category: "litter"},
        cachedMatch: true,
        product: cached,
        timestamp: new Date(),
        outcome: "litter",
        path: hitPath,
        gtin,
      });
      timer.mark("scanLog");

      logger.info("scan timings", {
        requestId,
        path: hitPath,
        identitySource,
        ...timer.summary(),
        structuredData: true,
      });

      return {
        message: "Litter found in cache",
        userId,
        geminiResponse: "",
        category: "litter",
        ...emptyFood,
        litter: cached,
        litterLocalizedText: localized.text,
        userPhotoFallbackUrl: cachedFallback,
        ...scanMeta(requestId, gtin, {
          outcome: "litter",
          path: hitPath,
          identification: wireIdentification,
          productKey: cached.id,
        }),
      };
    }
  }

  // Step 3 — full analysis. As on the food path, the SerpAPI image lookup runs
  // concurrently so it stays off the critical path.
  logger.info("No litter cache match, running full analysis", {
    brand: identification.brand,
    name: identification.name,
    structuredData: true,
  });

  const provisionalKey = resolveKey(
    overwriteKey,
    litterCacheKey(identification.brand, identification.name)
  );
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

  const {litter, rawResponse} = await analyzeLitterImage(
    image,
    mimeType,
    identification,
    countryCode,
    requestId,
    gtin ?? undefined
  );
  timer.mark("analyze");

  if (!litter || !litter.name) {
    await logScanRequest({
      requestId,
      userId,
      userPhotoUrl,
      identification: {...identification, category: "litter"},
      cachedMatch: false,
      product: null,
      timestamp: new Date(),
      outcome: "litter_analysis_failed",
      path: "litter-analysis-failed",
      gtin,
    });
    timer.mark("finalize");

    logger.info("scan timings", {
      requestId,
      path: "litter-analysis-failed",
      identitySource,
      ...timer.summary(),
      structuredData: true,
    });

    return {
      message: "Could not analyze the cat litter in the image",
      userId,
      geminiResponse: rawResponse,
      category: "litter",
      ...emptyFood,
      litter: null,
      litterLocalizedText: null,
      userPhotoFallbackUrl: null,
      ...scanMeta(requestId, gtin, {
        outcome: "litter_analysis_failed",
        path: "litter-analysis-failed",
        identification: wireIdentification,
      }),
    };
  }

  litter.isAiIdentified = true;
  const cacheKey = resolveKey(
    overwriteKey,
    litterCacheKey(litter.brand, litter.name)
  );
  litter.id = cacheKey;
  if (gtin) {
    litter.gtin = gtin;
    litter.gtinSource = identitySource === "photo" ? "scan" : "resolver";
  }

  // Translation overlaps image hosting — it only needs the analysed text, and
  // it used to sit serially after `imageHost` (~2.3 s on the critical path).
  // Runs before the cache write, so the translation lands in the same Algolia
  // round-trip. `ensureTranslation` mutates `litter.translations` only.
  const translationPromise = ensureTranslation(litter, language, requestId);

  // The model's own imageUrl was unusable in about half of scans; SerpAPI
  // (already hosted in parallel with analyze) is the sole image source.
  litter.imageUrl = await serpApiHostedPromise;
  timer.mark("imageHost");

  litter.lastAnalysisAttempt = Date.now();
  litter.lastImageAttempt = Date.now();

  const localizedText = (await translationPromise).text;
  timer.mark("translate");

  await Promise.all([
    cacheLitter(cacheKey, litter),
    logScanRequest({
      requestId,
      userId,
      userPhotoUrl,
      identification: {...identification, category: "litter"},
      cachedMatch: false,
      product: litter,
      timestamp: new Date(),
      outcome: "litter",
      path: "litter-full-analysis",
      gtin,
    }),
  ]);
  timer.mark("finalize");

  // After the cache write, so the fallback cannot reach the shared record.
  const userPhotoFallbackUrl = await resolveUserPhotoFallback(
    litter,
    userPhotoUrl,
    requestId,
    "litter-full-analysis"
  );
  timer.mark("userPhotoFallback");

  logger.info("scan timings", {
    requestId,
    path: "litter-full-analysis",
    identitySource,
    ...timer.summary(),
    structuredData: true,
  });

  return {
    message: "Litter analyzed",
    userId,
    geminiResponse: rawResponse,
    category: "litter",
    ...emptyFood,
    litter,
    litterLocalizedText: localizedText,
    userPhotoFallbackUrl,
    ...scanMeta(requestId, gtin, {
      outcome: "litter",
      path: "litter-full-analysis",
      identification: wireIdentification,
      productKey: cacheKey,
    }),
  };
}

/**
 * Litter cache identity. Text-derived like the food key and with the same
 * caveat: any drift in how Haiku transcribes the name creates a duplicate row,
 * which is why the identify prompt insists on transcribing printed text only.
 * The `lit-` prefix keeps the two key spaces visibly distinct in logs.
 */
function litterCacheKey(brand: string, name: string): string {
  return `lit-${brand}-${name}`.toLowerCase().replace(/\s+/g, "-");
}

export const fetchProductByImageV2 = onCall(
  {
    cors: config.functions.corsEnabled,
    timeoutSeconds: config.functions.timeoutSeconds,
    // 256 MiB at the default concurrency of 80 was OOM-killing scans (sharp on
    // multi-MB photos plus the base64 copies of 80 requests). Fewer, larger
    // instances: the scan is CPU- and memory-bound, not I/O-bound.
    memory: config.functions.memory,
    cpu: 1,
    concurrency: config.functions.concurrency,
    secrets: ["ANTHROPIC_API_KEY", "ALGOLIA_API_KEY", "SERPAPI_API_KEY"],
  },
  async (request): Promise<ScanResponse> => {
    // Anyone with the project id could call a $0.10, 300-second endpoint.
    // Every client signs in anonymously at splash before it can reach the
    // scanner, so this costs a legitimate user nothing.
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in required");
    }

    const {image, mimeType, countryCode, locale} = request.data;
    const userId = request.auth.uid;

    // Optional normalised barcode the client read off the still. Re-validated
    // here (check digit) — a misread is dropped, never stored.
    const gtin = normalizeGtin(request.data.gtin);

    if (!image || typeof image !== "string") {
      throw new HttpsError(
        "invalid-argument",
        "Missing required field: image (base64-encoded string)"
      );
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

    // Trust the bytes, not the header: clients label everything image/jpeg,
    // and the model API 400s on a mislabeled PNG. HEIC can't be decoded
    // downstream at all, so refuse it up front instead of failing mid-scan.
    const sniffed = sniffMediaType(image);
    if (sniffed === "image/heic") {
      throw new HttpsError(
        "invalid-argument",
        "HEIC images are not supported; send JPEG or PNG"
      );
    }
    const resolvedMimeType = sniffed ?? "image/jpeg";

    const requestId = `scan-${Date.now()}-${Math.random().toString(36).substring(2, 8)}`;

    logger.info("Image endpoint called", {
      requestId,
      userId,
      mimeType: resolvedMimeType,
      declaredMimeType: typeof mimeType === "string" ? mimeType : null,
      imageSize: image.length,
      language: resolvedLanguage ?? CANONICAL_LANGUAGE,
      gtin,
      gtinDeclared: typeof request.data.gtin === "string",
      structuredData: true,
    });

    // Per-step latency instrumentation (measurement only — see utils/timing.ts).
    const timer = createTimer();

    try {
      // Background: upload the user's scan photo to Storage.
      const userPhotoPromise = uploadUserPhoto(image, resolvedMimeType, requestId);

      // Step 0 — barcode fast path. A GTIN is the one deterministic identity a
      // pack has, so a row already carrying it is a hit before we spend a
      // vision call. Both indexes are checked: the client cannot know which
      // category the pack is.
      let gtinProduct: Product | null = null;
      let gtinLitter: Litter | null = null;
      if (gtin) {
        [gtinProduct, gtinLitter] = await Promise.all([
          findProductByGtin(gtin),
          findLitterByGtin(gtin),
        ]);
        timer.mark("gtinLookup");
      }

      if (gtinLitter) {
        const userPhotoUrl = await userPhotoPromise;
        timer.mark("userPhotoUpload");
        return await handleLitterScan({
          image,
          mimeType: resolvedMimeType,
          identification: {brand: gtinLitter.brand, name: gtinLitter.name},
          requestId,
          userId: userId || null,
          userPhotoUrl,
          countryCode: resolvedCountry,
          language: resolvedLanguage,
          timer,
          gtin,
          preMatched: gtinLitter,
          identitySource: "gtin-cache",
        });
      }

      let identification: ProductIdentification;
      let cachedProduct: Product | null = null;
      let identitySource: IdentitySource = "photo";
      let hitPath = "cache-hit";
      const identifyModel = pickIdentifyModel(requestId);

      if (gtinProduct) {
        identification = {
          brand: gtinProduct.brand,
          name: gtinProduct.name,
          foodType: gtinProduct.foodType,
        };
        cachedProduct = gtinProduct;
        identitySource = "gtin-cache";
        hitPath = "gtin-hit";
      } else {
        // Step 1 — fast identification (vision, no web_search). Decides
        // food vs litter vs neither; everything downstream branches on that.
        // The model is the A/B pick for this request (see pickIdentifyModel).
        let scanSubject: ScanSubject = await identifyScanSubject(
          image, resolvedMimeType, requestId, identifyModel
        );
        timer.mark("identify");

        // The pack was unreadable but the barcode wasn't: recover brand/name
        // from the GTIN (Open Pet Food Facts, then one web search) and carry
        // on exactly as if identify had read it.
        if (scanSubject.category === "none" && gtin) {
          const resolved = await resolveIdentityFromGtin(
            gtin, resolvedCountry, requestId
          );
          timer.mark("gtinResolve");
          if (resolved) {
            scanSubject = resolved.identification;
            identitySource =
              resolved.resolver === "opff" ? "gtin-opff" : "gtin-search";
          }
        }

        if (scanSubject.category === "none") {
          const userPhotoUrl = await userPhotoPromise;
          timer.mark("userPhotoUpload");
          const outcome = outcomeForRejection(scanSubject.reason);
          await logScanRequest({
            requestId,
            userId: userId || null,
            userPhotoUrl,
            identification: null,
            cachedMatch: false,
            product: null,
            timestamp: new Date(),
            outcome,
            reason: scanSubject.reason,
            path: "not-identified",
            gtin,
          });
          timer.mark("scanLog");

          logger.info("scan timings", {
            requestId,
            path: "not-identified",
            // Splits "not a cat product" from "couldn't read the pack" — the
            // two halves of the 20% not-identified rate need different fixes.
            identifyReason: scanSubject.reason,
            identifyNote: scanSubject.note ?? null,
            outcome,
            ...timer.summary(),
            structuredData: true,
          });

          return {
            message: "Could not identify a cat food or litter product in the image",
            userId: userId || null,
            geminiResponse: "",
            category: null,
            product: null,
            localizedText: null,
            litter: null,
            litterLocalizedText: null,
            userPhotoFallbackUrl: null,
            ...scanMeta(requestId, gtin, {
              outcome,
              reason: scanSubject.reason,
              path: "not-identified",
            }, {identify: identifyModel}),
          };
        }

        if (scanSubject.category === "litter") {
          const userPhotoUrl = await userPhotoPromise;
          timer.mark("userPhotoUpload");
          return await handleLitterScan({
            image,
            mimeType: resolvedMimeType,
            identification: scanSubject.litter,
            requestId,
            userId: userId || null,
            userPhotoUrl,
            countryCode: resolvedCountry,
            language: resolvedLanguage,
            timer,
            gtin,
            identitySource,
          });
        }

        identification = scanSubject.food;

        // Step 2 — Algolia cache lookup with V2 string matching.
        const lookup = await lookupProductByNameV2(
          identification.brand,
          identification.name,
          identification.foodType
        );
        cachedProduct = lookup.match;
        timer.mark("cacheLookup");

        // Step 2b — optional LLM verification when string match misses. Picks
        // from the hits the lookup already returned (it used to re-run the
        // identical Algolia query to fetch the same candidates).
        if (
          !cachedProduct &&
          config.algolia.useLLMVerification &&
          lookup.hits.length > 0
        ) {
          cachedProduct = await verifyMatchWithLLM(
            identification, lookup.hits, requestId
          );
          timer.mark("llmVerify");
        }

        // A name match with a barcode in hand: stamp it so the next scan of
        // this pack takes the gtin fast path and never re-pays identify.
        if (cachedProduct && gtin && !cachedProduct.gtin) {
          cachedProduct.gtin = gtin;
          cachedProduct.gtinSource = "scan";
          void attachGtin(config.algolia.indexName, cachedProduct.barcode, gtin);
        }
      }

      const userPhotoUrl = await userPhotoPromise;
      timer.mark("userPhotoUpload");
      const wireIdentification = {
        brand: identification.brand,
        name: identification.name,
        foodType: identification.foodType,
      };

      // When the cache hit is a stale no-data entry, fall through to a full
      // re-analysis and overwrite it in place (under this object id).
      let overwriteKey: string | undefined;

      if (cachedProduct) {
        const staleJunk =
          !hasAnalysisData(cachedProduct) &&
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
          // An imageless hit is served as-is (the client falls back to the
          // user's own photo); the nightly job backfills images off the
          // request path. Inline, this turned a 4 s hit into a 30 s one.
          logger.info("Cache hit, skipping full analysis", {
            brand: cachedProduct.brand,
            name: cachedProduct.name,
            structuredData: true,
          });

          // Lazy translation fill: the first requester of a language pays one
          // small Haiku call, everyone after reads it off the record.
          const localized = await ensureTranslation(
            cachedProduct,
            resolvedLanguage,
            requestId
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
            hitPath
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
            outcome: "product",
            path: hitPath,
            gtin,
          });
          timer.mark("scanLog");

          logger.info("scan timings", {
            requestId,
            path: hitPath,
            identitySource,
            ...timer.summary(),
            structuredData: true,
          });

          return {
            message: "Product found in cache",
            userId: userId || null,
            geminiResponse: "",
            category: "food" as const,
            product: cachedProduct,
            localizedText: localized.text,
            litter: null,
            litterLocalizedText: null,
            userPhotoFallbackUrl: cachedFallback,
            ...scanMeta(requestId, gtin, {
              outcome: "product",
              path: hitPath,
              identification: wireIdentification,
              productKey: cachedProduct.barcode,
            }, {identify: identifyModel}),
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
      const provisionalKey = resolveKey(
        overwriteKey,
        `img-${identification.brand}-${identification.name}`
          .toLowerCase()
          .replace(/\s+/g, "-")
      );
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
          resolvedCountry,
          requestId,
          gtin ?? undefined
        ) :
        await analyzeProductImage(
          image,
          resolvedMimeType,
          identification,
          resolvedCountry,
          requestId,
          gtin ?? undefined
        );
      timer.mark("analyze");

      let localizedText: ProductText | null = null;
      let userPhotoFallbackUrl: string | null = null;
      let productKey: string | null = null;

      if (product && product.name) {
        // Image-flow products are always AI-identified.
        product.isAiIdentified = true;

        const derivedKey = `img-${product.brand}-${product.name}`
          .toLowerCase()
          .replace(/\s+/g, "-");
        // Reuse the existing object id when re-analyzing a stale entry so we
        // overwrite it in place rather than create a near-duplicate sibling.
        const cacheKey = resolveKey(overwriteKey, derivedKey);
        product.barcode = cacheKey;
        productKey = cacheKey;
        if (gtin) {
          product.gtin = gtin;
          product.gtinSource = identitySource === "photo" ? "scan" : "resolver";
        }

        // Translation overlaps image hosting — it only needs the analysed
        // text and used to sit serially after `imageHost` (~2.3 s on the
        // critical path). Still before the cache write, so it lands in the
        // same Algolia round-trip. Mutates `product.translations` only.
        const translationPromise = ensureTranslation(
          product, resolvedLanguage, requestId
        );

        // The model's own imageUrl was unusable in about half of scans (page
        // URLs, dead links) while SerpAPI won 134 of 135 times — so the image
        // already hosted in parallel during analyze is the sole source. The
        // await usually resolves instantly.
        product.imageUrl = await serpApiHostedPromise;
        timer.mark("imageHost");

        // Timestamps throttle the next self-heal attempt (see REANALYZE_AFTER_MS).
        product.lastAnalysisAttempt = Date.now();
        product.lastImageAttempt = Date.now();

        localizedText = (await translationPromise).text;
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
            outcome: "product",
            path: "full-analysis",
            gtin,
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
          outcome: "analysis_failed",
          path: "analysis-failed",
          gtin,
        });
        timer.mark("finalize");
      }

      const analysed = !!(product && product.name);
      const path = analysed ? "full-analysis" : "analysis-failed";
      logger.info("scan timings", {
        requestId,
        path,
        identitySource,
        identifyModel,
        ...timer.summary(),
        structuredData: true,
      });

      return {
        message: "Image processed successfully",
        userId: userId || null,
        geminiResponse: rawResponse,
        category: "food" as const,
        product,
        localizedText,
        litter: null,
        litterLocalizedText: null,
        userPhotoFallbackUrl,
        ...scanMeta(requestId, gtin, {
          outcome: analysed ? "product" : "analysis_failed",
          path,
          identification: wireIdentification,
          productKey,
        }, {identify: identifyModel}),
      };
    } catch (error) {
      logger.error("Error processing product image", {
        requestId,
        error: error instanceof Error ? error.message : String(error),
        structuredData: true,
      });
      throw toHttpsError(error, requestId);
    }
  }
);

/**
 * Back-label rescue (Phase 2). The client sends a photo of the ingredients /
 * analysis panel plus whatever it knows about the product — the Algolia key
 * from a scan result, the barcode, or just brand/name — and gets back the full
 * product with the nutrition read straight off the label.
 *
 * A separate callable rather than a `mode` on `fetchProductByImageV2`: no web
 * search, no SerpAPI, a 90 s budget, a different request shape, and invisible
 * to clients that predate it.
 *
 * Target resolution order: `productKey` → `gtin` → name lookup → a new row.
 * The label overwrites the target's nutrition (that is the point) but never its
 * identity or image; a score-0 extraction never overwrites a row that has data.
 * Litter targets are refused — litter has no analysis panel.
 */
export const analyzeProductLabel = onCall(
  {
    cors: config.functions.corsEnabled,
    timeoutSeconds: config.functions.labelTimeoutSeconds,
    memory: config.functions.memory,
    cpu: 1,
    concurrency: config.functions.concurrency,
    secrets: ["ANTHROPIC_API_KEY", "ALGOLIA_API_KEY"],
  },
  async (request): Promise<ScanResponse> => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in required");
    }
    const {labelImage, productKey, countryCode, locale} = request.data;
    const userId = request.auth.uid;

    if (!labelImage || typeof labelImage !== "string") {
      throw new HttpsError(
        "invalid-argument",
        "Missing required field: labelImage (base64-encoded string)"
      );
    }
    const key = typeof productKey === "string" && productKey.trim() ?
      productKey.trim() :
      null;
    if (key && key.startsWith("lit-")) {
      throw new HttpsError(
        "invalid-argument",
        "Litter has no analysis panel; the label path is food-only"
      );
    }
    const gtin = normalizeGtin(request.data.gtin);
    const rawId = request.data.identification;
    const sentIdentification =
      rawId && typeof rawId === "object" &&
      (typeof rawId.brand === "string" || typeof rawId.name === "string") ?
        {
          brand: typeof rawId.brand === "string" ? rawId.brand.trim() : "",
          name: typeof rawId.name === "string" ? rawId.name.trim() : "",
          foodType: typeof rawId.foodType === "string" ? rawId.foodType : undefined,
        } :
        undefined;
    const resolvedLanguage = normalizeLanguage(locale);
    const resolvedCountry =
      typeof countryCode === "string" && countryCode.trim() ?
        countryCode.trim() :
        undefined;

    const sniffed = sniffMediaType(labelImage);
    if (sniffed === "image/heic") {
      throw new HttpsError(
        "invalid-argument",
        "HEIC images are not supported; send JPEG or PNG"
      );
    }
    const resolvedMimeType = sniffed ?? "image/jpeg";
    const requestId = `label-${Date.now()}-${Math.random().toString(36).substring(2, 8)}`;
    const timer = createTimer();

    logger.info("Label endpoint called", {
      requestId,
      userId,
      productKey: key,
      gtin,
      hasIdentification: !!sentIdentification,
      imageSize: labelImage.length,
      country: resolvedCountry ?? null,
      language: resolvedLanguage ?? CANONICAL_LANGUAGE,
      structuredData: true,
    });

    try {
      const userPhotoPromise = uploadUserPhoto(labelImage, resolvedMimeType, requestId);

      // Resolve the record this label belongs to.
      let existing: Product | null = null;
      if (key) existing = await getCachedProduct(key);
      if (!existing && gtin) existing = await findProductByGtin(gtin);
      let identification = sentIdentification;
      if (existing) {
        identification = {
          brand: existing.brand, name: existing.name, foodType: existing.foodType,
        };
      } else if (identification && (identification.brand || identification.name)) {
        const lookup = await lookupProductByNameV2(
          identification.brand, identification.name, identification.foodType
        );
        existing = lookup.match;
      }
      timer.mark("targetLookup");

      // The label model is a deploy-time param (Phase 3 A/B): the extraction
      // is one vision call where model quality shows up directly in the figures.
      const labelModel = labelModelParam.value();
      const {product: extracted, rawResponse} = await analyzeProductLabelImage(
        labelImage, resolvedMimeType, identification, requestId, labelModel
      );
      timer.mark("labelExtract");

      const userPhotoUrl = await userPhotoPromise;
      timer.mark("userPhotoUpload");

      const wireIdentification = identification ?? (extracted && extracted.name ?
        {brand: extracted.brand, name: extracted.name, foodType: extracted.foodType} :
        null);

      const fail = async (
        outcome: "unreadable" | "label_no_data"
      ): Promise<ScanResponse> => {
        await logScanRequest({
          requestId,
          userId,
          userPhotoUrl,
          identification: wireIdentification,
          cachedMatch: !!existing,
          product: null,
          timestamp: new Date(),
          outcome,
          path: "label",
          gtin,
          kind: "label",
        });
        timer.mark("finalize");
        logger.info("scan timings", {
          requestId, path: "label", outcome, ...timer.summary(), structuredData: true,
        });
        return {
          message: outcome === "unreadable" ?
            "Could not read the label" :
            "Label held no analysis",
          userId,
          geminiResponse: rawResponse,
          category: "food",
          product: null,
          localizedText: null,
          litter: null,
          litterLocalizedText: null,
          userPhotoFallbackUrl: null,
          ...scanMeta(requestId, gtin, {
            outcome,
            path: "label",
            identification: wireIdentification,
            productKey: existing?.barcode ?? key,
          }, {analyze: labelModel}),
        };
      };

      if (!extracted) return await fail("unreadable");
      // A panel that was read but held no figures must not erase real data.
      if (extracted.score <= 0) return await fail("label_no_data");

      const merged = mergeLabelIntoProduct(existing, extracted, identification, {
        gtin, requestId,
      });
      if (!merged.name && !merged.brand) return await fail("unreadable");
      const cacheKey = existing?.barcode ||
        `img-${merged.brand}-${merged.name}`.toLowerCase().replace(/\s+/g, "-");
      merged.barcode = cacheKey;

      const localizedText = (await ensureTranslation(
        merged, resolvedLanguage, requestId
      )).text;
      timer.mark("translate");

      await Promise.all([
        cacheProduct(cacheKey, merged),
        logScanRequest({
          requestId,
          userId,
          userPhotoUrl,
          identification: wireIdentification,
          cachedMatch: !!existing,
          product: merged,
          timestamp: new Date(),
          outcome: "product",
          path: "label",
          gtin,
          kind: "label",
        }),
      ]);
      timer.mark("finalize");

      // The label photo is the user's; it may stand in for a missing product
      // image for *this* user only, never in the shared record.
      const userPhotoFallbackUrl = await resolveUserPhotoFallback(
        merged, userPhotoUrl, requestId, "label"
      );
      timer.mark("userPhotoFallback");

      logger.info("scan timings", {
        requestId,
        path: "label",
        outcome: "product",
        labelModel,
        hadExisting: !!existing,
        ...timer.summary(),
        structuredData: true,
      });

      return {
        message: "Label analyzed",
        userId,
        geminiResponse: rawResponse,
        category: "food",
        product: merged,
        localizedText,
        litter: null,
        litterLocalizedText: null,
        userPhotoFallbackUrl,
        ...scanMeta(requestId, gtin, {
          outcome: "product",
          path: "label",
          identification: wireIdentification,
          productKey: cacheKey,
        }, {analyze: labelModel}),
      };
    } catch (error) {
      logger.error("Error processing label image", {
        requestId,
        error: error instanceof Error ? error.message : String(error),
        structuredData: true,
      });
      throw toHttpsError(error, requestId);
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
