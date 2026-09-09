/**
 * Re-hosts every article and recipe image on Firebase Storage.
 *
 * Articles and recipes are authored as Markdown with a front-matter `image:`
 * plus inline `![alt](url)` blocks, and `convert-markdown.ts` copies those URLs
 * verbatim into `scripts/data/<kind>.json` and from there into Firestore. When
 * the authored URLs point at a third-party CDN, the app hotlinks it forever.
 * This walks the authored folder, uploads every referenced image to our own
 * bucket, and **rewrites the `.md` sources in place** so a later convert run
 * cannot reintroduce a remote host.
 *
 * Supersedes `upload-article-images.ts` / `upload-recipe-images.ts`: filenames
 * in `<source>/images/` already equal document ids, so there is no hand-written
 * filename map to go stale — and unlike those two, this also covers the images
 * *inside* the body, which are the majority.
 *
 * Naming keeps the documented convention:
 *   hero of doc X        -> {articles|recipes}/{X}.jpeg
 *   body-only image      -> {articles|recipes}/{X}-b{n}.jpeg
 * A URL used by more than one document is uploaded once and shared.
 *
 * Writes `scripts/data/image-url-map.json` (sourceUrl -> storageUrl), which is
 * what `rehost-firestore-image-urls.ts` replays against the live documents.
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/rehost-content-images.ts \
 *     --source="$HOME/Downloads/markdown" --dry-run
 *
 * Firestore/Storage auth comes from GOOGLE_APPLICATION_CREDENTIALS or
 * `gcloud auth application-default login`.
 */
import * as fs from "fs";
import * as path from "path";
import * as crypto from "crypto";
import * as admin from "firebase-admin";
import {IMAGE_OPTIMIZATION} from "../src/constants";
import {config} from "../src/config";

const PROJECT_ID =
  process.env.FIREBASE_PROJECT_ID ??
  process.env.GOOGLE_CLOUD_PROJECT ??
  "yucat-d8fb5";

const KINDS = ["articles", "recipes"] as const;
type Kind = (typeof KINDS)[number];

const args = process.argv.slice(2);
const flag = (name: string): string | undefined =>
  args.find((a) => a.startsWith(`--${name}=`))?.split("=").slice(1).join("=");
const DRY_RUN = args.includes("--dry-run");
/** Refuse to fetch anything that has no local file, instead of downloading. */
const NO_DOWNLOAD = args.includes("--no-download");

const SOURCE = flag("source");
if (!SOURCE) {
  console.error(
    "Missing --source=<dir> (the folder holding articles/, recipes/ and images/)"
  );
  process.exit(1);
}

const IMAGES_DIR = path.join(SOURCE, "images");
const EXTRA_DIR = path.join(IMAGES_DIR, "_extra");
const MAP_PATH = path.join(__dirname, "data", "image-url-map.json");

/** Anything we host ourselves already — left alone, and never re-uploaded. */
const SELF_HOSTED = `https://storage.googleapis.com/${config.storage.bucketName}/`;

interface Doc {
  kind: Kind;
  id: string;
  file: string;
  raw: string;
  hero: string | null;
  /** Distinct body image URLs, in first-appearance order. */
  body: string[];
}

interface Job {
  url: string;
  /** Storage object path, e.g. "articles/why-cats-purr.jpeg". */
  target: string;
  /** Local file, or null when it still has to be downloaded. */
  localFile: string | null;
  usedBy: string[];
}

/** Front-matter `image:` — flat scalar, optionally quoted, same as convert-markdown. */
function frontMatterImage(raw: string): string | null {
  const end = raw.indexOf("\n---", 3);
  if (!raw.startsWith("---") || end === -1) return null;
  const block = raw.slice(3, end);
  for (const line of block.split("\n")) {
    const m = /^image:\s*(.*)$/.exec(line.trim());
    if (!m) continue;
    return m[1].trim().replace(/^["']|["']$/g, "") || null;
  }
  return null;
}

/** Every inline Markdown image URL, deduped, in first-appearance order. */
function bodyImages(raw: string): string[] {
  const out: string[] = [];
  for (const m of raw.matchAll(/!\[[^\]]*\]\(([^)\s]+)[^)]*\)/g)) {
    if (!out.includes(m[1])) out.push(m[1]);
  }
  return out;
}

