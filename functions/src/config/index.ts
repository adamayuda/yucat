/**
 * Configuration module for environment variables and API keys.
 *
 * ANTHROPIC_API_KEY must be set via Firebase Functions secret manager:
 *   firebase functions:secrets:set ANTHROPIC_API_KEY
 * and declared in the onCall runtime options:
 *   onCall({secrets: ["ANTHROPIC_API_KEY"], ...}, ...)
 */

import {defineInt, defineString, defineBoolean} from "firebase-functions/params";

// --- Deploy-time parameters (Phase 3 A/B plumbing) -------------------------
// `firebase-functions/params`: values come from `functions/.env*` or the
// deploy prompt, and a change is a redeploy, not a code edit. ⚠️ `.value()`
// must be read inside a function body, never at module load — the CLI
// evaluates this module to discover functions and params.
//
// The identify and label steps are single vision calls where model quality
// shows up directly in the not-identified rate and in the label figures, so
// they are the ones switchable; the analyze fan-out stays on the base model.
export const identifyModelParam = defineString("IDENTIFY_MODEL", {
  default: "claude-haiku-4-5-20251001",
  description: "Model for the identify step when a request lands in the A/B bucket",
});
export const labelModelParam = defineString("LABEL_MODEL", {
  default: "claude-haiku-4-5-20251001",
  description: "Model for the back-label extraction",
});
export const identifyRolloutPctParam = defineInt("IDENTIFY_MODEL_ROLLOUT_PCT", {
  default: 0,
  description: "0-100: share of scans whose identify step uses IDENTIFY_MODEL",
});
export const selfHealDryRunParam = defineBoolean("SELF_HEAL_DRY_RUN", {
  default: false,
  description: "Nightly self-heal logs its candidates and writes nothing",
});

export const config = {
  // Anthropic / Claude Haiku Configuration
  anthropic: {
    apiKey: process.env.ANTHROPIC_API_KEY || "",
    model: "claude-haiku-4-5-20251001",
    temperature: 0.1,
    // Web searches run sequentially server-side (~2.5-3s each) and dominate the
    // analyze step. Capped at 3 to bound latency; raise if data completeness on
    // obscure products regresses. See prompts/analyze-product SEARCH STRATEGY.
    maxWebSearches: 3,
    // Experiment (A/B): when true, the analyze step fans out to several
    // single-source Claude calls in parallel and keeps the most complete result,
    // instead of one free-search call. ~3x cost; see analyzeProductImageParallel.
    useParallelAnalysis: true,
    // Per-instance web_search budget for the parallel fan-out (each instance
    // covers one source, so it needs few searches).
    parallelMaxUses: 2,
    // Manufacturer-page nutrition fallback: when analyze finds no guaranteed
    // analysis, fetch likely product pages (SerpAPI organic results) and extract
    // the analysis directly from their HTML. Niche/non-US brands often host the
    // data on their own site even when Claude's web_search index misses it.
    // No-ops when SerpAPI is unconfigured. See analyzeFromProductPages.
    useManufacturerPageFallback: true,
    // How many candidate pages to fetch + feed to the extraction call.
    pageFallbackMaxPages: 3,
  },

  // Algolia Configuration
  // FE handles lookups, backend saves new products to cache
  algolia: {
    applicationId: process.env.ALGOLIA_APP_ID || "GI8VPYUYCP",
    apiKey: process.env.ALGOLIA_API_KEY ||
      "5b6e53aabd413a6325207b6cecb26a2d",
    indexName: "products2",
    // Cat litter lives in its OWN index, not behind a facet on products2: the
    // app's search tab queries products2 unfiltered and maps every hit through
    // the food display model, so a litter row in there would render as a food
    // with no macros. Separate index = no coupling to fix.
    litterIndexName: "litters",
    enabled: true,
    useLLMVerification: true,
  },

  // SerpAPI (Google Images) — fallback for product-image lookup when Claude's
  // web search returns no direct image URL. SERPAPI_API_KEY must be set via
  // Firebase Functions secret manager:
  //   firebase functions:secrets:set SERPAPI_API_KEY
  // and declared in the onCall runtime options' `secrets` array. Disabled
  // (no-op fallback) when the key is absent.
  serpapi: {
    apiKey: process.env.SERPAPI_API_KEY || "",
    enabled: !!process.env.SERPAPI_API_KEY,
  },

  // Firebase Storage Configuration
  storage: {
    bucketName: process.env.STORAGE_BUCKET ||
      "yucat-d8fb5.firebasestorage.app",
    productsFolder: "products/",
  },

  // Cloud Function Configuration
  functions: {
    timeoutSeconds: 300,
    corsEnabled: true,
    // Scan instances: sharp decodes multi-MB photos and every in-flight request
    // holds a base64 copy, so the 256 MiB / 80-concurrency default was being
    // OOM-killed (5 times in 14 days). Memory-bound work wants fewer, larger
    // instances. Traffic is ~15 scans/day, so cost is negligible either way.
    memory: "1GiB" as const,
    concurrency: 10,
    // The back-label rescue is one vision call, no web search: ~5-12 s.
    labelTimeoutSeconds: 90,
  },

  // Nightly self-heal (jobs/self-heal.ts). Caps bound the model spend per
  // night (≈ 15 × $0.06 ≈ $1) and keep the run inside its 9-minute budget.
  selfHeal: {
    // A row is re-attempted at most once per window — shared with the scan
    // pipeline's "stale junk" predicate in index.ts.
    reanalyzeAfterMs: 14 * 24 * 60 * 60 * 1000,
    schedule: "every day 03:30",
    timeZone: "Europe/Madrid",
    timeoutSeconds: 540,
    // Stop starting new work after this; in-flight items still finish.
    budgetMs: 480_000,
    reanalyzePerRun: 15,
    reanalyzeConcurrency: 3,
    imageBackfillPerRun: 40,
    imageBackfillConcurrency: 5,
    litterReanalyzePerRun: 5,
    litterImageBackfillPerRun: 10,
  },
} as const;
