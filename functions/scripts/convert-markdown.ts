/**
 * Converts authored Markdown into the seed JSON the Firestore seeders read.
 *
 *   npx ts-node scripts/convert-markdown.ts --source=<dir> [--kind=articles]
 *     [--only=<id>] [--order-base=130] [--dry-run]
 *
 * Authored content lives as one `.md` file per item with YAML front matter, in
 * `<dir>/articles/` and `<dir>/recipes/`. This flattens each file into an entry
 * in `scripts/data/<kind>.json`, merging by `id` so existing entries are
 * updated in place and everything else is left alone.
 *
 * Not compiled and not linted (`tsconfig` covers only `src`), same as every
 * other script here.
 */
import * as fs from "fs";
import * as path from "path";

const args = process.argv.slice(2);
const flag = (name: string): string | undefined =>
  args.find((a) => a.startsWith(`--${name}=`))?.split("=").slice(1).join("=");
const has = (name: string): boolean => args.includes(`--${name}`);

const SOURCE = flag("source");
const KIND = flag("kind") ?? "articles";
const ONLY = flag("only");
const ORDER_BASE = Number(flag("order-base") ?? "0");
const DRY_RUN = has("dry-run");
/**
 * Replace the JSON with exactly the converted items instead of merging by id.
 *
 * Needed whenever the authored folder IS the catalogue: the seeder's `--prune`
 * only unpublishes documents that are absent from the JSON, so a merged file
 * would keep superseded entries alive *and* pay to re-translate them.
 */
const REPLACE = has("replace");

if (!SOURCE) {
  console.error("Missing --source=<dir> (the folder holding articles/ and recipes/)");
  process.exit(1);
}
if (KIND !== "articles" && KIND !== "recipes") {
  console.error(`Unsupported --kind=${KIND}. Use articles or recipes.`);
  process.exit(1);
}

/**
 * Minimal front-matter reader.
 *
 * Deliberately not a YAML dependency: the front matter is flat `key: value`
 * with optionally-quoted scalars, and `scripts/` is unlinted and untyped, so
 * the fewer moving parts the better. It rejects anything it does not
 * understand rather than guessing.
 */
function parseFrontMatter(raw: string): {
  meta: Record<string, string>;
  body: string;
} {
  if (!raw.startsWith("---")) {
    throw new Error("file does not start with front matter");
  }
  const close = raw.indexOf("\n---", 3);
  if (close === -1) throw new Error("unterminated front matter");

  const meta: Record<string, string> = {};
  for (const line of raw.slice(4, close).split("\n")) {
    if (!line.trim() || line.trimStart().startsWith("#")) continue;
    const at = line.indexOf(":");
    if (at === -1) throw new Error(`unparsable front-matter line: ${line}`);
    const key = line.slice(0, at).trim();
    let value = line.slice(at + 1).trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    meta[key] = value;
  }

  const body = raw.slice(raw.indexOf("\n", close + 1) + 1);
  return {meta, body};
}

/**
 * Splits a Markdown document into the block array the client renders and the
 * translator guards.
 *
 * Blank lines are the separator, which keeps every multi-line construct intact:
 * tables, lists and fenced code contain no blank lines, so they survive as one
 * block each. Verified against the whole authored corpus — no table row or list
 * item leaks out of its block.
 *
 * The leading `# H1` is dropped: it repeats the `title`/`name` the detail screen
 * already renders as `displayLg`, and keeping it would print the headline twice.
 */
