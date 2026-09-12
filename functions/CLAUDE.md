# Backend — Firebase Functions

Everything about YuCat's backend: the callables, the image-scan pipeline, prompts and
tool schemas, config, secrets, the one-off scripts, and the known gaps.

This is the source of truth for `functions/`. The root `CLAUDE.md` carries a summary only.

---

## 1. What this is

A TypeScript / Node 22 Firebase Functions codebase, co-located with the Flutter app
(single repo, single deploy). It backs three things: **product image scanning** (the core
feature — cat food *and* cat litter, through one callable) and two **onboarding LLM calls**
(a personalized cat note and a brand critique).

Everything model-facing runs on **Claude Haiku 4.5** (`claude-haiku-4-5-20251001`) with
forced tool-use for structured output, plus the `web_search_20250305` server-side tool on
the analysis path.

The legacy Gemini-based `fetchProductByImage` lives in a **separate `yucat-api` repo** and
still serves App Store builds shipped before the V2 cutover. Once all live clients call V2,
`yucat-api` can be retired. The barcode flow (`fetchProductByBarcode`) was orphaned and has
been removed from both backend and client.

---

## 2. The three callables and the nightly job

All in `src/index.ts`, all `onCall` (firebase-functions/v2/https). No region or minInstances
is set (us-central1). `admin.initializeApp()` runs at module load, followed by
`firestore().settings({ignoreUndefinedProperties: true})` — a fresh analysis has
`translations: undefined`, which Firestore otherwise rejects, and that silently dropped 16% of
`scans` docs.

| Function | Timeout | Runtime | Secrets | Purpose |
|---|---|---|---|---|
| `fetchProductByImageV2` | 300s | **1 GiB, 1 cpu, concurrency 10** (`config.functions`) | `ANTHROPIC_API_KEY`, `ALGOLIA_API_KEY`, `SERPAPI_API_KEY` | The scan pipeline — food (§3) and cat litter (§3b) |
| `analyzeProductLabel` | 90s | same | `ANTHROPIC_API_KEY`, `ALGOLIA_API_KEY` | The back-label rescue (§3c) — one vision read, no web search |
| `nightlySelfHeal` (`jobs/self-heal.ts`) | 540s | 1 GiB, `onSchedule` 03:30 Europe/Madrid | all three | Re-analyses score-0 rows and backfills images off the request path (§3d) |
| `generateCatNarrative` | 60s | defaults (256 MiB) | `ANTHROPIC_API_KEY` | Onboarding personalized note |
| `analyzeBrand` | 60s | defaults (256 MiB) | `ANTHROPIC_API_KEY` | Onboarding brand critique |

The scan runtime is sized deliberately: sharp decodes multi-MB photos and every in-flight
request holds a base64 copy, so the 256 MiB / concurrency-80 default was OOM-killed five
times in two weeks. Memory-bound work wants fewer, larger instances.

**`fetchProductByImageV2` requires `request.auth`** and throws `unauthenticated` otherwise —
the client signs in anonymously at splash before it can reach the scanner, so a real user
never hits it. `userId` in the scan log is `request.auth.uid`, not a request field. The two
onboarding callables still do not check auth (they are dormant, see below).

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
in:  {image: string /* base64, required */, mimeType?: string /* advisory — bytes are sniffed */,
      countryCode?: string /* ISO 3166-1 alpha-2 */,
      locale?: string /* app language, e.g. "fr" — see prompts/languages.ts */,
      gtin?: string /* barcode read off the still; re-validated by normalizeGtin */}
out: {message: string, userId: string | null /* request.auth.uid */,
      geminiResponse: string,
      category: "food" | "litter" | null,   // what the photo turned out to be
      product: Product | null,              // food scans only
      localizedText: ProductText | null,
      litter: Litter | null,                // litter scans only (§3b)
      litterLocalizedText: LitterText | null,
      userPhotoFallbackUrl: string | null,
      // --- Phase 1 (additive; older clients ignore them) ---
      outcome: "product" | "litter" | "not_cat_product" | "unreadable"
             | "analysis_failed" | "litter_analysis_failed",
      reason: string | null,      // identify's rejection enum on the two not-identified outcomes
      path: string,               // the "scan timings" path: gtin-hit | cache-hit | full-analysis | …
      requestId: string,
      gtin: string | null,        // normalised, when the client sent a valid one
      identification: {brand, name, foodType?} | null,
      productKey: string | null,  // Algolia objectID (== product.barcode / litter.id)
      models: {identify: string, analyze: string}}

// analyzeProductLabel — the back-label rescue (§3c)
in:  {labelImage: string /* base64, required */, mimeType?: string,
      productKey?: string /* Algolia objectID from a scan result */,
      gtin?: string, identification?: {brand, name, foodType?},
      countryCode?: string, locale?: string}
out: ScanResponse with outcome: "product" | "unreadable" | "label_no_data", path: "label",
     productKey: the row the label was merged into

// generateCatNarrative — in: CatNarrativeInput (requires `name`)
out: {narrative: string | null, outlook: string | null}

