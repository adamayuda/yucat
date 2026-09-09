/**
 * Seeds the Firestore `articles` collection from scripts/data/articles.json.
 *
 * Articles are an authored catalogue, not something the server discovers at
 * scan time — so like recipes and the food guide, translations are produced
 * ONCE here rather than lazily per request. Every language is written into the
 * document, and the app reads whichever one it needs with no runtime
 * translation.
 *
 * `articles.json` holds the canonical ENGLISH copy; this script fills in the
 * other five languages. Adding an article means editing that file and
 * re-running.
 *
 * ⚠️ `body` is an ARRAY of paragraphs, and the translator enforces the same
 * count and order. A language whose translation comes back the wrong length is
 * discarded rather than written.
 *
 * ⚠️ The FIRST published article by `order` is what Home's news card features,
 * so `order` is an editorial decision, not just a sort key.
 *
 * ⚠️ The `published == true` + `orderBy('order')` query the app runs needs a
 * composite index on `articles` (`published ASC, order ASC`). Indexes for this
 * project are managed in the console, not in this repo.
 *
 * Re-runs are nearly free: each document stores a SHA-1 of its canonical text,
 * and an article is only re-translated when that hash changes (or with
 * --force-retranslate). That also fixes a gap the product path has, where
 * editing the English leaves stale translations behind forever.
 *
 * Usage:
 *   cd functions
 *   ANTHROPIC_API_KEY=$(npx firebase-tools@latest functions:secrets:access ANTHROPIC_API_KEY) \
 *   npx ts-node scripts/seed-articles.ts --dry-run --only=why-cats-drink-little
 *
 * Firestore auth comes from GOOGLE_APPLICATION_CREDENTIALS (service account) or
 * `gcloud auth application-default login`. Override the project with
 * FIREBASE_PROJECT_ID if it is not yucat-d8fb5.
 *
 * Flags:
 *   --dry-run             Translate and print, write nothing.
 *   --limit=N             Only process the first N articles.
 *   --only=<id>           Only process this article id.
 *   --force-retranslate   Re-translate even when the source hash matches.
 *   --prune               Set published:false on stored articles that are no
 *                         longer in articles.json. Documents are kept, so a
 *                         retired article can be restored by re-adding it.
 */
import * as crypto from "crypto";
import * as fs from "fs";
import * as path from "path";
import * as admin from "firebase-admin";
import {
  Article,
  ArticleText,
  canonicalArticleText,
} from "../src/models/article";
import {translateArticleText} from "../src/services/anthropic.service";
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
const ALL_LANGUAGES = Object.keys(LANGUAGE_NAMES).filter(
  (lang) => lang !== CANONICAL_LANGUAGE
);

/**
 * Languages this run may translate. Defaults to all of them.
 *
 * ⚠️ A language left out is **preserved, not dropped** — its stored text is
 * carried through untouched. That is what makes hand-authored translations
 * safe: `apply-translations.ts` can write a language this script would
 * otherwise overwrite with a machine translation on the next run, because a
 * document with no `translationsSourceHash` re-translates every language.
 */
const TARGET_LANGUAGES = (strFlag("languages") ?? ALL_LANGUAGES.join(","))
  .split(",")
  .map((l) => l.trim())
  .filter((l) => l.length > 0);

const unknownLanguages = TARGET_LANGUAGES.filter(
  (l) => !ALL_LANGUAGES.includes(l)
);
if (unknownLanguages.length > 0) {
  console.error(`Unsupported --languages entry: ${unknownLanguages.join(", ")}`);
  process.exit(1);
}

const DATA_PATH = path.join(__dirname, "data", "articles.json");

/** Stable hash of the translatable text, so edits invalidate translations. */
function sourceHash(text: ArticleText): string {
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
  item: Article;
  translated: string[];
  reused: string[];
  failed: string[];
  skipped: boolean;
}

