/**
 * One-shot script to configure Algolia index settings + synonyms for the
 * `products2` index. Run manually after a relevant settings change:
 *
 *   cd functions && npx ts-node scripts/configure-algolia.ts
 *
 * Requires ALGOLIA_APP_ID and ALGOLIA_API_KEY in env (the API key must be
 * an admin key, not the search-only key).
 */
import {algoliasearch} from "algoliasearch";

const APP_ID = process.env.ALGOLIA_APP_ID;
const ADMIN_API_KEY = process.env.ALGOLIA_ADMIN_API_KEY;
const INDEX_NAME = process.env.ALGOLIA_INDEX_NAME || "products2";

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
        "foodType",
      ],
      attributesForFaceting: [
        "filterOnly(foodType)",
        "searchable(brand)",
        "filterOnly(barcode)",
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

  // Cat-food domain synonyms. Use one-way synonyms where the relationship is
  // semantically asymmetric (e.g. "salmon" is a kind of "fish", but a query
  // for "fish" should match salmon products — not the reverse).
  const oneWaySynonyms: Array<{objectID: string; input: string; synonyms: string[]}> = [
    {objectID: "syn-fish", input: "fish", synonyms: ["salmon", "tuna", "whitefish", "sardine", "mackerel"]},
    {objectID: "syn-poultry", input: "poultry", synonyms: ["chicken", "turkey", "duck"]},
  ];

  const equivalentSynonyms: Array<{objectID: string; synonyms: string[]}> = [
    {objectID: "syn-kitten", synonyms: ["kitten", "junior", "puppy"]},
    {objectID: "syn-treat", synonyms: ["treat", "snack", "reward"]},
    {
      objectID: "syn-wet-format",
      synonyms: [
        "wet", "pâté", "pate", "paste", "gravy", "chunks", "jelly",
        "in sauce", "mousse",
      ],
    },
    {objectID: "syn-dry-format", synonyms: ["dry", "kibble", "croquettes"]},
    {objectID: "syn-senior", synonyms: ["senior", "7+", "mature", "aging"]},
  ];

  const synonymRequests = [
    ...oneWaySynonyms.map((s) => ({
      objectID: s.objectID,
      type: "oneWaySynonym" as const,
      input: s.input,
      synonyms: s.synonyms,
    })),
    ...equivalentSynonyms.map((s) => ({
      objectID: s.objectID,
      type: "synonym" as const,
      synonyms: s.synonyms,
    })),
  ];

  console.log(`Saving ${synonymRequests.length} synonym sets`);
  await client.saveSynonyms({
    indexName: INDEX_NAME,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    synonymHit: synonymRequests as any,
    replaceExistingSynonyms: true,
  });
  console.log("Synonyms applied.");

  console.log("Done. Configuration is live for index:", INDEX_NAME);
}

main().catch((error) => {
  console.error("Configuration failed:", error);
  process.exit(1);
});