// analyzeBrand — in: BrandVerdictInput (requires `brand`)
out: {verdict: BrandVerdictResult | null}
```

`mimeType` is whitelisted against `VALID_MIME_TYPES`
(`image/jpeg|png|webp|heic`) and coerced to `image/jpeg` otherwise.

**`userPhotoFallbackUrl`** is a **per-user** image fallback: when neither the analyze step
nor SerpAPI produced a usable product image, the backend hosts a display-sized copy of the
user's own scan photo at `scans/{requestId}-display.jpeg` and returns that URL. The client
renders it when `product.imageUrl` is empty.

⚠️ It is deliberately **not** written into `product.imageUrl` or the Algolia record.
`products/{key}.jpeg` is keyed by product and served to every user, so persisting it would
(a) publish one user's photo to everyone — beyond the Terms' "operate the app **for you**"
licence — and (b) let two users scanning the same imageless product overwrite each other's
photos. Leaving the record's `imageUrl` empty also keeps the 14-day self-heal and
`backfill-images.ts` hunting for a real product shot. `resolveUserPhotoFallback` runs
**after** every `cacheProduct` call for exactly this reason.

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

0. **Media sniff** — `sniffMediaType` (`utils/media-type.ts`) reads the magic bytes and
   overrides whatever `mimeType` the client declared (clients label everything
   `image/jpeg`; a mislabeled PNG 400s at the model API). HEIC is refused with
   `invalid-argument` rather than failing mid-pipeline.
0b. **Barcode fast path** *(`gtinLookup`)* — when the client sent a valid `gtin`, both
   indexes are queried by the exact `gtin` facet **before identify**. A `products2` hit
   enters the cache-hit branch with the identification synthesised from the row and
   `path: "gtin-hit"` (no vision call at all); a `litters` hit goes to §3b with
   `preMatched`, `path: "litter-gtin-hit"`. Self-heal predicates still apply, so a score-0
   gtin row falls through to re-analysis like any other stale-junk hit.
1. `uploadUserPhoto(...)` — **started but not awaited**, uploads the scan to
   `scans/{requestId}.{ext}`.
2. `identifyScanSubject(image, mime, requestId)` → `ScanSubject` — Haiku vision, no web
   search. Classifies **food / litter / none** and transcribes brand + name; the
   discriminated `category` is what the whole pipeline branches on. A `none` result carries
   a `reason` (`dog_food | human_food | other_item | no_product | unreadable`, or `no_tool`
   when the model returned no tool call) — the split between "not a cat product" and
   "couldn't read the pack" that the not-identified 20% needed. *(`identify`)*
2b. **GTIN resolver** *(`gtinResolve`)* — a `none` result **with** a gtin goes to
   `resolveIdentityFromGtin` (`services/gtin-resolver.service.ts`): Open Pet Food Facts
   first (free, 3 s timeout, 404 = miss, accepted only with a `cat` category tag), then
   `identifyByGtinSearch` — one Haiku call with a single `web_search` for the EAN, using
   the same identify tools. A hit replaces `scanSubject` and the pipeline continues as if
   the pack had been read; `identitySource` (`photo | gtin-cache | gtin-opff | gtin-search`)
   is logged on every "scan timings" line so the barcode paths are measurable.
3. `await userPhotoPromise` *(`userPhotoUpload`)*
4. **Not identified** → `logScanRequest` *(`scanLog`)*, log `path: "not-identified"` with
   `identifyReason`, return `product: null` with `outcome: not_cat_product | unreadable`
   (`unreadable` covers the `unreadable`, `no_product` and `no_tool` reasons). ⟵ exit 1
4b. **Litter** → hand off to `handleLitterScan` (§3b). ⟵ exits 4-6
5. `lookupProductByNameV2(brand, name, foodType)` → `{match, hits}` — Algolia cache lookup
   *(`cacheLookup`)*. Brand goes in `optionalFilters` **quoted** (`brand:"Royal Canin"`;
   unquoted, multi-word brands were never boosted).
6. On a miss, if `config.algolia.useLLMVerification` and `hits` is non-empty:
   `verifyMatchWithLLM(identification, hits)` *(`llmVerify`)* — it picks from the hits the
   lookup already returned; there is no second Algolia query. `foodType` is a soft boost
   in `optionalFilters`, not a hard filter — identify's treat-vs-dry disagreement with the
   row used to force a full re-analysis. A name hit with a gtin in hand and none on the row
   gets `attachGtin` (fire-and-forget `partialUpdateObject`), so the next scan of that pack
   takes the fast path.
7. **Cache-hit branching** — see below. Plain hit → `logScanRequest` *(`scanLog`)*,
   `path: "cache-hit"`. ⟵ exit 2
8. **Full analysis.** Two things start concurrently:
   - `serpApiHostedPromise` = `findProductImageUrl` → `processProductImage`, under a
     *provisional* key, `.catch(() => "")`. SerpAPI is the **only** image source: the
     model's own `imageUrl` was unusable in about half of scans (page URLs, dead links)
     while SerpAPI won 134 of 135 times, so the field is no longer requested or hosted.
   - `analyzeProductImageParallel(...)` (default) or `analyzeProductImage(...)` when
     `useParallelAnalysis` is false. *(`analyze`)* The gtin, when present, rides in the user
     prompt as a search anchor (`generateAnalysisUserPrompt(identification, hint, gtin)`).
9. On a product: set `isAiIdentified = true`, compute `cacheKey`, set `product.barcode`,
   set `product.gtin` / `gtinSource` (`scan` when identify read the pack, `resolver` when
   the barcode recovered the identity),
   **start `ensureTranslation` immediately**, then `product.imageUrl = await
   serpApiHostedPromise` *(`imageHost`)*, stamp `lastAnalysisAttempt` + `lastImageAttempt`,
   then await the translation *(`translate`)*. Translation used to run serially after image
   hosting (~2.3 s on the critical path); it only needs the analysed text, so it overlaps.
10. `Promise.all([cacheProduct, logScanRequest])` *(`finalize`)*, log
    `path: "full-analysis"`, `outcome: "product"`, `productKey: cacheKey`. ⟵ exit 3
11. **Analysis failed** (no `submit_product` even after the force-submit) → log
    `path: "analysis-failed"`, return `product: null` with `outcome: "analysis_failed"` and
    the `identification` — the client can now tell this apart from not-identified. ⟵ exit 4

### Self-healing cache — the least obvious logic in the file

A cached entry can be re-attempted **at most once per `REANALYZE_AFTER_MS` (14 days)**.
Three predicates drive it (`index.ts:67-72`):

```ts
// All three take a `ScannedRecord` — the structural interface both Product and
// Litter satisfy — so food and litter self-heal by exactly the same rules.
hasAnalysisData = (r) => r.score > 0      // score 0 is a sentinel, not a grade
hasImage        = (r) => !!r.imageUrl
isStale         = (ts) => !ts || Date.now() - ts > REANALYZE_AFTER_MS
```

| Cached entry | Action |
|---|---|
| No nutrition **and** stale `lastAnalysisAttempt` ("stale junk") | Fall through to full re-analysis, setting `overwriteKey = cachedProduct.barcode` so the row is **overwritten in place** rather than duplicated |
| Nutrition but no image | **Served as-is** (the client falls back to the user's own photo). Image backfill left the request path in Phase 3 — `nightlySelfHeal` (§3d) does it; inline it turned a 4 s hit into a 30 s one |
| Otherwise | Plain cache hit |

`lastAnalysisAttempt` and `lastImageAttempt` are **separate stamps** precisely so an entry
with nutrition but no image can retry the image without paying for a full re-analysis.
Both are absent on pre-V2 rows, which reads as "never attempted".

---

## 3c. The back-label rescue (`analyzeProductLabel`)

The data is on the pack: analytical constituents and the composition are printed on every
cat food by law. When the search found nothing (a score-0 row → the detail page's no-data
card) or the pack was unreadable / identified-but-empty (the scan error view), the client
offers "Photograph the back label" and this callable reads the nutrition straight off it —
one forced `submit_product` vision call (`analyzeProductLabelImage`, `prompts/analyze-label.ts`,
rubric first, multilingual label vocabulary, no `web_search`), ~5-12 s, under a cent.

1. Auth, `labelImage` validation, media sniff, `normalizeGtin`. A `productKey` starting
   `lit-` is refused (`invalid-argument`) — litter has no analysis panel.
2. **Target resolution** *(`targetLookup`)*: `getCachedProduct(productKey)` → `findProductByGtin`
   → `lookupProductByNameV2(identification)` (match only) → none (a new row). An existing
   row's identity overrides whatever the client sent.
3. `analyzeProductLabelImage` *(`labelExtract`)*, with the identification pinning name/brand.
4. **Exits**: no `submit_product` → `outcome: "unreadable"`; a read with `score <= 0` →
   `outcome: "label_no_data"` — and in both cases **nothing is written**, so a bad photo can
   never erase real data. Otherwise `mergeLabelIntoProduct` (`utils/merge-label.ts`):
   macros / score / pros / cons / ingredients / description from the label; name, brand,
   foodType, format, packageSize, imageUrl, key from the existing row (falling back to the
   extraction); `translations` **dropped** (they described the empty analysis) and refilled
   lazily; `analysisSource: "label"`, `labelRequestId`. The label photo is never the product
   image — it may come back as `userPhotoFallbackUrl` for this user only.
5. `cacheProduct` + `logScanRequest({kind: "label"})` *(`finalize`)*, `path: "label"` on
   the timings line. The client treats the result exactly like a scanned product (history,
   `Product Selected { path: label }`, detail page).

## 3d. Nightly self-heal (`nightlySelfHeal`, `jobs/self-heal.ts`)

`onSchedule("every day 03:30", Europe/Madrid, 540 s, 1 GiB, retryCount 0)`, all tunables in
`config.selfHeal`. It exists because the inline self-heal never really ran: a row could
only be retried when a user happened to rescan it ≥ 14 days later, so 225 score-0 rows sat
in the catalogue and the stale-junk branch fired once in two weeks.

| Pass | Selection | Cap / concurrency | Action |
|---|---|---|---|
| 1 | `products2`, `score = 0`, stale `lastAnalysisAttempt`, oldest first | 15 / 3 | `analyzeProductImageParallel(null, …)` — **no photo**; the prompts take `hasImage=false` and lean on brand/name + gtin. Recovered → `cacheProduct` under the **same objectID** (image, gtin kept; `translations` cleared). Miss/error → stamp `lastAnalysisAttempt` |
| 2 | `products2`, `score > 0`, empty `imageUrl`, stale `lastImageAttempt` | 40 / 5 | `findProductImageUrl` → `processProductImage` → `partialUpdateRecord({imageUrl, lastImageAttempt})` |
| 3–4 | the same two passes on `litters` | 5 / 2 and 10 / 3 | `analyzeLitterImage(null, …)` / image backfill |

Selection uses paginated `search` with a numeric filter (`fetchRowsByFilter`), not
`browse` — it needs only the `search` ACL and the catalogue fits in a few 1,000-hit pages.
A `budgetMs` (480 s) guard stops *starting* new items; in-flight ones finish. One
`"self-heal summary"` line per run: `reanalyzeCandidates / reanalyzed / recovered`,
`imageCandidates / imagesAttempted / imagesFound`, the litter equivalents,
`budgetExhausted`, `ms`. Cost ceiling ≈ 15 × $0.05 ≈ $1/night.

**`SELF_HEAL_DRY_RUN=true`** (a `defineBoolean` param) logs the candidates and writes
nothing — run one dry night after deploying. `scripts/backfill-images.ts` remains as the
manual escape hatch and shares `utils/map-pool.ts`.

## 3b. The litter path (`handleLitterScan`)

Structurally the same pipeline against a different index and a different model:
`searchLitterByNameV2` → `verifyLitterMatchWithLLM` on a near-tie → self-heal (identical
`hasAnalysisData` / `hasImage` / `isStale` predicates, identical 14-day window) →
`analyzeLitterImage` → image hosting → `cacheLitter` + `logScanRequest`. Log paths are
`litter-cache-hit`, `litter-full-analysis`, `litter-analysis-failed`.

Three deliberate differences from the food path:

| | Food | Litter |
|---|---|---|
| Analysis | 4-way parallel fan-out (`analyzeProductImageParallel`) | **one** `web_search` call at `maxWebSearches` |
| Index | `products2` | `litters` (`config.algolia.litterIndexName`) |
| Cache key | `img-{brand}-{name}` → `product.barcode` | `lit-{brand}-{name}` → `litter.id` |

The single analyze call is a cost decision, not an oversight: a guaranteed analysis is
data one retailer has and another doesn't, so breadth pays; litter attributes are pack
claims every source repeats verbatim, so three sources would buy the same answer at 3×.

**`score === 0` is the same "no data" sentinel** as for food, and the litter prompt says so
explicitly — a litter that could be characterized must score ≥ 1. The `ScannedRecord`
interface in `index.ts` is what lets both categories share `ensureTranslation`,
`resolveUserPhotoFallback` and the self-heal predicates; `Product` and `Litter` both
satisfy it structurally, so the two paths cannot drift apart silently.

`translateProductText` is reused verbatim — `LitterText` is structurally identical to
`ProductText` (the same five renderable fields), so litter gets the same lazy per-language
translation cache for free. Unlike food, though, the canonical-English fields carry **no
hidden contract**: the client's per-cat litter rules read the structured attribute enums,
not a keyword scan of the prose.

---

## 4. Parallel analysis

`analyzeProductImageParallel` is the default (`config.anthropic.useParallelAnalysis: true`).
It fans out to **3 concurrent sources** and keeps the most complete result:

| Source | What it does |
|---|---|
| `manufacturer` | `analyzeOneSource` hinted at the brand's own domain (makers often host the guaranteed analysis when retailers don't) |
| one **country-aware retailer** (`prompts/retailers.ts`, `retailerFor(countryCode)`) | `analyzeOneSource` hinted at zooplus + local Amazon for EU countries (`retailer-eu`), Chewy/Amazon for US/CA (`retailer-na`), Pets at Home for GB/IE (`retailer-uk`), Petbarn for AU/NZ, Amazon elsewhere. The hint label is logged as `retailerHint` |
| manufacturer **pages** | `analyzeFromManufacturerPages` — SerpAPI organic results → `fetchPage` → follow `/product(s)/` links scoring ≥2 slug-token matches → best 2 → `fetchPageText` → `analyzeFromProductPages` extraction call. Location-independent; catches niche/non-US brands that Claude's search index misses |

Phase 3 cut the fan-out from three web-search instances to two: the third cost two searches
per scan (6 → 4, and web search was 70% of a cache miss's cost) while finishing within a
second of the others and adding no measurable recall. **Guardrail:** `chosenHasNutrition` in
`"analyzeProductImageParallel complete"` must stay near its 70% baseline over a week; if it
drops, restore the second retailer. Each `analyzeOneSource` instance gets
`parallelMaxUses: 2` web searches. An instance that throws is caught and becomes `null`
rather than failing the fan-out. Every analyze path accepts `imageBase64: null` (the image
block is simply omitted and the system prompt says no photo is available) — that is how the
nightly job re-analyses rows from their brand/name alone.

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
│   ├── models/litter.ts          Litter interface + LitterModel + attribute enums
│   ├── models/recipe.ts          Recipe + RecipeText + canonicalRecipeText
│   ├── models/food-guide.ts      FoodGuideItem + FoodGuideText + canonicalFoodGuideText
│   ├── models/article.ts         Article + ArticleText + canonicalArticleText
│   ├── jobs/self-heal.ts         nightlySelfHeal — scheduled re-analysis + image backfill (§3d)
│   ├── prompts/                  (§6)
│   │   ├── identify-product.ts   analyze-product.ts    quality-rubric.ts
│   │   ├── analyze-label.ts      back-label extraction (§3c)
│   │   ├── retailers.ts          retailerFor(countryCode) — the fan-out's second source (§4)
│   │   ├── analyze-litter.ts     litter-rubric.ts
│   │   ├── translate-recipe.ts   translate-food-guide.ts
│   │   ├── translate-article.ts
│   │   └── cat-narrative.ts      brand-verdict.ts      rescore-product.ts
│   ├── services/
│   │   ├── anthropic.service.ts  ~2400 lines — every model call + all tool schemas
│   │   ├── algolia.service.ts    V2 fuzzy lookup, gtin lookup/attach, cache R/W
│   │   ├── gtin-resolver.service.ts  barcode → identity (OPFF, then one web search)
│   │   ├── image.service.ts      URL validation, download, sharp optimize, Storage upload
│   │   └── serpapi.service.ts    Google Images + Google organic lookups
│   └── utils/
│       ├── gtin.ts               normalizeGtin — check digit + EAN-13 form (mirrored in Dart)
│       ├── image-helpers.ts      uploadUserPhoto, processProductImage
│       ├── map-pool.ts           bounded-concurrency map (job + backfill script)
│       ├── media-type.ts         sniffMediaType — magic-byte image type detection
│       ├── merge-label.ts        mergeLabelIntoProduct — label data into the target row (§3c)
│       ├── page-fetch.ts         fetchPage, fetchPageText, extractProductLinks, htmlToText
│       ├── scan-log.ts           logScanRequest → Firestore /scans
│       ├── timing.ts             createTimer / mark / summary
│       └── validation.ts         validateImageData
├── scripts/                      one-off ts-node scripts (§11) — not compiled, not linted
│   └── lib/markdown.ts           front-matter + block splitting, shared by convert-markdown
│                                 and import-md-translations (the guards compare their output)
└── lib/                          gitignored build output — NOT truth
```

