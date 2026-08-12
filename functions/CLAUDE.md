# Backend — Firebase Functions

Everything about YuCat's backend: the callables, the image-scan pipeline, prompts and
tool schemas, config, secrets, the one-off scripts, and the known gaps.

This is the source of truth for `functions/`. The root `CLAUDE.md` carries a summary only.

---

## 1. What this is

A TypeScript / Node 22 Firebase Functions codebase, co-located with the Flutter app
(single repo, single deploy). It backs three things: **product image scanning** (the core
feature) and two **onboarding LLM calls** (a personalized cat note and a brand critique).

Everything model-facing runs on **Claude Haiku 4.5** (`claude-haiku-4-5-20251001`) with
forced tool-use for structured output, plus the `web_search_20250305` server-side tool on
the analysis path.

The legacy Gemini-based `fetchProductByImage` lives in a **separate `yucat-api` repo** and
still serves App Store builds shipped before the V2 cutover. Once all live clients call V2,
`yucat-api` can be retired. The barcode flow (`fetchProductByBarcode`) was orphaned and has
been removed from both backend and client.

---

## 2. The three callables

All in `src/index.ts`, all `onCall` (firebase-functions/v2/https). **No region, memory, cpu,
minInstances or concurrency is set anywhere** — everything runs on defaults (us-central1,
256 MiB). `admin.initializeApp()` runs at module load.

| Function | Timeout | Secrets | Purpose |
|---|---|---|---|
| `fetchProductByImageV2` (`index.ts:41`) | 300s | `ANTHROPIC_API_KEY`, `ALGOLIA_API_KEY`, `SERPAPI_API_KEY` | The scan pipeline (§3) |
| `generateCatNarrative` (`index.ts:364`) | 60s | `ANTHROPIC_API_KEY` | Onboarding personalized note |
| `analyzeBrand` (`index.ts:406`) | 60s | `ANTHROPIC_API_KEY` | Onboarding brand critique |

**None of them inspects `request.auth`** — the Flutter client checks
`FirebaseAuth.currentUser` itself before calling. See §13.

> ⚠️ **Only `fetchProductByImageV2` is actually called by the app.**
> `generateCatNarrative` and `analyzeBrand` are deployed and reachable, but the client-side
> chains that would call them (`CatNarrativeDataSource → CatNarrativeRepository →
> GenerateCatNarrativeUsecase`, and the `BrandVerdict*` equivalent) are registered in
> `service_locator.dart` and injected into **nothing**. They were built for onboarding beats
> that don't call them today. Treat both as dormant: safe to change, but don't assume a
> production regression will show up in user-facing behaviour.

### Wire shapes

```ts
// fetchProductByImageV2
in:  {image: string /* base64, required */, mimeType?: string,
      userId?: string, countryCode?: string /* ISO 3166-1 alpha-2 */}
out: {message: string, userId: string | null,
      geminiResponse: string, product: Product | null}

// generateCatNarrative — in: CatNarrativeInput (requires `name`)
out: {narrative: string | null, outlook: string | null}

// analyzeBrand — in: BrandVerdictInput (requires `brand`)
out: {verdict: BrandVerdictResult | null}
```

`mimeType` is whitelisted against `VALID_MIME_TYPES`
(`image/jpeg|png|webp|heic`) and coerced to `image/jpeg` otherwise.

**`geminiResponse` is a vestigial field name**, kept for wire compatibility with the
retired Gemini-era API. It now carries `JSON.stringify(submit_product.input)` on a full
analysis, and `""` on the cache-hit and not-identified paths. Don't rename it without a
coordinated client release.

The two onboarding functions are **non-critical enhancements**: they return `null` rather
than throwing when the model call fails, so the client falls back to its local template.

---

## 3. The scan pipeline (`fetchProductByImageV2`)

`requestId = scan-{Date.now()}-{6 random chars}`. Each step is wrapped in
`timer.mark(<label>)`; those labels are exactly what appears in the `"scan timings"` log
line, so use them when reading logs.

1. `uploadUserPhoto(...)` — **started but not awaited**, uploads the scan to
   `scans/{requestId}.{ext}`.
2. `identifyProductFromImage(image, mime)` → `{brand, name, foodType} | null` — Haiku
   vision, no web search. *(`identify`)*
