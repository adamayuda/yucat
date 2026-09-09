/**
 * One-off migration: swaps third-party image URLs for our own Storage URLs on
 * the live `articles` and `recipes` documents, **without re-translating**.
 *
 * `rehost-content-images.ts` uploads the images and rewrites the authored
 * Markdown; `convert-markdown.ts` then regenerates the seed JSON. That alone is
 * not enough, for two reasons:
 *
 *  1. The stored `translations.<lang>.body` blocks still carry the old URLs, so
 *     every non-English reader would keep hotlinking the third party.
 *  2. Changing `body[]` changes `canonicalArticleText`, so `translationsSourceHash`
 *     moves and the seeders would re-translate all 50 documents in 5 languages.
 *
 * A URL is byte-identical in every language, so the swap is mechanical: apply
 * the same map to English and to each translation, then write the hash the next
 * seed run will compute. Nothing is sent to a model.
 *
 * ⚠️ The hash is written ONLY for a document that already has translations.
 * Most of the current catalogue has none — the translation step never ran for
 * the September reseed — and stamping a matching hash onto an untranslated
 * document would tell the seeder it is up to date, freezing it in English.
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/rehost-firestore-image-urls.ts --dry-run
 *   npx ts-node scripts/rehost-firestore-image-urls.ts [--kind=articles] [--only=<id>]
 *
 * Firestore credentials come from GOOGLE_APPLICATION_CREDENTIALS or
 * `gcloud auth application-default login`.
 */
import * as fs from "fs";
import * as path from "path";
import * as crypto from "crypto";
import * as admin from "firebase-admin";
import {Article, canonicalArticleText} from "../src/models/article";
import {Recipe, canonicalRecipeText} from "../src/models/recipe";

const PROJECT_ID =
  process.env.FIREBASE_PROJECT_ID ??
  process.env.GOOGLE_CLOUD_PROJECT ??
  "yucat-d8fb5";

const args = process.argv.slice(2);
const flag = (name: string): string | undefined =>
  args.find((a) => a.startsWith(`--${name}=`))?.split("=").slice(1).join("=");
const DRY_RUN = args.includes("--dry-run");
/** Migrate a document whose stored body has drifted from the seed file. */
const FORCE = args.includes("--force");
const ONLY = flag("only");
const KIND_FILTER = flag("kind");

const DATA_DIR = path.join(__dirname, "data");
const MAP_PATH = path.join(DATA_DIR, "image-url-map.json");

/** Hosts that must not survive the migration. */
const REMOTE_HOSTS = ["images.unsplash.com", "live.staticflickr.com"];

interface KindSpec {
  kind: "articles" | "recipes";
  collection: string;
  dataFile: string;
  canonical: (doc: any) => unknown;
}

const KINDS: KindSpec[] = [
  {
    kind: "articles",
    collection: "articles",
    dataFile: "articles.json",
    canonical: (doc) => canonicalArticleText(doc as Article),
  },
  {
    kind: "recipes",
    collection: "recipes",
    dataFile: "recipes.json",
    canonical: (doc) => canonicalRecipeText(doc as Recipe),
  },
];

/** Same hash the seeders compute — sha1 over JSON.stringify, key order included. */
function sourceHash(text: unknown): string {
  return crypto.createHash("sha1").update(JSON.stringify(text)).digest("hex");
}

/** Plain string replace — URLs carry `?` and `&`, so never build a RegExp. */
function applyMap(text: string, map: Record<string, string>): string {
  let out = text;
  for (const [from, to] of Object.entries(map)) out = out.split(from).join(to);
  return out;
}

/** Recursively map every string in a value, leaving structure untouched. */
function mapDeep<T>(value: T, map: Record<string, string>): T {
  if (typeof value === "string") return applyMap(value, map) as unknown as T;
  if (Array.isArray(value)) {
    return value.map((v) => mapDeep(v, map)) as unknown as T;
  }
  if (value && typeof value === "object") {
    const out: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(value)) out[k] = mapDeep(v, map);
    return out as unknown as T;
  }
  return value;
}

function findRemote(value: unknown): string[] {
  const hits: string[] = [];
  const walk = (v: unknown) => {
    if (typeof v === "string") {
      for (const host of REMOTE_HOSTS) if (v.includes(host)) hits.push(host);
      return;
    }
    if (Array.isArray(v)) return v.forEach(walk);
    if (v && typeof v === "object") return Object.values(v).forEach(walk);
  };
  walk(value);
  return [...new Set(hits)];
}

