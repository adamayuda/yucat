/**
 * Minimal HTML page fetcher + text extractor.
 *
 * Used by the manufacturer-page nutrition fallback: when Claude's web_search
 * can't surface a niche brand's guaranteed analysis, we fetch the likely
 * product page(s) ourselves (URLs from SerpAPI organic results) and hand the
 * stripped text to Claude for extraction. Fully self-contained — no JS
 * rendering, so pages that only render nutrition client-side yield nothing and
 * the caller falls back gracefully.
 */
import * as logger from "firebase-functions/logger";

/** Cap per-page text so a few pages stay well within the model's token budget. */
const MAX_TEXT_CHARS = 9000;
/** Abort a slow page rather than blocking the whole scan. */
const FETCH_TIMEOUT_MS = 8000;
/** Cap discovered product links so a huge listing page can't explode the set. */
const MAX_LINKS = 60;

export interface FetchedPage {
  /** Stripped, length-capped page text. */
  text: string;
  /**
   * Same-host product-detail URLs found on the page (paths containing
   * `/product/` or `/products/`). Lets the caller follow a collection/listing
   * page down to the actual product page, which often outranks it in search.
   */
  productLinks: string[];
}

const BROWSER_HEADERS = {
  // Some sites 403 a default fetch UA; present a real browser UA.
  "user-agent":
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " +
    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36",
  "accept": "text/html,application/xhtml+xml",
};

/**
 * Extracts same-host product-detail links (Shopify/Woo-style `/products/` or
 * `/product/` paths) from raw HTML, as absolute URLs with query/hash stripped.
 * Returns [] for sites that don't use that pattern (the caller then just uses
 * the page text directly).
 */
export function extractProductLinks(html: string, baseUrl: string): string[] {
  let origin: URL;
  try {
    origin = new URL(baseUrl);
  } catch {
    return [];
  }
  const out = new Set<string>();
  for (const match of html.matchAll(/href="([^"#]+)"/g)) {
    let abs: URL;
    try {
      abs = new URL(match[1], origin);
    } catch {
      continue;
    }
    if (abs.host !== origin.host) continue;
    if (!/\/products?\//i.test(abs.pathname)) continue;
    abs.search = "";
    abs.hash = "";
    out.add(abs.toString());
    if (out.size >= MAX_LINKS) break;
  }
  return [...out];
}

/**
 * Strips an HTML document to readable text: removes script/style/comment blocks
 * and tags, decodes the few common entities, and collapses whitespace.
 */
export function htmlToText(html: string): string {
  return html
    .replace(/<script[\s\S]*?<\/script>/gi, " ")
    .replace(/<style[\s\S]*?<\/style>/gi, " ")
    .replace(/<!--[\s\S]*?-->/g, " ")
    // Treat block-ish boundaries as spaces so adjacent text/numbers don't merge
    // (e.g. "Protein</td><td>9%" must not become "Protein9%").
    .replace(/<\/(p|div|tr|td|th|li|br|h[1-6]|table)[^>]*>/gi, " ")
    .replace(/<[^>]+>/g, " ")
    .replace(/&nbsp;/gi, " ")
    .replace(/&amp;/gi, "&")
    .replace(/&lt;/gi, "<")
    .replace(/&gt;/gi, ">")
    .replace(/&quot;/gi, "\"")
    .replace(/&#39;|&apos;/gi, "'")
    .replace(/\s+/g, " ")
    .trim();
}

/**
 * Fetches a URL and returns its stripped text plus discovered product-detail
 * links. Returns {text:"", productLinks:[]} on any failure (non-OK status,
 * non-HTML content, timeout, network error) — never throws, so callers can fan
 * out over candidates without guarding each one.
 */
export async function fetchPage(url: string): Promise<FetchedPage> {
  try {
    const response = await fetch(url, {
      redirect: "follow",
      signal: AbortSignal.timeout(FETCH_TIMEOUT_MS),
      headers: BROWSER_HEADERS,
    });
    if (!response.ok) return {text: "", productLinks: []};
    const contentType = response.headers.get("content-type") || "";
    if (!contentType.includes("html") && !contentType.includes("text")) {
      return {text: "", productLinks: []};
    }
    const html = await response.text();
    return {
      text: htmlToText(html).slice(0, MAX_TEXT_CHARS),
      productLinks: extractProductLinks(html, response.url || url),
    };
  } catch (error) {
    logger.info("fetchPage failed", {
      url,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return {text: "", productLinks: []};
  }
}

/** Convenience wrapper when only the text is needed (no link discovery). */
export async function fetchPageText(url: string): Promise<string> {
  return (await fetchPage(url)).text;
}
