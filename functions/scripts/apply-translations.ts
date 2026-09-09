/**
 * Applies hand-authored translations to Firestore, with the same guards the
 * model path enforces.
 *
 *   npx ts-node scripts/apply-translations.ts --kind=articles [--only=<id>]
 *     [--dry-run]
 *
 * Reads `scripts/data/translations/<kind>/<id>.json`, each holding
 * `{ "<lang>": { ...XText } }` for the five non-English languages, validates
 * every block against the canonical English in `scripts/data/<kind>.json`, and
 * writes `translations` + `translationsSourceHash`.
 *
 * ⚠️ This exists because the seeders translate through the Anthropic API and
 * that path can be unavailable (no credit, an outage). It is a **substitute for
 * the model, not for the guards**: an item whose blocks do not match the source
 * structure is rejected here exactly as `translateArticleText` would reject it,
 * because a hand-written translation can drop a bullet just as easily.
 *
 * The hash is only written when all five languages pass, matching the seeders —
 * so a partial run leaves the item retryable instead of frozen.
 *
 * `--languages=fr,es` narrows the run to the languages actually supplied, for
 * when a catalogue is translated one language at a time. Those languages are
 * validated and written as usual, but the hash is still withheld until all five
 * exist on the document, so the seeders keep translating the rest.
 */
import * as admin from "firebase-admin";
import * as crypto from "crypto";
import * as fs from "fs";
import * as path from "path";
import {Article, ArticleText, canonicalArticleText} from "../src/models/article";
import {Recipe, RecipeText, canonicalRecipeText} from "../src/models/recipe";
import {markupSignature} from "../src/services/anthropic.service";

const args = process.argv.slice(2);
const flag = (n: string) =>
  args.find((a) => a.startsWith(`--${n}=`))?.split("=").slice(1).join("=");
const has = (n: string) => args.includes(`--${n}`);

const KIND = flag("kind") ?? "articles";
const ONLY = flag("only");
const DRY_RUN = has("dry-run");
const PROJECT_ID = process.env.GCLOUD_PROJECT ?? "yucat-d8fb5";
const ALL_LANGUAGES = ["es", "fr", "hu", "de", "pt"];
/** Languages this run is expected to supply. Defaults to all five. */
const TARGET_LANGUAGES = (flag("languages") ?? ALL_LANGUAGES.join(","))
  .split(",")
  .map((l) => l.trim())
  .filter((l) => l.length > 0);

const unknown = TARGET_LANGUAGES.filter((l) => !ALL_LANGUAGES.includes(l));
if (unknown.length > 0) {
  console.error(`Unsupported --languages entry: ${unknown.join(", ")}`);
  process.exit(1);
}

if (KIND !== "articles" && KIND !== "recipes") {
  console.error(`Unsupported --kind=${KIND}`);
  process.exit(1);
}

type AnyText = ArticleText | RecipeText;

/** Structural check, block by block. Returns a reason, or null when valid. */
function validate(source: string[], got: unknown, lang: string): string | null {
  if (!Array.isArray(got)) return `${lang}: body is not an array`;
  const body = got as string[];
  if (body.length !== source.length) {
    return `${lang}: block count ${body.length} != ${source.length}`;
  }
  for (let i = 0; i < source.length; i++) {
    if (typeof body[i] !== "string") return `${lang}: block ${i} is not a string`;
    if (source[i].trim().length > 0 && body[i].trim().length === 0) {
      return `${lang}: block ${i} is empty`;
    }
    if (markupSignature(source[i]) !== markupSignature(body[i])) {
      return (
        `${lang}: block ${i} markup mismatch\n` +
        `      expected ${markupSignature(source[i])}\n` +
        `      got      ${markupSignature(body[i])}`
      );
    }
  }
  return null;
}