async function main() {
  admin.initializeApp({projectId: PROJECT_ID});
  const db = admin.firestore();

  // 1. Gather.
  const raw = JSON.parse(fs.readFileSync(DATA_PATH, "utf8")) as Article[];
  let items = raw;
  if (ONLY) items = items.filter((r) => r.id === ONLY);
  if (LIMIT !== undefined) items = items.slice(0, LIMIT);

  if (items.length === 0) {
    console.error("No articles matched the filters.");
    process.exit(1);
  }
  console.log(
    `Project ${PROJECT_ID}: seeding ${items.length} article(s) into ` +
      `${TARGET_LANGUAGES.length} language(s): ${TARGET_LANGUAGES.join(", ")}`
  );

  // 2. Read what is already stored, so unchanged articles cost nothing.
  const existing = new Map<string, Article>();
  await Promise.all(
    items.map(async (r) => {
      const snap = await db.collection("articles").doc(r.id).get();
      if (snap.exists) existing.set(r.id, snap.data() as Article);
    })
  );

  // 3. Translate.
  const outcomes = await mapPool<Article, SeedOutcome>(
    items,
    CONCURRENCY,
    async (item) => {
      const canonical = canonicalArticleText(item);
      const hash = sourceHash(canonical);
      const prior = existing.get(item.id);
      const priorTranslations = prior?.translations ?? {};
      const hashMatches = prior?.translationsSourceHash === hash;

      const translations: Record<string, ArticleText> = {};
      const translated: string[] = [];
      const reused: string[] = [];
      const failed: string[] = [];

      // Languages outside this run keep whatever they already had.
      for (const lang of ALL_LANGUAGES) {
        const cached = priorTranslations[lang];
        if (!TARGET_LANGUAGES.includes(lang)) {
          if (cached) {
            translations[lang] = cached;
            reused.push(lang);
          }
          continue;
        }
        if (cached && hashMatches && !FORCE) {
          translations[lang] = cached;
          reused.push(lang);
          continue;
        }
        const result = await translateArticleText(canonical, lang);
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
        item: {
          ...item,
          translations,
          // Advance the stored hash only when every language succeeded.
          //
          // Writing it unconditionally made the script's own "Re-run to retry"
          // advice false: a plain re-run would see hashMatches plus a cached
          // value, report the language as "reused", and freeze the stale
          // translation until someone remembered --force-retranslate. Keeping
          // the prior hash on a partial failure means the next run retries
          // exactly the languages that failed.
          translationsSourceHash:
            failed.length === 0 &&
            ALL_LANGUAGES.every((l) => translations[l] !== undefined) ?
              hash :
              prior?.translationsSourceHash ?? "",
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
    console.log(`  ${o.item.id.padEnd(26)} ${bits.join("  |  ")}`);
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
    console.log(`\nSample (${sample.item.id} / ${sampleLang}):`);
    console.log(
      JSON.stringify(sample.item.translations?.[sampleLang], null, 2)
    );
  }

  // Orphans: stored articles that articles.json no longer lists. Only
  // meaningful on a full run — with --only/--limit everything else looks
  // orphaned.
  let orphans: string[] = [];
  if (!ONLY && LIMIT === undefined) {
    const stored = await db.collection("articles").get();
    const known = new Set(raw.map((r) => r.id));
    orphans = stored.docs
      .filter((d) => !known.has(d.id) && d.data().published !== false)
      .map((d) => d.id);
    if (orphans.length > 0) {
      console.log(
        `\n${orphans.length} published article(s) not in articles.json: ` +
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
        db.collection("articles").doc(o.item.id),
        {
          ...o.item,
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
        db.collection("articles").doc(id),
        {
          published: false,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true}
      );
    }
    await batch.commit();
    console.log(`Unpublished ${orphans.length} orphaned article(s).`);
  }

  console.log("Done.");
}

main().catch((error) => {
  console.error("seed-articles failed:", error);
  process.exit(1);
});