function readDocs(): Doc[] {
  const docs: Doc[] = [];
  for (const kind of KINDS) {
    const dir = path.join(SOURCE!, kind);
    if (!fs.existsSync(dir)) {
      console.error(`Missing ${dir}`);
      process.exit(1);
    }
    for (const name of fs.readdirSync(dir).sort()) {
      if (!name.endsWith(".md")) continue;
      const file = path.join(dir, name);
      const raw = fs.readFileSync(file, "utf8");
      docs.push({
        kind,
        id: path.parse(name).name.normalize("NFC"),
        file,
        raw,
        hero: frontMatterImage(raw),
        body: bodyImages(raw),
      });
    }
  }
  return docs;
}

/**
 * Assign a Storage path to every referenced URL.
 *
 * Heroes claim `{kind}/{id}.jpeg` first so the documented convention holds;
 * whatever is left over is a body-only image and gets a `-b{n}` suffix under
 * the first document that references it.
 */
function planJobs(docs: Doc[]): Job[] {
  const byUrl = new Map<string, Job>();

  const claim = (url: string, target: string, localFile: string | null) => {
    byUrl.set(url, {url, target, localFile, usedBy: []});
  };

  for (const doc of docs) {
    if (!doc.hero || doc.hero.startsWith(SELF_HOSTED)) continue;
    if (byUrl.has(doc.hero)) continue;
    claim(
      doc.hero,
      `${doc.kind}/${doc.id}.jpeg`,
      path.join(IMAGES_DIR, `${doc.id}.jpg`)
    );
  }

  for (const doc of docs) {
    let n = 0;
    for (const url of doc.body) {
      if (url.startsWith(SELF_HOSTED) || byUrl.has(url)) continue;
      n += 1;
      claim(url, `${doc.kind}/${doc.id}-b${n}.jpeg`, null);
    }
  }

  for (const doc of docs) {
    const ref = `${doc.kind}/${doc.id}`;
    for (const url of [doc.hero, ...doc.body]) {
      const job = url ? byUrl.get(url) : undefined;
      if (job && !job.usedBy.includes(ref)) job.usedBy.push(ref);
    }
  }

  return [...byUrl.values()];
}

async function resolveBytes(job: Job): Promise<Buffer> {
  if (job.localFile && fs.existsSync(job.localFile)) {
    return fs.readFileSync(job.localFile);
  }
  if (job.localFile) {
    // A hero with no photo in images/ is an authoring mistake, not something
    // to paper over by silently re-downloading the third-party original.
    throw new Error(
      `expected local file ${job.localFile} for ${job.target} — not found`
    );
  }

  const cached = path.join(
    EXTRA_DIR,
    `${crypto.createHash("sha1").update(job.url).digest("hex").slice(0, 16)}.jpg`
  );
  if (fs.existsSync(cached)) return fs.readFileSync(cached);
  if (NO_DOWNLOAD) {
    throw new Error(`no local file for ${job.url} (--no-download)`);
  }

  const res = await fetch(job.url);
  if (!res.ok) throw new Error(`GET ${job.url} -> ${res.status}`);
  const buf = Buffer.from(await res.arrayBuffer());
  fs.mkdirSync(EXTRA_DIR, {recursive: true});
  fs.writeFileSync(cached, buf);
  return buf;
}

/** Plain string replace — URLs carry `?` and `&`, so never build a RegExp. */
function applyMap(text: string, map: Record<string, string>): string {
  let out = text;
  for (const [from, to] of Object.entries(map)) out = out.split(from).join(to);
  return out;
}

