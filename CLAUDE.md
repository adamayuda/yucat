# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

YuCat is a Flutter mobile application (iOS-focused) that helps cat owners evaluate cat food products. Users can scan a product by photographing its package, search for products, create cat profiles, and receive personalized product assessments based on their cat's specific characteristics (age, weight, breed, health conditions, etc.).

## Technology Stack

- **Framework**: Flutter 3.41.9 with Dart 3.11.5 (pinned via FVM — see `.fvmrc`)
- **State Management**: BLoC pattern (`flutter_bloc ^9.1.1`); `provider ^6.1.5+1` is also used in DI for BlocProvider factories
- **Dependency Injection**: GetIt ^9.0.5
- **Navigation**: AutoRoute ^9.2.2
- **Backend Services**: Firebase (Auth, Firestore, Functions, Storage, Analytics)
- **Search**: Algolia (`algolia ^1.1.2`, `algoliasearch ^1.41.0`); search input debounced with `easy_debounce`
- **Subscriptions**: RevenueCat (`purchases_flutter`, iOS + Android) — custom paywall UI on top of the SDK; the `purchases_ui_flutter` drop-in is **not** used. See `lib/features/paywall/README.md`.
- **Analytics**: Mixpanel (events, People profiles, Session Replay). `firebase_analytics` ships but sends **no custom events** — it is kept for the Firebase SDK's own auto-collection, which feeds Google Ads / Play install attribution
- **Device features**: `camera` + `image_picker` (product-image scan and cat photos)
- **Markdown**: `flutter_markdown_plus` (the maintained continuation of the discontinued official `flutter_markdown`) renders the **article and recipe body blocks** via `DSMarkdownBlock` — headings, tables, task lists, blockquotes, inline images and links. Content is authored as `.md` files with YAML front matter and converted by `functions/scripts/convert-markdown.ts`. ⚠️ Never use it on a card or row: `MarkdownBody` has no `maxLines`/ellipsis, which every list surface relies on. The **food guide** stays structured on purpose — its icon-and-colour fact rows are layout, not prose
- **UI**: Bricolage Grotesque (bundled variable font — display/headings) + DM Sans (body — **bundled**, static 400/500/600/700, latin + latin-ext); `lottie` (animations), `smooth_page_indicator`, `url_launcher`

## Architecture

The codebase follows **Clean Architecture** with a feature-based organization:

```
lib/
├── features/          # Feature modules (domain, data, presentation)
├── core/              # Shared utilities (subscription, etc.)
├── config/            # App configuration (routes, themes)
├── services/          # Business services (tracking, etc.)
└── presentation/      # Shared UI components
```

### Feature Structure

Each feature follows Clean Architecture layers:

```
feature_name/
├── domain/
│   ├── entities/       # Business models
│   ├── repositories/   # Repository interfaces
│   └── usecases/       # Business logic
├── data/
│   ├── datasources/    # API/Firebase implementations
│   ├── repositories/   # Repository implementations
│   └── mappers/        # Domain ↔ Data conversions
└── presentation/
    ├── bloc/           # BLoC state management
    ├── widgets/        # UI components
    ├── models/         # Presentation models
    └── mappers/        # Entity → Model conversions
```

### Key Features

Grouped by area (each lives under `lib/features/<name>/`):

**App shell / onboarding**
- **splash**: Bootstraps services and routes to onboarding, paywall or main
- **onboarding**: First-launch flow — a 12-phase `PageView` (the `OnBoardingPhase` enum *is* the order, and its ordinal is the Mixpanel `step_index`), then a router push-chain out of the bloc: cat-create wizard → paywall. `onboarding_completed` is written **when the cat is created**, before the paywall. The current-food scan + result beats (and the `onboarding_scan_enabled` flag) were **removed 2026-09-12**. **Full details in `lib/features/onboarding/README.md`** — read it before touching the feature
- **bottom_navigation_bar**: Shared tab shell for the Main route. Four nav slots (Home / Scan / Recipes / Profile) over **three** tabs — Scan is an action that pushes `ScannerRoute`, not a tab, so `bottom_nav_bar.dart` owns the slot↔tab mapping. Visually it's a **full-width frosted bar** (`DSBottomNav`): edge-to-edge, `BackdropFilter` blur under a translucent `surfaceCard` fill, hairline top border, safe-area inset inside the bar, and an outlined icon above a label per slot — `accentInfo` blue when selected, `inkTertiary` otherwise
- **recipes**: Recipes tab — searchable, category-filtered list of home-made cat treats. Backed by the Firestore **`recipes`** collection (doc id = authored slug). Each document holds the canonical **English** copy in flat fields plus a `translations` map keyed by language with **no `en` key** — English *is* the flat fields, the same contract products and litter use. Recipe copy therefore never goes through the ARBs; only chrome does. Unlike products, translations are produced **once, at seed time** by `functions/scripts/seed-recipes.ts`, not lazily per request — recipes are a curated catalogue, so there's no runtime translation on the read path. That script also stores a `translationsSourceHash`, so editing the English re-translates rather than leaving stale copy behind (a gap the product path has). `compatibility` is still a **seeded flag**, not computed — the per-cat rules land later. ⚠️ `RecipeFirestoreDataSource` **throws** on failure rather than returning null like `CatDataSource`/`BrandDataSource` — their repositories collapse null to `[]`, which here would show the "no matches" empty state on a network error instead of the retryable error state. `RecipesRepositoryImpl` memoizes successes per language, because the page re-fires its initial event on every tab visit — and because there are now **two** consumers: the tab, and Home's `HomeRecipesSection`, which runs its own `RecipesBloc` instance off the same repository at no extra Firestore cost. Filtering is in-memory and **undebounced on purpose** (unlike `SearchBloc`, which debounces because it hits Algolia). Tapping a card pushes `RecipeDetailRoute` — a **stateless, bloc-free** screen (hero, meta, ingredients, numbered steps, optional tip); everything it renders arrives on the `RecipeDisplayModel` the route carries, so there's no async work to orchestrate
- **articles**: Editorial cat-care articles. Backed by the Firestore **`articles`** collection (doc id = authored slug), on the **same contract as recipes and the food guide** — canonical English in flat fields, a `translations` map with **no `en` key**, produced once at seed time by `functions/scripts/seed-articles.ts` with a `translationsSourceHash`. Rendered in three places: Home's `HomeArticlesSection` lane (the first 6 by `order` — so `order` is an editorial decision, not just a sort key), `ArticlesRoute` — a pushed list screen with search and category chips — and `ArticleDetailRoute`, a bloc-free screen (hero, blue category pill, headline, read time, body paragraphs). ⚠️ It is the **one detail screen that is stateful**, and only for measurement: a dwell timer plus a `ScrollController` tracking the furthest scroll reached, reported once on `dispose` as `Article Read { seconds, scroll_pct, paragraphs }`. None of that state reaches `build`, so the screen still renders purely from the model the route carries. An article short enough to fit the viewport reports `scroll_pct` **100**, resolved by a post-frame extent check — left at 0 it would be indistinguishable from a bounce. ⚠️ Home's lane **hides itself** on error while `ArticlesPage` **surfaces** it with a retryable `DSStateView.error`. Both stateful consumers own a fresh `sl<ArticlesBloc>()` and close it in `dispose`; Home reads **`all`**, the list screen reads **`visible`**. ⚠️ `HomeNewsCard` — a fourth surface that featured article 0 above the lane — was **unmounted in YUC-24** to lift the lanes above the fold; it is parked in `lib/features/home/widgets/`, and `HomeArticlesSection._skip` went back to **0** with it (it existed only to stop that article showing twice, so leaving it at 1 would drop article 0 from Home entirely). `body` is a **Markdown block array** (rendered by `DSMarkdownBlock`), so `translateArticleText` enforces a count guard **plus** a per-block `markupSignature` guard — the count check is blind inside an item, where a dropped bullet or demoted heading would silently delete advice. It stays an array because `Article Read { paragraphs }` is `body.length` and the count guard needs something to count. ⚠️ Markdown must never reach `title`/`excerpt` — cards rely on `maxLines`, which `MarkdownBody` lacks. `excerpt` is its own field, not a clipped `body[0]`. `ArticleCategory.fromWire` degrades to **`other`**, a hidden bucket excluded from `filterable`. ⚠️ Needs a composite index on `published ASC, order ASC`.
- **food_guide**: Which human foods a cat can eat. Backed by the Firestore **`foodGuide`** collection (doc id = authored slug), on the **same contract as recipes** — canonical English in flat fields, a `translations` map with **no `en` key**, produced once at seed time by `functions/scripts/seed-food-guide.ts` with a `translationsSourceHash` so editing the English re-translates. Rendered in three places: the Home swimlane (photo tile + name), `FoodGuideRoute` — a pushed list screen reached from that lane's "See all", showing every category as a photo row (`FoodGuideListRow`: thumbnail, name, safety pill, chevron) — and `FoodGuideDetailRoute`, a **stateless, bloc-free** screen with a hero, the name, a `FoodSafetyPill`, a description, up to three fact rows and an optional `DSTipCard`. ⚠️ `FoodGuidePage` **surfaces** load errors (`DSStateView.error` + retry) while the Home lane **hides** itself — a feed section may disappear gracefully, a screen the user navigated to may not. Both own a fresh `sl<FoodGuideBloc>()` and close it in `dispose`. ⚠️ The three rows (`whyGood` / `howToServe` / `avoid`) are **fixed slots, each optional**: the document stores `''` for "doesn't apply" and the mapper turns that into `null`, which is how `dangerous-foods` shows only its avoid row. Row headings and the pill labels are ARB chrome; everything else is Firestore content. `FoodSafety.fromWire` degrades unknown values to **`caution`, never `safe`**. Photos are hosted at `foodGuide/{id}.jpeg` in Storage (uploaded by `functions/scripts/upload-food-guide-images.ts`); `FoodGuideEmoji` is the shared fallback across **all three** surfaces when `imageUrl` is null or the fetch fails — the Home tile stopped inlining its own `Text(emoji)` in YUC-14. ⚠️ Needs a composite index on `published ASC, order ASC`, same as recipes.
- **profile**: Hub screen — Your Cats, Saved Products and Scan History rows with counts, legal links, and two QA rows gated on `kQaToolsEnabled` (debug **and TestFlight**, never the App Store): Reset Onboarding, and **Reset test user** (`QaResetService`) — signs out of RevenueCat, OneSignal, Mixpanel and Firebase, clears prefs and restarts from splash as a brand-new uid. ⚠️ Deleting the app does *not* do this: the anonymous Firebase session survives an uninstall in the iOS Keychain, so a reinstall is the same user, same RevenueCat customer, same sandbox entitlement

