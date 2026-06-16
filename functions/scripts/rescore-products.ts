/* eslint-disable max-len */
/**
 * One-off batch re-score of the `products2` catalog with the ingredient-quality
 * QUALITY_RUBRIC. Re-grades each product's `score` (keeping the old value in
 * `scoreLegacy` for rollback). Existing pros/cons/macros are left untouched.
 *
 *   cd functions
 *   ANTHROPIC_API_KEY=$(npx firebase-tools@latest functions:secrets:access ANTHROPIC_API_KEY) \
 *   ALGOLIA_APP_ID=GI8VPYUYCP ALGOLIA_ADMIN_API_KEY=<admin-key> \
 *   npx ts-node scripts/rescore-products.ts --dry-run --limit=30
 *
 * Flags:
 *   --dry-run         compute + print proposed changes, write NOTHING
 *   --limit=N         only process the first N products (sampling)
 *   --concurrency=N   parallel Haiku calls (default 10)
 *
 * Requires an ADMIN Algolia key (search-only keys cannot write) and the
 * Anthropic key (used by regradeProductQuality via getClient).
 */
import {algoliasearch} from "algoliasearch";
import {regradeProductQuality} from "../src/services/anthropic.service";

const APP_ID = process.env.ALGOLIA_APP_ID;
const ADMIN_API_KEY = process.env.ALGOLIA_ADMIN_API_KEY;
const INDEX_NAME = process.env.ALGOLIA_INDEX_NAME || "products2";

if (!APP_ID || !ADMIN_API_KEY) {
  console.error(
    "Set ALGOLIA_APP_ID and ALGOLIA_ADMIN_API_KEY (admin key required to write)."
  );
  process.exit(1);
}
if (!process.env.ANTHROPIC_API_KEY) {
  console.error("Set ANTHROPIC_API_KEY (used to re-grade each product).");
  process.exit(1);
}

const args = process.argv.slice(2);
const DRY_RUN = args.includes("--dry-run");
const LIMIT = numFlag("--limit");
const CONCURRENCY = numFlag("--concurrency") ?? 10;
const QUERY = strFlag("--query"); // spot-check: only grade products matching this

function numFlag(name: string): number | undefined {
  const a = args.find((x) => x.startsWith(`${name}=`));
  return a ? Number(a.split("=")[1]) : undefined;
}

function strFlag(name: string): string | undefined {
  const a = args.find((x) => x.startsWith(`${name}=`));
  return a ? a.split("=").slice(1).join("=") : undefined;
}

const client = algoliasearch(APP_ID, ADMIN_API_KEY);

interface Hit {
  objectID: string;
  name?: string;
  brand?: string;
  foodType?: string;
  protein?: number;
  fat?: number;
  carbs?: number;
  fiber?: number;
  moisture?: number;
  ash?: number;
  score?: number;
  pros?: string[];
  cons?: string[];
}

async function mapPool<T, R>(
  items: T[],
  concurrency: number,
  fn: (item: T, index: number) => Promise<R>
): Promise<R[]> {
  const results: R[] = new Array(items.length);
  let next = 0;
  async function worker() {
    while (next < items.length) {
      const i = next++;
      results[i] = await fn(items[i], i);
    }
  }
  await Promise.all(
    Array.from({length: Math.min(concurrency, items.length)}, worker)
  );
  return results;
}

