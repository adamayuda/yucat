/**
 * Uploads local recipe photos to Firebase Storage and links them to their
 * recipe documents.
 *
 * Photos arrive named in French after the dish; recipe ids are English slugs,
 * so the mapping is spelled out below rather than derived. Each file is
 * optimized with the same settings as the product image pipeline
 * (IMAGE_OPTIMIZATION: 800x800 inside, progressive JPEG q85) — the source PNGs
 * are ~2 MB each, which would be a miserable payload for a list screen.
 *
 * Writes the resulting public URL to Firestore `recipes/{id}.imageUrl` AND back
 * into scripts/data/recipes.json, so a later `seed-recipes.ts` run doesn't
 * clobber it with null.
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/upload-recipe-images.ts --source="$HOME/Downloads/recette image" --dry-run
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

/** Source filename (without extension) → recipe document id. */
const FILE_TO_RECIPE: Record<string, string> = {
  "Biscuits au thon": "tuna-biscuits",
  "Biscuits au poulet": "chicken-biscuits",
  "Mini-gâteau au thon": "tuna-mini-cake",
  "Bouchées glacées au thon": "frozen-tuna-bites",
  "Bouchées glacées à la pâtée": "frozen-wet-food-bites",
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

const DATA_PATH = path.join(__dirname, "data", "recipes.json");
const STORAGE_FOLDER = "recipes/";

async function main() {
  admin.initializeApp({
    projectId: PROJECT_ID,
    storageBucket: config.storage.bucketName,
  });

  const sharp = (await import("sharp")).default;
  const bucket = admin.storage().bucket(config.storage.bucketName);
  const db = admin.firestore();

  const files = fs.readdirSync(SOURCE_DIR!).filter((f) => !f.startsWith("."));
  const recipes = JSON.parse(fs.readFileSync(DATA_PATH, "utf8")) as {
    id: string;
    imageUrl: string | null;
  }[];
  const knownIds = new Set(recipes.map((r) => r.id));

  // 1. Resolve every file to a recipe, refusing to guess.
  const jobs: {file: string; recipeId: string}[] = [];
  for (const file of files) {
    // macOS stores filenames decomposed (NFD); the literals above are
    // composed (NFC), so "Bouchées" would not match without this.
    const stem = path.parse(file).name.normalize("NFC");
    const recipeId = FILE_TO_RECIPE[stem];
    if (!recipeId) {
      console.error(`  UNMAPPED FILE: "${file}" — add it to FILE_TO_RECIPE.`);
      process.exit(1);
    }
    if (!knownIds.has(recipeId)) {
      console.error(`  "${file}" maps to unknown recipe "${recipeId}".`);
      process.exit(1);
    }
    jobs.push({file, recipeId});
  }

  const withoutImage = recipes
    .map((r) => r.id)
    .filter((id) => !jobs.some((j) => j.recipeId === id));
  if (withoutImage.length > 0) {
    console.log(
      `No photo supplied for: ${withoutImage.join(", ")} ` +
        "(they keep the tinted placeholder)."
    );
  }

  // 2. Optimize + upload.
  const results: {recipeId: string; url: string; before: number; after: number}[] =
    [];
  for (const {file, recipeId} of jobs) {
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

    const fileName = `${STORAGE_FOLDER}${recipeId}.jpeg`;
    const url =
      `https://storage.googleapis.com/${bucket.name}/${fileName}`;

    console.log(
      `  ${recipeId.padEnd(23)} ${(source.length / 1024).toFixed(0)} KB -> ` +
        `${(optimized.length / 1024).toFixed(0)} KB   ${fileName}`
    );

    if (!DRY_RUN) {
      const storageFile = bucket.file(fileName);
      await storageFile.save(optimized, {
        contentType: "image/jpeg",
        metadata: {metadata: {recipeId}},
      });
      await storageFile.makePublic();
    }

    results.push({
      recipeId,
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
      db.collection("recipes").doc(r.recipeId),
      {
        imageUrl: r.url,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true}
    );
  }
  await batch.commit();
  console.log(`\nLinked ${results.length} image(s) to Firestore.`);

  const byId = new Map(results.map((r) => [r.recipeId, r.url]));
  for (const recipe of recipes) {
    const url = byId.get(recipe.id);
    if (url) recipe.imageUrl = url;
  }
  fs.writeFileSync(DATA_PATH, `${JSON.stringify(recipes, null, 2)}\n`);
  console.log("Updated scripts/data/recipes.json.");
}

main().catch((error) => {
  console.error("upload-recipe-images failed:", error);
  process.exit(1);
});