function toBlocks(body: string): string[] {
  const blocks = body
    .split(/\n\s*\n/)
    .map((b) => b.trim())
    .filter((b) => b.length > 0);
  if (blocks.length > 0 && /^#\s/.test(blocks[0])) blocks.shift();
  return blocks;
}

function requireField(
  meta: Record<string, string>,
  key: string,
  file: string
): string {
  const value = meta[key];
  if (value === undefined || value === "") {
    throw new Error(`${file}: missing front-matter field "${key}"`);
  }
  return value;
}

type Entry = Record<string, unknown>;

function buildArticle(
  meta: Record<string, string>,
  blocks: string[],
  file: string
): Entry {
  const category = requireField(meta, "category", file);
  if (!["nutrition", "health", "behaviour", "other"].includes(category)) {
    throw new Error(`${file}: unknown category "${category}"`);
  }
  // Key order matches the existing entries so the JSON stays diff-friendly.
  return {
    id: requireField(meta, "id", file),
    category,
    readMinutes: Number(requireField(meta, "readMinutes", file)),
    imageUrl: meta.image || null,
    published: meta.published !== "false",
    // Offset so new items append rather than displacing the existing catalogue.
    // ⚠️ Article `order` is editorial: the lowest-ordered published article is
    // what Home's news card features, so an un-offset import would silently
    // take over the front page.
    order: Number(requireField(meta, "order", file)) + ORDER_BASE,
    title: requireField(meta, "title", file),
    excerpt: requireField(meta, "excerpt", file),
    body: blocks,
  };
}

function buildRecipe(
  meta: Record<string, string>,
  blocks: string[],
  file: string
): Entry {
  const category = requireField(meta, "category", file);
  if (!["biscuits", "cakes", "frozen", "meals", "other"].includes(category)) {
    throw new Error(`${file}: unknown category "${category}"`);
  }
  const difficulty = meta.difficulty ?? "easy";
  if (!["easy", "medium", "hard"].includes(difficulty)) {
    throw new Error(`${file}: unknown difficulty "${difficulty}"`);
  }
  // `ingredients`, `steps` and `tip` stay in the shape the model expects but
  // are left empty: authored recipes express all of that as prose inside
  // `body` (a bolded quantity phrase reads better than a {name, quantity}
  // split, and Storage/Variations/Cautions have no typed home at all). The
  // detail screen renders `body` when it is non-empty and falls back to the
  // structured fields otherwise, so old seeded recipes keep working.
  return {
    id: requireField(meta, "id", file),
    category,
    prepMinutes: Number(requireField(meta, "prepMinutes", file)),
    requiresFreezing: meta.requiresFreezing === "true",
    difficulty,
    compatibility: meta.compatibility ?? "compatible",
    imageUrl: meta.image || null,
    published: meta.published !== "false",
    order: Number(requireField(meta, "order", file)) + ORDER_BASE,
    name: requireField(meta, "name", file),
    description: requireField(meta, "description", file),
    ingredients: [],
    steps: [],
    tip: null,
    body: blocks,
  };
}

function main() {
  const dir = path.join(SOURCE!, KIND);
  if (!fs.existsSync(dir)) {
    console.error(`No ${KIND}/ folder under ${SOURCE}`);
    process.exit(1);
  }

  const files = fs
    .readdirSync(dir)
    .filter((n) => n.endsWith(".md"))
    .sort();

  const built: Entry[] = [];
  for (const name of files) {
    const raw = fs.readFileSync(path.join(dir, name), "utf8");
    const {meta, body} = parseFrontMatter(raw);
    if (ONLY && meta.id !== ONLY) continue;

    const blocks = toBlocks(body);
    built.push(
      KIND === "articles" ?
        buildArticle(meta, blocks, name) :
        buildRecipe(meta, blocks, name)
    );
    console.log(
      `  ${name.padEnd(38)} blocks=${String(blocks.length).padStart(3)}  ` +
        `order=${built[built.length - 1].order}`
    );
  }

  if (built.length === 0) {
    console.error(ONLY ? `No file with id "${ONLY}"` : "Nothing to convert");
    process.exit(1);
  }

  const target = path.join(__dirname, "data", `${KIND}.json`);
  const existing: Entry[] = JSON.parse(fs.readFileSync(target, "utf8"));
  const priorById = new Map(existing.map((e) => [e.id as string, e]));
  const byId = REPLACE ? new Map<string, Entry>() : new Map(priorById);

  let added = 0;
  let updated = 0;
  for (const entry of built) {
    const id = entry.id as string;
    // Preserve any field the JSON carries that Markdown does not author — a
    // hosted imageUrl written back by the image-upload script. Looked up in
    // `priorById` so this survives --replace too.
    const prior = priorById.get(id);
    if (prior) {
      byId.set(id, {
        ...prior,
        ...entry,
        imageUrl: entry.imageUrl ?? prior.imageUrl,
      });
      updated++;
    } else {
      byId.set(id, entry);
      added++;
    }
  }

  if (REPLACE) {
    const dropped = [...priorById.keys()].filter(
      (id) => !byId.has(id)
    );
    if (dropped.length > 0) {
      console.log(
        `\n--replace: ${dropped.length} entr(ies) removed from ${KIND}.json:`
      );
      console.log(`  ${dropped.join(", ")}`);
      console.log(
        "  Seed with --prune to set published:false on them in Firestore."
      );
    }
  }

  const merged = [...byId.values()].sort(
    (a, b) => (a.order as number) - (b.order as number)
  );

  console.log(
    `\n${KIND}: +${added} added, ${updated} updated, ${merged.length} total`
  );

  if (DRY_RUN) {
    console.log("(dry run — nothing written)");
    return;
  }
  fs.writeFileSync(target, `${JSON.stringify(merged, null, 2)}\n`, "utf8");
  console.log(`Wrote ${path.relative(process.cwd(), target)}`);
}

main();