async function main() {
  console.log(
    `Re-scoring "${INDEX_NAME}" — ${DRY_RUN ? "DRY RUN (no writes)" : "LIVE"}` +
    `${LIMIT ? `, limit ${LIMIT}` : ""}, concurrency ${CONCURRENCY}`
  );

  const attrs = [
    "objectID", "name", "brand", "foodType",
    "protein", "fat", "carbs", "fiber", "moisture", "ash",
    "score", "pros", "cons",
  ];

  // 1. Gather products — either all (browse) or a query subset (spot-check).
  const all: Hit[] = [];
  if (QUERY) {
    const res = await client.searchSingleIndex<Hit>({
      indexName: INDEX_NAME,
      searchParams: {query: QUERY, hitsPerPage: 20, attributesToRetrieve: attrs},
    });
    for (const h of res.hits as Hit[]) all.push(h);
  } else {
    await client.browseObjects<Hit>({
      indexName: INDEX_NAME,
      browseParams: {query: "", hitsPerPage: 1000, attributesToRetrieve: attrs},
      aggregator: (response) => {
        for (const h of response.hits as Hit[]) all.push(h);
      },
    });
  }

  const targets = (LIMIT ? all.slice(0, LIMIT) : all)
    // Skip no-data products (score 0 means no guaranteed analysis was found).
    .filter((h) => (h.score ?? 0) > 0);
  console.log(`Fetched ${all.length} products; re-grading ${targets.length}.`);

  // 2. Re-grade each.
  let done = 0;
  const changes = await mapPool(targets, CONCURRENCY, async (h) => {
    const newScore = await regradeProductQuality({
      name: h.name ?? "",
      brand: h.brand ?? "",
      foodType: h.foodType ?? "",
      protein: h.protein ?? 0,
      fat: h.fat ?? 0,
      carbs: h.carbs ?? 0,
      fiber: h.fiber ?? 0,
      moisture: h.moisture ?? 0,
      ash: h.ash ?? 0,
      pros: h.pros ?? [],
      cons: h.cons ?? [],
    });
    done++;
    if (done % 50 === 0) console.log(`  …re-graded ${done}/${targets.length}`);
    return {hit: h, oldScore: h.score ?? 0, newScore};
  });

  const valid = changes.filter((c) => c.newScore != null) as Array<{
    hit: Hit; oldScore: number; newScore: number;
  }>;

  // 3. Summary.
  const deltas = valid.map((c) => c.newScore - c.oldScore);
  const avg = (xs: number[]) =>
    xs.length ? Math.round((xs.reduce((a, b) => a + b, 0) / xs.length) * 10) / 10 : 0;
  console.log("\n=== Summary ===");
  console.log(`Re-graded OK: ${valid.length} / ${targets.length}`);
  console.log(`Avg old: ${avg(valid.map((c) => c.oldScore))}  ` +
    `Avg new: ${avg(valid.map((c) => c.newScore))}  Avg delta: ${avg(deltas)}`);
  const biggestDrops = [...valid]
    .sort((a, b) => (a.newScore - a.oldScore) - (b.newScore - b.oldScore))
    .slice(0, 15);
  console.log("\nBiggest drops:");
  for (const c of biggestDrops) {
    console.log(`  ${c.oldScore} → ${c.newScore}  ${c.hit.brand} ${c.hit.name}`);
  }

  if (QUERY) {
    console.log("\nAll graded (spot-check):");
    for (const c of valid) {
      console.log(`  ${c.oldScore} → ${c.newScore}  ${c.hit.brand} ${c.hit.name}`);
    }
  }

  if (DRY_RUN) {
    console.log("\nDRY RUN — no changes written.");
    return;
  }

  // 4. Write back (score + scoreLegacy), batched.
  const objects = valid
    .filter((c) => c.newScore !== c.oldScore)
    .map((c) => ({
      objectID: c.hit.objectID,
      score: c.newScore,
      scoreLegacy: c.oldScore,
    }));
  console.log(`\nWriting ${objects.length} updated scores…`);
  const batchSize = 200;
  for (let i = 0; i < objects.length; i += batchSize) {
    await client.partialUpdateObjects({
      indexName: INDEX_NAME,
      objects: objects.slice(i, i + batchSize),
      createIfNotExists: false,
    });
    console.log(`  …wrote ${Math.min(i + batchSize, objects.length)}/${objects.length}`);
  }
  console.log("Done. Re-score is live.");
}

main().catch((error) => {
  console.error("Re-score failed:", error);
  process.exit(1);
});