3. `await userPhotoPromise` *(`userPhotoUpload`)*
4. **Not identified** → `logScanRequest` *(`scanLog`)*, log `path: "not-identified"`,
   return `product: null`. ⟵ exit 1
5. `searchProductByNameV2(brand, name, foodType)` — Algolia cache lookup *(`cacheLookup`)*
6. On a miss, if `config.algolia.useLLMVerification`: `fetchCandidatesByName(...)` →
   `verifyMatchWithLLM(...)` *(`llmVerify`)*
7. **Cache-hit branching** — see below. Plain hit → `logScanRequest` *(`scanLog`)*,
   `path: "cache-hit"`. ⟵ exit 2
8. **Full analysis.** Two things start concurrently:
   - `serpApiHostedPromise` = `findProductImageUrl` → `processProductImage`, under a
     *provisional* key, `.catch(() => "")`. Claude almost never returns a hostable image
     URL, so SerpAPI is needed on essentially every miss — doing it concurrently keeps it
     off the critical path.
   - `analyzeProductImageParallel(...)` (default) or `analyzeProductImage(...)` when
     `useParallelAnalysis` is false. *(`analyze`)*
9. On a product: set `isAiIdentified = true`, compute `cacheKey`, set `product.barcode`,
   host the analyze-provided image, and fall back to `await serpApiHostedPromise` if that
   yields nothing *(`imageHost`)*. Stamp `lastAnalysisAttempt` + `lastImageAttempt`.
10. `Promise.all([cacheProduct, logScanRequest])` *(`finalize`)*, log
    `path: "full-analysis"`. ⟵ exit 3

### Self-healing cache — the least obvious logic in the file

A cached entry can be re-attempted **at most once per `REANALYZE_AFTER_MS` (14 days)**.
Three predicates drive it (`index.ts:36-39`):

```ts
hasNutritionData = (p) => p.score > 0      // score 0 is a sentinel, not a grade
hasImage         = (p) => !!p.imageUrl
isStale          = (ts) => !ts || Date.now() - ts > REANALYZE_AFTER_MS
```

| Cached entry | Action |
|---|---|
| No nutrition **and** stale `lastAnalysisAttempt` ("stale junk") | Fall through to full re-analysis, setting `overwriteKey = cachedProduct.barcode` so the row is **overwritten in place** rather than duplicated |
| Nutrition but no image, stale `lastImageAttempt` | Image-only backfill (`findProductImageUrl` → `processProductImage` → `cacheProduct`) *(`imageBackfill`)*, then return the hit — much cheaper than re-analyzing |
| Otherwise | Plain cache hit |

`lastAnalysisAttempt` and `lastImageAttempt` are **separate stamps** precisely so an entry
with nutrition but no image can retry the image without paying for a full re-analysis.
Both are absent on pre-V2 rows, which reads as "never attempted".

---

## 4. Parallel analysis

`analyzeProductImageParallel` (`anthropic.service.ts:549`) is the default
(`config.anthropic.useParallelAnalysis: true`). It fans out to **4 concurrent sources** and
keeps the most complete result:

| Source | What it does |
|---|---|
| `manufacturer` | `analyzeOneSource` hinted at the brand's own domain (makers often host the guaranteed analysis when retailers don't) |
| `retailer-a` | `analyzeOneSource` hinted at Chewy / Amazon |
| `retailer-b` | `analyzeOneSource` hinted at zooplus / Petco / Pets at Home |
| manufacturer **pages** | `analyzeFromManufacturerPages` — SerpAPI organic results → `fetchPage` → follow `/product(s)/` links scoring ≥2 slug-token matches → best 2 → `fetchPageText` → `analyzeFromProductPages` extraction call. Location-independent; catches niche/non-US brands that Claude's search index misses |

The three `analyzeOneSource` instances each get `parallelMaxUses: 2` web searches. An
instance that throws is caught and becomes `null` rather than failing the fan-out.

`pickBestProduct` (`anthropic.service.ts:613`) scores completeness as
`2×(score > 0) + 1×(ingredients.length > 0)` and keeps the first strict maximum — so
**order is load-bearing**: `manufacturer` wins ties over the retailers, and the page-fetch
source is ordered last so it only wins when it *alone* has nutrition.

Setting `useParallelAnalysis: false` falls back to `analyzeProductImage` — one free-search
call at `max_uses: 3` plus the manufacturer-page source. Roughly a third of the cost, at
the price of data completeness on obscure products. Config comments the parallel path as
"~3x cost".

