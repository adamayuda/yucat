# Cat litter

The second scannable category. One camera, two outcomes: the backend classifies a
photo as cat food, cat litter, or neither, and the client routes accordingly.

This is the source of truth for the litter feature — the attribute model, the per-cat
safety rules, the stores, and the decisions that look arbitrary from the code alone.
The backend half is documented in `functions/CLAUDE.md` §3b.

---

## 1. What it is

A litter scan produces a **universal 0-100 quality score** plus a set of factual
attributes, and — separately — a short list of per-cat safety notes.

**There is deliberately no per-cat score and no breed dimension.** Breed does not change
what makes a litter good; a Maine Coon and a Siamese want the same thing from a litter
box. What *does* vary is a handful of safety and monitoring facts driven by age, health
conditions and coat length, and those are surfaced as flags rather than folded into a
number. This is the one place in the app where the score is the same for every user.

---

## 2. File map

```
lib/features/
├── litter/                          domain + data only (no presentation)
│   ├── domain/entities/litter_entity.dart      LitterEntity + the 3 attribute enums
│   └── data/mappers/litter_to_domain_mapper.dart
└── litter_detail/
    ├── presentation/
    │   ├── litter_detail_page.dart             the result screen
    │   ├── bloc/                               LitterDetailBloc (saved-state only)
    │   ├── models/
    │   │   ├── litter_display_model.dart
    │   │   └── litter_display_codec.dart       ← the ONE codec, shared by both stores
    │   ├── mappers/litter_entity_to_model_mapper.dart
    │   ├── utils/
    │   │   ├── cat_litter_safety.dart          the per-cat rules (§4)
    │   │   ├── litter_flag_copy.dart           flag code → localized copy
    │   │   ├── litter_attribute_labels.dart    enum → chip label + tone
    │   │   └── litter_additive_labels.dart     additive string → localized label
    │   └── widgets/                            hero, score, attributes, cat notes, list row
    └── README.md                               this file
```

Storage lives with its food siblings rather than here — see §5.

---

## 3. The attribute model, and the `unknown` contract

`LitterEntity` carries no macros. Instead:

| Field | Type |
|---|---|
| `material` | `LitterMaterial` — bentonite / non-clumping clay / silica / corn / wheat / tofu / paper / wood / walnut / grass / mixed / other |
| `clumping`, `scented`, `flushable`, `biodegradable` | `LitterTristate` — yes / no / **unknown** |
| `dustLevel`, `trackingLevel`, `odorControl` | `LitterLevel` — low / moderate / high / **unknown** |
| `additives` | `List<String>` — e.g. "Baking soda", "Activated charcoal" |

⚠️ **`unknown` is a first-class value, not a null to paper over.** Most of these are not
printed on every pack. An `unknown` attribute renders **no chip** and fires **no flag** —
the prompt explicitly tells the model to prefer `unknown` over an inference, including
"do not infer dust from the material". Anything that makes `unknown` behave like a
default value (e.g. treating it as `no`) silently converts "we don't know" into a claim.

`LitterMaterial.wire` mirrors the backend enum in `functions/src/models/litter.ts`, and
the tool schema's `enum` lists are built from those same constants. An unrecognized wire
value degrades to `other` rather than throwing.

**`score == 0` is the "no data found" sentinel**, exactly as for food — not a grade. It
drives `LitterDisplayModel.dataUnavailable`, which hides the score ring, the attributes
card and the per-cat card, and swaps in the neutral "we couldn't find the details yet"
copy. The scoring rubric says so explicitly: any litter the model could characterize
must score at least 1.

---

## 4. The per-cat safety rules

`utils/cat_litter_safety.dart` → `litterFlagsForCat(cat, litter)` returns
`List<LitterCatFlag>` sorted most-severe first (`warning` → `caution` → `good`). It emits
**codes**, never strings; `utils/litter_flag_copy.dart` is the single place copy is wired
up, which keeps the engine free of the six ARB files.

| Trigger | Condition | Severity |
|---|---|---|
| Kitten + bentonite clay | `clumping != no` | warning |
| Kitten + silica crystals | — | warning |
| Urinary / kidney / diabetes | `clumping == yes` | good |
| Urinary / kidney / diabetes | `clumping == no` | caution |
| Skin allergies | `scented == yes` | caution |
| Skin allergies | `dustLevel == high` | caution |
| Senior or joint issues | coarse substrate (silica, wood) | caution |
| Senior or joint issues | fine sand-like grain | good |
| Long coat | `trackingLevel == high` | caution |

Two things worth knowing:

