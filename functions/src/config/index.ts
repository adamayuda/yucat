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
      "3c0ee15455a00d73d8325e1985556008",
    indexName: "products2",
    enabled: true,
    useLLMVerification: true,
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