⚠️ **Never read `lib/` as truth.** It's stale build output and still contains
`lib/prompts/find-image.js`, whose source was deleted.

---

## 6. Prompts and tool schemas

| Prompt file | Exports | Consumer |
|---|---|---|
| `identify-product.ts` | `generateIdentificationPrompt()` | `identifyScanSubject` |
| `analyze-litter.ts` | `generateLitterAnalysisSystemPrompt/UserPrompt()` | `analyzeLitterImage` |
| `litter-rubric.ts` | `LITTER_RUBRIC` | Embedded in the litter analysis system prompt |
| `analyze-product.ts` | `generateAnalysisSystemPrompt()`, `generateAnalysisUserPrompt(identification?, sourceHint?, gtin?)` | `analyzeOneSource`, `analyzeFromProductPages` |
| `analyze-label.ts` | `generateLabelSystemPrompt()` (rubric **first** — the stable prefix), `generateLabelUserPrompt(identification?)` | `analyzeProductLabelImage` |
| `quality-rubric.ts` | `QUALITY_RUBRIC` | Embedded verbatim in **both** the analyze and regrade system prompts |
| `cat-narrative.ts` | `generateCatNarrativeSystemPrompt/UserPrompt`, `CatNarrativeInput`, `DietTip`; internal `CARE_NOTES` (10 conditions), `deriveCombos()`, `LANGUAGE_NAMES` (en/es/fr/hu) | `generateCatNarrative` |
| `brand-verdict.ts` | `generateBrandVerdictSystemPrompt/UserPrompt`, `BrandVerdictInput`, `BrandCatalogContext` | `analyzeBrand` |
| `rescore-product.ts` | `generateRegradeSystemPrompt/UserPrompt`, `RegradeInput` | `regradeProductQuality` (scripts only) |
| `translate-recipe.ts` | `generateRecipeTranslationSystemPrompt/UserPrompt` | `translateRecipeText` (seeder only) |
| `translate-food-guide.ts` | `generateFoodGuideTranslationSystemPrompt/UserPrompt` | `translateFoodGuideText` (seeder only) |
| `translate-article.ts` | `generateArticleTranslationSystemPrompt/UserPrompt` | `translateArticleText` (seeder only) |