---

## 5. File map

```
functions/
├── src/
│   ├── index.ts                  the 3 callables + scan pipeline + self-heal logic
│   ├── config/index.ts           all tunables and keys (§8)
│   ├── constants/index.ts        retry, image validation/optimization, score bounds
│   ├── models/product.ts         Product interface + ProductModel (§9)
│   ├── prompts/                  (§6)
│   │   ├── identify-product.ts   analyze-product.ts    quality-rubric.ts
│   │   └── cat-narrative.ts      brand-verdict.ts      rescore-product.ts
│   ├── services/
│   │   ├── anthropic.service.ts  ~1250 lines — every model call + all tool schemas
│   │   ├── algolia.service.ts    V2 fuzzy search, candidates, cache R/W
│   │   ├── image.service.ts      URL validation, download, sharp optimize, Storage upload
│   │   └── serpapi.service.ts    Google Images + Google organic lookups
│   └── utils/
│       ├── image-helpers.ts      uploadUserPhoto, processProductImage
│       ├── page-fetch.ts         fetchPage, fetchPageText, extractProductLinks, htmlToText
│       ├── scan-log.ts           logScanRequest → Firestore /scans
│       ├── timing.ts             createTimer / mark / summary
│       └── validation.ts         validateImageData
├── scripts/                      one-off ts-node scripts (§11) — not compiled, not linted
└── lib/                          gitignored build output — NOT truth
```

⚠️ **Never read `lib/` as truth.** It's stale build output and still contains
`lib/prompts/find-image.js`, whose source was deleted.

---

## 6. Prompts and tool schemas

| Prompt file | Exports | Consumer |
|---|---|---|
| `identify-product.ts` | `generateIdentificationPrompt()` | `identifyProductFromImage` |
| `analyze-product.ts` | `generateAnalysisSystemPrompt()`, `generateAnalysisUserPrompt(identification?, sourceHint?)` | `analyzeOneSource`, `analyzeFromProductPages` |
| `quality-rubric.ts` | `QUALITY_RUBRIC` | Embedded verbatim in **both** the analyze and regrade system prompts |
| `cat-narrative.ts` | `generateCatNarrativeSystemPrompt/UserPrompt`, `CatNarrativeInput`, `DietTip`; internal `CARE_NOTES` (10 conditions), `deriveCombos()`, `LANGUAGE_NAMES` (en/es/fr/hu) | `generateCatNarrative` |
| `brand-verdict.ts` | `generateBrandVerdictSystemPrompt/UserPrompt`, `BrandVerdictInput`, `BrandCatalogContext` | `analyzeBrand` |
| `rescore-product.ts` | `generateRegradeSystemPrompt/UserPrompt`, `RegradeInput` | `regradeProductQuality` (scripts only) |

`QUALITY_RUBRIC` is the **single source of scoring truth** — change it there, and both
live analysis and batch re-scoring move together. Then re-score the catalog (§11) or the
index carries two incompatible score generations.

**Tool schemas live in `anthropic.service.ts`, not in `prompts/`:**

| Const | Tool(s) | Notes |
|---|---|---|
| `IDENTIFICATION_TOOLS` | `submit_identification`, `not_cat_food` | requires `brand`, `name`, `foodType` ∈ wet/dry/treat/topper/supplement |
| `ANALYSIS_TOOLS` | `submit_product` | **17 required fields**; numbers bounded 0–100; `pros`/`cons` `maxItems: 3` |
| `NARRATIVE_TOOLS` | `submit_narrative` | `narrative` (~50 words) + `outlook` (~25 words) |
| `SCORE_TOOLS` | `submit_score` | `score` 0–100 |
| `BRAND_VERDICT_TOOLS` | `submit_brand_verdict` | `score`, `headline`, `reasons` (2–4), optional `positives` (≤2) |
| inline in `verifyMatchWithLLM` | `submit_match` | `matchIndex`, min −1 (= "none of these") |

---

## 7. Model and inference parameters

One model everywhere — `config.anthropic.model` = **`claude-haiku-4-5-20251001`**. No other
model string is hardcoded anywhere in `functions/`.

