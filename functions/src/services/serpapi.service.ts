/**
 * SerpAPI (Google Images) product-image lookup.
 *
 * Claude's web_search rarely surfaces a direct image file URL, so this is the
 * fallback used by findProductImageUrl: it queries Google Images via SerpAPI
 * and returns the candidate `original` (full-resolution) image URLs for the
 * caller to validate + re-host. No-ops to [] when SERPAPI_API_KEY is unset.
 */
import * as logger from "firebase-functions/logger";
import {config} from "../config";

const SERPAPI_ENDPOINT = "https://serpapi.com/search.json";
const MAX_CANDIDATES = 6;
/** How many organic page URLs to return for the nutrition-page fallback. */
const MAX_PAGE_CANDIDATES = 4;

interface SerpImageResult {
  original?: unknown;
}

interface SerpOrganicResult {
  link?: unknown;
}

/**
 * Queries SerpAPI's Google Images engine for product-shot candidates. Returns
 * up to MAX_CANDIDATES direct image URLs, best-first. Returns [] when SerpAPI
 * is not configured, the request fails, or no usable results come back.
 */
export async function searchProductImageUrls(
  brand: string,
  name: string
): Promise<string[]> {
  if (!config.serpapi.enabled) return [];

  const query = `${brand} ${name}`.trim();
  if (!query) return [];

  const params = new URLSearchParams({
    engine: "google_images",
    q: query,
    api_key: config.serpapi.apiKey,
    num: "20",
  });

  try {
    const response = await fetch(`${SERPAPI_ENDPOINT}?${params.toString()}`);
    if (!response.ok) {
      logger.warn("SerpAPI request failed", {
        status: response.status,
        query,
        structuredData: true,
      });
      return [];
    }

    const data = (await response.json()) as {
      images_results?: SerpImageResult[];
    };
    const results: SerpImageResult[] = Array.isArray(data?.images_results) ?
      data.images_results :
      [];

    const urls = results
      .map((r) => (typeof r?.original === "string" ? r.original : ""))
      .filter((u) => u.startsWith("http"))
      .slice(0, MAX_CANDIDATES);

    logger.info("SerpAPI returned image candidates", {
      query,
      count: urls.length,
      structuredData: true,
    });
    return urls;
  } catch (error) {
    logger.warn("SerpAPI request errored", {
      query,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return [];
  }
}

/**
 * Queries SerpAPI's Google web engine for candidate product PAGE URLs (organic
 * results), best-first. Used by the manufacturer-page nutrition fallback to find
 * the brand's own product page (which typically ranks first for a brand+name
 * query and hosts the guaranteed analysis when web_search misses it). Returns []
 * when SerpAPI is not configured, the request fails, or no results come back.
 */
export async function searchProductPageUrls(
  brand: string,
  name: string
): Promise<string[]> {
  if (!config.serpapi.enabled) return [];

  const query = `${brand} ${name}`.trim();
  if (!query) return [];

  const params = new URLSearchParams({
    engine: "google",
    q: query,
    api_key: config.serpapi.apiKey,
    num: "10",
  });

  try {
    const response = await fetch(`${SERPAPI_ENDPOINT}?${params.toString()}`);
    if (!response.ok) {
      logger.warn("SerpAPI page request failed", {
        status: response.status,
        query,
        structuredData: true,
      });
      return [];
    }

    const data = (await response.json()) as {
      organic_results?: SerpOrganicResult[];
    };
    const results: SerpOrganicResult[] = Array.isArray(data?.organic_results) ?
      data.organic_results :
      [];

    const urls = results
      .map((r) => (typeof r?.link === "string" ? r.link : ""))
      .filter((u) => u.startsWith("http"))
      .slice(0, MAX_PAGE_CANDIDATES);

    logger.info("SerpAPI returned page candidates", {
      query,
      count: urls.length,
      structuredData: true,
    });
    return urls;
  } catch (error) {
    logger.warn("SerpAPI page request errored", {
      query,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return [];
  }
}
