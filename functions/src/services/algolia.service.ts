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
 * Algolia's search response decorates every hit with `objectID`,
 * `_highlightResult`, `_snippetResult`, `_rankingInfo`… — and a cache-hit row
 * flows straight back into `cacheProduct` on an image backfill or translation
 * fill. Without this, each write-back re-embedded the previous response's
 * highlight envelope (and then highlighted the highlight), bloating records
 * toward Algolia's per-record limit. Strip it before every write.
 */
const ALGOLIA_ENVELOPE_KEYS = [
  "objectID", "_highlightResult", "_snippetResult", "_rankingInfo",
  "_distinctSeqID",
];

function sanitizeForIndex<T extends object>(record: T): T {
  const clean = {...(record as Record<string, unknown>)};
  for (const key of ALGOLIA_ENVELOPE_KEYS) delete clean[key];
  return clean as T;
}

/**
 * Brand values carry spaces and apostrophes ("Royal Canin", "Hill's Science
 * Diet"). Unquoted, Algolia parses `brand:Royal Canin` as `brand:Royal` plus a
 * stray token, so the soft boost never fired for any multi-word brand.
 */
function brandFilter(brand: string): string[] | undefined {
  const trimmed = brand.trim();
  if (!trimmed) return undefined;
  return [`brand:"${trimmed.replace(/"/g, "\\\"")}"`];
}

// --- GTIN identity ---------------------------------------------------------
// The barcode is the one deterministic identity a pack has. Rows are still
// keyed by the text-derived objectID for compatibility; `gtin` is a filterOnly
// facet (see scripts/configure-*.ts) that is looked up before identify and
// attached to existing rows as scans encounter them, so the catalogue converges
// on barcode identity without a migration.

