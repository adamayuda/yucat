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
    maxWebSearches: 5,
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
