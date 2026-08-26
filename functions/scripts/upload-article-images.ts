/**
 * Uploads local article photos to Firebase Storage and links them to their
 * documents.
 *
 * Photos arrive named however the author saved them; document ids are authored
 * slugs, so the mapping is spelled out below rather than derived — a near-miss
 * filename should be a hard error, not a silently wrong hero. Each file is
 * optimized with the same settings as the product image pipeline
 * (IMAGE_OPTIMIZATION: 800x800 inside, progressive JPEG q85) — source PNGs run
 * ~2 MB each, which would be a miserable payload for a list screen.
 *
 * Writes the resulting public URL to Firestore `articles/{id}.imageUrl` AND
 * back into scripts/data/articles.json, so a later `seed-articles.ts` run
 * doesn't clobber it with null.
 *
 * ⚠️ FILE_TO_ARTICLE below starts EMPTY. Add one entry per photo before
 * running, or every file is reported as unmapped.
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/upload-article-images.ts \
 *     --source="$HOME/Downloads/article-images" --dry-run
 *
 * Firestore/Storage auth comes from GOOGLE_APPLICATION_CREDENTIALS or
 * `gcloud auth application-default login`.
 */
import * as fs from "fs";
import * as path from "path";
import * as admin from "firebase-admin";
import {IMAGE_OPTIMIZATION} from "../src/constants";
import {config} from "../src/config";

const PROJECT_ID =
  process.env.FIREBASE_PROJECT_ID ??
  process.env.GOOGLE_CLOUD_PROJECT ??
  "yucat-d8fb5";

/**
 * Source filename (without extension) → article document id.
 *
 * Photos are named in French after the headline; ids are English slugs, so the
 * mapping is spelled out rather than derived. Note the curly apostrophe in
 * "l\u2019hydratation" — it is U+2019, not U+0027.
 */
const FILE_TO_ARTICLE: Record<string, string> = {
  "Pourquoi les chats boivent-ils si peu ?": "why-cats-drink-little",
  "Pourquoi l\u2019hydratation est essentielle": "why-hydration-matters",
  "Comment bien choisir ses croquettes": "choosing-dry-food",
  "Reconnaître les signes de stress chez le chat": "signs-of-stress",
  "Pourquoi le chat est un carnivore strict": "obligate-carnivore",
  "La taurine, un nutriment que le chat ne fabrique pas": "taurine-essential",
  "Portions et surpoids - ce qui compte vraiment": "portion-control",
  "Changer d'alimentation sans troubles digestifs": "food-transition",
  "L'alimentation du chat âgé": "senior-cat-nutrition",
};

const args = process.argv.slice(2);
const DRY_RUN = args.includes("--dry-run");

function strFlag(name: string): string | undefined {
  const hit = args.find((a) => a.startsWith(`--${name}=`));
  return hit ? hit.split("=").slice(1).join("=") : undefined;
}

const SOURCE_DIR = strFlag("source");
if (!SOURCE_DIR) {
  console.error("Missing --source=<folder with the photos>");
  process.exit(1);
}

const DATA_PATH = path.join(__dirname, "data", "articles.json");
const STORAGE_FOLDER = "articles/";

async function main() {
  admin.initializeApp({
    projectId: PROJECT_ID,
    storageBucket: config.storage.bucketName,
  });

  const sharp = (await import("sharp")).default;
  const bucket = admin.storage().bucket(config.storage.bucketName);
  const db = admin.firestore();

  // Files only: unzipping a macOS archive leaves a "__MACOSX" directory
  // beside the photos, and an unmapped *directory* would hard-error below.
  const files = fs
    .readdirSync(SOURCE_DIR!, {withFileTypes: true})
    .filter((e) => e.isFile() && !e.name.startsWith("."))
    .map((e) => e.name);
  const articles = JSON.parse(fs.readFileSync(DATA_PATH, "utf8")) as {
    id: string;
    imageUrl: string | null;
  }[];
  const knownIds = new Set(articles.map((r) => r.id));

  // 1. Resolve every file to an article, refusing to guess.
  const jobs: {file: string; articleId: string}[] = [];
  for (const file of files) {
    // macOS stores filenames decomposed (NFD); the literals above are
    // composed (NFC), so an accented stem would not match without this.
    const stem = path.parse(file).name.normalize("NFC");
    const articleId = FILE_TO_ARTICLE[stem];
    if (!articleId) {
      console.error(`  UNMAPPED FILE: "${file}" — add it to FILE_TO_ARTICLE.`);
      process.exit(1);
    }
    if (!knownIds.has(articleId)) {
      console.error(`  "${file}" maps to unknown article "${articleId}".`);
      process.exit(1);
    }
    jobs.push({file, articleId});
  }

  const withoutImage = articles
    .map((r) => r.id)
    .filter((id) => !jobs.some((j) => j.articleId === id));
  if (withoutImage.length > 0) {
    console.log(
      `No photo supplied for: ${withoutImage.join(", ")} ` +
        "(they keep the tinted placeholder)."
    );
  }

  // 2. Optimize + upload.
  const results: {
    articleId: string;
    url: string;
    before: number;
    after: number;
  }[] = [];
  for (const {file, articleId} of jobs) {
    const source = fs.readFileSync(path.join(SOURCE_DIR!, file));
    const optimized = await sharp(source)
      .resize({
        width: IMAGE_OPTIMIZATION.MAX_WIDTH,
        height: IMAGE_OPTIMIZATION.MAX_HEIGHT,
        fit: IMAGE_OPTIMIZATION.FIT,
        withoutEnlargement: true,
      })
      .jpeg({quality: IMAGE_OPTIMIZATION.JPEG_QUALITY, progressive: true})
      .toBuffer();

    const fileName = `${STORAGE_FOLDER}${articleId}.jpeg`;
    const url =
      `https://storage.googleapis.com/${bucket.name}/${fileName}`;

    console.log(
      `  ${articleId.padEnd(24)} ${(source.length / 1024).toFixed(0)} KB -> ` +
        `${(optimized.length / 1024).toFixed(0)} KB   ${fileName}`
    );

    if (!DRY_RUN) {
      const storageFile = bucket.file(fileName);
      await storageFile.save(optimized, {
        contentType: "image/jpeg",
        metadata: {metadata: {articleId}},
      });
      await storageFile.makePublic();
    }

    results.push({
      articleId,
      url,
      before: source.length,
      after: optimized.length,
    });
  }

  if (DRY_RUN) {
    console.log("\nDRY RUN — nothing uploaded, nothing written.");
    return;
  }

  // 3. Link: Firestore, then the seed file so re-seeding preserves it.
  const batch = db.batch();
  for (const r of results) {
    batch.set(
      db.collection("articles").doc(r.articleId),
      {
        imageUrl: r.url,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true}
    );
  }
  await batch.commit();
  console.log(`\nLinked ${results.length} image(s) to Firestore.`);

  const byId = new Map(results.map((r) => [r.articleId, r.url]));
  for (const article of articles) {
    const url = byId.get(article.id);
    if (url) article.imageUrl = url;
  }
  fs.writeFileSync(DATA_PATH, `${JSON.stringify(articles, null, 2)}\n`);
  console.log("Updated scripts/data/articles.json.");
}

main().catch((error) => {
  console.error("upload-article-images failed:", error);
  process.exit(1);
});
