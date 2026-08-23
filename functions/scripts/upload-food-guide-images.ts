/**
 * Uploads local food-guide photos to Firebase Storage and links them to their
 * documents.
 *
 * Photos arrive named loosely in French ("Produit letier.png"); document ids
 * are authored slugs, so the mapping is spelled out below rather than derived
 * — a near-miss filename should be a hard error, not a silently wrong hero.
 * Each file is optimized with the same settings as the product image pipeline
 * (IMAGE_OPTIMIZATION: 800x800 inside, progressive JPEG q85) — the source PNGs
 * are ~2 MB each, which would be a miserable payload for a detail screen.
 *
 * Writes the resulting public URL to Firestore `foodGuide/{id}.imageUrl` AND
 * back into scripts/data/food-guide.json, so a later `seed-food-guide.ts` run
 * doesn't clobber it with null.
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/upload-food-guide-images.ts \
 *     --source="$HOME/Downloads/Images/guide aliments" --dry-run
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

/** Source filename (without extension) → foodGuide document id. */
const FILE_TO_ENTRY: Record<string, string> = {
  "viande": "viandes",
  "Poissons": "poissons",
  "oeufs": "oeufs",
  "Fruit et legume": "fruitslegumes",
  "Produit letier": "laitiers",
  "Aliments dangereux": "dangereux",
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

const DATA_PATH = path.join(__dirname, "data", "food-guide.json");
const STORAGE_FOLDER = "foodGuide/";

async function main() {
  admin.initializeApp({
    projectId: PROJECT_ID,
    storageBucket: config.storage.bucketName,
  });

  const sharp = (await import("sharp")).default;
  const bucket = admin.storage().bucket(config.storage.bucketName);
  const db = admin.firestore();

  const files = fs.readdirSync(SOURCE_DIR!).filter((f) => !f.startsWith("."));
  const entries = JSON.parse(fs.readFileSync(DATA_PATH, "utf8")) as {
    id: string;
    imageUrl: string | null;
  }[];
  const knownIds = new Set(entries.map((r) => r.id));

  // 1. Resolve every file to an entry, refusing to guess.
  const jobs: {file: string; entryId: string}[] = [];
  for (const file of files) {
    // macOS stores filenames decomposed (NFD); the literals above are
    // composed (NFC), so an accented stem would not match without this.
    const stem = path.parse(file).name.normalize("NFC");
    const entryId = FILE_TO_ENTRY[stem];
    if (!entryId) {
      console.error(`  UNMAPPED FILE: "${file}" — add it to FILE_TO_ENTRY.`);
      process.exit(1);
    }
    if (!knownIds.has(entryId)) {
      console.error(`  "${file}" maps to unknown entry "${entryId}".`);
      process.exit(1);
    }
    jobs.push({file, entryId});
  }

  const withoutImage = entries
    .map((r) => r.id)
    .filter((id) => !jobs.some((j) => j.entryId === id));
  if (withoutImage.length > 0) {
    console.log(
      `No photo supplied for: ${withoutImage.join(", ")} ` +
        "(they keep the emoji hero)."
    );
  }

  // 2. Optimize + upload.
  const results: {entryId: string; url: string; before: number; after: number}[] =
    [];
  for (const {file, entryId} of jobs) {
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

    const fileName = `${STORAGE_FOLDER}${entryId}.jpeg`;
    const url =
      `https://storage.googleapis.com/${bucket.name}/${fileName}`;

    console.log(
      `  ${entryId.padEnd(15)} ${(source.length / 1024).toFixed(0)} KB -> ` +
        `${(optimized.length / 1024).toFixed(0)} KB   ${fileName}`
    );

    if (!DRY_RUN) {
      const storageFile = bucket.file(fileName);
      await storageFile.save(optimized, {
        contentType: "image/jpeg",
        metadata: {metadata: {entryId}},
      });
      await storageFile.makePublic();
    }

    results.push({
      entryId,
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
      db.collection("foodGuide").doc(r.entryId),
      {
        imageUrl: r.url,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true}
    );
  }
  await batch.commit();
  console.log(`\nLinked ${results.length} image(s) to Firestore.`);

  const byId = new Map(results.map((r) => [r.entryId, r.url]));
  for (const entry of entries) {
    const url = byId.get(entry.id);
    if (url) entry.imageUrl = url;
  }
  fs.writeFileSync(DATA_PATH, `${JSON.stringify(entries, null, 2)}\n`);
  console.log("Updated scripts/data/food-guide.json.");
}

main().catch((error) => {
  console.error("upload-food-guide-images failed:", error);
  process.exit(1);
});
