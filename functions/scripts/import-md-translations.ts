/**
 * Imports a hand-authored translated catalogue (Markdown) into the
 * `scripts/data/translations/<kind>/<id>.json` files that
 * `apply-translations.ts` reads.
 *
 * Translations arrive the same way the English does — one `.md` per item, with
 * the same front matter and the same body — under a per-language folder:
 *
 *   <source>/articles/*.md
 *   <source>/recipes/*.md          (--lang=fr)
 *
 * Two things make this more than a file format conversion:
 *
 *  1. **Block splitting must match the English exactly.** The translation
 *     guards compare block counts and per-block `markupSignature`s, so this
 *     reuses `lib/markdown.ts` rather than re-implementing the split.
 *  2. **Image URLs must be mapped.** `markupSignature` fingerprints every link
 *     target, so a translation still pointing at the original third-party
 *     photo fails the guard on every image block. `image-url-map.json` (written
 *     by `rehost-content-images.ts`) is applied to the source text first.
 *
 * Existing languages in a translations file are preserved — this merges one
 * language key in rather than replacing the file.
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/import-md-translations.ts \
 *     --source="$HOME/Downloads/fr" --lang=fr --dry-run
 *
 * Then apply them:
 *   npx ts-node scripts/apply-translations.ts --kind=articles --languages=fr
 */
import * as fs from "fs";
import * as path from "path";
import {parseFrontMatter, toBlocks} from "./lib/markdown";
import {markupSignature} from "../src/services/anthropic.service";

const KINDS = ["articles", "recipes"] as const;
type Kind = (typeof KINDS)[number];

const args = process.argv.slice(2);
const flag = (name: string): string | undefined =>
  args.find((a) => a.startsWith(`--${name}=`))?.split("=").slice(1).join("=");
const DRY_RUN = args.includes("--dry-run");

const SOURCE = flag("source");
const LANG = flag("lang");
const KIND_FILTER = flag("kind");
const ONLY = flag("only");

if (!SOURCE || !LANG) {
  console.error(
    "Usage: --source=<dir holding articles/ and recipes/> --lang=<code> " +
      "[--kind=] [--only=] [--dry-run]"
  );
  process.exit(1);
}
if (LANG === "en") {
  console.error("English is the canonical flat fields, not a translation.");
  process.exit(1);
}

const DATA_DIR = path.join(__dirname, "data");
const MAP_PATH = path.join(DATA_DIR, "image-url-map.json");

/** Plain string replace — URLs carry `?` and `&`, so never build a RegExp. */
function applyMap(text: string, map: Record<string, string>): string {
  let out = text;
  for (const [from, to] of Object.entries(map)) out = out.split(from).join(to);
  return out;
}

/** The same structural check `apply-translations.ts` and the model path run. */
function validate(source: string[], body: string[]): string[] {
  const problems: string[] = [];
  if (body.length !== source.length) {
    return [`block count ${body.length} != ${source.length}`];
  }
  for (let i = 0; i < source.length; i++) {
    if (source[i].trim().length > 0 && body[i].trim().length === 0) {
      problems.push(`block ${i} is empty`);
      continue;
    }
    if (markupSignature(source[i]) !== markupSignature(body[i])) {
      problems.push(
        `block ${i} markup mismatch\n      expected ${markupSignature(source[i])}` +
          `\n      got      ${markupSignature(body[i])}`
      );
    }
  }
  return problems;
}

function main() {
  const map: Record<string, string> = fs.existsSync(MAP_PATH) ?
    JSON.parse(fs.readFileSync(MAP_PATH, "utf8")) :
    {};
  if (Object.keys(map).length === 0) {
    console.log(
      "No image-url-map.json — source URLs are used as authored. " +
        "If the English was re-hosted, every image block will fail the guard."
    );
  }

  let written = 0;
  let rejected = 0;

  for (const kind of KINDS as readonly Kind[]) {
    if (KIND_FILTER && KIND_FILTER !== kind) continue;
    const dir = path.join(SOURCE!, kind);
    if (!fs.existsSync(dir)) {
      console.log(`\n${kind}: no ${kind}/ folder under ${SOURCE} — skipped`);
      continue;
    }

    const english = JSON.parse(
      fs.readFileSync(path.join(DATA_DIR, `${kind}.json`), "utf8")
    ) as Record<string, any>[];
    const byId = new Map(english.map((e) => [e.id as string, e]));

    const outDir = path.join(DATA_DIR, "translations", kind);
    const files = fs.readdirSync(dir).filter((n) => n.endsWith(".md")).sort();
    console.log(`\n=== ${kind} (${files.length} file(s)) ===`);

    for (const name of files) {
      const id = path.parse(name).name.normalize("NFC");
      if (ONLY && id !== ONLY) continue;

      const source = byId.get(id);
      if (!source) {
        console.log(`  ${id.padEnd(42)} NOT IN ${kind}.json — skipped`);
        rejected += 1;
        continue;
      }

      const raw = applyMap(fs.readFileSync(path.join(dir, name), "utf8"), map);
      const {meta, body} = parseFrontMatter(raw);
      const blocks = toBlocks(body);

      const problems = validate(source.body as string[], blocks);
      if (problems.length > 0) {
        console.log(`  ${id.padEnd(42)} REJECT`);
        for (const p of problems.slice(0, 3)) console.log(`    ${p}`);
        if (problems.length > 3) {
          console.log(`    ...and ${problems.length - 3} more`);
        }
        rejected += 1;
        continue;
      }

      // `ingredients`, `steps` and `tip` mirror the English: authored recipes
      // put all of that in `body` as prose, so the typed fields stay empty on
      // both sides rather than inventing content only one language has.
      const text = kind === "articles" ?
        {
          title: meta.title,
          excerpt: meta.excerpt,
          body: blocks,
        } :
        {
          name: meta.name,
          description: meta.description,
          ingredients: [],
          steps: [],
          tip: null,
          body: blocks,
        };

      const missing = Object.entries(text)
        .filter(([, v]) => v === undefined || v === "")
        .map(([k]) => k);
      if (missing.length > 0) {
        console.log(
          `  ${id.padEnd(42)} REJECT — missing front matter: ${missing.join(", ")}`
        );
        rejected += 1;
        continue;
      }

      const outFile = path.join(outDir, `${id}.json`);
      const existing: Record<string, unknown> = fs.existsSync(outFile) ?
        JSON.parse(fs.readFileSync(outFile, "utf8")) :
        {};
      const had = Object.keys(existing).sort();
      existing[LANG!] = text;

      console.log(
        `  ${id.padEnd(42)} ok  ${blocks.length} blocks  ` +
          `[${had.length > 0 ? `${had.join(",")} + ` : ""}${LANG}]`
      );

      if (!DRY_RUN) {
        fs.mkdirSync(outDir, {recursive: true});
        const ordered = Object.fromEntries(
          Object.keys(existing).sort().map((k) => [k, existing[k]])
        );
        fs.writeFileSync(outFile, `${JSON.stringify(ordered, null, 2)}\n`);
      }
      written += 1;
    }
  }

  console.log(`\n${written} valid, ${rejected} rejected.`);
  if (DRY_RUN) {
    console.log("DRY RUN — no translations file written.");
    return;
  }
  console.log(
    `\nNext: npx ts-node scripts/apply-translations.ts --kind=<kind> --languages=${LANG}`
  );
}

main();
