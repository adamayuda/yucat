/**
 * One-shot script to purge a single cached product from the `products2`
 * Algolia index so the next scan re-analyzes it from scratch.
 *
 * Usage (admin key is NOT committed — pass it via env):
 *   cd functions
 *   ALGOLIA_ADMIN_API_KEY=xxxx npx ts-node scripts/purge-cache-entry.ts "arquivet" "bluefin"
 *
 * Args: <brandSubstr> [nameSubstr]
 *   - Case-insensitive substring filters applied to the cached brand/name.
 *   - Only image-scan entries (objectID starting "img-") are eligible.
 *   - Prints every match and asks nothing — it deletes the matches. Review the
 *     printed list; re-run with a tighter filter if it catches too much.
 */
import {algoliasearch} from "algoliasearch";

const APP_ID = process.env.ALGOLIA_APP_ID || "GI8VPYUYCP";
const ADMIN_API_KEY = process.env.ALGOLIA_ADMIN_API_KEY;
const INDEX_NAME = "products2";

if (!ADMIN_API_KEY) {
  console.error(
    "Set ALGOLIA_ADMIN_API_KEY before running (admin key is not committed)."
  );
  process.exit(1);
}

const brandSubstr = (process.argv[2] || "").toLowerCase();
const nameSubstr = (process.argv[3] || "").toLowerCase();

if (!brandSubstr) {
  console.error('Usage: purge-cache-entry.ts "<brandSubstr>" [nameSubstr]');
  process.exit(1);
}

const client = algoliasearch(APP_ID, ADMIN_API_KEY);

async function main(): Promise<void> {
  // Search by brand+name; we filter client-side so we control exactly what dies.
  const query = `${brandSubstr} ${nameSubstr}`.trim();
  const res = await client.search({
    requests: [{indexName: INDEX_NAME, query, hitsPerPage: 50}],
  });

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const hits = ((res.results[0] as any)?.hits || []) as any[];

  const matches = hits.filter((h) => {
    const brand = String(h.brand || "").toLowerCase();
    const name = String(h.name || "").toLowerCase();
    const id = String(h.objectID || "");
    return (
      id.startsWith("img-") &&
      brand.includes(brandSubstr) &&
      (!nameSubstr || name.includes(nameSubstr))
    );
  });

  if (matches.length === 0) {
    console.log("No matching image-scan cache entries found. Nothing to purge.");
    return;
  }

  console.log(`Found ${matches.length} entry(ies) to purge:`);
  for (const m of matches) {
    console.log(
      `  - objectID=${m.objectID} | ${m.brand} | ${m.name} | ` +
        `protein=${m.protein} score=${m.score}`
    );
  }

  const ids = matches.map((m) => String(m.objectID));
  await client.deleteObjects({indexName: INDEX_NAME, objectIDs: ids});
  console.log(`Deleted ${ids.length} object(s) from "${INDEX_NAME}".`);
}

main().catch((e) => {
  console.error("Purge failed:", e);
  process.exit(1);
});
