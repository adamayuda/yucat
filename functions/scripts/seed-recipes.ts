/**
 * Seeds the Firestore `recipes` collection from scripts/data/recipes.json.
 *
 * Recipes are a curated catalogue, not something the server discovers at scan
 * time — so unlike products, translations are produced ONCE here rather than
 * lazily per request. Every language is written into the document, and the app
 * reads whichever one it needs with no runtime translation.
 *
 * `recipes.json` holds the canonical ENGLISH copy; this script fills in the
 * other five languages. Adding recipes means editing that file and re-running.
 *
 * Re-runs are nearly free: each document stores a SHA-1 of its canonical text,
 * and a recipe is only re-translated when that hash changes (or with
 * --force-retranslate). That also fixes a gap the product path has, where
 * editing the English leaves stale translations behind forever.
 *
 * Usage:
 *   cd functions
 *   ANTHROPIC_API_KEY=$(npx firebase-tools@latest functions:secrets:access ANTHROPIC_API_KEY) \
 *   npx ts-node scripts/seed-recipes.ts --dry-run --only=tuna-biscuits
 *
 * Firestore auth comes from GOOGLE_APPLICATION_CREDENTIALS (service account) or
 * `gcloud auth application-default login`. Override the project with
 * FIREBASE_PROJECT_ID if it is not yucat-d8fb5.
 *
 * Flags:
 *   --dry-run             Translate and print, write nothing.
 *   --limit=N             Only process the first N recipes.
 *   --only=<id>           Only process this recipe id.
 *   --force-retranslate   Re-translate even when the source hash matches.
 *   --prune               Set published:false on stored recipes that are no
 *                         longer in recipes.json. Documents are kept, so a
 *                         retired recipe can be restored by re-adding it.
 */
import * as crypto from "crypto";
import * as fs from "fs";
import * as path from "path";
import * as admin from "firebase-admin";
import {
  Recipe,
  RecipeText,
  canonicalRecipeText,
} from "../src/models/recipe";
import {translateRecipeText} from "../src/services/anthropic.service";
import {CANONICAL_LANGUAGE, LANGUAGE_NAMES} from "../src/prompts/languages";

const ANTHROPIC_API_KEY = process.env.ANTHROPIC_API_KEY;
if (!ANTHROPIC_API_KEY) {
  console.error("Missing ANTHROPIC_API_KEY.");
  process.exit(1);
}
// Firestore auth: either a service-account file via
// GOOGLE_APPLICATION_CREDENTIALS, or application-default credentials from
// `gcloud auth application-default login`. ADC carries no project id, so it is
// pinned explicitly.
const PROJECT_ID =
  process.env.FIREBASE_PROJECT_ID ??
  process.env.GOOGLE_CLOUD_PROJECT ??
  "yucat-d8fb5";

const args = process.argv.slice(2);
const DRY_RUN = args.includes("--dry-run");
const FORCE = args.includes("--force-retranslate");
const PRUNE = args.includes("--prune");

function numFlag(name: string): number | undefined {
  const hit = args.find((a) => a.startsWith(`--${name}=`));
  if (!hit) return undefined;
  const value = Number(hit.split("=")[1]);
  return Number.isFinite(value) ? value : undefined;
}
function strFlag(name: string): string | undefined {
  const hit = args.find((a) => a.startsWith(`--${name}=`));
  return hit ? hit.split("=").slice(1).join("=") : undefined;
}

const LIMIT = numFlag("limit");
const ONLY = strFlag("only");
const CONCURRENCY = numFlag("concurrency") ?? 3;

/** Every supported language except the canonical one. */
const TARGET_LANGUAGES = Object.keys(LANGUAGE_NAMES).filter(
  (lang) => lang !== CANONICAL_LANGUAGE
);

const DATA_PATH = path.join(__dirname, "data", "recipes.json");

/** Stable hash of the translatable text, so edits invalidate translations. */
function sourceHash(text: RecipeText): string {
  return crypto
    .createHash("sha1")
    .update(JSON.stringify(text))
    .digest("hex");
}

async function mapPool<T, R>(
  items: T[],
  concurrency: number,
  fn: (item: T, index: number) => Promise<R>
): Promise<R[]> {
  const results: R[] = new Array(items.length);
  let cursor = 0;
  const workers = Array.from(
    {length: Math.min(concurrency, items.length)},
    async () => {
      for (;;) {
        const i = cursor++;
        if (i >= items.length) return;
        results[i] = await fn(items[i], i);
      }
    }
  );
  await Promise.all(workers);
  return results;
}

interface SeedOutcome {
  recipe: Recipe;
  translated: string[];
  reused: string[];
  failed: string[];
  skipped: boolean;
}

