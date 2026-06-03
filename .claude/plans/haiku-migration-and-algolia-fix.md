# Co-locate Firebase Functions inside `yucat`, build a new Haiku 4.5 image-recognition function, and fix Algolia search relevance

## Context

Two changes are bundled here because they touch the same surface:

1. **Repo consolidation** — the user wants to retire the separate `/Users/adam.ayuda/Projects/yucat-api` repo and put the Firebase Function inside the Flutter app repo at `/Users/adam.ayuda/Projects/yucat/functions/`. Same Firebase project (`yucat-d8fb5`), one repo, one deploy.
2. **New `fetchProductByImage` implementation built on Claude Haiku 4.5** + native `web_search` tool, not a port of the existing Gemini code. Goal: speed (P50 cache-miss <15s vs current ~22s) and JSON reliability via tool-use forced output. The barcode flow is **not** ported — it's dead on the client and never gets re-introduced.
3. **Algolia search relevance fix** — the user reports correct products aren't being found even when they exist. After reading both the backend `searchProductByName` and the Flutter datasource, there are concrete code- and index-settings-level bugs causing this. Fixed in the same pass since the new function reuses the same index.

The Flutter app keeps its current call site (`fetchProductByImage` Callable Function name unchanged) — only the implementation and host repo change.

**Locked-in decisions**:
- Model: `claude-haiku-4-5-20251001` with `web_search_20250305` tool, `max_uses: 3`
- Primary goal: speed
- Co-locate in `yucat/functions/`; do not keep `yucat-api` as a parallel deploy
- Drop `fetchProductByBarcode` entirely (backend + Flutter)
- Algolia index name stays `products2` (don't reindex, just fix settings + matching code)

## Phase 1 — Set up `functions/` inside yucat

### 1.1 Create the directory and Firebase wiring
- Create `/Users/adam.ayuda/Projects/yucat/functions/` with TypeScript scaffolding (Node 22, same versions yucat-api uses)
- Create `/Users/adam.ayuda/Projects/yucat/.firebaserc` with `{"projects": {"default": "yucat-d8fb5"}}` to match yucat-api's project
- **Extend** existing `/Users/adam.ayuda/Projects/yucat/firebase.json` — it currently only has the FlutterFire `flutter` block. Add a sibling `functions` block (do **not** overwrite the file):
  ```json
  {
    "flutter": { ... existing FlutterFire config ... },
    "functions": [{
      "source": "functions",
      "codebase": "default",
      "ignore": ["node_modules", ".git", "firebase-debug.log", "firebase-debug.*.log", "*.local"],
      "predeploy": [
        "npm --prefix \"$RESOURCE_DIR\" run lint",
        "npm --prefix \"$RESOURCE_DIR\" run build"
      ]
    }]
  }
  ```
- Add `functions/node_modules`, `functions/lib`, `functions/.env*` to `/Users/adam.ayuda/Projects/yucat/.gitignore`

### 1.2 functions/package.json
Mirror what yucat-api needs but trim unused. Required deps:
- `@anthropic-ai/sdk` (latest) — Haiku + web_search
- `algoliasearch` ^5.46.2 — same version yucat-api uses
- `firebase-admin` ^12.6.0
- `firebase-functions` ^6.0.1
- `sharp` ^0.34.5 — product image optimization
- `mime` ^4.1.0

**Drop entirely**: `@google/genai`, `@google/generative-ai`, `cheerio`, `express` (none are reused). Drop SerpAPI dependencies — the new flow uses Anthropic's `web_search` exclusively.

### 1.3 Files to port from yucat-api (selectively)

Port and adapt — don't blind-copy:

| yucat-api source | yucat/functions destination | Action |
|---|---|---|
| `src/config/index.ts` | `functions/src/config/index.ts` | Copy. **Replace `gemini` block with `anthropic` block** (apiKey from env, model `claude-haiku-4-5-20251001`, `maxWebSearches: 3`). **Drop `serpapi` block.** Keep `algolia` and `functions` blocks. |
| `src/constants/index.ts` | `functions/src/constants/index.ts` | Copy `RETRY_CONFIG` and any non-Gemini-specific constants. |
| `src/models/product.ts` | `functions/src/models/product.ts` | Copy as-is. |
| `src/services/algolia.service.ts` | `functions/src/services/algolia.service.ts` | Copy + apply Phase 3 fixes (see below). |
| `src/services/image.service.ts` | `functions/src/services/image.service.ts` | Copy. Used by image processing. |
| `src/index.ts:97-232` (`processProductImage`, `uploadUserPhoto`, `validateImageUrl`, image-fetch helpers) | `functions/src/utils/image-helpers.ts` (new) | Extract these helpers from `index.ts` into their own file for cleanliness. **Remove the SerpAPI thumbnail fallback path (line 134-156)** — Haiku's web_search returns a URL we can use directly; if invalid, just return empty `imageUrl` (the Flutter UI tolerates this). |
| `src/index.ts:logScanRequest` (Firestore write) | `functions/src/utils/scan-log.ts` (new) | Extract. |
| `src/prompts/identify-product-image.ts` | `functions/src/prompts/identify-product.ts` | Copy + tighten for Haiku tool-use (see Phase 2). |
| `src/prompts/analyze-product-image.ts` | `functions/src/prompts/analyze-product.ts` | Copy + tighten for Haiku tool-use + web_search bound. |

**Do not port**:
- `src/services/gemini.service.ts` — entire file replaced by Anthropic service
- `src/services/search.service.ts` — SerpAPI-only, gone
- `src/prompts/analyze-shopping-data.ts` — barcode-only, gone
- `src/utils/url-fetcher.ts` — depends on search.service, gone
- `src/utils/response-parser.ts` — Haiku tool-use returns structured input; no JSON parsing needed
- `fetchProductByBarcode` export (yucat-api `src/index.ts:239-358`) — gone

### 1.4 New `functions/src/index.ts`
Single export: `fetchProductByImage`. Structure mirrors yucat-api's flow at `src/index.ts:365-529` but with the new Anthropic service and improved cache-search:

```
1. Validate input (image base64, mimeType)
2. Kick off uploadUserPhoto in background (non-blocking)
3. identifyProductFromImage(image, mimeType) — Haiku vision, no tools, ~2-4s
4. If null → return "couldn't identify cat food"
5. searchProductByNameV2(brand, name, foodType) — improved Algolia search (see Phase 3)
6. If hit → return cached product (~3-5s total)
7. analyzeProductImage(image, mimeType) — Haiku + web_search tool, ~10-15s
8. processProductImage(...) — download/optimize/upload to Firebase Storage
9. cacheProduct(...) — write to Algolia
10. logScanRequest(...) — write to Firestore /scans
11. Return Product
```

Response shape stays **identical** to current — Flutter's `fetchProductByImage` in `lib/features/product/data/datasources/product_remote_datasource.dart:37-65` reads `result.data` as a generic map, so any field changes would propagate to the Product mapper. To avoid client breakage:
- Keep `geminiResponse` field name (don't rename to `claudeResponse`) — Flutter currently doesn't read it but other code paths might log it
- Keep `product` shape exactly as the existing `Product` model in yucat-api `src/models/product.ts`

## Phase 2 — Anthropic service implementation

### 2.1 `functions/src/services/anthropic.service.ts`
Two exports, lazy-init singleton, retry helper. Pattern matches yucat-api's `gemini.service.ts:24-34, 43-95, 107-162` for consistency.

**`identifyProductFromImage(base64, mimeType)`**:
- Model: Haiku 4.5
- `max_tokens: 256` — enough for one tool call
- `temperature: 0.1` — match current Gemini setting (deterministic)
- Tools: `[submit_identification, not_cat_food]` with `tool_choice: {type: "any"}`
  - `submit_identification` schema: `{brand: string, name: string, foodType: enum}`
  - `not_cat_food` schema: `{}` — called when image isn't cat food
- Vision input: `[{type: "image", source: {type: "base64", media_type, data}}, {type: "text", text: prompt}]`
- Read `tool_use.name` to dispatch — return `null` if `not_cat_food`, else return parsed input
- **No web_search tool** in this step — speed matters and packaging text is enough

**`analyzeProductImage(base64, mimeType)`**:
- Model: Haiku 4.5
- `max_tokens: 4096` — accommodates web_search round-trips + final answer
- `temperature: 0.1`
- Tools: `[{type: "web_search_20250305", name: "web_search", max_uses: 3}, submit_product]`
- `tool_choice: {type: "auto"}` — model decides when to search vs submit
- System prompt enforces: "Do at most 3 web searches. After collecting nutrition data, call `submit_product` with the final answer. If you cannot find guaranteed-analysis data, call `submit_product` with empty `pros` and `cons` arrays — never invent values."
- **Prompt caching**: add `cache_control: {type: "ephemeral"}` to the system prompt block. The system prompt + tool schemas total ~1500 tokens of mostly-static content; on warm calls (after first scan in a 5-min window) this cuts input tokens ~85%.
- `submit_product` tool schema (forces structured output, eliminates JSON parsing failures):
  ```ts
  {
    name: "submit_product",
    description: "Submit the final cat food product analysis",
    input_schema: {
      type: "object",
      required: ["name", "brand", "foodType", "protein", "fat", "moisture",
                 "carbs", "fiber", "ash", "imageUrl", "score", "pros", "cons"],
      properties: {
        name: {type: "string"},
        brand: {type: "string"},
        foodType: {type: "string", enum: ["wet", "dry", "treat", "topper", "supplement"]},
        protein: {type: "number", minimum: 0, maximum: 100},
        fat: {type: "number", minimum: 0, maximum: 100},
        moisture: {type: "number", minimum: 0, maximum: 100},
        carbs: {type: "number", minimum: 0, maximum: 100},
        fiber: {type: "number", minimum: 0, maximum: 100},
        ash: {type: "number", minimum: 0, maximum: 100},
        imageUrl: {type: "string"},
        score: {type: "number", minimum: 0, maximum: 100},
        pros: {type: "array", items: {type: "string"}, maxItems: 3},
        cons: {type: "array", items: {type: "string"}, maxItems: 3},
      },
    },
  }
  ```
- Tool-use loop: iterate calling `messages.create` with growing message history until model emits a `submit_product` `tool_use` block. The Anthropic SDK's `client.messages.create` returns `stop_reason: "tool_use"` when the model wants a tool — for `web_search`, the SDK handles it server-side (no manual round-trip needed because it's a server-side tool); for `submit_product` we extract input and stop. **Verify this assumption when implementing** — if `web_search` requires client-side handling in the SDK version we install, we add a manual loop.

### 2.2 ANTHROPIC_API_KEY setup
- Add to `functions/.env` for local emulator (gitignored)
- For production: `firebase functions:secrets:set ANTHROPIC_API_KEY` then declare `secrets: ["ANTHROPIC_API_KEY"]` in the `onCall` runtime options
- Document in yucat root `CLAUDE.md` that this secret is required

## Phase 3 — Algolia search relevance fix

The user's reported "correct products not found" issue is caused by 6 specific defects. Fix code first, then index settings.

### 3.1 Code: rewrite `searchProductByName` (`functions/src/services/algolia.service.ts`)

Current bugs (from yucat-api `algolia.service.ts:121-207`):
1. Only inspects `hits[0]` even though `hitsPerPage: 3` — misses correct match at index 1/2
2. 80% threshold too strict + asymmetric `.includes()` (`"treats".includes("treat")` works, reverse fails)
3. No brand verification — can return a different brand whose name overlaps
4. Word filter `length > 2` arbitrary — keeps "the"/"and" out but loses "in" which matters in "in gravy"
5. Naive `\s+` tokenization — misses hyphens, commas, ampersands
6. No accent/case normalization beyond `toLowerCase`

Fixed version (`searchProductByNameV2`):
- Send query as **just `name`** (not `${brand} ${name}`); add brand as an `optionalFilters: ["brand:${brand}"]` boost — Algolia weights it as a soft preference, not a hard filter
- Hard filter on `foodType` if provided (current behavior, keep it)
- `hitsPerPage: 5` (up from 3)
- **Iterate all hits**, score each:
  - `brandMatch` (case-insensitive equality after stripping accents) — required, hits without it filtered out
  - `wordOverlap` — bidirectional substring + Levenshtein-1 fuzzy match (use `fast-levenshtein` or hand-rolled), normalized 0-1
  - Combined score: `0.5 * brandMatch + 0.5 * wordOverlap`
  - Threshold: ≥0.6 to accept (down from 0.8 effective)
- Tokenize with `/[\s\-,&/]+/` not `/\s+/`
- Strip diacritics with `String.prototype.normalize('NFD').replace(/[̀-ͯ]/g, '')`
- Pick highest-scoring hit ≥ threshold; return null if none qualify
- Log the full ranked list at info level so we can debug future misses from Cloud Logging

**Optional Haiku-assisted match verification** (recommended, included in the plan):
After Algolia returns its top 3-5 candidates, send a tiny Haiku call: "Here are 5 candidate products and the scanned packaging shows brand=X, name=Y. Which (if any) is the same product? Reply with index 0-4 or 'none'." Cost: ~$0.0001 per call, latency ~600ms. Eliminates false negatives from string-matching edge cases (e.g. "Royal Canin Kitten" vs "Royal Canin Junior" — semantic equivalence). Implement as a tool-call with enum-constrained output.

Trade-off: adds ~600ms to the cache-hit path (3-5s → 4-6s) but eliminates the bug that causes cache misses on products that **are** indexed. Since cache-miss path is 12-15s, paying 600ms to convert a miss into a hit is heavily net-positive. Make it toggleable via config flag `algolia.useLLMVerification: true` so we can A/B test.

### 3.2 Index settings (one-time configuration)
These changes don't reindex data, only update settings on the existing `products2` index. Apply via Algolia dashboard or via a one-shot Node script in `functions/scripts/configure-algolia.ts` (committed to the repo, runnable manually via `npx ts-node`). Settings:

```ts
{
  searchableAttributes: [
    "unordered(brand)",       // brand match weighted equally regardless of position
    "unordered(name)",        // same for name
    "foodType",               // lower priority
  ],
  attributesForFaceting: [
    "filterOnly(foodType)",   // used as hard filter
    "searchable(brand)",      // boost via optionalFilters
    "filterOnly(barcode)",    // for direct barcode lookups (still used by getCachedProduct)
  ],
  customRanking: [
    "desc(score)",            // higher-quality products surface first when tied
  ],
  typoTolerance: true,
  minWordSizefor1Typo: 3,     // 1-char typo allowed for words ≥3 chars
  minWordSizefor2Typos: 7,
  removeStopWords: ["en"],     // drop "and", "the", "for", "with" from queries
  ignorePlurals: ["en"],       // "treats" matches "treat"
  // Optional: synonyms — see 3.3
}
```

### 3.3 Synonyms (Algolia Synonyms tab or via API)
Cat food has heavy domain-specific aliasing that string matching can't catch:
- `kitten` ↔ `junior` ↔ `puppy` (some brands mix species terms)
- `treat` ↔ `snack` ↔ `reward`
- `wet` ↔ `pâté` ↔ `paste` ↔ `gravy` ↔ `chunks` ↔ `jelly` ↔ `in sauce` ↔ `mousse`
- `dry` ↔ `kibble` ↔ `croquettes`
- `senior` ↔ `7+` ↔ `mature` ↔ `aging`
- `salmon` ↔ `fish` (domain-specific; salmon is fish but query "fish" should match salmon products)

Add as one-way synonyms (`oneWaySynonym` type) where appropriate so we don't pollute the reverse direction. Configure in `functions/scripts/configure-algolia.ts` alongside the index settings so it's reproducible.

### 3.4 Backfill consideration (out-of-scope, called out)
Existing rows in `products2` have whatever shape Gemini produced. The new Haiku-produced rows use the same schema, so no migration is required. **One concern**: rows from before the foodType strict-enum change might have `foodType` values outside `["wet", "dry", "treat", "topper", "supplement"]` — the `filterOnly(foodType)` facet will simply not match those rows when filtered. Run a one-off audit: `algoliaClient.search({indexName: "products2", attributesToRetrieve: ["foodType"], hitsPerPage: 1000}).then(filter and log invalid foodTypes)`. Out of scope for this plan but worth a follow-up.

## Phase 4 — Flutter cleanup (yucat)

The barcode flow is fully orphaned (`FetchProductByBarcodeUsecase` registered in DI but no consumers). Delete:
- `lib/features/product/data/datasources/product_remote_datasource.dart:14-35` — `fetchProductByBarcode` method
- `lib/features/product/data/repositories/product_repository.dart:26-46` — `fetchProductByBarcode` impl + the `_algoliaDataSource.searchByBarcode` call inside it
- `lib/features/product/domain/repositories/product_repository.dart:4` — interface declaration
- `lib/features/product/domain/usecases/fetch_product_by_barcode_usecase.dart` — entire file
- `lib/service_locator.dart:56` (import) and `lib/service_locator.dart:216-217` (registration)
- `lib/features/search/data/datasources/algolia_search_datasource.dart:12-30` — the broken `searchByBarcode` method (verify with `grep -rn searchByBarcode lib/` that no callers remain after the repository delete)

The `RemoteSearchDataSource` class in `product_remote_datasource.dart` keeps only `fetchProductByImage` (lines 37-65) — that method's implementation is unchanged because the Callable Function name and request/response shape are preserved.

Run `flutter analyze` after — must be clean.

## Phase 5 — Verification

1. **Build**: `cd /Users/adam.ayuda/Projects/yucat/functions && npm run build` — TS compiles clean
2. **Lint**: `npm run lint` — no new violations (yucat-api uses google eslint config; mirror it)
3. **Local emulator** (from `/Users/adam.ayuda/Projects/yucat/`): `firebase emulators:start --only functions` — function loads, no init errors
4. **Functional test** via `firebase functions:shell` with three test images:
   - **Common cat food (Royal Canin can)**: cache miss path. Expect 10-15s, returns full Product with valid nutrient values, written to Algolia with `version: "v2"` (or `"v3"` if we bump)
   - **Same image again**: cache hit path. Expect 3-5s (or 4-6s with LLM verification), returns cached Product
   - **Non-cat-food image (a coffee mug photo)**: returns `{product: null, message: "Could not identify..."}` in <5s
5. **Algolia search regression test**: pick 5 known products in the index, simulate the brand+name they'd be identified as, run `searchProductByNameV2` against each. All 5 should return the correct cached row. (Pick known-failing cases the user has seen — log them first.)
6. **Latency comparison vs yucat-api prod**: capture P50/P95 from both for the same 10 sample images. Expect Haiku miss-path P50 ≤15s vs Gemini's ~22s.
7. **Quality spot check**: For 3 sample products, verify nutrient values match the manufacturer's published guaranteed analysis within ±1 percentage point. Verify pros/cons are nutrition-focused (not marketing language).
8. **Deploy to staging-style channel**: `firebase deploy --only functions:fetchProductByImage` from yucat repo. **Confirm** the function appears in the Firebase console with the new code; **leave yucat-api deployment alone** (do not delete its function yet — see step 10).
9. **Flutter device test**: `flutter run` on iOS device. Trigger camera scan flow; product renders correctly in `ProductDetail`. Test 3-5 products including the ones the user reported as missing-from-Algolia previously.
10. **Cutover and yucat-api retirement** (manual):
    - Once yucat-deployed function is verified in production for ~1 day, **delete** the function exports from yucat-api by deploying an empty index, OR delete the function via `firebase functions:delete fetchProductByImage` — but **only after** confirming the new yucat-deployed function is the one being called (Firebase replaces by name on deploy from yucat, so this should already be the case). Archive or delete the yucat-api repo.

**Rollback plan**: The two repos can coexist during transition. If the new function regresses, deploy from yucat-api to restore the Gemini-based one (same function name, will overwrite). The cleanup in step 10 is the only irreversible step — do it last and only after confidence.

## Critical files to create / modify

**yucat (new files)**:
- `functions/package.json`
- `functions/tsconfig.json`, `functions/tsconfig.dev.json`
- `functions/.eslintrc.js`
- `functions/src/index.ts` (single export: `fetchProductByImage`)
- `functions/src/config/index.ts`
- `functions/src/constants/index.ts`
- `functions/src/models/product.ts`
- `functions/src/services/anthropic.service.ts` (the new core)
- `functions/src/services/algolia.service.ts` (with `searchProductByNameV2` fix)
- `functions/src/utils/image-helpers.ts` (extracted from yucat-api `index.ts:97-232`)
- `functions/src/utils/scan-log.ts` (extracted Firestore write)
- `functions/src/prompts/identify-product.ts`
- `functions/src/prompts/analyze-product.ts`
- `functions/scripts/configure-algolia.ts` (one-shot index settings + synonyms script)

**yucat (modifications)**:
- `firebase.json` — **extend** with `functions` block; do not overwrite the FlutterFire `flutter` block
- `.firebaserc` — create with project `yucat-d8fb5`
- `.gitignore` — add `functions/node_modules/`, `functions/lib/`, `functions/.env*`
- `lib/features/product/data/datasources/product_remote_datasource.dart` — delete `fetchProductByBarcode` method (lines 14-35)
- `lib/features/product/data/repositories/product_repository.dart` — delete `fetchProductByBarcode` impl
- `lib/features/product/domain/repositories/product_repository.dart` — delete interface method
- `lib/features/product/domain/usecases/fetch_product_by_barcode_usecase.dart` — **delete file**
- `lib/service_locator.dart` — delete import (line 56) + registration (lines 216-217)
- `lib/features/search/data/datasources/algolia_search_datasource.dart` — delete `searchByBarcode` method only after grep confirms zero remaining callers
- `CLAUDE.md` — add a "Backend (Firebase Functions)" section noting that functions live in `functions/`, deploy via `firebase deploy --only functions` from repo root, secret is `ANTHROPIC_API_KEY`

**yucat-api**: untouched until cutover (Phase 5, step 10). Then archive/delete.

## Reuse opportunities

- Retry helper structure in yucat-api `gemini.service.ts:43-95, 107-162` — port the **pattern** (lazy init + exponential backoff) but rewrite for Anthropic SDK shape
- `processProductImage` and helpers (yucat-api `index.ts:97-232`) — port verbatim minus SerpAPI fallback
- `RETRY_CONFIG` (yucat-api `constants/index.ts:22-25`) — copy as-is
- The Product model and Algolia field shape — preserve identically so existing cached rows remain valid

## What NOT to do (out of scope)

- Don't reindex `products2` — only update settings + synonyms
- Don't migrate existing Gemini-produced rows to Haiku — they're schema-compatible
- Don't restructure the 3-step pipeline beyond the LLM-verified cache match — no speculative analysis, no parallel pre-search
- Don't replace web search with a structured product DB (Open Pet Food Facts) — separate larger initiative
- Don't migrate to Sonnet — explicitly rejected for cost/latency
- Don't change the Callable Function name or response shape — Flutter contract preserved

## Expected outcome

- Cache-miss P50: **22s → 12-15s** (≈40% faster)
- Cache-hit P50: **3-6s → 4-6s** (slightly slower with LLM verification, but converts previous misses-on-existing-products into hits)
- Cache hit rate on repeat scans of the user's reported "missing" products: **0% → ~95%** (the relevance fix is the big win for them)
- Result quality: parity on nutrition values, eliminate JSON parse failures (tool-use forced output)
- Cost per call: ~3× current Gemini cost, partially offset by prompt caching on warm calls
- Repo footprint: yucat-api retired, single deploy target, ~700 lines of dead barcode/SerpAPI code never ported
