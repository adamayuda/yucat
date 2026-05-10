import * as logger from "firebase-functions/logger";
import {config} from "../config";
import {Product} from "../models/product";
import {algoliasearch} from "algoliasearch";

const algoliaClient = algoliasearch(
  config.algolia.applicationId,
  config.algolia.apiKey
);

const NAME_MATCH_THRESHOLD = 0.6;
const HITS_PER_PAGE_V2 = 5;

function stripAccents(s: string): string {
  return s.normalize("NFD").replace(/[̀-ͯ]/g, "");
}

function normalize(s: string): string {
  return stripAccents(s.toLowerCase().trim());
}

function tokenize(s: string): string[] {
  return s.split(/[\s\-,&/]+/).filter((t) => t.length > 0);
}

function isWithinEditDistance1(a: string, b: string): boolean {
  if (a === b) return true;
  const la = a.length;
  const lb = b.length;
  if (Math.abs(la - lb) > 1) return false;

  let i = 0;
  let j = 0;
  let edits = 0;
  while (i < la && j < lb) {
    if (a[i] === b[j]) {
      i++;
      j++;
      continue;
    }
    if (++edits > 1) return false;
    if (la === lb) {
      i++;
      j++;
    } else if (la > lb) {
      i++;
    } else {
      j++;
    }
  }
  if (i < la || j < lb) edits++;
  return edits <= 1;
}

function fuzzyContains(haystackTokens: string[], needle: string): boolean {
  for (const word of haystackTokens) {
    if (word === needle) return true;
    if (needle.length >= 3 && word.length >= 3) {
      if (word.includes(needle) || needle.includes(word)) return true;
    }
    if (isWithinEditDistance1(word, needle)) return true;
  }
  return false;
}

function wordOverlap(queryTokens: string[], hitTokens: string[]): number {
  if (queryTokens.length === 0) return 0;
  let matched = 0;
  for (const q of queryTokens) {
    if (fuzzyContains(hitTokens, q)) matched++;
  }
  return matched / queryTokens.length;
}

/**
 * Retrieves a product from Algolia cache by objectID (barcode or cache key)
 */
export async function getCachedProduct(
  barcode: string
): Promise<Product | null> {
  if (!config.algolia.enabled) {
    logger.info("Algolia cache disabled, skipping lookup", {
      barcode,
      structuredData: true,
    });
    return null;
  }

  try {
    const cachedProduct = await algoliaClient.getObject({
      indexName: config.algolia.indexName,
      objectID: barcode,
    });

    if (cachedProduct) {
      logger.info("Product found in Algolia cache", {
        barcode,
        productName: (cachedProduct as unknown as Product).name,
        structuredData: true,
      });
      return cachedProduct as unknown as Product;
    }

    return null;
  } catch (error) {
    logger.info("Product not in cache, proceeding with AI lookup", {
      barcode,
      structuredData: true,
    });
    return null;
  }
}

/**
 * Saves a product to Algolia cache. Failures are swallowed (warning logged).
 */
