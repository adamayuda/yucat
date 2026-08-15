import * as logger from "firebase-functions/logger";
import {config} from "../config";
import {Product} from "../models/product";
import {Litter} from "../models/litter";
import {algoliasearch} from "algoliasearch";

const algoliaClient = algoliasearch(
  config.algolia.applicationId,
  config.algolia.apiKey
);

const NAME_MATCH_THRESHOLD = 0.6;
const HITS_PER_PAGE_V2 = 5;
// When the top string-match score isn't clearly ahead of the runner-up, the
// match is ambiguous (e.g. a generic "Kitten" scan ties 1.0 with "Persian
// Kitten", "Maine Coon Kitten", "Kitten Up to 12 months", ...). In that case we
// defer to the LLM verifier instead of blindly taking the first hit.
const AMBIGUITY_MARGIN = 0.15;

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

    // Ambiguity guard: a short/generic scanned name matches many distinct
    // variants equally (the one-directional wordOverlap can't tell "Kitten"
    // apart from "Persian Kitten"). When the runner-up is about as good as the
    // best, return null so the caller's LLM verifier disambiguates among the
    // full candidate set instead of us silently picking the first hit.
    const second = scored[1];
    if (second && best.score - second.score < AMBIGUITY_MARGIN) {
      logger.info("Algolia v2: ambiguous top match, deferring to LLM verifier", {
        topScore: best.score.toFixed(2),
        runnerUpScore: second.score.toFixed(2),
        tiedNames: scored
          .filter((s) => best.score - s.score < AMBIGUITY_MARGIN)
          .map((s) => s.hit.name),
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

// --- Cat litter ------------------------------------------------------------
// Litter uses its own index (config.algolia.litterIndexName) but the exact same
// matching helpers and thresholds as the food path, so behaviour stays in sync.

/**
 * Saves a litter to the Algolia cache. Failures are swallowed (warning logged).
 */
export async function cacheLitter(id: string, litter: Litter): Promise<void> {
  if (!config.algolia.enabled) {
    logger.info("Algolia cache disabled, skipping litter save", {
      id,
      litterName: litter.name,
      structuredData: true,
    });
    return;
  }

  try {
    await algoliaClient.saveObject({
      indexName: config.algolia.litterIndexName,
      body: {objectID: id, ...litter},
    });

    logger.info("Litter successfully saved to Algolia", {
      objectID: id,
      indexName: config.algolia.litterIndexName,
      litterName: litter.name,
      litterBrand: litter.brand,
      structuredData: true,
    });
  } catch (error) {
    logger.warn("Failed to save litter to Algolia", {
      objectID: id,
      indexName: config.algolia.litterIndexName,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
  }
}

/**
 * Litter counterpart to {@link searchProductByNameV2} — same scoring, same
 * threshold, same ambiguity guard (a near-tie returns null so the caller's LLM
 * verifier disambiguates instead of us picking the first hit).
 */
export async function searchLitterByNameV2(
  brand: string,
  name: string
): Promise<Litter | null> {
  if (!config.algolia.enabled) {
    return null;
  }

  try {
    const queryTokens = tokenize(normalize(name));
    const expectedBrand = normalize(brand);

    const result = await algoliaClient.search({
      requests: [{
        indexName: config.algolia.litterIndexName,
        query: name,
        hitsPerPage: HITS_PER_PAGE_V2,
        optionalFilters: brand ? [`brand:${brand}`] : undefined,
      }],
    });

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const hits = ((result.results[0] as any)?.hits || []) as any[];
    if (hits.length === 0) {
      logger.info("Algolia litter: no hits", {
        brand, name, structuredData: true,
      });
      return null;
    }

    const scored = hits.map((hit) => {
      const hitBrand = normalize(hit.brand || "");
      const hitNameTokens = tokenize(normalize(hit.name || ""));
      const brandMatch = hitBrand === expectedBrand ? 1 : 0;
      const overlap = wordOverlap(queryTokens, hitNameTokens);
      return {hit, score: 0.5 * brandMatch + 0.5 * overlap, brandMatch, overlap};
    });

    scored.sort((a, b) => b.score - a.score);

    logger.info("Algolia litter: ranked candidates", {
      query: `${brand} ${name}`,
      candidates: scored.map((s) => ({
        name: s.hit.name,
        brand: s.hit.brand,
        score: s.score.toFixed(2),
        brandMatch: s.brandMatch,
      })),
      structuredData: true,
    });

    const best = scored[0];
    if (!best || best.score < NAME_MATCH_THRESHOLD || best.brandMatch === 0) {
      return null;
    }

    const second = scored[1];
    if (second && best.score - second.score < AMBIGUITY_MARGIN) {
      logger.info("Algolia litter: ambiguous top match, deferring to verifier", {
        topScore: best.score.toFixed(2),
        runnerUpScore: second.score.toFixed(2),
        structuredData: true,
      });
      return null;
    }

    return best.hit as Litter;
  } catch (error) {
    logger.warn("Algolia litter name search failed", {
      brand,
      name,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return null;
  }
}

/**
 * Litter counterpart to {@link fetchCandidatesByName} — the unfiltered
 * candidate pool the LLM verifier picks from.
 */
export async function fetchLitterCandidatesByName(
  brand: string,
  name: string
): Promise<Litter[]> {
  if (!config.algolia.enabled) {
    return [];
  }

  try {
    const result = await algoliaClient.search({
      requests: [{
        indexName: config.algolia.litterIndexName,
        query: name,
        hitsPerPage: HITS_PER_PAGE_V2,
        optionalFilters: brand ? [`brand:${brand}`] : undefined,
      }],
    });

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const hits = ((result.results[0] as any)?.hits || []) as any[];
    return hits as Litter[];
  } catch (error) {
    logger.warn("Algolia litter candidate fetch failed", {
      brand,
      name,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return [];
  }
}