| Call site | max_tokens | temp | tool_choice | prompt cache |
|---|---|---|---|---|
| `identifyProductFromImage` | 256 | 0.1 | `{type: "any"}` | — |
| `analyzeOneSource` | 8192 | 0.1 | `{type: "auto"}` | ephemeral (system) |
| ↳ force-submit fallback | 4096 | 0.1 | `{type: "tool", name: "submit_product"}` | ephemeral |
| `analyzeFromProductPages` | 4096 | 0.1 | `{type: "tool", name: "submit_product"}` | ephemeral |
| `generateCatNarrative` | 400 | **0.7** | `submit_narrative` | ephemeral |
| `analyzeBrand` | 600 | **0.4** | `submit_brand_verdict` | ephemeral |
| `regradeProductQuality` | 128 | **0** | `submit_score` | ephemeral |
| `verifyMatchWithLLM` | 128 | **0** | `{type: "any"}` | — |

**Web search** appears only in `analyzeOneSource`:

```ts
{type: "web_search_20250305", name: "web_search",
 max_uses: <3 single-source | 2 parallel>,
 user_location: {type: "approximate", country}}   // cast `as any`
```

The `as any` cast is required because the pinned `@anthropic-ai/sdk ^0.40.0` predates the
web_search tool type. Country biasing is **best-effort**: Claude accepts only an allowlist
of country codes, so a 400 whose message matches `/country code/i` clears `country` and
retries once without `user_location`.

Other model-layer machinery in `anthropic.service.ts`:
- `withRetry(label, fn)` — retries **only** on HTTP 429 or ≥500. `MAX_RETRIES = 2`
  (3 attempts), backoff `1000 × 2^attempt` ms.
- `MAX_CONTINUATIONS = 3` — resume loop for `stop_reason === "pause_turn"` (search loop
  paused mid-task) and `"max_tokens"`.
- `normalizeMediaType` — narrows to jpeg/png/gif/webp for the Anthropic call.
- Per-call telemetry logged: `roundTrips`, `roundTripMs[]`, `webSearchMs`,
  `webSearchCount` (from `server_tool_use` blocks), `inputTokens`, `outputTokens`,
  `stopReasons`.

---

## 8. Config and secrets

`src/config/index.ts` is `as const` and holds every tunable. Committed literals double as
fallbacks when the env var is absent:

| Key | Committed value |
|---|---|
| `algolia.applicationId` | `GI8VPYUYCP` |
| `algolia.apiKey` | `5b6e53…` — **search-only key, intentionally in source** |
| `algolia.indexName` | `products2` |
| `algolia.useLLMVerification` | `true` |
| `storage.bucketName` | `yucat-d8fb5.firebasestorage.app` |
| `storage.productsFolder` | `products/` |
| `functions.timeoutSeconds` / `corsEnabled` | `300` / `true` |
| `anthropic.*` | model, `temperature: 0.1`, `maxWebSearches: 3`, `useParallelAnalysis: true`, `parallelMaxUses: 2`, `useManufacturerPageFallback: true`, `pageFallbackMaxPages: 3` |

**Secrets** (Firebase Secret Manager, declared in the `onCall` `secrets` array so the
runtime injects them into `process.env`):

```bash
firebase functions:secrets:set ANTHROPIC_API_KEY   # also SERPAPI_API_KEY, ALGOLIA_API_KEY
```

Env vars read: `ANTHROPIC_API_KEY`, `ALGOLIA_API_KEY`, `ALGOLIA_APP_ID`, `SERPAPI_API_KEY`,
`STORAGE_BUCKET` in `src/`; `ALGOLIA_ADMIN_API_KEY`, `ALGOLIA_INDEX_NAME` in `scripts/`.
There are **no `.env` files** in the repo.

Two subtleties:
- `ALGOLIA_API_KEY` is declared as a secret, but `config` falls back to the committed
  search-only key — so the function keeps working even if that secret is unset. Anything
  that **writes** to Algolia needs `ALGOLIA_ADMIN_API_KEY`, which is never committed.
- SerpAPI self-disables when its key is missing (`enabled: !!process.env.SERPAPI_API_KEY`).
  Both SerpAPI helpers then return `[]`, so image lookup and the manufacturer-page source
  silently no-op rather than erroring.

---

## 9. Data model and stores

`src/models/product.ts` — `Product` (interface) and `ProductModel` (class with
`fromObject` / `toObject`; `version` defaults `"v2"`, `foodType` defaults `"dry"`):