`QUALITY_RUBRIC` is the **single source of scoring truth** — change it there, and both
live analysis and batch re-scoring move together. Then re-score the catalog (§11) or the
index carries two incompatible score generations.

**Tool schemas live in `anthropic.service.ts`, not in `prompts/`:**

| Const | Tool(s) | Notes |
|---|---|---|
| `IDENTIFICATION_TOOLS` | `submit_identification`, `submit_litter_identification`, `not_cat_product` | food requires `brand`, `name`, `foodType` ∈ wet/dry/treat/topper/supplement; litter requires `brand`, `name` |
| `LITTER_ANALYSIS_TOOLS` | `submit_litter` | **18 required fields**; every graded attribute has an explicit `unknown` member |
| `ANALYSIS_TOOLS` | `submit_product` | **17 required fields**; numbers bounded 0–100; `pros`/`cons` `maxItems: 3` |
| `NARRATIVE_TOOLS` | `submit_narrative` | `narrative` (~50 words) + `outlook` (~25 words) |
| `SCORE_TOOLS` | `submit_score` | `score` 0–100 |
| `BRAND_VERDICT_TOOLS` | `submit_brand_verdict` | `score`, `headline`, `reasons` (2–4), optional `positives` (≤2) |
| `RECIPE_TRANSLATION_TOOLS` | `submit_recipe_translation` | **6** required; count guard on `ingredients`/`steps`/`body`, plus per-block `markupSignature` + empty-block guards on `body` |
| `FOOD_GUIDE_TRANSLATION_TOOLS` | `submit_food_guide_translation` | 6 required, all scalars — **no count guard needed** |
| `ARTICLE_TRANSLATION_TOOLS` | `submit_article_translation` | 3 required; **count guard** on the `body` block array, **plus** a per-block `markupSignature` guard — items are Markdown |
| inline in `verifyMatchWithLLM` | `submit_match` | `matchIndex`, min −1 (= "none of these") |

---

## 7. Model and inference parameters

One base model — `config.anthropic.model` = **`claude-haiku-4-5-20251001`** — plus two
deploy-time params for the Phase 3 A/B (`firebase-functions/params`, set in `functions/.env`
or at the deploy prompt; a change is a redeploy): `IDENTIFY_MODEL` + `IDENTIFY_MODEL_ROLLOUT_PCT`
(the share of scans whose identify step uses it, bucketed by a hash of `requestId`) and
`LABEL_MODEL` (every label extraction). Both default to the base model. The analyze fan-out
is not switchable. ⚠️ `.value()` on a param is read inside the handler, never at module load.

**Per-model request shapes** (`modelParams`, `webSearchTool` in `anthropic.service.ts`):
Sonnet 5 / Opus 5 reject `temperature` (400) and run adaptive thinking unless
`thinking: {type: "disabled"}` is sent — identify and label are extraction tasks, so it is;
they also take `web_search_20260209`. Haiku 4.5 keeps `temperature: 0.1` and
`web_search_20250305`. **Any model-switchable call must go through `modelParams`** — a call
site that hardcodes `temperature` 400s the moment the param names Sonnet. The wire `models`
field and the `"anthropic usage"` / `"scan timings"` lines carry the model actually used, and
the client reports it as `identify_model` / `label_model` on the outcome events.

