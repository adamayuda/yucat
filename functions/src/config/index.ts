/**
 * Configuration module for environment variables and API keys.
 *
 * ANTHROPIC_API_KEY must be set via Firebase Functions secret manager:
 *   firebase functions:secrets:set ANTHROPIC_API_KEY
 * and declared in the onCall runtime options:
 *   onCall({secrets: ["ANTHROPIC_API_KEY"], ...}, ...)
 */

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
  },
} as const;
