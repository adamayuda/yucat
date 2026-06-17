/* eslint-disable max-len */
/**
 * One-off backfill of missing product images in the `products2` catalog.
 *
 * Finds + hosts an image for every product that has nutrition data (score > 0)
 * but an empty `imageUrl`, reusing the exact pipeline the live self-heal uses:
 * findProductImageUrl (Claude web search → SerpAPI fallback) → processProductImage
 * (validate + optimize + upload to Firebase Storage) → write `imageUrl` back.
 *
 * Image-only: nutrition, pros/cons, score, and ingredients are left untouched.
 *
 *   cd functions
 *   ANTHROPIC_API_KEY=$(npx firebase-tools@latest functions:secrets:access ANTHROPIC_API_KEY) \
 *   SERPAPI_API_KEY=$(npx firebase-tools@latest functions:secrets:access SERPAPI_API_KEY) \
 *   ALGOLIA_APP_ID=GI8VPYUYCP ALGOLIA_ADMIN_API_KEY=<admin-key> \
 *   GOOGLE_APPLICATION_CREDENTIALS=$HOME/yucat-sa.json \
 *   npx ts-node scripts/backfill-images.ts --dry-run --limit=10
 *
 * Storage auth: this script uploads to Firebase Storage, so it needs
 * application-default credentials — either GOOGLE_APPLICATION_CREDENTIALS
 * pointing at a service-account JSON, or `gcloud auth application-default login`
 * with an account that has Storage object admin on the bucket.
 *
 * Flags:
 *   --dry-run         find images + print results, write NOTHING (no Storage upload either)
 *   --limit=N         only process the first N imageless products (sampling)
 *   --concurrency=N   parallel workers (default 5 — each does a web search + upload)
 *
 * Requires an ADMIN Algolia key (search-only keys cannot write) and the
 * Anthropic key. SERPAPI_API_KEY is optional (fallback auto-disables without it).
 */
import * as admin from "firebase-admin";
import {algoliasearch} from "algoliasearch";
import {config} from "../src/config";
import {findProductImageUrl} from "../src/services/anthropic.service";
import {processProductImage} from "../src/utils/image-helpers";

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
  console.error("Set ANTHROPIC_API_KEY (used to find each product image).");
  process.exit(1);
}

const args = process.argv.slice(2);
const DRY_RUN = args.includes("--dry-run");
const LIMIT = numFlag("--limit");
const CONCURRENCY = numFlag("--concurrency") ?? 5;

function numFlag(name: string): number | undefined {
  const a = args.find((x) => x.startsWith(`${name}=`));
  return a ? Number(a.split("=")[1]) : undefined;
}

// Storage upload (processProductImage → uploadImageToFirebaseStorage) calls
// admin.storage(), so the default app must be initialized before we run.
admin.initializeApp({storageBucket: config.storage.bucketName});

const client = algoliasearch(APP_ID, ADMIN_API_KEY);

interface Hit {
  objectID: string;
  name?: string;
  brand?: string;
  imageUrl?: string;
  score?: number;
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
    `Backfilling images in "${INDEX_NAME}" — ${DRY_RUN ? "DRY RUN (no writes)" : "LIVE"}` +
    `${LIMIT ? `, limit ${LIMIT}` : ""}, concurrency ${CONCURRENCY}` +
    `${config.serpapi.enabled ? "" : " (SerpAPI DISABLED — no key)"}`
  );

  const attrs = ["objectID", "name", "brand", "imageUrl", "score"];

  // 1. Gather all products, then keep those with data but no image.
  const all: Hit[] = [];
  await client.browseObjects<Hit>({
    indexName: INDEX_NAME,
    browseParams: {query: "", hitsPerPage: 1000, attributesToRetrieve: attrs},
    aggregator: (response) => {
      for (const h of response.hits as Hit[]) all.push(h);
    },
  });

  const imageless = all.filter((h) => (h.score ?? 0) > 0 && !h.imageUrl);
  const targets = LIMIT ? imageless.slice(0, LIMIT) : imageless;
  console.log(
    `Fetched ${all.length} products; ${imageless.length} have data but no image; ` +
    `processing ${targets.length}.`
  );

  // 2. Find + host an image for each.
  let done = 0;
  const results = await mapPool(targets, CONCURRENCY, async (h) => {
    const brand = h.brand ?? "";
    const name = h.name ?? "";
    let hosted = "";
    let rawUrl = "";
    try {
      rawUrl = await findProductImageUrl(brand, name);
      if (rawUrl && !DRY_RUN) {
        hosted = await processProductImage(rawUrl, h.objectID, name, brand);
      }
    } catch (error) {
      console.warn(`  ! ${brand} ${name}: ${error instanceof Error ? error.message : String(error)}`);
    }
    done++;
    if (done % 10 === 0) console.log(`  …processed ${done}/${targets.length}`);
    return {hit: h, rawUrl, hosted};
  });

  // 3. Summary.
  const found = results.filter((r) => r.rawUrl);
  const uploaded = results.filter((r) => r.hosted);
  console.log("\n=== Summary ===");
  console.log(`Image URL found:  ${found.length} / ${targets.length}`);
  if (!DRY_RUN) console.log(`Hosted + ready:   ${uploaded.length} / ${targets.length}`);
  console.log(`No image found:   ${targets.length - found.length}`);
  console.log("\nSample:");
  for (const r of results.slice(0, 15)) {
    const status = r.hosted ? "HOSTED" : (r.rawUrl ? (DRY_RUN ? "FOUND" : "UPLOAD-FAILED") : "none");
    console.log(`  [${status}] ${r.hit.brand} ${r.hit.name}`);
  }

  if (DRY_RUN) {
    console.log("\nDRY RUN — no Storage uploads, no Algolia writes.");
    return;
  }

  // 4. Write back imageUrl + lastImageAttempt (stamp every attempt so the row is
  //    marked attempted, matching the live self-heal throttle). Batched.
  const now = Date.now();
  const objects = results.map((r) => ({
    objectID: r.hit.objectID,
    imageUrl: r.hosted,
    lastImageAttempt: now,
  }));
  console.log(`\nWriting ${objects.length} records (${uploaded.length} with a new image)…`);
  const batchSize = 200;
  for (let i = 0; i < objects.length; i += batchSize) {
    await client.partialUpdateObjects({
      indexName: INDEX_NAME,
      objects: objects.slice(i, i + batchSize),
      createIfNotExists: false,
    });
    console.log(`  …wrote ${Math.min(i + batchSize, objects.length)}/${objects.length}`);
  }
  console.log("Done. Image backfill is live.");
}

main().catch((error) => {
  console.error("Backfill failed:", error);
  process.exit(1);
});