| Call site | max_tokens | temp | tool_choice | prompt cache |
|---|---|---|---|---|
| `identifyScanSubject` | 256 | 0.1 (Haiku) / thinking off (Sonnet) | `{type: "any"}` | — |
| `analyzeLitterImage` | 8192 | 0.1 | `{type: "auto"}` | ephemeral (system) |
| ↳ force-submit fallback | 4096 | 0.1 | `{type: "tool", name: "submit_litter"}` | ephemeral |
| `analyzeOneSource` | 8192 | 0.1 | `{type: "auto"}` | ephemeral (system) |
| ↳ force-submit fallback | 4096 | 0.1 | `{type: "tool", name: "submit_product"}` | ephemeral |
| `analyzeFromProductPages` | 4096 | 0.1 | `{type: "tool", name: "submit_product"}` | ephemeral |
| `analyzeProductLabelImage` | 4096 | 0.1 (Haiku) / thinking off (Sonnet) | `{type: "tool", name: "submit_product"}` | ephemeral (system, rubric first — crosses Sonnet's 1,024-token minimum, so on Sonnet expect `cacheReadInputTokens > 0` from the second call) |
| `identifyByGtinSearch` | 1024 | 0.1 | `{type: "auto"}` + `web_search` `max_uses: 1` | — |
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
| `algolia.litterIndexName` | `litters` |
| `algolia.useLLMVerification` | `true` |
| `storage.bucketName` | `yucat-d8fb5.firebasestorage.app` |
| `storage.productsFolder` | `products/` |
| `functions.timeoutSeconds` / `corsEnabled` | `300` / `true` |
| `anthropic.*` | model, `temperature: 0.1`, `maxWebSearches: 3`, `useParallelAnalysis: true`, `parallelMaxUses: 2`, `useManufacturerPageFallback: true`, `pageFallbackMaxPages: 3` |
| `functions.*` | `timeoutSeconds: 300`, `labelTimeoutSeconds: 90`, `memory: "1GiB"`, `concurrency: 10` |
| `selfHeal.*` | `reanalyzeAfterMs` (14 d), `schedule`, `timeZone`, `timeoutSeconds: 540`, `budgetMs: 480000`, `reanalyzePerRun: 15`, `imageBackfillPerRun: 40`, litter caps (§3d) |
| params | `IDENTIFY_MODEL`, `LABEL_MODEL`, `IDENTIFY_MODEL_ROLLOUT_PCT`, `SELF_HEAL_DRY_RUN` (§7, §3d) |

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
             lastAnalysisAttempt lastImageAttempt translations
Phase 1/2:   gtin gtinSource ("scan" | "resolver")
             analysisSource ("web" | "label") labelRequestId
```

**`translations`** is `Record<lang, ProductText>` — cached translations of the five
renderable fields (`format`, `packageSize`, `description`, `pros`, `cons`), keyed by language
code, with no `en` entry (that's the flat fields). Filled **lazily**: the first request for a
language pays one small Haiku call (`translateProductText`), everyone after reads it off the
record. `name`/`brand` are never translated (they're transcribed off the packaging), and
`ingredients` isn't either (the app never renders it).

⚠️ **The flat fields stay canonical English on purpose.** The Flutter client's per-cat rules
engine (`cat_product_assessment.dart`) keyword-scans `pros + cons + name + brand` against
hardcoded English needles (`'chicken'`, `'renal'`, `'corn'`…) to build the per-cat verdict.
Localizing them in place would silently break allergen, kidney and filler detection. The
client renders `localizedText` and assesses on the canonical.

The V2 fields are optional so pre-V2 cached rows still round-trip cleanly.

`src/models/litter.ts` — `Litter` / `LitterModel` / `LitterText`, plus the attribute enums
(`LitterMaterial`, `LitterLevel`, `Tristate`) that the tool schema's `enum` lists are built
from, so schema and type cannot drift. Attributes are graded, not measured, and `unknown`
is a first-class value the prompt is told to prefer over a guess.

**Algolia** — two indexes: `products2` (`{objectID: cacheKey, ...Product}`) and `litters`
(`{objectID: id, ...Litter}`). Separate rather than one index with a `category` facet
because the Flutter search tab queries `products2` unfiltered and maps every hit through
the food display model — a litter row in there would render as a food with no macros.

⚠️ **Cache identity is text-derived, not a real barcode.** The key is
`img-{brand}-{name}` lowercased with whitespace → `-`, written to **both** `objectID` and
`product.barcode`. Any drift in how Haiku transcribes a product name creates a duplicate
row — which is exactly why `identify-product.ts` insists on transcribing only printed text
and no marketing taglines. Those identification strings are used verbatim for both the web
search and the cache identity.

**`gtin` is the real barcode** (Phase 1): the normalised EAN-13 the client read off the
still, stored as an optional field with `gtinSource: "scan" | "resolver"`, declared as a
`filterOnly(gtin)` facet on both indexes (`scripts/configure-algolia.ts`,
`configure-litter-index.ts`) and looked up with `filters: 'gtin:"…"'` before identify.
`objectID` stays the text key so nothing needs migrating; rows converge on barcode identity
as scans hit them (`attachGtin`). ⚠️ **Run both configure scripts before deploying Phase 1**
— with the facet undeclared a `filters: 'gtin:"…"'` query returns **0 hits with no error**
(verified against the live index, and the same for any unknown attribute), so every scan
silently takes the old path and `"Algolia gtin lookup"` logs `hit: false` forever. The only
way to confirm the facet is the index settings (admin key or the Algolia MCP), not a query. Two text-keyed rows can still describe one gtin (transcription drift
before the barcode was known); the nightly job (Phase 3) is where those get merged.

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
| `backfill-images.ts` | Manual escape hatch for what `nightlySelfHeal` (§3d) now does every night: finds + hosts images for products with `score > 0` and empty `imageUrl`. Stamps `lastImageAttempt` even on failure. Flags: `--dry-run`, `--limit=N`, `--concurrency=N` (5). |
| `configure-litter-index.ts` | Applies `litters` index settings + litter synonyms. ⚠️ **Must be run once before the litter cache can work** — `searchLitterByNameV2` soft-filters on `brand`, and Algolia rejects a filter on an undeclared facet, so until then every lookup errors silently and every litter scan pays for a full analysis. |
| `convert-markdown.ts` | Converts authored Markdown (`<dir>/articles/*.md`, `<dir>/recipes/*.md`, YAML front matter) into `scripts/data/<kind>.json`. Splits the body on blank lines into the block array, and **drops the leading `# H1`** — the detail screen already renders the title. ⚠️ Use **`--replace`** when the authored folder *is* the catalogue: the default merges by id, which would keep superseded entries alive *and* pay to re-translate them, since the seeders' `--prune` only unpublishes what is absent from the JSON. `--order-base=N` offsets `order` when appending instead. Flags: `--source=<dir>` (required), `--kind=`, `--only=`, `--replace`, `--order-base=`, `--dry-run`. Not compiled, not linted. |
| `apply-translations.ts` | Applies hand-authored translations from `scripts/data/translations/<kind>/<id>.json` when the API path is unavailable (no credit, an outage). ⚠️ A substitute for the **model**, not for the **guards**: it runs the same count / `markupSignature` / empty-block checks, because a hand-written translation drops a bullet just as easily. Writes the identical `translationsSourceHash`, so the two paths interleave freely — a later `seed-*.ts` run reuses whatever this wrote instead of re-translating it. `--languages=fr,es` narrows a run to the languages actually supplied; ⚠️ the hash is then **withheld** until the document carries all five, because writing it early would freeze the item with a hole in it. Flags: `--kind=`, `--only=`, `--languages=`, `--dry-run`. |
| `import-md-translations.ts` | Turns a hand-authored **translated** catalogue (one `.md` per item, same front matter and body as the English, under `<source>/{articles,recipes}/`) into the `scripts/data/translations/<kind>/<id>.json` files `apply-translations.ts` reads, merging one language key in without disturbing the others. Two non-obvious jobs: it splits blocks through the shared `scripts/lib/markdown.ts` so counts match the English exactly, and it applies `image-url-map.json` first — `markupSignature` fingerprints every link target, so a translation still pointing at the pre-rehost photo fails the guard on every image block. Validates with the real `markupSignature` before writing, so a bad file is rejected here rather than at apply time. Flags: `--source=<dir>` (required), `--lang=` (required), `--kind=`, `--only=`, `--dry-run`. |
| `seed-articles.ts` | Seeds the Firestore `articles` collection from `scripts/data/articles.json` — same shape and flags as the other two seeders. ⚠️ `body` is a paragraph **array**, so `translateArticleText` enforces the same count-and-order guard recipes use and discards a mismatched language rather than writing it. ⚠️ The **first** published article by `order` is what Home's news card features, so `order` is an editorial decision. `--languages=es,de` restricts which languages a run may translate; ⚠️ a language left out is **preserved, not dropped**, which is the only thing protecting a hand-authored translation — a document with no `translationsSourceHash` otherwise re-translates *every* language, machine-overwriting it. The hash now advances only when all five languages are present, not merely when this run's slice succeeded. Needs `ANTHROPIC_API_KEY` + Firestore credentials. |
| `seed-food-guide.ts` | Seeds the Firestore `foodGuide` collection from `scripts/data/food-guide.json` — same shape as `seed-recipes.ts` (same flags, same `translationsSourceHash` reuse, same `--prune` semantics), against a simpler model: six scalar text fields, no arrays. ⚠️ An **empty string means "this row does not apply"** (a dangerous food has no `whyGood`/`howToServe`); the prompt is told to return empty fields unchanged, and the client turns `''` into `null`. Needs `ANTHROPIC_API_KEY` + Firestore credentials. |
| `seed-recipes.ts` | Seeds the Firestore `recipes` collection from `scripts/data/recipes.json`, translating each recipe into the five non-English languages. One of the two Firestore seeders (see `seed-food-guide.ts`). Re-runs are near-free: a recipe is re-translated only when its `translationsSourceHash` changes, or with `--force-retranslate`. Flags: `--dry-run`, `--limit=N`, `--only=<id>`, `--concurrency=N` (3), `--languages=` (same preserve-what-is-omitted semantics as `seed-articles.ts`), `--prune` (unpublishes stored recipes no longer in the JSON — documents are kept, and orphan detection is skipped when `--only`/`--limit` narrow the run, since everything else would look orphaned). Needs `ANTHROPIC_API_KEY` + `GOOGLE_APPLICATION_CREDENTIALS`. |
| `upload-food-guide-images.ts` | The last of the per-hero uploaders, still valid because the food-guide photos really are named after the dish rather than the slug: same `IMAGE_OPTIMIZATION` settings (~2 MB PNG → ~70 KB JPEG), same NFC filename normalization, same explicit `FILE_TO_ENTRY` map that hard-errors on an unmapped file rather than guessing. Uploads to `foodGuide/{id}.jpeg`, then writes `imageUrl` to Firestore **and** back into `scripts/data/food-guide.json`. ⚠️ Same ordering trap as the recipe script — run uploads **after** seeds, and commit the updated JSON, or the next seed run nulls `imageUrl` back out. Flags: `--source=<dir>` (required), `--dry-run`. |
| `rehost-content-images.ts` | Hosts **every** article/recipe image on our own bucket — hero *and* the inline `![](…)` images inside the Markdown `body`, which the old per-hero uploaders ignored. Reads the authored folder (`<dir>/{articles,recipes}/*.md` + `<dir>/images/`), resolves each hero to `images/{id}.jpg` (filenames already equal ids, so there is no hand-written map to go stale), downloads anything body-only into `images/_extra/`, optimizes with the shared `IMAGE_OPTIMIZATION`, uploads to `{articles|recipes}/{id}.jpeg` and `-b{n}` for body extras, and **rewrites the `.md` sources in place** so a later `convert-markdown` run cannot reintroduce a remote host. A URL used by several documents is uploaded once and shared. Emits `scripts/data/image-url-map.json`. ⚠️ Replaces `upload-article-images.ts` / `upload-recipe-images.ts`, both deleted. Flags: `--source=<dir>` (required), `--dry-run`, `--no-download`. |
| `rehost-firestore-image-urls.ts` | One-off companion to the above: replays `image-url-map.json` against the live `articles` / `recipes` documents. Rewrites `imageUrl`, `body[]` **and every `translations.<lang>.body[]`** — a URL is byte-identical in every language, so the swap is mechanical and no model is called — then writes the `translationsSourceHash` the *seed file* hashes to, which is what stops the seeders re-translating an already-translated document. ⚠️ The hash is written **only** where translations actually exist: stamping it onto an untranslated document would tell the seeder it is current and freeze it in English. Skips (rather than guesses at) any document whose stored body has drifted from `scripts/data/<kind>.json`. Also rewrites the hand-authored files under `scripts/data/translations/`. Asserts at the end that no `images.unsplash.com` / `live.staticflickr.com` string survives. Flags: `--dry-run`, `--kind=`, `--only=`, `--force`. |
| `purge-cache-entry.ts` | `purge-cache-entry.ts "<brandSubstr>" [nameSubstr]` — deletes matching `img-*` entries so the next scan re-analyzes from scratch. **Deletes without confirmation** — review the printed matches, and tighten the filter if it catches too much. |

The three Firestore seeders (`seed-recipes.ts`, `seed-food-guide.ts`, `seed-articles.ts`) need `ANTHROPIC_API_KEY`
plus Firestore credentials, not Algolia. All three Algolia write-scripts need `ALGOLIA_ADMIN_API_KEY` (search-only keys cannot mutate).
`backfill-images.ts` additionally uploads to Storage, so it needs application-default
credentials — `GOOGLE_APPLICATION_CREDENTIALS` pointing at a service-account JSON, or
`gcloud auth application-default login` with Storage object admin on the bucket.

⚠️ `configure-algolia.ts`'s header comment says it needs `ALGOLIA_API_KEY`; the code
actually reads **`ALGOLIA_ADMIN_API_KEY`**.

> Scripts that write to Algolia or Storage are production mutations — run them only when
> explicitly asked, and prefer `--dry-run --limit=N` first.

---

## 11b. Recipes (`recipes` Firestore collection)

Recipes are the one piece of content that is **authored, not discovered**. There is no
callable, no analysis and no runtime translation — `scripts/seed-recipes.ts` writes the
whole catalogue, every language included, and the Flutter client reads Firestore directly.

- **Document** — `recipes/{slug}`. Shared fields (`category`, `prepMinutes`,
  `requiresFreezing`, `difficulty`, `compatibility`, `imageUrl`, `published`, `order`),
  canonical English flat (`name`, `description`, `ingredients[]`, `steps[]`, `tip`), and
  `translations: Record<lang, RecipeText>` with **no `en` key** — same rule as
  `Product.translations`.
- **Types** — `src/models/recipe.ts`. The wire strings (`frozen-treats`, `easy`,
  `compatible`, …) must match the Dart enums in
  `lib/features/recipes/domain/entities/recipe_entity.dart`; the client parses them with a
  lenient `fromWire` that degrades silently, so drift shows up as wrong categories rather
  than errors.
- **Translation** — `translateRecipeText()` (`services/anthropic.service.ts`) +
  `prompts/translate-recipe.ts` + the `submit_recipe_translation` tool.
  `translateProductText` could not be reused: it translates exactly five flat fields,
  while recipes carry structured `ingredients` and `steps` arrays.
  ⚠️ It enforces **same count, same order** on both arrays and returns `null` on a
  mismatch.
- **`body` is the authored Markdown**, one block per item, and is what the detail screen
  renders. Authored recipes express quantities as prose (`**150 g chicken liver**,
  trimmed`) and carry Portioning / Storage / Variations / Cautions sections that the typed
  fields cannot hold, so `ingredients`, `steps` and `tip` are seeded **empty** and the
  client falls back to them only for older documents that predate `body`. ⚠️ Adding `body`
  to `canonicalRecipeText` changed the key order, so every stored hash was invalidated
  once by design. For products a mismatch desyncs a chip row; for recipes a dropped step
  silently renumbers the instructions the user is following.
- **Staleness** — the document stores `translationsSourceHash` (SHA-1 of the canonical
  text). This is the one place translations *are* invalidated; the product path never
  re-translates, so an English edit there leaves stale copy forever (see §13).
- **Images** — `recipes/{id}.jpeg` in Storage, public URLs in `imageUrl`, uploaded by
  `scripts/rehost-content-images.ts`. Recipes without a photo keep `imageUrl: null` and the
  client renders a tinted placeholder, so a missing image is never a broken state.
  ⚠️ Same rule as articles: the Markdown `body` carries its own inline images at
  `recipes/{id}-b{n}.jpeg`, and front matter must reference the Storage URL.
- **Rules and indexes** — `recipes` is public-read, Admin-SDK-write. Both rules and
  indexes live outside this repo: there is no `firestore.rules`, and `firebase.json` has
  no `firestore` block, so a rules deploy from here would replace the console ruleset
  wholesale.
  ⚠️ The client's list query is `where("published", "==", true).orderBy("order")`, which
  **requires a composite index** on `published ASC, order ASC` — an equality filter plus an
  `orderBy` on a *different* field is never covered by the single-field auto-indexes.
  Created out-of-band with:
  ```bash
  gcloud firestore indexes composite create --project=yucat-d8fb5 \
    --collection-group=recipes \
    --field-config=field-path=published,order=ascending \
    --field-config=field-path=order,order=ascending
  ```

---

## 11c. Food guide (`foodGuide` Firestore collection)

The second authored catalogue, built on exactly the recipes pattern (§11b) — no callable,
no analysis, no runtime translation. `scripts/seed-food-guide.ts` writes every language;
the Flutter client reads Firestore directly and renders the Home swimlane plus a detail
screen.

- **Document** — `foodGuide/{slug}` (`meats`, `fish`, `eggs`, `fruits-vegetables`,
  `dairy`, `dangerous-foods`). Shared fields (`emoji`, `safety`, `imageUrl`, `published`,
  `order`), canonical English flat (`name`, `description`, `whyGood`, `howToServe`,
  `avoid`, `tip`), and `translations: Record<lang, FoodGuideText>` with **no `en` key**.
- **`safety`** is `safe | caution | unsafe`, driving the coloured pill. The Dart
  `FoodSafety.fromWire` degrades unknown values to **`caution`, never `safe`** — a wire
  typo must not read as a green light.
- **Empty string ≠ missing.** An empty text field means "this row does not apply", which
  is how `dangerous-foods` renders only its `avoid` row. Both the prompt and the tool
  schema say to return empty fields unchanged; the Dart mapper normalizes `''` to `null`.
- **Photos** — `foodGuide/{id}.jpeg` in Storage, public URLs in `imageUrl`, uploaded by
  `scripts/upload-food-guide-images.ts`. An entry without a photo keeps `imageUrl: null` and
  the client falls back to its `emoji`, so a missing image is never a broken state.
- **Translation** — `translateFoodGuideText()` + `prompts/translate-food-guide.ts` + the
  `submit_food_guide_translation` tool. Simpler than the recipe path: six scalars, so no
  item-count guard, just per-field fallback to the source. The system prompt leans hard on
  never softening a safety warning — this copy tells owners what is safe to feed.
- **Staleness** — same `translationsSourceHash` (SHA-1 of `canonicalFoodGuideText`).
  ⚠️ The hash is `JSON.stringify` of that object, so **key order is part of it**;
  reordering the fields in `canonicalFoodGuideText` forces a full re-translation.
- **Rules and indexes** — public-read, Admin-SDK-write, managed in the console like
  `recipes`. ⚠️ The client query is `where("published", "==", true).orderBy("order")`, so it
  **requires a composite index**:
  ```bash
  gcloud firestore indexes composite create --project=yucat-d8fb5 \
    --collection-group=foodGuide \
    --field-config=field-path=published,order=ascending \
    --field-config=field-path=order,order=ascending
  ```
  Until both the index and the seeded documents exist, the Home section renders nothing at
  all — error and empty both collapse it, header included.

---

## 11d. Articles (`articles` Firestore collection)

The third authored catalogue, on the recipes pattern (§11b) — no callable, no analysis,
no runtime translation. `scripts/seed-articles.ts` writes every language; the Flutter
client reads Firestore directly.

- **Document** — `articles/{slug}`. Shared fields (`category`, `readMinutes`,
  `imageUrl`, `published`, `order`), canonical English flat (`title`, `excerpt`,
  `body[]`), and `translations: Record<lang, ArticleText>` with **no `en` key**.
- **`category`** is `nutrition | health | behaviour | other`. The Dart
  `ArticleCategory.fromWire` degrades unknown values to `other`, which is a hidden
  bucket — never a filter chip — so a category added server-side ahead of a client
  release still appears under "All".
- **`excerpt` is its own field**, not a clipped `body[0]`. The Home card wants one
  short complete sentence; truncating prose at a character count cuts mid-word.
- **`body` is an array of Markdown blocks** — a paragraph, a heading, or a list per
  item, rendered client-side by `DSMarkdownBlock`. It stays an array rather than one
  Markdown document for two reasons: the client's `Article Read { paragraphs }` event is
  `body.length`, and the item-count guard needs something to count.
- **Two guards, not one.** `translateArticleText` returns `null` on an item-count
  mismatch (as `translateRecipeText` does) **and** on a per-block `markupSignature`
  mismatch. ⚠️ The count guard is blind *inside* an item: with Markdown, a dropped bullet
  or a demoted heading or a localised URL leaves the count untouched. The signature
  fingerprints heading levels, bullet/ordered/quote counts, every link URL and the `**`
  count — deliberately **not** `_italic_`, since underscores are common in prose and URLs
  and would fail legitimate translations more often than they'd catch a real loss.
  For a recipe a dropped step renumbers the instructions; for an article dropped content
  silently deletes advice the reader never learns was missing.
- `max_tokens` on this call is **8192**, not the 4096 its two siblings use: Markdown adds
  syntax to every block and there is no continuation loop here, so a truncated response
  becomes a discarded language.
- ⚠️ **Authoring caveat**: prose containing `*`, `_`, `#` or `[` is now interpreted as
  markup. Nothing in `articles.json` does today, but "5 * 3" or `snake_case` would
  surprise someone.
- **`order` is editorial.** The lowest-ordered published article is what Home's news
  card features, so re-ordering the seed file changes what users see first.
- **Photos** — `articles/{id}.jpeg` in Storage via `scripts/rehost-content-images.ts`.
  An article without one keeps `imageUrl: null` and the card renders its tinted
  placeholder, so a missing image is never a broken state.
  ⚠️ The `body` blocks carry their **own** inline `![](…)` images, hosted at
  `articles/{id}-b{n}.jpeg` (a photo shared by several documents is uploaded once
  under the first one that uses it). Front matter must reference the Storage URL —
  `convert-markdown.ts` copies `image:` through verbatim and its
  `entry.imageUrl ?? prior.imageUrl` fallback only fires when there is no `image:`
  at all, so an authored third-party URL silently overwrites a hosted one.
- **Hand-authored translations.** A language can be written by a person instead of
  the model: author it as Markdown mirroring the English, run
  `import-md-translations.ts --lang=<code>`, then
  `apply-translations.ts --languages=<code>`. ⚠️ Two guards make this safe and both
  are load-bearing — the importer maps image URLs through `image-url-map.json`
  (`markupSignature` fingerprints link targets) and the seeders' `--languages=`
  preserves what it omits, because a document with no `translationsSourceHash`
  re-translates *every* language and would machine-overwrite the hand-written one.
- **Staleness** — same `translationsSourceHash` (SHA-1 of `canonicalArticleText`).
  ⚠️ Key order in that function is part of the hash. Note prompt changes do **not**
  invalidate it, so a prompt edit alone re-translates nothing — an article re-translates
  the first time its English body is edited, or under `--force-retranslate`.
  All three seeders now advance the stored hash **only when every language succeeded**;
  previously it advanced unconditionally, which made their own "Re-run to retry" advice
  false and froze a failed language until someone remembered `--force-retranslate`.
- **Rules and indexes** — public-read, Admin-SDK-write, managed in the console.
  ⚠️ Needs its own composite index:
  ```bash
  gcloud firestore indexes composite create --project=yucat-d8fb5 \
    --collection-group=articles \
    --field-config=field-path=published,order=ascending \
    --field-config=field-path=order,order=ascending
  ```
  Until both the index and the seeded documents exist, Home's news card renders
  nothing at all — error and empty both collapse it.

---

## 12. Errors and logging

**The scan callable throws typed `HttpsError`s** (`toHttpsError` in `index.ts`), which the
client reads as `ScanException.code`:

| Code | When |
|---|---|
| `unauthenticated` | no `request.auth` |
| `invalid-argument` | missing `image`, or a HEIC payload (sniffed, not declared) |
| `resource-exhausted` | the Anthropic error message matches `/credit balance/i` — the one outage mode with no fallback. Also logs `"anthropic credit exhausted"` at `error` level, which is what the GCP alert keys on (below) |
| `internal` | everything else, message `Error processing product image: …` |

The two onboarding callables still throw plain `Error`s (surfaced as `INTERNAL`).

Retry exists **only** for Anthropic calls (`withRetry`). SerpAPI, page fetch, Algolia and
Storage have no retry — they degrade to `[]` / `""` / a swallowed `logger.warn`. Every
outbound fetch is now **bounded**: SerpAPI 6 s, image HEAD 3 s, image download 8 s (and
≤ 8 MB), page fetch 8 s. A hanging CDN used to produce a 128 s `imageHost` step.

**Alerting** (console steps, not in the repo): Anthropic Console → Billing → enable
auto-reload and the low-balance email. In GCP, a log-based metric on
`jsonPayload.message="anthropic credit exhausted"` and one on `"Memory limit"`, each with an
alerting policy (> 0 in 5 min) to the owner's email.

Logging uses `firebase-functions/logger` with a structured object always ending
`structuredData: true`. `logger.info` for milestones and timing, `logger.warn` for
degraded-but-recovered paths, `logger.error` only in the top-level scan catch. Searchable
messages worth knowing:

- `"anthropic usage"` — **one line per model call**, joinable to a scan by `requestId`:
  `label` (`identify`, `analyze:manufacturer|retailer-a|retailer-b|pages|litter`,
  `…:forceSubmit`, `verifyMatch`, `translate`), `model`, `inputTokens`, `outputTokens`,
  `cacheCreationInputTokens`, `cacheReadInputTokens`, `webSearchRequests`, `stopReason`.
  Sum per `requestId` for cost per scan. Expect the cache counters to be **0** on Haiku 4.5
  (see §7) — that is the measurement, not a bug in the logging.
- `"scan timings"` — per-step breakdown + `path: not-identified | cache-hit | full-analysis`
  (+ `identifyReason` on `not-identified`)
- `"analyzeProductImageParallel complete"` — instances, succeeded, `parallelMs`, `chosenHasNutrition`
- `"analyzeProductImage web_search timing"`
- `"Algolia v2: ranked candidates"`
- `"findProductImageUrl using SerpAPI candidate"` / `"findProductImageUrl found no image"`
- `"Cache hit is a stale no-data entry — re-analyzing"` / `"Cache hit missing image — attempting image backfill"`

---

## 13. Known gaps

Accepted behavior, documented so it isn't rediscovered as a surprise:

- **No auth check on the two onboarding callables.** The scan callable requires
  `request.auth` (§2); `generateCatNarrative` and `analyzeBrand` still accept anonymous
  calls — acceptable while nothing calls them.
- **Client gives up before the server does.** Scan: client 120s vs server 300s. Narrative
  and brand: client 30s vs server 60s.
- **HEIC is refused, not converted.** `sniffMediaType` returns `invalid-argument` for a
  genuine HEIC payload. Current clients transcode to JPEG before upload, so only
  pre-compression builds can hit it.
- **Prompt caching is a no-op on Haiku 4.5.** Its minimum cacheable prefix is 4,096 tokens
  and the analyze system prompt (+ tool schema) is ~2,000, so every `cache_control` marker
  silently creates nothing (`cacheCreationInputTokens: 0` in `"anthropic usage"`). Sonnet 5
  caches from 1,024. The markers are left in place for the day the prompt or model changes.
- **Score 0 is a sentinel, not a grade.** `score > 0` is what `hasAnalysisData`,
  `pickBestProduct`, `rescore-products.ts` and `backfill-images.ts` all test. A rubric
  change that lets a real product legitimately score 0 breaks the self-heal logic.
- **Provisional vs final image key can diverge.** The parallel SerpAPI upload names the
  file from the *identification* brand/name; the final cache key uses the *analyzed* ones.
  When they differ the URL still works, but `products/{barcode}.jpeg` is not a reliable
  lookup convention.
- **The ambiguity guard couples two files.** `lookupProductByNameV2` returns
  `match: null` on a near-tie *expecting* `index.ts` to call `verifyMatchWithLLM` over its
  `hits`. Turning off `useLLMVerification` converts those near-ties into full, expensive
  re-analyses rather than falling back to the top hit.
- **Write-backs are sanitized.** A cache-hit row is the raw Algolia hit (with `objectID`,
  `_highlightResult`, …); `cacheProduct`/`cacheLitter` strip that envelope before writing.
  Rows written before this carry one or more nested `_highlightResult` copies — harmless,
  cleaned up on their next write.
- **`sharp` failure is silent** — the dynamic import is caught, and the original
  unoptimized buffer is stored. It shows up only as unusually large images plus a
  `"Sharp not available"` warning.
- **Dead code**: `getCachedProduct` and the V1 `searchProductByName` are unexercised;
  `mime` is a declared but never-imported dependency.
- **`rescore-products.ts` targets `products2` only**, so a change to `LITTER_RUBRIC` cannot
  be back-applied to cached litter rows. (Imageless and score-0 litter rows *are* healed by
  the nightly job since Phase 3.)
- **Litter images are hosted under `products/`**, keyed `lit-{brand}-{name}`. They do not
  collide with food keys, but `products/` is not a category-scoped folder — do not treat
  the prefix as a namespace guarantee.
- **The litter path has no analyze fan-out**, by design (§3b). If attribute coverage
  turns out to be thin on obscure brands, that is the first knob to turn — and the reason
  it is a knob rather than an oversight is written down there.
- **No tests exist**, despite `firebase-functions-test` being installed. There is no CI
  config under `functions/`.
