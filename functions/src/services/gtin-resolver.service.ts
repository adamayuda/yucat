/**
 * Identity from a barcode alone.
 *
 * Used when the photo could not be identified (blurry, back of the pack, only
 * the barcode in frame) but the client read a GTIN off it. Two sources, in
 * order of cost:
 *
 * 1. Open Pet Food Facts — free, ~200 ms. Too sparse to be a *data* source
 *    (~1,600 cat foods, almost none with nutrition) but a fine brand/name
 *    resolver when the product is there. A 404 is a miss, not an error.
 * 2. One Haiku call with a single web search for the EAN — retailers list
 *    barcodes on product pages, so the number alone usually finds the product.
 *
 * Returns a `ScanIdentification` the rest of the pipeline can use exactly as
 * if identify had read the pack, or null.
 */
import * as logger from "firebase-functions/logger";
import {
  ScanIdentification,
  identifyByGtinSearch,
} from "./anthropic.service";

const OPFF_ENDPOINT = "https://world.openpetfoodfacts.org/api/v2/product";
const OPFF_TIMEOUT_MS = 3000;

interface OpffProduct {
  brands?: unknown;
  product_name?: unknown;
  categories_tags?: unknown;
}

async function lookupOpff(gtin: string): Promise<ScanIdentification | null> {
  const url =
    `${OPFF_ENDPOINT}/${gtin}.json?fields=brands,product_name,categories_tags`;
  try {
    const response = await fetch(url, {
      headers: {"User-Agent": "YuCat/2 (scan gtin resolver)"},
      signal: AbortSignal.timeout(OPFF_TIMEOUT_MS),
    });
    if (response.status === 404) return null;
    if (!response.ok) {
      logger.warn("OPFF request failed", {
        gtin, status: response.status, structuredData: true,
      });
      return null;
    }
    const data = (await response.json()) as {product?: OpffProduct};
    const product = data?.product;
    if (!product) return null;

    const tags = Array.isArray(product.categories_tags) ?
      product.categories_tags.map(String) :
      [];
    // Only trust the entry when it is categorised as a cat product at all —
    // the barcode space is shared with dog food and human groceries.
    const isCat = tags.some((t) => /cat/i.test(t));
    const isLitter = tags.some((t) => /litter/i.test(t));
    const brand = typeof product.brands === "string" ?
      product.brands.split(",")[0].trim() :
      "";
    const name = typeof product.product_name === "string" ?
      product.product_name.trim() :
      "";
    if (!isCat || !brand || !name) return null;

    if (isLitter) return {category: "litter", litter: {brand, name}};
    return {category: "food", food: {brand, name, foodType: "wet"}};
  } catch (error) {
    logger.warn("OPFF request errored", {
      gtin,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return null;
  }
}

export async function resolveIdentityFromGtin(
  gtin: string,
  countryCode: string | undefined,
  requestId: string
): Promise<{identification: ScanIdentification; resolver: string} | null> {
  const fromOpff = await lookupOpff(gtin);
  if (fromOpff) {
    logger.info("gtin resolved via OPFF", {requestId, gtin, structuredData: true});
    return {identification: fromOpff, resolver: "opff"};
  }

  const fromSearch = await identifyByGtinSearch(gtin, countryCode, requestId);
  if (fromSearch) {
    logger.info("gtin resolved via web search", {
      requestId, gtin, structuredData: true,
    });
    return {identification: fromSearch, resolver: "search"};
  }

  logger.info("gtin unresolved", {requestId, gtin, structuredData: true});
  return null;
}