async function main() {
  admin.initializeApp({projectId: PROJECT_ID});
  const db = admin.firestore();

  const dataPath = path.join(__dirname, "data", `${KIND}.json`);
  const items = JSON.parse(fs.readFileSync(dataPath, "utf8")) as (
    | Article
    | Recipe
  )[];
  const dir = path.join(__dirname, "data", "translations", KIND);
  if (!fs.existsSync(dir)) {
    console.error(`No translations folder at ${dir}`);
    process.exit(1);
  }

  const ok: string[] = [];
  const skipped: string[] = [];
  const rejected: string[] = [];
  const writes: {
    id: string;
    translations: Record<string, AnyText>;
    hash: string | null;
  }[] = [];

  // What each document already carries, so a partial run can tell whether it
  // completes the set. Read once, before any write.
  const stored = new Map<string, Set<string>>();
  for (const item of items) {
    if (ONLY && item.id !== ONLY) continue;
    const snap = await db.collection(KIND).doc(item.id).get();
    stored.set(
      item.id,
      new Set(Object.keys((snap.data()?.translations as object) ?? {}))
    );
  }
  const existingLanguages = (id: string): Set<string> =>
    stored.get(id) ?? new Set<string>();

  for (const item of items) {
    if (ONLY && item.id !== ONLY) continue;
    const file = path.join(dir, `${item.id}.json`);
    if (!fs.existsSync(file)) {
      skipped.push(item.id);
      continue;
    }

    const canonical =
      KIND === "articles" ?
        canonicalArticleText(item as Article) :
        canonicalRecipeText(item as Recipe);
    const supplied = JSON.parse(fs.readFileSync(file, "utf8")) as Record<
      string,
      AnyText
    >;

    const translations: Record<string, AnyText> = {};
    const problems: string[] = [];
    for (const lang of TARGET_LANGUAGES) {
      const t = supplied[lang];
      if (!t) {
        problems.push(`${lang}: missing`);
        continue;
      }
      const reason = validate(canonical.body, (t as AnyText).body, lang);
      if (reason) {
        problems.push(reason);
        continue;
      }
      translations[lang] = t;
    }

    if (problems.length > 0) {
      rejected.push(item.id);
      console.log(`  REJECT ${item.id}`);
      for (const p of problems) console.log(`    ${p}`);
      continue;
    }

    // Same hash the seeders compute, so a later `seed-*.ts` run sees these as
    // current and reuses them instead of paying to translate again.
    //
    // ⚠️ Withheld unless this run completes the set. On a partial run the
    // document gains real translations but stays hash-less, which is what keeps
    // the seeders translating the languages nobody has hand-written yet —
    // writing it early would freeze the item with a hole in it.
    const complete = ALL_LANGUAGES.every(
      (l) => translations[l] !== undefined || existingLanguages(item.id).has(l)
    );
    const hash = complete ?
      crypto.createHash("sha1").update(JSON.stringify(canonical)).digest("hex") :
      null;
    writes.push({id: item.id, translations, hash});
    ok.push(item.id);
  }

  console.log(
    `\n${KIND}: ${ok.length} valid, ${rejected.length} rejected, ` +
      `${skipped.length} without a translation file ` +
      `(languages: ${TARGET_LANGUAGES.join(", ")})`
  );
  const partial = writes.filter((w) => w.hash === null).length;
  if (partial > 0) {
    console.log(
      `  ${partial} item(s) still incomplete — hash withheld so the seeders ` +
        `translate the missing language(s).`
    );
  }
  if (skipped.length > 0 && skipped.length <= 60) {
    console.log(`  awaiting: ${skipped.join(", ")}`);
  }

  if (DRY_RUN) {
    console.log("DRY RUN — nothing written.");
    return;
  }
  if (writes.length === 0) return;

  const batchSize = 400;
  for (let i = 0; i < writes.length; i += batchSize) {
    const batch = db.batch();
    for (const w of writes.slice(i, i + batchSize)) {
      const payload: Record<string, unknown> = {
        translations: w.translations,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      if (w.hash !== null) payload.translationsSourceHash = w.hash;
      batch.set(db.collection(KIND).doc(w.id), payload, {merge: true});
    }
    await batch.commit();
    console.log(`Wrote ${Math.min(i + batchSize, writes.length)}/${writes.length}`);
  }
  console.log("Done.");
}

main().catch((e) => {
  console.error("apply-translations failed:", e);
  process.exit(1);
});