```
required: barcode name brand foodType protein fat moisture carbs fiber ash
          imageUrl score pros[] cons[] version
V2 optional: isAiIdentified format packageSize description ingredients[]
             lastAnalysisAttempt lastImageAttempt
```

The V2 fields are optional so pre-V2 cached rows still round-trip cleanly.

**Algolia** — one index, `products2`, record = `{objectID: cacheKey, ...Product}`.

⚠️ **Cache identity is text-derived, not a real barcode.** The key is
`img-{brand}-{name}` lowercased with whitespace → `-`, written to **both** `objectID` and
`product.barcode`. Any drift in how Haiku transcribes a product name creates a duplicate
row — which is exactly why `identify-product.ts` insists on transcribing only printed text
and no marketing taglines. Those identification strings are used verbatim for both the web
search and the cache identity.

**Firebase Storage** (`yucat-d8fb5.firebasestorage.app`) — `scans/{requestId}.{ext}` for
raw user photos, `products/{cacheKey}.jpeg` for hosted product images. Everything is
`makePublic()`d and served as `https://storage.googleapis.com/{bucket}/{path}`. Images are
resized to 800×800 `inside` (no enlargement) and saved as progressive JPEG q85.

**Firestore** — one collection, `scans`, doc id = `requestId`, written by `logScanRequest`
with `{requestId, userId, userPhotoUrl, identification, cachedMatch, product, timestamp}`.
Write-only: nothing in the backend ever reads it back. Failures are swallowed — scan
logging must never affect the user-facing response.

**Algolia search behavior** (`searchProductByNameV2`): query is the **name only**, brand
goes in `optionalFilters`, `foodType` in `filters`, `hitsPerPage: 5`. Each hit scores
`0.5×brandMatch + 0.5×wordOverlap` and must clear `NAME_MATCH_THRESHOLD = 0.6` *and* match
the brand exactly (normalized). If the best and runner-up are within
`AMBIGUITY_MARGIN = 0.15`, it deliberately returns `null` so `verifyMatchWithLLM`
disambiguates instead of guessing. Matching helpers: `stripAccents`, `normalize`,
`tokenize`, `isWithinEditDistance1`, `fuzzyContains`, `wordOverlap`.

---

## 10. Local dev, build, deploy

```bash
cd functions
npm install
npm run build      # tsc → lib/
npm run lint
npm run serve      # build + firebase emulators:start --only functions
npm run dev        # tsc --watch + emulators, concurrently
npm run shell      # build + firebase functions:shell (interactive REPL)
npm run logs       # firebase functions:log
```

Deploy from the **repo root**:

```bash
firebase deploy --only functions                          # all three
firebase deploy --only functions:fetchProductByImageV2    # one
```

> **Deploys happen only on explicit instruction.** Building and testing locally is never
> authorization to deploy.

Two gotchas:
- Root `firebase.json` sets `predeploy: ["npm run lint", "npm run build"]`, so **a lint
  error blocks the deploy.** Lint before you plan to ship.
- `tsconfig.json` has `include: ["src"]` and `.eslintrc.js` has `ignorePatterns` covering
  `/scripts/**` — so `scripts/` is **neither type-checked nor linted**. Breakage there
  surfaces only at `ts-node` runtime.
- `firebase-tools` 13.34 crashes on Node 26; use `npx firebase-tools@latest`.

---

## 11. One-off scripts (`functions/scripts/`)

All run via `npx ts-node`, none are deployed, none are compiled or linted. Note `ts-node`
itself is not a declared dependency (`npx` fetches it).

| Script | What it does |
|---|---|
| `configure-algolia.ts` | Applies `products2` index settings (searchable attributes, faceting, `customRanking: desc(score)`, typo tolerance) + replaces 7 synonym sets. Run after any relevant settings change. |
| `rescore-products.ts` | Batch re-grades `score` against `QUALITY_RUBRIC`, keeping the old value in `scoreLegacy` for rollback. Skips `score === 0`. Flags: `--dry-run`, `--limit=N`, `--concurrency=N` (10), `--query=`. |
| `backfill-images.ts` | Finds + hosts images for products with `score > 0` and empty `imageUrl`, reusing the live self-heal path. Stamps `lastImageAttempt` even on failure, matching live throttling. Flags: `--dry-run`, `--limit=N`, `--concurrency=N` (5). |
| `purge-cache-entry.ts` | `purge-cache-entry.ts "<brandSubstr>" [nameSubstr]` — deletes matching `img-*` entries so the next scan re-analyzes from scratch. **Deletes without confirmation** — review the printed matches, and tighten the filter if it catches too much. |