async function main() {
  const docs = readDocs();
  const jobs = planJobs(docs);

  console.log(
    `${docs.length} documents (${docs.filter((d) => d.kind === "articles").length} articles, ` +
      `${docs.filter((d) => d.kind === "recipes").length} recipes)`
  );
  console.log(`${jobs.length} distinct images to host.`);

  const missingHero = docs.filter((d) => !d.hero);
  if (missingHero.length > 0) {
    console.log(
      `No front-matter image on: ${missingHero.map((d) => d.id).join(", ")}`
    );
  }

  const toDownload = jobs.filter(
    (j) => !j.localFile && !fs.existsSync(
      path.join(
        EXTRA_DIR,
        `${crypto.createHash("sha1").update(j.url).digest("hex").slice(0, 16)}.jpg`
      )
    )
  );
  if (toDownload.length > 0) {
    console.log(`\n${toDownload.length} image(s) have no local file and will be fetched:`);
    for (const j of toDownload) console.log(`  ${j.target}  <-  ${j.url}`);
  }

  // 1. Resolve every byte first — a missing hero must fail before we upload
  //    half the catalogue and leave the .md files half-rewritten.
  const bytes = new Map<string, Buffer>();
  const failures: string[] = [];
  for (const job of jobs) {
    try {
      bytes.set(job.url, await resolveBytes(job));
    } catch (error) {
      failures.push(`  ${job.target}: ${(error as Error).message}`);
    }
  }
  if (failures.length > 0) {
    console.error(`\n${failures.length} image(s) could not be resolved:`);
    console.error(failures.join("\n"));
    process.exit(1);
  }

  admin.initializeApp({
    projectId: PROJECT_ID,
    storageBucket: config.storage.bucketName,
  });
  const sharp = (await import("sharp")).default;
  const bucket = admin.storage().bucket(config.storage.bucketName);

  // 2. Optimize + upload.
  const map: Record<string, string> = {};
  console.log("");
  for (const job of jobs) {
    const source = bytes.get(job.url)!;
    const optimized = await sharp(source)
      .resize({
        width: IMAGE_OPTIMIZATION.MAX_WIDTH,
        height: IMAGE_OPTIMIZATION.MAX_HEIGHT,
        fit: IMAGE_OPTIMIZATION.FIT,
        withoutEnlargement: true,
      })
      .jpeg({quality: IMAGE_OPTIMIZATION.JPEG_QUALITY, progressive: true})
      .toBuffer();

    const url = `${SELF_HOSTED}${job.target}`;
    map[job.url] = url;

    console.log(
      `  ${job.target.padEnd(42)} ${(source.length / 1024).toFixed(0).padStart(5)} KB -> ` +
        `${(optimized.length / 1024).toFixed(0).padStart(4)} KB   ` +
        `${job.usedBy.length > 1 ? `shared by ${job.usedBy.length}` : ""}`
    );

    if (!DRY_RUN) {
      const file = bucket.file(job.target);
      await file.save(optimized, {
        contentType: "image/jpeg",
        metadata: {metadata: {usedBy: job.usedBy.join(",")}},
      });
      await file.makePublic();
    }
  }

  if (DRY_RUN) {
    console.log("\nDRY RUN — nothing uploaded, no .md rewritten, no map written.");
    return;
  }

  // 3. Rewrite the authored Markdown so a later convert-markdown run keeps it.
  let rewritten = 0;
  for (const doc of docs) {
    const next = applyMap(doc.raw, map);
    if (next === doc.raw) continue;
    fs.writeFileSync(doc.file, next);
    rewritten += 1;
  }
  console.log(`\nRewrote ${rewritten} Markdown file(s) under ${SOURCE}.`);

  // 4. The map is the contract with rehost-firestore-image-urls.ts.
  const sorted = Object.fromEntries(
    Object.entries(map).sort(([, a], [, b]) => a.localeCompare(b))
  );
  fs.writeFileSync(MAP_PATH, `${JSON.stringify(sorted, null, 2)}\n`);
  console.log(`Wrote ${Object.keys(sorted).length} entries to scripts/data/image-url-map.json.`);
  console.log(
    "\nNext: re-run convert-markdown.ts for both kinds, then " +
      "rehost-firestore-image-urls.ts to migrate the live documents."
  );
}

main().catch((error) => {
  console.error("rehost-content-images failed:", error);
  process.exit(1);
});