async function main() {
  admin.initializeApp({projectId: PROJECT_ID});
  const db = admin.firestore();

  // 1. Gather.
  const raw = JSON.parse(fs.readFileSync(DATA_PATH, "utf8")) as Recipe[];
  let recipes = raw;
  if (ONLY) recipes = recipes.filter((r) => r.id === ONLY);
  if (LIMIT !== undefined) recipes = recipes.slice(0, LIMIT);

  if (recipes.length === 0) {
    console.error("No recipes matched the filters.");
    process.exit(1);
  }
  console.log(
    `Project ${PROJECT_ID}: seeding ${recipes.length} recipe(s) into ` +
      `${TARGET_LANGUAGES.length} language(s): ${TARGET_LANGUAGES.join(", ")}`
  );

  // 2. Read what is already stored, so unchanged recipes cost nothing.
  const existing = new Map<string, Recipe>();
  await Promise.all(
    recipes.map(async (r) => {
      const snap = await db.collection("recipes").doc(r.id).get();
      if (snap.exists) existing.set(r.id, snap.data() as Recipe);
    })
  );

  // 3. Translate.
  const outcomes = await mapPool<Recipe, SeedOutcome>(
    recipes,
    CONCURRENCY,
    async (recipe) => {
      const canonical = canonicalRecipeText(recipe);
      const hash = sourceHash(canonical);
      const prior = existing.get(recipe.id);
      const priorTranslations = prior?.translations ?? {};
      const hashMatches = prior?.translationsSourceHash === hash;

      const translations: Record<string, RecipeText> = {};
      const translated: string[] = [];
      const reused: string[] = [];
      const failed: string[] = [];

      for (const lang of TARGET_LANGUAGES) {
        const cached = priorTranslations[lang];
        if (cached && hashMatches && !FORCE) {
          translations[lang] = cached;
          reused.push(lang);
          continue;
        }
        const result = await translateRecipeText(canonical, lang);
        if (result) {
          translations[lang] = result;
          translated.push(lang);
        } else {
          // Keep whatever we had rather than dropping the language entirely;
          // a stale translation still beats English for that user.
          if (cached) translations[lang] = cached;
          failed.push(lang);
        }
      }

      return {
        recipe: {
          ...recipe,
          translations,
          translationsSourceHash: hash,
        },
        translated,
        reused,
        failed,
        skipped: hashMatches && !FORCE && translated.length === 0,
      };
    }
  );

  // 4. Summary.
  console.log("\n=== Summary ===");
  for (const o of outcomes) {
    const bits = [
      `translated: ${o.translated.join(",") || "-"}`,
      `reused: ${o.reused.join(",") || "-"}`,
      o.failed.length ? `FAILED: ${o.failed.join(",")}` : null,
    ].filter(Boolean);
    console.log(`  ${o.recipe.id.padEnd(24)} ${bits.join("  |  ")}`);
  }
  const totalFailed = outcomes.reduce((n, o) => n + o.failed.length, 0);
  if (totalFailed > 0) {
    console.log(
      `\n${totalFailed} translation(s) failed — those languages fall back to ` +
        "English in the app. Re-run to retry."
    );
  }

  const sample = outcomes[0];
  const sampleLang = sample.translated[0] ?? sample.reused[0];
  if (sampleLang) {
    console.log(`\nSample (${sample.recipe.id} / ${sampleLang}):`);
    console.log(
      JSON.stringify(sample.recipe.translations?.[sampleLang], null, 2)
    );
  }

  // Orphans: stored recipes that recipes.json no longer lists. Only meaningful
  // on a full run — with --only/--limit everything else looks orphaned.
  let orphans: string[] = [];
  if (!ONLY && LIMIT === undefined) {
    const stored = await db.collection("recipes").get();
    const known = new Set(raw.map((r) => r.id));
    orphans = stored.docs
      .filter((d) => !known.has(d.id) && d.data().published !== false)
      .map((d) => d.id);
    if (orphans.length > 0) {
      console.log(
        `\n${orphans.length} published recipe(s) not in recipes.json: ` +
          orphans.join(", ")
      );
      console.log(
        PRUNE ?
          "  --prune set: these will be unpublished (documents kept)." :
          "  Re-run with --prune to unpublish them."
      );
    }
  }

  if (DRY_RUN) {
    console.log("\nDRY RUN — no changes written.");
    return;
  }

  // 5. Write.
  const batchSize = 400;
  for (let i = 0; i < outcomes.length; i += batchSize) {
    const batch = db.batch();
    for (const o of outcomes.slice(i, i + batchSize)) {
      batch.set(
        db.collection("recipes").doc(o.recipe.id),
        {
          ...o.recipe,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true}
      );
    }
    await batch.commit();
    console.log(
      `Wrote ${Math.min(i + batchSize, outcomes.length)}/${outcomes.length}`
    );
  }
  if (PRUNE && orphans.length > 0) {
    const batch = db.batch();
    for (const id of orphans) {
      batch.set(
        db.collection("recipes").doc(id),
        {
          published: false,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true}
      );
    }
    await batch.commit();
    console.log(`Unpublished ${orphans.length} orphaned recipe(s).`);
  }

  console.log("Done.");
}

main().catch((error) => {
  console.error("seed-recipes failed:", error);
  process.exit(1);
});