All three write-scripts need `ALGOLIA_ADMIN_API_KEY` (search-only keys cannot mutate).
`backfill-images.ts` additionally uploads to Storage, so it needs application-default
credentials — `GOOGLE_APPLICATION_CREDENTIALS` pointing at a service-account JSON, or
`gcloud auth application-default login` with Storage object admin on the bucket.

⚠️ `configure-algolia.ts`'s header comment says it needs `ALGOLIA_API_KEY`; the code
actually reads **`ALGOLIA_ADMIN_API_KEY`**.

> Scripts that write to Algolia or Storage are production mutations — run them only when
> explicitly asked, and prefer `--dry-run --limit=N` first.

---

## 12. Errors and logging

**There is no `HttpsError` anywhere.** Every failure throws a plain `Error`, which the
Functions SDK surfaces to the client as `INTERNAL` with the message masked — so
client-side, "missing image" and "analysis crashed" are indistinguishable. Validation
messages are `Missing required field: image (base64-encoded string) | name | brand`; the
catch-all rethrows as `` `Error processing product image: ${msg}` ``.

Retry exists **only** for Anthropic calls (`withRetry`). SerpAPI, page fetch, Algolia and
Storage have no retry — they degrade to `[]` / `""` / a swallowed `logger.warn`.

Logging uses `firebase-functions/logger` with a structured object always ending
`structuredData: true`. `logger.info` for milestones and timing, `logger.warn` for
degraded-but-recovered paths, `logger.error` only in the top-level scan catch. Searchable
messages worth knowing:

- `"scan timings"` — per-step breakdown + `path: not-identified | cache-hit | full-analysis`
- `"analyzeProductImageParallel complete"` — instances, succeeded, `parallelMs`, `chosenHasNutrition`
- `"analyzeProductImage web_search timing"`
- `"Algolia v2: ranked candidates"`
- `"findProductImageUrl using SerpAPI candidate"` / `"findProductImageUrl found no image"`
- `"Cache hit is a stale no-data entry — re-analyzing"` / `"Cache hit missing image — attempting image backfill"`

---

## 13. Known gaps

Accepted behavior, documented so it isn't rediscovered as a surprise:

- **`userId` is always `null` in practice.** `index.ts` reads `request.data.userId`, but
  `product_remote_datasource.dart` sends only `image`, `mimeType`, `countryCode` — it
  reads the uid purely to assert the user is signed in. Every `scans` doc is therefore
  unattributed.
- **No auth check on any callable.** Anyone with the project id can call them.
- **Client gives up before the server does.** Scan: client 120s vs server 300s. Narrative
  and brand: client 30s vs server 60s.
- **`image/heic` is accepted at the boundary but not supported downstream** —
  `normalizeMediaType` silently relabels it `image/jpeg`, which will fail or mis-decode for
  a genuine HEIC payload.
- **Score 0 is a sentinel, not a grade.** `score > 0` is what `hasNutritionData`,
  `pickBestProduct`, `rescore-products.ts` and `backfill-images.ts` all test. A rubric
  change that lets a real product legitimately score 0 breaks the self-heal logic.
- **Provisional vs final image key can diverge.** The parallel SerpAPI upload names the
  file from the *identification* brand/name; the final cache key uses the *analyzed* ones.
  When they differ the URL still works, but `products/{barcode}.jpeg` is not a reliable
  lookup convention.
- **The ambiguity guard couples two files.** `searchProductByNameV2` returns `null` on a
  near-tie *expecting* `index.ts` to call `verifyMatchWithLLM`. Turning off
  `useLLMVerification` converts those near-ties into full, expensive re-analyses rather
  than falling back to the top hit.
- **`sharp` failure is silent** — the dynamic import is caught, and the original
  unoptimized buffer is stored. It shows up only as unusually large images plus a
  `"Sharp not available"` warning.
- **Dead code**: `getCachedProduct` and the V1 `searchProductByName` are unexercised;
  `mime` is a declared but never-imported dependency.
- **No tests exist**, despite `firebase-functions-test` being installed. There is no CI
  config under `functions/`.