async function main() {
  if (!fs.existsSync(MAP_PATH)) {
    console.error(
      `Missing ${MAP_PATH} — run rehost-content-images.ts (without --dry-run) first.`
    );
    process.exit(1);
  }
  const map = JSON.parse(fs.readFileSync(MAP_PATH, "utf8")) as Record<string, string>;
  console.log(`${Object.keys(map).length} URL(s) in the map.`);

  admin.initializeApp({projectId: PROJECT_ID});
  const db = admin.firestore();

  let migrated = 0;
  let skipped = 0;
  let unchanged = 0;

  for (const spec of KINDS) {
    if (KIND_FILTER && KIND_FILTER !== spec.kind) continue;

    const seed = JSON.parse(
      fs.readFileSync(path.join(DATA_DIR, spec.dataFile), "utf8")
    ) as {id: string}[];
    const items = ONLY ? seed.filter((s) => s.id === ONLY) : seed;
    if (items.length === 0) continue;

    console.log(`\n=== ${spec.collection} (${items.length}) ===`);
    const batch = db.batch();
    let pending = 0;

    for (const item of items) {
      const ref = db.collection(spec.collection).doc(item.id);
      const snap = await ref.get();
      if (!snap.exists) {
        console.log(`  ${item.id.padEnd(40)} NOT IN FIRESTORE — skipped`);
        skipped += 1;
        continue;
      }
      const stored = snap.data() as Record<string, unknown>;

      const nextImageUrl =
        typeof stored.imageUrl === "string" ?
          applyMap(stored.imageUrl, map) :
          stored.imageUrl ?? null;
      const nextBody = mapDeep(
        (stored.body as string[] | undefined) ?? [],
        map
      );
      const nextTranslations = stored.translations ?
        mapDeep(stored.translations as Record<string, unknown>, map) :
        undefined;

      // Drift guard: the migrated English body must equal the seed file, or the
      // hash we write below would not be the one the next seed run computes.
      const seedBody = (item as {body?: string[]}).body ?? [];
      const drifted =
        JSON.stringify(nextBody) !== JSON.stringify(seedBody);
      if (drifted && !FORCE) {
        console.log(
          `  ${item.id.padEnd(40)} BODY DRIFT vs ${spec.dataFile} — skipped ` +
            `(stored ${nextBody.length} block(s), seed ${seedBody.length}); ` +
            "re-seed it or pass --force"
        );
        skipped += 1;
        continue;
      }

      // Hash the SEED item: that is exactly what seed-*.ts will hash next run,
      // so writing it here is what makes the seeder skip re-translation.
      //
      // ⚠️ Only for a document that HAS translations. Most of the current
      // catalogue was seeded without any (the translation step never ran), and
      // writing a matching hash onto an untranslated document would tell the
      // seeder it is up to date — freezing it in English forever.
      const langs = Object.keys(
        (nextTranslations as Record<string, unknown> | undefined) ?? {}
      );
      const hash = langs.length > 0 ? sourceHash(spec.canonical(item)) : null;

      const blocksTouched = nextBody.filter(
        (b, i) => b !== ((stored.body as string[]) ?? [])[i]
      ).length;
      const noChange =
        nextImageUrl === stored.imageUrl &&
        blocksTouched === 0 &&
        JSON.stringify(nextTranslations) === JSON.stringify(stored.translations) &&
        (hash === null || stored.translationsSourceHash === hash);

      if (noChange) {
        unchanged += 1;
        continue;
      }

      console.log(
        `  ${item.id.padEnd(40)} imageUrl ${
          nextImageUrl === stored.imageUrl ? "unchanged" : "->storage"
        }, ${blocksTouched} body block(s), ${langs.length} translation(s), hash ${
          hash === null ?
            "left unset (untranslated — seeder must still translate it)" :
            stored.translationsSourceHash === hash ? "unchanged" : "recomputed"
        }`
      );

      if (!DRY_RUN) {
        const payload: Record<string, unknown> = {
          imageUrl: nextImageUrl,
          body: nextBody,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        if (hash !== null) payload.translationsSourceHash = hash;
        if (nextTranslations) payload.translations = nextTranslations;
        batch.set(ref, payload, {merge: true});
        pending += 1;
      }
      migrated += 1;
    }

    if (!DRY_RUN && pending > 0) {
      await batch.commit();
      console.log(`  committed ${pending} document(s).`);
    }
  }

  // Hand-authored translation files feed apply-translations.ts, so they would
  // reintroduce a remote host on the next run if left alone.
  const translationsDir = path.join(DATA_DIR, "translations");
  if (fs.existsSync(translationsDir)) {
    for (const kindDir of fs.readdirSync(translationsDir)) {
      const dir = path.join(translationsDir, kindDir);
      if (!fs.statSync(dir).isDirectory()) continue;
      for (const name of fs.readdirSync(dir)) {
        if (!name.endsWith(".json")) continue;
        const file = path.join(dir, name);
        const raw = fs.readFileSync(file, "utf8");
        const next = applyMap(raw, map);
        if (next === raw) continue;
        console.log(`\nRewrote translations/${kindDir}/${name}`);
        if (!DRY_RUN) fs.writeFileSync(file, next);
      }
    }
  }

  console.log(
    `\n${migrated} migrated, ${unchanged} already current, ${skipped} skipped.`
  );

  if (DRY_RUN) {
    console.log("DRY RUN — nothing written.");
    return;
  }

  // Final assertion: no third-party host may survive anywhere.
  const offenders: string[] = [];
  for (const spec of KINDS) {
    if (KIND_FILTER && KIND_FILTER !== spec.kind) continue;
    const all = await db.collection(spec.collection).get();
    for (const doc of all.docs) {
      const hits = findRemote(doc.data());
      if (hits.length > 0) {
        offenders.push(`  ${spec.collection}/${doc.id}: ${hits.join(", ")}`);
      }
    }
  }
  if (offenders.length > 0) {
    console.error(`\n${offenders.length} document(s) still reference a remote host:`);
    console.error(offenders.join("\n"));
    process.exit(1);
  }
  console.log("Verified: no remote image host remains in articles or recipes.");
}

main().catch((error) => {
  console.error("rehost-firestore-image-urls failed:", error);
  process.exit(1);
});