async function findByGtin<T>(indexName: string, gtin: string): Promise<T | null> {
  if (!config.algolia.enabled) return null;
  try {
    const result = await algoliaClient.search({
      requests: [{
        indexName,
        query: "",
        hitsPerPage: 1,
        filters: `gtin:"${gtin}"`,
      }],
    });
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const hits = ((result.results[0] as any)?.hits || []) as any[];
    logger.info("Algolia gtin lookup", {
      indexName,
      gtin,
      hit: hits.length > 0,
      structuredData: true,
    });
    return hits.length > 0 ? (hits[0] as T) : null;
  } catch (error) {
    // ⚠️ An undeclared facet does NOT reach here: verified against the live
    // index, a `filters` clause on an unknown attribute returns 0 hits with no
    // error. Until `configure-*.ts` declares `filterOnly(gtin)`, every gtin
    // lookup is a silent miss and the pipeline takes the text path.
    logger.warn("Algolia gtin lookup failed", {
      indexName,
      gtin,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return null;
  }
}

export function findProductByGtin(gtin: string): Promise<Product | null> {
  return findByGtin<Product>(config.algolia.indexName, gtin);
}

export function findLitterByGtin(gtin: string): Promise<Litter | null> {
  return findByGtin<Litter>(config.algolia.litterIndexName, gtin);
}

/**
 * Stamps a GTIN onto an existing row that was matched by name. Fire-and-forget
 * at the call site: the scan's result does not depend on it, and the next scan
 * of the same pack then takes the gtin fast path.
 */
export async function attachGtin(
  indexName: string,
  objectID: string,
  gtin: string
): Promise<void> {
  if (!config.algolia.enabled || !objectID) return;
  try {
    await algoliaClient.partialUpdateObject({
      indexName,
      objectID,
      attributesToUpdate: {gtin, gtinSource: "scan"},
      createIfNotExists: false,
    });
    logger.info("Algolia gtin attached", {
      indexName, objectID, gtin, structuredData: true,
    });
  } catch (error) {
    logger.warn("Algolia gtin attach failed", {
      indexName,
      objectID,
      gtin,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
  }
}

// --- Nightly self-heal support (jobs/self-heal.ts) --------------------------

/**
 * Every row matching an Algolia `filters` expression, with only the listed
 * attributes. Paginated search rather than `browse`: it needs only the
 * `search` ACL the runtime key certainly has, and the catalogue (~3.4k rows)
 * fits in a handful of 1,000-hit pages. Stops at `maxRows`.
 */
export async function fetchRowsByFilter<T>(
  indexName: string,
  filters: string,
  attributesToRetrieve: string[],
  maxRows = 5000
): Promise<T[]> {
  if (!config.algolia.enabled) return [];
  const rows: T[] = [];
  for (let page = 0; rows.length < maxRows; page++) {
    const result = await algoliaClient.search({
      requests: [{
        indexName,
        query: "",
        filters,
        hitsPerPage: 1000,
        page,
        attributesToRetrieve,
      }],
    });
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const res = result.results[0] as any;
    const hits = (res?.hits || []) as T[];
    rows.push(...hits);
    if (hits.length === 0 || page + 1 >= (res?.nbPages ?? 1)) break;
  }
  return rows.slice(0, maxRows);
}

/** Partial update of one row; never creates. Failures are logged, not thrown. */
export async function partialUpdateRecord(
  indexName: string,
  objectID: string,
  attributes: Record<string, unknown>
): Promise<boolean> {
  if (!config.algolia.enabled || !objectID) return false;
  try {
    await algoliaClient.partialUpdateObject({
      indexName,
      objectID,
      attributesToUpdate: attributes,
      createIfNotExists: false,
    });
    return true;
  } catch (error) {
    logger.warn("Algolia partial update failed", {
      indexName,
      objectID,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return false;
  }
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
      ...sanitizeForIndex(product),
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
 * What a cache lookup yields: the confident match (if any) plus the raw
 * candidate pool the query returned, so the caller's LLM verifier can pick
 * from the same hits instead of re-running the identical query.
 */
export interface CacheLookup<T> {
  match: T | null;
  hits: T[];
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
 *
 * Returns `{match, hits}` — see {@link CacheLookup}. `match` is null when no
 * hit clears the threshold OR when the top two are a near-tie (the caller
 * then hands `hits` to the LLM verifier rather than us guessing).
 */
export async function lookupProductByNameV2(
  brand: string,
  name: string,
  foodType?: string
): Promise<CacheLookup<Product>> {
  if (!config.algolia.enabled) {
    return {match: null, hits: []};
  }

  try {
    const queryTokens = tokenize(normalize(name));
    const expectedBrand = normalize(brand);

    // `foodType` is a soft boost, not a hard filter: identify's treat-vs-dry or
    // topper-vs-wet call disagreeing with the cached row used to turn a would-be
    // hit into a full $0.085 re-analysis. Brand equality is still enforced below.
    const result = await algoliaClient.search({
      requests: [{
        indexName: config.algolia.indexName,
        query: name,
        hitsPerPage: HITS_PER_PAGE_V2,
        optionalFilters: [
          ...(brandFilter(brand) ?? []),
          ...(foodType ? [`foodType:${foodType}`] : []),
        ],
      }],
    });

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const hits = ((result.results[0] as any)?.hits || []) as any[];
    if (hits.length === 0) {
      logger.info("Algolia v2: no hits", {
        brand, name, foodType: foodType || "none", structuredData: true,
      });
      return {match: null, hits: []};
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

    const pool = hits as Product[];
    const best = scored[0];
    if (!best || best.score < NAME_MATCH_THRESHOLD || best.brandMatch === 0) {
      logger.info("Algolia v2: no match passes threshold", {
        threshold: NAME_MATCH_THRESHOLD,
        topScore: best?.score?.toFixed(2) ?? "n/a",
        topBrandMatch: best?.brandMatch ?? "n/a",
        structuredData: true,
      });
      return {match: null, hits: pool};
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
      return {match: null, hits: pool};
    }

    return {match: best.hit as Product, hits: pool};
  } catch (error) {
    logger.warn("Algolia v2 name search failed", {
      brand,
      name,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return {match: null, hits: []};
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
      body: {objectID: id, ...sanitizeForIndex(litter)},
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
 * Litter counterpart to {@link lookupProductByNameV2} — same scoring, same
 * threshold, same ambiguity guard (a near-tie returns a null `match` so the
 * caller's LLM verifier disambiguates over `hits` instead of us picking the
 * first one).
 */
export async function lookupLitterByNameV2(
  brand: string,
  name: string
): Promise<CacheLookup<Litter>> {
  if (!config.algolia.enabled) {
    return {match: null, hits: []};
  }

  try {
    const queryTokens = tokenize(normalize(name));
    const expectedBrand = normalize(brand);

    const result = await algoliaClient.search({
      requests: [{
        indexName: config.algolia.litterIndexName,
        query: name,
        hitsPerPage: HITS_PER_PAGE_V2,
        optionalFilters: brandFilter(brand),
      }],
    });

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const hits = ((result.results[0] as any)?.hits || []) as any[];
    if (hits.length === 0) {
      logger.info("Algolia litter: no hits", {
        brand, name, structuredData: true,
      });
      return {match: null, hits: []};
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

    const pool = hits as Litter[];
    const best = scored[0];
    if (!best || best.score < NAME_MATCH_THRESHOLD || best.brandMatch === 0) {
      return {match: null, hits: pool};
    }

    const second = scored[1];
    if (second && best.score - second.score < AMBIGUITY_MARGIN) {
      logger.info("Algolia litter: ambiguous top match, deferring to verifier", {
        topScore: best.score.toFixed(2),
        runnerUpScore: second.score.toFixed(2),
        structuredData: true,
      });
      return {match: null, hits: pool};
    }

    return {match: best.hit as Litter, hits: pool};
  } catch (error) {
    logger.warn("Algolia litter name search failed", {
      brand,
      name,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return {match: null, hits: []};
  }
}