- **Every rule reads a structured enum, never the prose.** This is the deliberate
  difference from `cat_product_assessment.dart`, which keyword-scans `pros + cons + name
  + brand` against English needles and consequently has documented false positives
  (`'fish'` inside `'fish oil'`, `'light'` inside `'delight'`). None of that class of bug
  can occur here — and the canonical-English constraint that binds the food engine does
  **not** apply to litter text.
- **Age falls back to months only when `ageGroup` is absent** (`< 12` kitten, `>= 120`
  senior — the same thresholds as `cat_create`). An explicitly-set `ageGroup` always wins.

The card renders every cat at once rather than behind a selector: there is no per-cat
score to switch between, and in a multi-cat home the kitten's warning matters while
you're reading the senior's note.

---

## 5. Storage

Litter has its **own** stores, not a discriminated list inside the food ones:

| | Key | Cap |
|---|---|---|
| Saved litters | `saved_litters_v1` | — |
| Litter history | `litter_history_v1` | 50 |

Identity is `${brand}__${name}` lowercased/trimmed, in its own key space. History is a
list of **distinct litters, not a scan log** — rescanning the same bag replaces the prior
entry rather than appending, and there is no timestamp. The write happens in `HomeBloc`
after a successful scan.

The repositories live under `features/saved_products/` and `features/scan_history/`
alongside their food siblings, because they back the same two screens. Separate stores
rather than one heterogeneous list, because the two models share nothing beyond
name/brand/score and a merged list would push a `switch` into every consumer.

⚠️ **Both stores share one codec** (`models/litter_display_codec.dart`). The food side
hand-rolls the same 18-field codec twice in two unrelated features, which is exactly how
`dataUnavailable` came to be unpersisted in both. Do not fork it. Enums serialize by
their stable `wire` string, never by index, so reordering an enum cannot silently
reinterpret saved rows.

---

## 6. Where litter shows up

| Surface | Behaviour |
|---|---|
| Home scan | Auto-detected; pushes `LitterDetailRoute` |
| Scan history | "Litters" subsection; page title is always the page's own |
| Saved products | Same |
| Profile library rows | Counts and cover thumbs **sum both** categories |
| Onboarding current-food | A litter photo is treated as an unrecognized scan (§8) |
| Search tab | Food only (§8) |
| Home saved preview | Food only (§8) |

---

## 7. Analytics

Four events, all via `AnalyticsEvents` constants — not literals:

| Event | Properties |
|---|---|
| `Litter Selected` | `litter_name`, `litter_brand`, `litter_material`, `source` |
| `Litter Detail Viewed` | `litter_name`, `litter_brand`, `litter_material` |
| `Litter Saved` / `Litter Unsaved` | `litter_name`, `litter_brand` |

⚠️ `Product Image Captured` and `Product Image Scan Failed` are **shared with food** —
the camera is one entry point, so only the outcome events split by category. A scan
funnel built on the capture event counts both. `total_scans` likewise counts both.

---

## 8. Known gaps

Accepted, documented so they aren't rediscovered as bugs:

- **The `litters` Algolia index must be configured before the cache works at all.**
  `functions/scripts/configure-litter-index.ts`. `searchLitterByNameV2` soft-filters on
  `brand`, and Algolia rejects a filter on an undeclared facet — until the script runs,
  every lookup errors, is swallowed, and every scan pays for a full analysis.
- **Additive names are localized client-side**, from a fixed list of the ones that
  recur. The backend returns them in English and they are not part of the translated
  `LitterText` payload. An unusual additive renders in English rather than vanishing.
- **Litter images are hosted in the `products/` Storage folder** under a `lit-` prefixed
  key. Harmless, but `products/{key}.jpeg` is not a category-scoped convention.
- **No maintenance scripts.** `rescore-products.ts` and `backfill-images.ts` only touch
  `products2`, so a litter-rubric change cannot be back-applied and an imageless litter
  row only heals on a rescan.
- **Onboarding shows a generic "not found"** for a litter photo. That beat asks what you
  feed your cat, so only a food scan can answer it — but the copy doesn't say so.
- **No litter in Search**, and Home's saved preview is food-only while Profile's counts
  include litter.
- `LitterDetailPage` borrows `ProductDetailSkeleton`, whose bones are shaped for a
  nutrition grid. It flashes for one frame.

---

## 9. See also

- `functions/CLAUDE.md` §3b — the backend pipeline, the rubric, the tool schema
- `functions/src/prompts/litter-rubric.ts` — the single source of scoring truth
- `docs/analytics.md` — the full event catalog
- `lib/features/product_detail/presentation/utils/cat_product_assessment.dart` — the food
  rules engine this one deliberately does not resemble
