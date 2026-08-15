/**
 * One-shot script to create + configure the Algolia `litters` index.
 *
 *   cd functions && npx ts-node scripts/configure-litter-index.ts
 *
 * ⚠️ **This must be run once before the litter scan path can hit its cache.**
 * `searchLitterByNameV2` passes `optionalFilters: ["brand:…"]`, and Algolia
 * rejects a filter on an attribute that is not declared for faceting. Until
 * that declaration exists every lookup errors, is swallowed, and every scan
 * falls through to a full (paid) analysis instead of a cache hit.
 *
 * Requires ALGOLIA_APP_ID and ALGOLIA_ADMIN_API_KEY in env — the admin key,
 * not the committed search-only key, which cannot mutate settings.
 *
 * Deliberately separate from `configure-algolia.ts`: the two indexes have
 * different attributes and different synonym needs, and running one should
 * never silently reconfigure the other.
 */
import {algoliasearch} from "algoliasearch";

const APP_ID = process.env.ALGOLIA_APP_ID;
const ADMIN_API_KEY = process.env.ALGOLIA_ADMIN_API_KEY;
const INDEX_NAME = process.env.ALGOLIA_LITTER_INDEX_NAME || "litters";

if (!APP_ID || !ADMIN_API_KEY) {
  console.error(
    "Set ALGOLIA_APP_ID and ALGOLIA_ADMIN_API_KEY before running. The " +
    "admin key is required — search-only keys cannot mutate settings."
  );
  process.exit(1);
}

const client = algoliasearch(APP_ID, ADMIN_API_KEY);

async function main() {
  console.log(`Updating settings for index: ${INDEX_NAME}`);

  await client.setSettings({
    indexName: INDEX_NAME,
    indexSettings: {
      searchableAttributes: [
        "unordered(brand)",
        "unordered(name)",
      ],
      attributesForFaceting: [
        // `brand` is load-bearing: searchLitterByNameV2 soft-boosts on it.
        "searchable(brand)",
        "filterOnly(material)",
        "filterOnly(clumping)",
        "filterOnly(scented)",
      ],
      customRanking: [
        "desc(score)",
      ],
      typoTolerance: true,
      minWordSizefor1Typo: 3,
      minWordSizefor2Typos: 7,
      removeStopWords: ["en"],
      ignorePlurals: ["en"],
    },
  });
  console.log("Settings applied.");

  // Litter-domain synonyms. Scanned names and cached names often disagree on
  // the substrate word ("bentonite" vs "clay") or the clumping word.
  const equivalentSynonyms: Array<{objectID: string; synonyms: string[]}> = [
    {objectID: "lit-syn-clumping", synonyms: ["clumping", "scoopable", "scooping"]},
    {objectID: "lit-syn-clay", synonyms: ["clay", "bentonite", "sodium bentonite"]},
    {objectID: "lit-syn-crystal", synonyms: ["crystal", "crystals", "silica", "silica gel"]},
    {objectID: "lit-syn-unscented", synonyms: ["unscented", "fragrance free", "fragrance-free", "no fragrance"]},
    {objectID: "lit-syn-tofu", synonyms: ["tofu", "soya", "soy", "bean curd"]},
    {objectID: "lit-syn-wood", synonyms: ["wood", "pine", "wooden", "pellets"]},
  ];

  const synonymRequests = equivalentSynonyms.map((s) => ({
    objectID: s.objectID,
    type: "synonym" as const,
    synonyms: s.synonyms,
  }));

  await client.saveSynonyms({
    indexName: INDEX_NAME,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    synonymHit: synonymRequests as any,
    replaceExistingSynonyms: true,
  });
  console.log(`Applied ${synonymRequests.length} synonym sets.`);
  console.log("Done.");
}

main().catch((err) => {
  console.error("Failed to configure litter index:", err);
  process.exit(1);
});