**Auth**
- **auth**: Anonymous Firebase authentication

**Cat lifecycle**
- **cat**: Cat profile CRUD (Firestore + Storage). Also hosts two rules engines in `presentation/utils/` — `cat_diet_recommendations.dart` (owner-facing tips) and `cat_product_recommendations.dart` (per-cat product picks). See *Product Assessment Logic* below
- **cat_create**: Multi-step cat profile creation wizard (see *Core domain* below)
- **cat_listing**: Lists the user's cats
- **cat_detail**: Single-cat detail view

**Product discovery**
- **home**: Dashboard + scan host. ⚠️ Scan failures render `HomeScanErrorView` (one layout per backend `outcome`, up to three exits: scan again / photograph the back label / search by name) when `HomeErrorState.outcome` is set; transport errors keep the plain `DSStateView.error`. The loading theater has a **Cancel** link (`ScanAbandonedEvent` → a generation counter in `HomeBloc` drops the in-flight result; the backend still finishes and caches). `HomeBloc` also owns the back-label rescue (`LabelImageCapturedEvent` → `AnalyzeProductLabelUsecase` → the same success tail as a scan). It is a **discovery surface**, not a per-cat one: `HomeScanHeader` → `FoodGuideSection` → `HomeRecipesSection` → `HomeArticlesSection` → `HomeMissionCard`, and `HomeDashboardPage` is **stateless**. ⚠️ `HomeGreetingCard` ("Welcome back" + the cat picker), `HomeCatSelector` and — since YUC-24 — `HomeNewsCard` are **parked, not deleted**: unmounted from Home, still in `widgets/`, kept for reuse — nothing imports them today, so don't prune them as dead code. The cat snapshot, completion nudge, diet tips and product picks were removed from Home and now live only on **cat_detail**, and the saved-products preview is gone too (Profile is the only route to `SavedProductsRoute`) — so `HomeLoadedState` carries **only `cats`**, and `HomeBloc` no longer depends on `GetSavedProductsUsecase`. ⚠️ `cats` is now loaded for its **side effect only** — the `UserAnalyticsService.syncCats` People-profile correction, which runs on every Home load (the OneSignal `has_cat` tag was dropped 2026-09-12 to fit the Free plan's six-tag budget). Nothing renders it; don't delete the fetch. **`HomeScanHeader` is the top of the page** and the only stateful widget in it (one repeating `AnimationController` for the viewfinder sweep): one full-bleed blue slab holding the read-only `SearchTextField` *and* the scan pitch, so the top reads as a single section rather than a pill floating above a banner. ⚠️ It bleeds under the status bar by adding `MediaQuery.padding.top` itself, which is why `HomeDashboardPage`'s `SafeArea` passes **`top: false`** and the `ListView` starts at **zero** top padding — restoring either leaves a `pageBackground` band above the blue. Status-bar icons are handled by nested `AnnotatedRegion`s (header light, page dark), so they flip as it scrolls off. ⚠️ **No barcode iconography anywhere in it** — the backend identifies a *photo of the package* and the barcode flow was deleted from both client and functions, so the affordance is a viewfinder framing a pack, never a barcode glyph. `HomeSkeleton`'s `_ScanHeaderBone` mirrors its height and must move with it — YUC-24 trimmed both together (viewfinder 104→**88** px, inner 72→**62**, the search→pitch gap and the slab's bottom inset `sizeL`→**`sizeS`**), since the viewfinder, not the copy, sets the header's floor. Scanning now has **two** entry points — the header CTA and the nav's Scan slot — separated only by `Scan Started { source }`; `HomePage` still hosts the scan theater (`HomeScanningState` → `HomeLoadingWidget`), which is why the nav slot switches to Home before pushing `ScannerRoute` and the header (already on Home) does not. The **recipe swimlane is live**: `HomeRecipesSection` is stateful and owns a **fresh** `sl<RecipesBloc>()` — deliberately *not* the root-owned instance the Recipes tab reads, because `_onInitial` emits `RecipesLoadingState` unconditionally (a shared bloc would wipe the tab's query + category chip) and `RecipesLoadedState.visible` applies those filters. It reads **`all`**, takes the first 6, and closes its bloc in `dispose` — the one line that must NOT be copied from `RecipesPage`. On error or an empty catalogue the section renders nothing at all, header included; the retryable error state stays on the tab. The **food-guide swimlane is live too**, on the identical pattern (own `sl<FoodGuideBloc>()`, closed in `dispose`, hides itself on error or empty); tapping a tile pushes `FoodGuideDetailRoute`, and its "See all" pushes `FoodGuideRoute`. The **articles lane is live too** (`HomeArticlesSection`, own `sl<ArticlesBloc>()` closed in `dispose`, hides itself on error or empty), showing the first six articles. `HomeMissionCard` closes the page — a flat `tintMist` panel with the mission statement beside `cat-idle.json`, an 80 px looping Lottie mascot (YUC-25 replaced the static `cat-thumb.svg`, which the cat-create coat step still uses); pure ARB chrome, no data source and no tap target by design. ⚠️ It passes **`frameRate: FrameRate.composition`** — the loop never ends and a `ListView` keeps it ticking off-screen inside the cache extent, so the default would repaint at the device refresh rate (4× per authored frame on a 120 Hz screen). The three lanes are added to the page `ListView` **unpadded** so they scroll edge-to-edge. ⚠️ All three content lanes (food guide, recipes, articles) mix in `ContentLaneAnalytics` and emit **`Content Lane Viewed { section, item_count }`** once per appearance — the honest denominator for lane conversion, since a lane that hid itself on an empty or failed read must not count as an ignored impression. The guard lives in each State, not in the bloc: `RecipesBloc`, `FoodGuideBloc` and `ArticlesBloc` are each constructed twice concurrently (the Home lane plus its own screen), so a bloc hook would fire twice per page load. ⚠️ `ContentSection.newsCard` and `ContentSource.homeNewsCard` are now **unreachable** — they existed only for the parked news card; keep them so a re-mount restores the old names
- **search** / **search_products**: Algolia-powered product/brand search. `SearchPage` is a **pushed route** (reached from Home's search bar), not a tab — so it owns a fresh `SearchBloc` per push (`sl<SearchBloc>()` in `initState`, closed in `dispose`) rather than sharing the root provider
- **brand**: Data-only feature (no presentation layer) backing brand search
- **product**: Calls the `fetchProductByImageV2` Cloud Function and maps the response to a sealed `ScanResultEntity` — `ScanFoodResult` / `ScanLitterResult` on success, `ScanNotIdentified` (with `notCatProduct` and the identify `reason`) / `ScanAnalysisFailed` (with the `identification` and `productKey`) on the two classified failures; transport and backend errors throw `ScanException(code)` carrying the callable's error code. Every variant carries the backend `path` (`gtin-hit` / `cache-hit` / `full-analysis` / …) and the `gtin` the scanner read. ⚠️ The scanner (`scanner_page.dart`) reads any EAN/UPC in the captured still **on-device** (`mobile_scanner.analyzeImage`, Apple Vision on iOS, never a started camera session) and sends it as `gtin`; there is deliberately no barcode *mode* and no barcode glyph — the gesture stays "photograph the pack". Uploads are transcoded to a 1280 px JPEG (`flutter_image_compress`) *after* the barcode read, since the downscale is what blurs the bars
- **product_listing**: Product list (e.g. by brand or search results)
- **product_detail**: Product detail with cat-specific assessment; bookmark icon toggles save state via `SavedProductsRepository`. The no-data card (score 0) carries a **"Photograph the back label"** CTA — the scan-pipeline Phase 2 rescue: it unwinds to the tab shell, activates Home and pushes `ScannerRoute(mode: ScanMode.label, labelTarget: …)`; `HomeBloc` owns the resulting theater and pushes the rescued product exactly like a scan (`Product Selected { path: label }`). Under the verdict, **`BetterAlternativesSection`** lists up to three catalogue foods that out-fit the product for the *selected* cat (`betterAlternativesFor` in `cat_product_recommendations.dart` — per-cat fit first, quality on a tie, the product itself excluded by the `brand__name` identity). It is nested *inside* `CatAssessmentSection` on purpose: the selected cat is that widget's local state, and a sibling would need it lifted just to stay in sync. Hidden while loading and when nothing beats the product — a great food ends at its verdict. Emits `Alternatives Shown` / `Alternative Tapped` from the widget layer (the bloc knows nothing about cats)
- **saved_products**: User-saved product bookmarks. Toggle from `ProductDetailPage`; list page accessible from Profile. Storage: `SharedPreferences` key `saved_products_v1`. Identity is `${brand}__${name}` (lowercased, trimmed). Analytics: `Product Saved` / `Product Unsaved`. Also hosts the **saved-litters** sibling store (`saved_litters_v1`), which the same page renders as a second section.
- **scan_history**: Every product successfully scanned, most recent first, reached from Profile. Storage: `SharedPreferences` key `scan_history_v1`, capped at **50** entries, same `${brand}__${name}` identity as saved_products. It's a list of **distinct foods, not a scan log** — rescanning the same can replaces the prior entry rather than appending, and there is no timestamp field. The write happens in `HomeBloc` after a successful scan, not in this feature; nothing in `scan_history` ever writes. No analytics of its own. Also hosts the **litter-history** sibling store (`litter_history_v1`, same cap and semantics).

**Cat litter** — the second scannable category, added after food. The camera is a *single* entry point: the backend's identify step classifies the photo as food / litter / neither, and the client branches on `ScanResultEntity` (`ScanFoodResult` | `ScanLitterResult`).

> **`lib/features/litter_detail/README.md` is the source of truth for litter** — the
> attribute model and its `unknown` contract, the per-cat safety rules, the stores, the
> analytics, and the known gaps. Read it before touching litter. Summary only below.

- **litter**: domain entity + response mapper. `LitterEntity` carries **structured attributes** (`material`, `clumping`, `dustLevel`, `scented`, `trackingLevel`, `odorControl`, `flushable`, `biodegradable`, `additives`) instead of macros. Every graded attribute has an explicit `unknown` value — the UI renders nothing rather than guessing.
- **litter_detail**: `LitterDisplayModel`, the result screen, and the two rules utilities. Reached via `LitterDetailRoute` from Home's scan, saved litters and litter history.
- Litter storage is **separate from food's**: `saved_litters_v1` and `litter_history_v1` (capped at 50, same distinct-products-not-a-log semantics). Both go through **one shared codec** (`litter_display_codec.dart`) rather than the hand-rolled per-feature copies the food side has. The saved-products and scan-history pages render food and litter as two sections; the Profile library rows sum both counts.
- **The litter score is universal — there is deliberately no per-cat score and no breed dimension.** Breed does not change what makes a litter good. What *does* vary is a short list of safety/monitoring notes driven by age, health conditions and coat, produced as codes by `cat_litter_safety.dart` and given copy by `litter_flag_copy.dart`. Unlike `cat_product_assessment.dart`, that engine reads the structured enums, never a keyword scan — so none of the canonical-English constraints below apply to litter text.
- ⚠️ **The `litters` Algolia index must be configured before the litter cache works** — `functions/scripts/configure-litter-index.ts`. Its `optionalFilters: brand:` needs `brand` declared for faceting; until then every lookup errors silently and every scan pays for a full analysis.

> ⚠️ **`ProductDisplayModel` is the de-facto cross-feature product currency** — a *presentation* model in `product_detail` imported by search_products, product_listing, scan_history, saved_products, home and profile. Three consequences worth knowing before you touch it: the carbs derivation is **forked three ways** and only `product_detail`'s mapper has the `hasMacroData` guard (so a zero-macro product from search renders carbs 100 %); `saved_products` and `scan_history` each hand-roll their own SharedPreferences codec over the same 18 fields, so adding a field means editing two unrelated features; and **neither codec serializes `dataUnavailable`**, so a score-0 product rehydrates as a red "Poor" verdict computed from all-zero macros — exactly what the flag exists to prevent.

**Monetization**
- **paywall**: RevenueCat-driven subscription flow (custom slide-up route). Single annual plan behind a 3-day free trial — full details in `lib/features/paywall/README.md`

**Cross-cutting**
- **analytics**: Mixpanel only. `AnalyticsRepositoryImpl` wraps a `Mixpanel` instance directly (plus a `replayIdProvider` callback for `$mp_replay_id`) — the orphaned `AnalyticsFirebaseDataSource` was deleted in the analytics audit. ⚠️ **Every event name is a constant in `analytics_events.dart`; there are no inline literals left in `lib/`** — keep it that way, a typo'd literal ships silently and no report ever picks it up. Global `FlutterError.onError` + `PlatformDispatcher.onError` handlers in `main()` emit `App Error`, deduped and capped at 25/session so a per-frame build failure can't flood the project

### Data Flow

1. **Entities** (domain layer) represent pure business objects
2. **Mappers** convert between layers (Document ↔ Entity ↔ Model)
3. **UseCases** execute single business operations
4. **BLoCs** manage UI state and orchestrate use cases
5. **Repositories** abstract data sources (Firestore, Functions, Algolia)

### Core domain models & logic

These are the parts that are slowest to recover from code — keep them current.

**Cat entity** (`lib/features/cat/domain/entities/cat_entity.dart`) — class is `CatEntity`:

| Field | Type | Notes |
|---|---|---|
| `id` | `String?` | Firestore doc id |
| `name` | `String` | Required |
| `age` | `int?` | Months (0–311; e.g. 30 = 2yr 6mo). Display via `ageGroup` or `_formatAge` |
| `weight` | `double?` | Kg |
| `gender` | `String?` | |
| `breed` | `String?` | Maine Coon, Persian, Siamese, Sphynx, British Shorthair, Bengal, … |
| `coatType` | `String?` | |
| `ageGroup` | `String?` | `kitten` / `adult` / `senior` |
| `weightCategory` | `String?` | `underweight` / `normal` / `overweight` / `obese` |
| `activityLevel` | `String?` | `low` / `high` |
| `neutered` | `bool` | Defaults `false` |
| `neuteredStatus` | `String?` | `neutered` / `pregnant` / `lactating` |
| `healthConditions` | `List<String>?` | e.g. `urinary_issues`, `kidney_disease`, … |
| `profileImageUrl` | `String?` | Firebase Storage URL |

**Product entity** — nutrient fields used by the assessment: `protein`, `fat`, `carbs`, `fiber`, `moisture`, `ash` (`calories` lives on `ProductDisplayModel`, not the domain entity). Plus `name`, `brand`, `score`, `imageUrl`, `pros: List<String>`, `cons: List<String>`, two nullable identity fields added in the scan-pipeline Phase 1 — `cacheKey` (the backend's Algolia objectID, `product.barcode` on the wire) and `gtin` (the pack's EAN-13 when known) — which the saved-products and scan-history codecs deliberately **do not** serialise (they exist for the rescue path and analytics, not for persisted rows), and the V2-era display fields: `isAiIdentified: bool` (true for any image-scanned product — note the `productDetailAiIdentifiedPill` string exists in all six ARBs but has **zero call sites**, so no pill is actually rendered), `format` (display string e.g. "Wet pâté", joined with `packageSize` into `ProductDisplayModel.formatLine` for the hero subtitle), `packageSize` (e.g. "85g pouch"), `description` (2-3 sentence nutrition-focused narrative shown under the verdict headline in `AnalysisCard`).

⚠️ **`format`, `packageSize`, `description`, `pros` and `cons` are canonical English and must stay that way.** `cat_product_assessment.dart` keyword-scans `pros + cons + name + brand` against hardcoded English needles to build the per-cat verdict, so translating them in place breaks allergen/kidney/filler detection. The backend returns a parallel `localizedText` object for the app's language (see `functions/CLAUDE.md` §2), which the entity and `ProductDisplayModel` carry as `localized*` fields. **Render the `display*` getters** (`displayDescription`, `displayPros`, `displayCons`, `displayFormat`, `displayPackageSize`) — they fall back to English when a translation is absent — and leave the assessment reading the canonical fields.

**Cat-create wizard** (`lib/features/cat_create/`) — a **12-step** `PageView` (10 input + 2 "did you know" interstitials) in two contexts: first-run onboarding and standalone create/edit.

> **`lib/features/cat_create/README.md` is the source of truth** — the canonical step table, the ~8 parallel magic numbers you must move together, the analytics contract, and the bloc's four bug-fix subtleties. Read it before touching the wizard, and **keep the step order documented there only** (it has been wrong in two places at once before).

The order lives in `_stepNames` (`cat_create_bloc.dart:21`). ⚠️ `step_index` feeds the Mixpanel wizard funnel, so renumbering invalidates historical data. `CatCreateBloc` is the only bloc deliberately **absent** from `main.dart`'s `MultiBlocProvider` — each session owns a fresh instance.

### Product Assessment Logic

The core business logic is in `lib/features/product_detail/presentation/utils/cat_product_assessment.dart`. It produces the per-cat pros/cons shown on `ProductDetail` by evaluating products across **6 dimensions**:

- **Age group** (`kitten` / `adult` / `senior`) — e.g. kittens want protein > 35 %; seniors want kidney-friendly low phosphorus and joint support (glucosamine/chondroitin)
- **Weight category** — underweight rewards higher kcal; overweight is *rewarded* for 280–320 kcal and penalised above 360 (obese above 330), and rewarded for fiber > 4 %
- **Activity level** — low-activity cats penalised for kcal > 360; high-activity rewarded for kcal > 380 and protein > 35 %
- **Neutered status** — neutered cats penalised for high kcal/fat; pregnant/lactating need protein > 35 %, fat > 20 %
- **Breed-specific rules** — **all 52** breeds the picker offers: six named (Maine Coon, Persian, Siamese, Sphynx, British Shorthair, Bengal) plus the rest grouped into archetypes (large/muscular, hairless/fine-coat, brachycephalic/long-coat, lean/active, kidney-watch, obesity-prone, diabetes-prone, joint, coat). ⚠️ The picker's `_breeds` list, this switch and the one in `cat_diet_recommendations.dart` are **three views of one set** and must stay equal — there is no `default:` branch, so a breed missing from a switch scores neutral in silence. That drift is not hypothetical — it was found and fixed: 14 offered breeds had no rules at all, and `siamese` was in this engine but absent from the diet one entirely
- **Health conditions** — 9: urinary, kidney, sensitive stomach, food allergy, skin allergy, diabetes, dental, hairball, heart condition

**The mental model you can't get from skimming the file:**

- **Macros are normalised to dry-matter basis; calories are not.** `_Nm.from()` scales protein/fat/carbs/fiber by `100/(100 − moisture)`. Calories stay as-fed on purpose (energy density as eaten). Every threshold below reads against DMB — which is why a wet food isn't scored as "low protein".
- **Score = `(70 + weightedDelta).clamp(0, 100)`** — 70 is a neutral baseline, not an average. Weighted delta is `(health×15 + weight×12 + age×10 + activity×8 + neutered×6 + breed×5) ~/ 10`; individual findings contribute ±6 to ±12.
- **Weight overrides neutered.** When those two dimensions pull in opposite directions, the entire neutered dimension is discarded, pros/cons lines included — an underweight neutered cat needs calories.
- **Ordering is the ranking.** Pros and cons are concatenated health → weight → age → activity → neutered → breed. `cat_verdict_card.dart` re-declares `_dimensionOrder` as a parallel constant that must stay in sync.
- **`score == 0` is a sentinel** meaning "no analysis", not a grade — it drives `ProductDisplayModel.dataUnavailable` and the neutral no-data UI.

Decisions combine numeric thresholds with keyword scans over **`pros + cons + name + brand`** (e.g. "cranberry", "DL-methionine" for urinary support). Two known false positives, documented so nobody re-derives them: `_kCommonAllergens` matches by plain substring with no word boundary and no "-free" exclusion (so `"contains no chicken"` triggers the allergy penalty, and `'fish'` matches inside `'fish oil'`), and `_kWeightManagement` includes `'light'`, which matches inside `'lightly'`/`'delight'`. For exact thresholds, read the file directly.

There is a **second rules engine**: `lib/features/cat/presentation/utils/cat_diet_recommendations.dart` (owner-facing diet tips, shown on Home and Cat Detail) carries its own copy of the same dimension weights plus `coat` and `hydration`, and keeps one tip per nutrient by priority. Change one engine's weights and you must change the other. `cat_product_recommendations.dart` alongside it ranks Algolia-fed product picks per cat (`_minBaseScore = 70`, `_minFit = 68`) behind a **process-global cache keyed by cat id** — invalidated on cat edit, but not otherwise refreshed until restart.

## Development Commands

### Running the App
```bash
# Run on iOS (default)
flutter run

# Run with specific device
flutter devices
flutter run -d <device-id>

# Run in debug mode
flutter run --debug

# Run in profile mode (performance testing)
flutter run --profile

# Run in release mode
flutter run --release
```

### Code Generation
```bash
# Generate route files (router.gr.dart)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for continuous generation
dart run build_runner watch --delete-conflicting-outputs
```

### Testing & Analysis
```bash
# Run static analysis
flutter analyze

# Run tests
flutter test

# Run specific test file
flutter test test/path/to/test_file.dart
```

### Building
```bash
# Build iOS app
flutter build ios

# Build iOS IPA
flutter build ipa

# Build Android APK
flutter build apk

# Build Android App Bundle
flutter build appbundle
```

### Cleaning
```bash
# Clean build artifacts
flutter clean

# Clean and reinstall dependencies
flutter clean && flutter pub get
```

### Publishing to App Store Connect

When the user asks to "publish" / "ship" / "release to the App Store", do the full
flow end-to-end (it's iOS-only). Confirm the version + that shipping the whole
working tree is intended, then:

1. **Bump the version** in `pubspec.yaml` (`version: 1.2.0+N` — increment the build
   number `+N`; bump the marketing version too if `1.x.y` is already released).
2. **Build the signed IPA** (signing is automatic via Xcode team `8UA5Q9FKL5`):
   ```bash
   fvm flutter build ipa --release   # → build/ios/ipa/yucat.ipa
   ```
3. **Upload** with the App Store Connect API key already on the machine
   (`xcrun altool`; key id `86D7A742NT`, issuer `4ee93d32-da4a-40f7-9365-3e056a27a5f4`;
   the `.p8` lives in `~/.appstoreconnect/private_keys/` and is **not** committed):
   ```bash
   xcrun altool --upload-app --type ios -f build/ios/ipa/yucat.ipa \
     --apiKey 86D7A742NT --apiIssuer 4ee93d32-da4a-40f7-9365-3e056a27a5f4
   ```
   Both steps are long-running — run them in the background and report the result.
4. **The user finishes in App Store Connect** (Claude can't do these): after ~5–15
   min processing the build appears under TestFlight → attach build N to the version,
   add **What's New**, attach any new/changed subscriptions to the same review, then
   **Submit for Review**.

## Dependency Injection (service_locator.dart)

All dependencies are registered in `lib/service_locator.dart` using GetIt. The initialization order is critical:

1. Mixpanel (analytics)
2. SharedPreferences
3. Dio (HTTP client)
4. FirebaseFunctions (region `us-central1`)
5. DataSources — `BrandDataSource`, `AlgoliaSearchDataSource`, `RemoteSearchDataSource`, `AuthDataSource`, `CatDataSource`, `CatNarrativeDataSource`, `BrandVerdictDataSource`, `RecipeSeedDataSource`
6. Mappers — Brand, Product (multiple variants), Litter (response ↔ entity, entity ↔ model), SearchProduct, Cat (entity ↔ document, entity ↔ model), Recipe (entity → model), FoodGuide (document → entity, entity → model), Article (document → entity, entity → model)
7. Repositories — Brand, Analytics, Product, Search, Cat, Auth, Subscription, SavedProducts, SavedLitters, ScanHistory, LitterHistory, RecentSearches, CatNarrative, BrandVerdict, Recipes
8. UseCases — search/brand, log-event, fetch-product-by-image, cat CRUD, auth, subscription (`HasActiveSubscription`, `GetSubscriptionStatus` → `{isActive, isTrial}`, `LinkSubscriptionUser` → `Purchases.logIn` + `setMixpanelDistinctID` at splash), saved-products (get/isSaved/save/unsave), saved-litters (same four), scan-history, litter-history, get-recipes
9. Services (**8**) — `ScanTrackingService`, `CatTrackingService`, `ReviewPromptService`, `RemoteConfigService`, `SessionReplayService`, `NotificationService`, `UserAnalyticsService`, `QaResetService`. ⚠️ Registration order in `_registerServices` is load-bearing: `RemoteConfigService` → `SessionReplayService` → `UserAnalyticsService`, because each reads the one before it
10. BLoCs (**17**, registered as factories) — Splash, OnBoarding, Search, Home, Profile, Recipes, FoodGuide, Articles, ProductListing, ProductDetail, LitterDetail, CatListing, CatDetail, CatCreate, Paywall, SavedProducts, ScanHistory. ⚠️ `FoodGuideBloc` and `ArticlesBloc` are the **second and third** blocs deliberately absent from `main.dart`'s `MultiBlocProvider` (after `CatCreateBloc`) — Home's `FoodGuideSection` and `HomeArticlesSection` are their only consumers and own the instances

**Important**: BLoCs are registered using a custom `registerBloc` extension that creates both the BLoC factory and a matching `BlocProvider` factory (which is why `provider` is a direct dependency).

⚠️ **Registered but unreachable.** Several chains are fully wired in DI and consumed by nothing. Check before "fixing" them, and don't assume registration implies use:
- `CatTrackingService` — the **whole class**; `canCreateCat` has no callers
- `ScanTrackingService` — the **whole class**. It used to be called by `HomeBloc` for a daily scan streak; the streak was removed (no screen ever rendered it), leaving only the dormant free-tier gating (`canPerformScan`, `getRemainingScans`, …)
- `GenerateCatNarrativeUsecase` → `CatNarrativeRepository` → `CatNarrativeDataSource` — the whole chain. The `generateCatNarrative` Cloud Function is **never called by the app**
- `AnalyzeBrandUsecase` → `BrandVerdictRepository` → `BrandVerdictDataSource` — likewise; `analyzeBrand` is never called

## Navigation

Uses AutoRoute with declarative routing in `lib/config/routes/router.dart`. Routes are generated into `router.gr.dart` — always rerun `build_runner` after route changes.

Structure:
- **Boot flow**: `SplashRoute` → `OnBoardingRoute` → `MainRoute`
- **`MainRoute`** is a tabbed shell with three children: `HomeRoute` (dashboard), `RecipesRoute`, `ProfileRoute` — but the nav renders **four** slots, with Scan sitting between Home and Recipes as an action that pushes `ScannerRoute`. (Search is **not** a tab — it's pushed from Home's search bar. Cats isn't either — it's reached from Home and Profile.) Tab identity is duplicated in three files that must stay in sync: `main_page.dart`, `router.dart`, `bottom_nav_bar.dart`. `MainPage` uses an **opaque** `pageBackground` Scaffold with the nav overlaid in a `Stack` — *not* `extendBody` + transparent, which caused a black blink during the `AutoTabsRouter` cross-fade. There is deliberately **no gradient fade** behind the nav: tab content scrolls straight under it, which is what the bar's `BackdropFilter` frosts. See `docs/design.md` §8c.
- **Stacked / modal routes**: `SearchRoute` (pushed from Home's search bar, autofocused), `ScannerRoute` (full-screen camera, opened from Home's hero card or the nav's Scan slot), `ProductDetailRoute`, `ProductListingRoute`, `CatDetailRoute`, `CreateCatRoute` (fullscreen dialog), `LitterDetailRoute`, `RecipeDetailRoute` (pushed from the Recipes tab and Home's lane), `FoodGuideRoute` (the full list, pushed from the food-guide lane's "See all") and `FoodGuideDetailRoute` (pushed from that lane and from the list), `ArticlesRoute` (the full list, pushed from the articles lane's "See all") and `ArticleDetailRoute` (pushed from the lane and the list), `SavedProductsRoute` and `ScanHistoryRoute` (both opened from Profile, and both listing food and litter), `PaywallRoute` (custom slide-up + `opaque: false` transition)
- **Screen-view analytics** auto-emitted via `AnalyticsRouteObserver` (`lib/config/routes/analytics_route_observer.dart`). `OnBoardingRoute` and `CreateCatRoute` are excluded — they handle their own multi-step PageView tracking inside the bloc.

## Themes & Design System

`lib/config/themes/theme.dart` exposes design-system tokens — **prefer these over inline hex / magic numbers**. Brand pink `#ED67CA` is **demoted to logo/splash use only**; black + pastels do all the UI heavy lifting.

- **`DSColors`** — `pageBackground` (`#F8F6FB`, every post-onboarding scaffold), section tints (`tintLavender` / `tintSky` / `tintMint` / `tintCoral` / `tintSand` / `tintAsh`), ink (`inkPrimary` / `inkSecondary` / `inkTertiary` / `inkInverse`), surfaces (`surfaceCard` / `surfaceCardDim`), accents (`accentSuccess` / `accentSuccessSoft` / `accentDanger` / `accentInfo`), `coralAccent` for emphasis chips, `brandPink` (logo only).
- **`DSDimens`** — 4–64 px spacing scale (`sizeXxxs` → `size5xl`).
- **`DSRadii`** — `sm`/`md`/`lg`/`xl`/`pill`. **`DSShadows`** — `e1`/`e2`/`e3`. **`DSMotion`** — durations + curves.
- **`DSTextStyles`** — `displayHero` / `displayLg` / `headlineMd` (Bricolage Grotesque, wght 800 + wdth 75 condensed, via the bundled variable font); `titleMd`, `bodyLg` / `bodyMd`, `label`, `caption` (DM Sans, bundled). ⚠️ `google_fonts` was **removed** — the runtime fetch was 84% of all `App Error` volume (`fonts.gstatic.com` host-lookup failures) and left body text in the platform fallback face whenever it failed. Only 400/500/600/700 ship, so a body `fontWeight` outside those snaps to the nearest bundled face.
- Material3 enabled.

Shared components live under `lib/presentation/components/`: `DSCard`, `DSPillButton` (variants `primary` / `secondary` / `danger`) + `DSTextLink`, `DSAppBar`, `DSStateView`, `DSConfirmDialog`, `DSOptionRow`, `DSBottomNav`, `DSChip`, `DSDotIndicator`, `DSStatPill`, `DSQuoteCard`, `LineChartCard`, `MascotSpeechBubble`, `MascotIllustration`, `OnboardingScaffold`, `WizardStepShell`, `CatAvatar`. Loading indicator: `lib/presentation/widgets/app_loading_widget.dart`. Tab shell: `lib/presentation/main/main_page.dart`. Confirmation popups go through `showDSConfirmDialog(...)` — never a raw Material `AlertDialog`.

**Empty / error / loading state illustrations use cat mascots, never raster GIFs.** `MascotIllustration` (cat SVG on a tinted circular halo, framed by gently-twinkling stars, with a native bob/twinkle animation) is the single source — `AppLoadingWidget` and both `DSStateView.error()` / `DSStateView.empty()` render through it. Callers pass a full cat figure (`cat-thinking` / `cat-laught` / `cat-rating`) plus a section `tint` that matches the state's mood (e.g. `tintCoral` for errors). The legacy `assets/images/Illustrations/*.gif` were removed.

**`docs/design.md`** is the design-system source of truth — token rationale (§2-7), component catalog (§8), onboarding flow (§9), open decisions (§12). Update §8 when adding a shared component.

## Firebase Configuration

Firebase is configured via `firebase_options.dart` (generated by FlutterFire CLI). The project uses:
- **Region**: us-central1 (for Functions)
- **Auth**: Anonymous sign-in only
- **Firestore**: cats live in a **top-level `cats` collection** with a `user` DocumentReference field (not a per-user subcollection); image-scan logs at `/scans/{requestId}`; the recipe catalogue at `/recipes/{slug}`, the food guide at `/foodGuide/{slug}` and articles at `/articles/{slug}` (all public read, Admin-SDK write only). ⚠️ Rules **and indexes** for this project are managed outside the repo — `firebase.json` has no `firestore` block, so deploying a rules file from here would replace the console ruleset wholesale. The recipes, food-guide **and articles** list queries (`where('published', == true).orderBy('order')`) each **need a composite index** on `published ASC, order ASC`; `recipes` and `foodGuide` exist in `yucat-d8fb5`, and `articles` needs its own, created with `gcloud firestore indexes composite create --collection-group=recipes …`. An equality filter plus an `orderBy` on a different field always needs one — the single-field auto-indexes are not enough
- **Storage**: Cat profile images, plus `recipes/{id}.jpeg`, `articles/{id}.jpeg` and `foodGuide/{id}.jpeg` (content photos, public — with `{id}-b{n}.jpeg` siblings for the images *inside* article/recipe Markdown bodies; all self-hosted, no third-party CDN), `products/` (cached product images, shared across all users) and `scans/` (raw user scans, plus `{requestId}-display.jpeg` — a per-user image fallback shown only to the scanner when no web image was found; never promoted to `products/`)
- **Analytics**: Screen view tracking via custom RouteObserver
- **Remote Config**: two keys (`RemoteConfigService`, both **fail-open** — the in-app defaults keep every feature on). `session_replay_enabled` (default `true`) and `session_replay_sample_percent` (default `100`) are the live levers for Mixpanel Session Replay. 1 h minimum fetch interval, so a console flip takes up to an hour plus a cold launch to land

## Backend (Firebase Functions)

> **`functions/CLAUDE.md` is the source of truth for the backend** — the callables and
> their wire shapes, the scan pipeline and self-healing cache, prompts and tool schemas,
> model parameters, config, secrets, the one-off scripts, and known gaps.
> Read it before touching anything in `functions/`. What follows is the summary only.

The backend lives at `functions/` (TypeScript, Node 22), co-located with the Flutter app (single-repo, single deploy). It exposes **four Callable Functions** — `fetchProductByImageV2` (product image scan, food **and** cat litter), `analyzeProductLabel` (the back-label rescue: one vision read of the analysis panel, no web search), `generateCatNarrative` and `analyzeBrand` (both onboarding-only, and both degrade to `null` rather than throwing) — plus one **scheduled function**, `nightlySelfHeal`, which re-analyses score-0 rows and backfills missing images off the request path (`SELF_HEAL_DRY_RUN` param for a candidates-only run). Everything model-facing runs on **Claude Haiku 4.5** with forced tool-use for structured output, plus the `web_search_20250305` server-side tool on the analysis path.

Scan pipeline (`functions/src/index.ts`): **barcode fast path** (an exact `gtin` lookup on both indexes when the client read one off the still) → **identify** (vision, no web search; the model is an A/B param) → **Algolia cache lookup** against `products2`, with a small Haiku verifier for ambiguous matches, and an Open-Pet-Food-Facts→web-search resolver when the photo was unreadable but the barcode wasn't → on a miss, **full analysis** (a 3-way parallel fan-out — the manufacturer plus one country-aware retailer via `web_search`, plus a SerpAPI-fed manufacturer-page extractor — with the most complete result winning) → **SerpAPI image hosting to Storage + Algolia cache write + scan log to Firestore**. Every exit returns a structured `outcome` / `path` / `productKey`. Score-0 rows and missing images are healed by the nightly job, not on the request path.

The identify step classifies the photo as **food, litter, or neither**. A litter scan takes the mirror-image path in `handleLitterScan` — same cache-then-analyze order, same self-heal predicates, same lazy translation — against the separate **`litters`** index, with a single `web_search` analyze call instead of the fan-out (litter attributes are a handful of pack claims every source repeats, so parallel sources would triple the cost for the same answer). The response carries `category` plus `litter` / `litterLocalizedText` alongside the existing product fields, so clients predating litter support are unaffected.

Secrets (all via `firebase functions:secrets:set`, declared in the `onCall` runtime options): `ANTHROPIC_API_KEY`, `SERPAPI_API_KEY`, `ALGOLIA_API_KEY`. The Algolia *search-only* key is committed to `functions/src/config/index.ts` and is safe in source; the **admin** key never is — pass it via env when running the scripts in `functions/scripts/`.

Local dev:
```bash
cd functions
npm install
npm run build      # tsc → lib/
npm run lint
npm run serve      # build + firebase emulators:start --only functions
firebase functions:shell  # interactive REPL
```

Deploy from repo root:
```bash
firebase deploy --only functions                          # all functions
firebase deploy --only functions:fetchProductByImageV2    # single function
```

The barcode flow (`fetchProductByBarcode`) was orphaned and has been removed from both the backend and the Flutter client.

## RevenueCat Integration & Hard Paywall

> **`lib/features/paywall/README.md` is the source of truth for the paywall** — UI, bloc, trial
> detection, store configuration, store IDs, analytics, testing and known gaps.
> Read it before touching anything in `lib/features/paywall/`. What follows is the
> summary only.

RevenueCat is configured for **iOS and Android** in `main.dart` (`appl_…` / `goog_…` keys selected by platform):
- Subscription state is read via `HasActiveSubscriptionUseCase` → `SubscriptionRepository`
- The paywall UI is **custom** (`lib/features/paywall/widgets/paywall_loaded_widget.dart`) on top of `Purchases.getOfferings()` / `Purchases.purchase(PurchaseParams.package(...))` / `Purchases.restorePurchases()`. The `purchases_ui_flutter` drop-in (`RevenueCatUI.presentPaywall()`) is intentionally not used.
- Entitlement id is **`yucat pro`** (`subscription_repository_impl.dart`) — the only store identifier hardcoded in the app.

**One plan, entered through a free trial.** The paywall shows a single **annual** plan with a **3-day free trial**. `PaywallBloc._onInitial` filters `availablePackages` to `PackageType.annual`; weekly and monthly still exist in the store and still bill existing subscribers, but are not surfaced. The one other plan a user can reach is the **second-chance offer** — the same yearly plan with a pay-up-front first year (`annual_offer` custom package), shown as a coupon-style sheet with a **10-minute in-session countdown** (set on the first presentation of a paywall session, in memory; at zero the offer and the close chip are dropped for that session) unprompted on the returning-user gate (once per session), after every cancel of Apple's purchase sheet on either gate, or on demand from the close chip that fades in on the hard gate after 7 s — and only to users still eligible for an introductory offer; see the paywall README §1. The trial is detected per-store by `utils/trial_info.dart` — Play exposes `SubscriptionOption.freePhase`, StoreKit folds trials and discounts into `introductoryPrice` where **only a zero price means a trial**. Eligibility resolves to `PaywallLoadedState.eligibleTrial`, and every trial claim in the UI is gated on it being non-null (fail-closed). iOS asks `Purchases.checkTrialOrIntroductoryPriceEligibility`; **Android cannot** — that API always returns `unknown` there, so Play's own server-side offer filtering is the signal, which makes the Play offer's "new customers only" setting load-bearing. Trials can only be exercised in store **sandbox** with a fresh tester account, and eligibility is permanent per store account per subscription group.

**The app is a hard paywall — there is no free tier.** Subscription is enforced at two non-limit gates: the final, non-dismissible beat of onboarding (`onboarding_bloc.dart`) and the splash screen for returning non-subscribers who finished onboarding (`splash_bloc.dart`). A trial counts as subscribed (`entitlement.isActive` is true throughout), so neither gate needed changing when the trial landed. Every active user is therefore a subscriber or a trialist.

Because of this, the old free-tier scan/cat limits are **no longer wired into any flow**. The two tracking services remain in `lib/services/` (`scan_tracking_service.dart`, `_maxFreeScans = 3`; `cat_tracking_service.dart`, `_maxFreeCats = 1`) and stay registered in `service_locator.dart`, but their gating methods (`canPerformScan`, `canCreateCat`, `getRemainingScans`, and the `Free Limit Hit` event they emit) are **not called** — kept intact only so a free tier can be re-enabled later. Both services now have **zero live callers** — `ScanTrackingService`'s last one was the scan streak, removed because it had no UI (it only fed a `Streak Milestone` event and a `current_streak` People property). Scanning and cat creation proceed unconditionally.

## Analytics

> **`docs/analytics.md` is the source of truth for analytics** — People properties, the full
> event catalog with per-event property lists, and the six named Mixpanel funnels.
> `docs/mixpanel-setup.md` covers project + dashboard setup. What follows is the summary only.

**Analytics is Mixpanel-only.** `AnalyticsRepositoryImpl` takes **only** Mixpanel; the orphaned Firebase Analytics datasource has been deleted (the `firebase_analytics` package stays for auto-collection / ad attribution, but the app logs nothing to it). ⚠️ The Mixpanel plan caps the project at **5 saved reports** and blocks cohorts, saved metrics, experiments and feature flags — budget slots before designing a board. Events flow `LogEventUsecase → AnalyticsRepository → mixpanel.track(...)`, bound to the anonymous Firebase UID via `mixpanel.identify(uid)` (called at boot in `SplashBloc`, again in `HomeBloc`). The revamp writes to its own Mixpanel project and stamps every event with `tracking_version = v2`. Screen views are auto-tracked by `AnalyticsRouteObserver`. Event categories (see `docs/analytics.md` for the full list — don't enumerate by hand):

- **Onboarding lifecycle** — Started / Get Started Tapped / Step Viewed / Step Back / Completed (⚠️ `Attribution Selected` + `Skipped` and the `attribution_source` People property are now **unreachable** — phase 2 became `recipesArticles`; the screen is parked, not deleted) (the `Onboarding Scan …` namespace was removed with the onboarding scan beat on 2026-09-12; historical rows only)
- **Cat lifecycle** — creation step started/completed/abandoned, Cat Wizard Step Viewed, Cat Created, profile viewed/updated/edit-started/deleted. `Cat Profile Updated` carries `fields_changed`, computed by a hand-written 11-field diff — a new `CatCreateModel` field must be added there or it silently never appears
- **Product & search** — Product Searched / Selected / Detail Viewed / Image Captured / Image Scan Failed, Search Results Viewed, Product Saved / Unsaved, `Push Opened { template_name }` (a tapped push, the only Mixpanel-side attribution for the OneSignal Journeys), `Scan Started { source }` (`ScanSource.homeHeader` / `bottomNav`) — fired when the camera *opens*, which is the only signal separating Home's header CTA from the nav's Scan slot, since `Product Image Captured` fires after the capture and carries no surface, ⚠️ **every** Home-surface event is now unreachable — `Home Saved Product Tapped`, `Home See All Saved Tapped`, `Home Cat Snapshot Tapped`, `Home Complete Profile Tapped`, `Home See All Cats Tapped` and `Home Active Cat Changed` — the Home revamp removed the surfaces that emitted them
- **Paywall & gating** — Paywall Shown / Dismissed / CTA Tapped / Restore Tapped, Subscription Completed / Restored, Purchase & Restore Failed. `Subscription Completed` carries `is_trial` — a trial start moves no money, so revenue reporting must separate them. ⚠️ **Two outcomes that are not failures were split out** of the failure events, where they were most of the volume: `Paywall Purchase Cancelled` (backing out of the store sheet) and `Paywall Restore Completed { restored: false }` (nothing to restore — the expected result for a first-time user). Historical rows with `reason = cancelled` / `no_active_subscription` predate the split. **`Paywall Second Chance Shown / Tapped / Dismissed`** cover the discounted-first-year sheet (custom package `annual_offer` → `com.adam.yucat.app.pro.yearly.offer`, pay-up-front intro offer) offered once after the first annual-sheet cancel, only to users still eligible for an intro offer — the one path on which `Plan Selected` now fires; `Subscription Completed` then carries `is_intro_offer` / `intro_price`. (`Free Limit Hit` is defined but unreachable.)

**Session Replay** (`mixpanel_flutter_session_replay`, `lib/services/session_replay_service.dart`) records sessions alongside those events. Three things about it are non-obvious:

- It is a **second, standalone SDK** — pure Dart, with no bridge into `mixpanel_flutter`'s native `track`. So it shares nothing automatically: identity is forwarded by hand in `UserAnalyticsService.identify` (miss that and replays land on a different Mixpanel profile than the events), and `$mp_replay_id` is stamped onto our events by `AnalyticsRepositoryImpl._withReplayId` (miss that and no event links to its replay). Mixpanel's docs claim both happen automatically; they do not here.
- **Release builds only** (`kReleaseMode || kTestBuildForceSessionReplay`), and additionally gated on `session_replay_enabled`. Recording is never started explicitly — `MixpanelSessionReplayWidget` in `main.dart` starts it on foreground, sampling at `session_replay_sample_percent`.
- Masking is **`autoMaskedViews: {AutoMaskedView.image}`** — text is deliberately left readable so replays are worth watching, images are masked because that's where the PII is (cat photos, scan captures). Text *input* (`TextField` &co) is masked by the SDK unconditionally and cannot be unmasked. ⚠️ Any new surface showing user-supplied text outside a text field needs an explicit `MixpanelMask`.

⚠️ **`SessionReplayService.start()` is awaited in `main()` before `runApp`, and must stay there.** `MixpanelSessionReplayWidget` renders its child bare while `instance` is null, then wraps it in three widgets (`LifecycleObserver > InteractionDetector > FrameMonitor`) once one arrives. That is a different widget type in the same slot, so Flutter unmounts the entire app subtree and inflates a fresh one — closing all 13 root blocs while live pages still hold references to them (`Bad state: Cannot add new events after calling close` on the next tap). Resolving the instance before the first build keeps the tree shape fixed. Mixpanel's docs recommend the async-in-`initState` pattern; it is not safe for an app with root-provided blocs.

⚠️ **`step_index` is a position, not an identity — never key a funnel on it.** Both the `OnBoardingPhase` ordinal and the cat-create `_stepNames` index are emitted as analytics dimensions and both get reused when a screen is swapped. This already happened: `attribution` held onboarding index 2 for 485 events before `recipesArticles` took the slot, so historical funnels on index 2 mix two unrelated screens. `OnBoardingPhaseAnalytics.stepId` is the stable, **append-only** alternative (a phase keeps its id forever; a replacement takes the next free number, so 2 stays retired) and is emitted as `step_id` alongside. Break funnels down by `step_name` or `step_id`.

The base methods live on the analytics datasource: `logEvent`, `logScreenView`, `logLogin`, `logSignUp`, `logSearch`.

## Important Notes

- **iOS-first, Android shipping**: RevenueCat is initialized on both platforms (see `main.dart`), but iOS remains the primary target
- **Tests**: there is **no `test/` directory** — unit coverage is currently zero. `integration_test/onboarding_screenshots_test.dart` is the only test file in the repo. (Docs referencing `test/features/paywall/trial_info_test.dart` are describing a file that was removed.)
- **Localization**: every user-facing string goes through `gen_l10n` — **6 locales** (`en` template, `de`, `es`, `fr`, `hu`, `pt`) at 641 keys each, currently in parity. `l10n.yaml` sets `nullable-getter: false`; `pubspec.yaml` has `generate: true`, and the generated `app_localizations*.dart` are committed under `lib/l10n/`. A new string must be added to **all six** ARB files. Localized *art* goes through `localizedAssetPath(...)`; every call site passes all six locales explicitly, but the helper's own `available` **default** is a stale `{en, es, fr, hu}` — a new call site relying on it would silently serve English art to `de` and `pt`. Details in `docs/design.md` §13
- **Push notifications**: OneSignal (`NotificationService`), **iOS only**, and deliberately no permission prompt at init — the ask lives on the onboarding `reminders` screen (phase 10 of 12). The `notifPrimer` screen before it is a mock that requests nothing. The service also writes **exactly six tags** (`funnel_stage`, `paywall_seen`, `is_subscriber`, `is_trial`, `last_active_at`, `last_scan_at` — the OneSignal Free-plan cap) at the existing Mixpanel checkpoints, which is what makes drop-off Segments and the two Journeys possible. ⚠️ Free also caps mobile push at 1,000 MAU from 2026-10-01 and the app is already above it. ⚠️ Because permission is asked so late, users who abandon before `reminders` are tagged but **unreachable**. **`docs/onesignal.md` is the source of truth** — read it before touching push or the tags
- **App Store review prompts**: `ReviewPromptService` gates on 5+ scans and 90+ days because Apple caps the native modal at 3 per 365 days. ⚠️ The onboarding `rating` screen bypasses that gate and calls `InAppReview.requestReview()` directly, spending one modal on every new user
- **Auto-route generation**: Always run `build_runner` after modifying routes
- **Mapper pattern**: Strict separation between domain entities and presentation models — entities never carry display-only fields (e.g. `calories` lives on `ProductDisplayModel`, not the `Product` entity). Note `ProductDisplayModel` itself breaks the layering in practice — see the warning under *saved_products* / *scan_history*
- **Analytics**: All screens auto-tracked via `AnalyticsRouteObserver`
- **Anonymous auth**: Users auto-signed in anonymously on first launch — awaited in `SplashBloc` **before** routing, because the cat wizard used to fail when sign-in only happened at Home
- **Test flags**: `lib/config/test_flags.dart` — `kTestBuildResetOnboarding`, `kTestBuildSkipPaywall` and `kTestBuildForceSessionReplay`. All three must be `false` for release
- **QA tools on TestFlight**: `lib/config/build_env.dart` exposes **`kQaToolsEnabled`** — true in debug builds *and* on TestFlight, false on the App Store. It gates Profile's Reset Onboarding row. ⚠️ The paywall's escape hatch is deliberately **narrower** — `kPaywallEscapeHatchEnabled`, which is `kDebugMode` alone, because **App Review installs carry a `sandboxReceipt` too**: anything on `kQaToolsEnabled` is visible to the reviewer, and a button that skips the hard paywall reads as exactly the beta/demo functionality Guideline 2.2 prohibits. Don't collapse the two flags back together. ⚠️ Use `kQaToolsEnabled`, not `kDebugMode`, for anything else a tester must reach: TestFlight ships a **release** build, so `kDebugMode` is a compile-time `false` there and strips those affordances out of the one build they exist for. Detection is runtime, not compile-time, because the TestFlight build *is* the build submitted for review — iOS names the app receipt `sandboxReceipt` on TestFlight and `receipt` on the App Store, read over a `MethodChannel` in `ios/Runner/AppDelegate.swift`. Resolved by `resolveBuildEnvironment()` awaited in `main()` before `runApp`, and **fails closed**: a non-iOS platform, a missing handler or any error leaves it false
- **Design tokens**: Use `DSColors` / `DSDimens` instead of inline hex values or magic numbers — and prefer the BitePal-aligned tokens over the legacy palette still in `theme.dart:6-29` (`DSColors.black` is a mid-grey, not `inkPrimary`). Catalog: `docs/design.md` §2

## Git Workflow - CRITICAL

**NEVER commit or push changes unless explicitly requested by the user.**

- Only commit when the user explicitly says "commit", "save changes", or uses similar language
- NEVER push to remote unless the user explicitly says "push"
- The user has a commit-push skill available - let them use it when they want
- Always ask before performing any git operations if unclear
