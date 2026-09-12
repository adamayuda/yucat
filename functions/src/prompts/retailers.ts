/**
 * Which retailer the second analyze source should search, by the user's
 * country.
 *
 * The fan-out used to run three near-identical web-search instances
 * (manufacturer, "Chewy or Amazon", "zooplus, Petco or Pets at Home"), each
 * costing two searches — six per scan, 70% of the cost of a cache miss — and
 * all three finished within a second of each other, so the third bought no
 * latency and, measured over two weeks, no recall the other two lacked. One
 * retailer chosen for the user's market covers the same ground: an FR user's
 * product is on zooplus.fr, not on Chewy.
 */

const EU_ZOOPLUS = new Set([
  "AT", "BE", "BG", "CH", "CZ", "DE", "DK", "EE", "ES", "FI", "FR", "GR",
  "HR", "HU", "IE", "IT", "LT", "LU", "LV", "NL", "NO", "PL", "PT", "RO",
  "SE", "SI", "SK",
]);

const AMAZON_TLD: Record<string, string> = {
  DE: "de", AT: "de", CH: "de", FR: "fr", BE: "fr", ES: "es", IT: "it",
  NL: "nl", PL: "pl", SE: "se", GB: "co.uk", IE: "co.uk", CA: "ca",
  AU: "com.au", JP: "co.jp", MX: "com.mx", BR: "com.br",
};

export function retailerFor(countryCode?: string): {label: string; hint: string} {
  const cc = countryCode?.trim().toUpperCase() ?? "";
  const amazon = AMAZON_TLD[cc] ? `Amazon.${AMAZON_TLD[cc]}` : "Amazon";

  if (cc === "US" || cc === "CA") {
    return {label: "retailer-na", hint: "a major retailer such as Chewy or Amazon"};
  }
  if (cc === "GB" || cc === "IE") {
    return {
      label: "retailer-uk",
      hint: `a major retailer such as Pets at Home, zooplus.co.uk or ${amazon}`,
    };
  }
  if (EU_ZOOPLUS.has(cc)) {
    return {
      label: "retailer-eu",
      hint:
        `a major retailer such as zooplus (the ${cc} country site) or ${amazon}`,
    };
  }
  if (cc === "AU" || cc === "NZ") {
    return {
      label: "retailer-anz",
      hint: `a major retailer such as Petbarn, Pet Circle or ${amazon}`,
    };
  }
  return {label: "retailer", hint: `a major retailer such as ${amazon} or zooplus`};
}