export async function cacheProduct(
  barcode: string,
  product: Product
): Promise<void> {
  if (!config.algolia.enabled) {
    logger.info("Algolia cache disabled, skipping save", {
      barcode,
      productName: product.name,
      structuredData: true,
    });
    return;
  }

  try {
    const productData = {
      objectID: barcode,
      ...product,
    };

    logger.info("Attempting to save product to Algolia", {
      objectID: barcode,
      indexName: config.algolia.indexName,
      productName: product.name,
      productBrand: product.brand,
      version: product.version,
      foodType: product.foodType,
      structuredData: true,
    });

    const response = await algoliaClient.saveObject({
      indexName: config.algolia.indexName,
      body: productData,
    });

    logger.info("Product successfully saved to Algolia", {
      objectID: barcode,
      indexName: config.algolia.indexName,
      productName: product.name,
      version: product.version,
      algoliaResponse: JSON.stringify(response),
      structuredData: true,
    });
  } catch (error) {
    logger.warn("Failed to save product to Algolia", {
      objectID: barcode,
      indexName: config.algolia.indexName,
      barcode,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
  }
}

/**
 * Searches Algolia for a product by brand + name keywords.
 *
 * Legacy implementation (kept for reference / fallback). Phase 3 of the Haiku
 * migration adds {@link searchProductByNameV2} which fixes the 6 known
 * relevance bugs in this version.
 */
export async function searchProductByName(
  brand: string,
  name: string,
  foodType?: string
): Promise<Product | null> {
  if (!config.algolia.enabled) {
    return null;
  }

  try {
    const query = `${brand} ${name}`;
    logger.info("Searching Algolia by product name", {
      query,
      foodType: foodType || "none",
      structuredData: true,
    });

    const result = await algoliaClient.search({
      requests: [{
        indexName: config.algolia.indexName,
        query,
        hitsPerPage: 3,
        ...(foodType ? {filters: `foodType:${foodType}`} : {}),
      }],
    });

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const hits = (result.results[0] as any)?.hits;
    if (!hits || hits.length === 0) {
      return null;
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const hit = hits[0] as any;
    const queryWords = name.toLowerCase().split(/\s+/)
      .filter((w: string) => w.length > 2);
    const hitName = (hit.name || "").toLowerCase();
    const matchingWords = queryWords
      .filter((w: string) => hitName.includes(w));
    const matchRatio = queryWords.length > 0 ?
      matchingWords.length / queryWords.length : 0;

    if (matchRatio < 0.8) {
      return null;
    }

    return hit as Product;
  } catch (error) {
    logger.warn("Algolia name search failed", {
      brand,
      name,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return null;
  }
}

/**
 * Phase-3 replacement for {@link searchProductByName}.
 *
 * Differences vs V1:
 * - Query is just the product name; brand goes in `optionalFilters` as a
 *   soft boost so we don't lose hits where brand is recorded slightly
 *   differently (e.g. "Royal Canin" vs "Royal Canin Veterinary Diet").
 * - Iterates ALL hits and scores each, instead of inspecting only the
 *   top hit.
 * - Bidirectional fuzzy match (substring + Levenshtein-1) instead of
 *   one-way `.includes`.
 * - Strips diacritics and tokenizes on whitespace/hyphen/comma/ampersand
 *   so multi-punctuation product names match correctly.
 * - Lowers the relevance threshold from 0.8 to 0.6, requiring brand
 *   equality as a hard filter.
 */
export async function searchProductByNameV2(
  brand: string,
  name: string,
  foodType?: string
): Promise<Product | null> {
  if (!config.algolia.enabled) {
    return null;
  }

  try {
    const queryTokens = tokenize(normalize(name));
    const expectedBrand = normalize(brand);

    const result = await algoliaClient.search({
      requests: [{
        indexName: config.algolia.indexName,
        query: name,
        hitsPerPage: HITS_PER_PAGE_V2,
        optionalFilters: brand ? [`brand:${brand}`] : undefined,
        ...(foodType ? {filters: `foodType:${foodType}`} : {}),
      }],
    });

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const hits = ((result.results[0] as any)?.hits || []) as any[];
    if (hits.length === 0) {
      logger.info("Algolia v2: no hits", {
        brand, name, foodType: foodType || "none", structuredData: true,
      });
      return null;
    }

    const scored = hits.map((hit) => {
      const hitBrand = normalize(hit.brand || "");
      const hitNameTokens = tokenize(normalize(hit.name || ""));
      const brandMatch = hitBrand === expectedBrand ? 1 : 0;
      const overlap = wordOverlap(queryTokens, hitNameTokens);
      const score = 0.5 * brandMatch + 0.5 * overlap;
      return {hit, score, brandMatch, overlap};
    });

    scored.sort((a, b) => b.score - a.score);

    logger.info("Algolia v2: ranked candidates", {
      query: `${brand} ${name}`,
      foodType: foodType || "none",
      candidates: scored.map((s) => ({
        name: s.hit.name,
        brand: s.hit.brand,
        score: s.score.toFixed(2),
        brandMatch: s.brandMatch,
        overlap: s.overlap.toFixed(2),
      })),
      structuredData: true,
    });

    const best = scored[0];
    if (!best || best.score < NAME_MATCH_THRESHOLD || best.brandMatch === 0) {
      logger.info("Algolia v2: no match passes threshold", {
        threshold: NAME_MATCH_THRESHOLD,
        topScore: best?.score?.toFixed(2) ?? "n/a",
        topBrandMatch: best?.brandMatch ?? "n/a",
        structuredData: true,
      });
      return null;
    }

    return best.hit as Product;
  } catch (error) {
    logger.warn("Algolia v2 name search failed", {
      brand,
      name,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return null;
  }
}

/**
 * Returns the top {@link HITS_PER_PAGE_V2} candidates for a query without
 * applying the V2 relevance threshold. Used by the optional LLM-verified
 * matching path so the model can pick from a wider candidate pool than the
 * string-matching threshold allows.
 */
export async function fetchCandidatesByName(
  brand: string,
  name: string,
  foodType?: string
): Promise<Product[]> {
  if (!config.algolia.enabled) {
    return [];
  }

  try {
    const result = await algoliaClient.search({
      requests: [{
        indexName: config.algolia.indexName,
        query: name,
        hitsPerPage: HITS_PER_PAGE_V2,
        optionalFilters: brand ? [`brand:${brand}`] : undefined,
        ...(foodType ? {filters: `foodType:${foodType}`} : {}),
      }],
    });

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const hits = ((result.results[0] as any)?.hits || []) as any[];
    return hits as Product[];
  } catch (error) {
    logger.warn("Algolia candidate fetch failed", {
      brand,
      name,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return [];
  }
}
