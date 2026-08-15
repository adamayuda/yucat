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
- **Analytics**: Firebase Analytics + Mixpanel
- **Device features**: `camera` + `image_picker` (product-image scan and cat photos)
- **UI**: Bricolage Grotesque (bundled variable font — display/headings) + DM Sans (body, via `google_fonts`); `lottie` (animations), `smooth_page_indicator`, `url_launcher`

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
- **onboarding**: First-launch flow — a 12-phase `PageView` (the `OnBoardingPhase` enum *is* the order, and its ordinal is the Mixpanel `step_index`), then a router push-chain out of the bloc: cat-create wizard → current-food scan → result → paywall. `onboarding_completed` is written **when the cat is created**, before the scan and paywall. `RemoteConfigService.onboardingScanEnabled` skips the scan+result beats. **Full details in `lib/features/onboarding/README.md`** — read it before touching the feature
- **bottom_navigation_bar**: Shared tab shell for the Main route (Search / Home / Profile)
- **profile**: Hub screen — Your Cats, Saved Products and Scan History rows with counts, legal links, and a debug-only Reset Onboarding row

**Auth**
- **auth**: Anonymous Firebase authentication

**Cat lifecycle**
- **cat**: Cat profile CRUD (Firestore + Storage). Also hosts two rules engines in `presentation/utils/` — `cat_diet_recommendations.dart` (owner-facing tips) and `cat_product_recommendations.dart` (per-cat product picks). See *Product Assessment Logic* below
- **cat_create**: Multi-step cat profile creation wizard (see *Core domain* below)
- **cat_listing**: Lists the user's cats
- **cat_detail**: Single-cat detail view

**Product discovery**
- **home**: Dashboard + scanner entry point; image scan calls `fetchProductByImageV2`
- **search** / **search_products**: Algolia-powered product/brand search
- **brand**: Data-only feature (no presentation layer) backing brand search
- **product**: Calls the `fetchProductByImageV2` Cloud Function and maps the response to `ProductEntity`
- **product_listing**: Product list (e.g. by brand or search results)
- **product_detail**: Product detail with cat-specific assessment; bookmark icon toggles save state via `SavedProductsRepository`
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
- **analytics**: Firebase Analytics + Mixpanel implementations behind a shared `AnalyticsDataSource`

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

**Product entity** — nutrient fields used by the assessment: `protein`, `fat`, `carbs`, `fiber`, `moisture`, `ash` (`calories` lives on `ProductDisplayModel`, not the domain entity). Plus `name`, `brand`, `score`, `imageUrl`, `pros: List<String>`, `cons: List<String>`, and the V2-era display fields: `isAiIdentified: bool` (true for any image-scanned product — note the `productDetailAiIdentifiedPill` string exists in all six ARBs but has **zero call sites**, so no pill is actually rendered), `format` (display string e.g. "Wet pâté", joined with `packageSize` into `ProductDisplayModel.formatLine` for the hero subtitle), `packageSize` (e.g. "85g pouch"), `description` (2-3 sentence nutrition-focused narrative shown under the verdict headline in `AnalysisCard`).

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
- **Breed-specific rules** — ~25 breeds: six named (Maine Coon, Persian, Siamese, Sphynx, British Shorthair, Bengal) plus ~19 more grouped into archetypes (large/muscular, hairless/fine-coat, brachycephalic/long-coat, lean/active, kidney-watch, obesity-prone, diabetes-prone, joint, coat)
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
5. DataSources — `BrandDataSource`, `AnalyticsDataSource`, `AlgoliaSearchDataSource`, `RemoteSearchDataSource`, `AuthDataSource`, `CatDataSource`, `CatNarrativeDataSource`, `BrandVerdictDataSource`
6. Mappers — Brand, Product (multiple variants), Litter (response ↔ entity, entity ↔ model), SearchProduct, Cat (entity ↔ document, entity ↔ model)
7. Repositories — Brand, Analytics, Product, Search, Cat, Auth, Subscription, SavedProducts, SavedLitters, ScanHistory, LitterHistory, RecentSearches, CatNarrative, BrandVerdict
8. UseCases — search/brand, log-event, fetch-product-by-image, cat CRUD, auth, subscription, saved-products (get/isSaved/save/unsave), saved-litters (same four), scan-history, litter-history
9. Services (**6**) — `ScanTrackingService`, `CatTrackingService`, `ReviewPromptService`, `RemoteConfigService`, `NotificationService`, `UserAnalyticsService`
10. BLoCs (**14**, registered as factories) — Splash, OnBoarding, Search, Home, Profile, ProductListing, ProductDetail, LitterDetail, CatListing, CatDetail, CatCreate, Paywall, SavedProducts, ScanHistory

**Important**: BLoCs are registered using a custom `registerBloc` extension that creates both the BLoC factory and a matching `BlocProvider` factory (which is why `provider` is a direct dependency).

⚠️ **Registered but unreachable.** Several chains are fully wired in DI and consumed by nothing. Check before "fixing" them, and don't assume registration implies use:
- `CatTrackingService` — the **whole class**; `canCreateCat` has no callers
- `ScanTrackingService` — the **whole class**. It used to be called by `HomeBloc` for a daily scan streak; the streak was removed (no screen ever rendered it), leaving only the dormant free-tier gating (`canPerformScan`, `getRemainingScans`, …)
- `GenerateCatNarrativeUsecase` → `CatNarrativeRepository` → `CatNarrativeDataSource` — the whole chain. The `generateCatNarrative` Cloud Function is **never called by the app**
- `AnalyzeBrandUsecase` → `BrandVerdictRepository` → `BrandVerdictDataSource` — likewise; `analyzeBrand` is never called
- `AnalyticsFirebaseDataSource` — registered, but `AnalyticsRepositoryImpl` takes only Mixpanel

## Navigation

Uses AutoRoute with declarative routing in `lib/config/routes/router.dart`. Routes are generated into `router.gr.dart` — always rerun `build_runner` after route changes.

Structure:
- **Boot flow**: `SplashRoute` → `OnBoardingRoute` → `MainRoute`
- **`MainRoute`** is a tabbed shell with three children: `SearchRoute`, `HomeRoute` (dashboard), `ProfileRoute`. (Cats is **not** a tab — it's reached from Home and Profile.) `MainPage` uses an **opaque** `tintLavender` Scaffold with the nav floating in a `Stack` — *not* `extendBody` + transparent, which caused a black blink during the `AutoTabsRouter` cross-fade. See `docs/design.md` §8c.
- **Stacked / modal routes**: `ScannerRoute` (full-screen camera, opened from Home), `ProductDetailRoute`, `ProductListingRoute`, `CatDetailRoute`, `CreateCatRoute` (fullscreen dialog), `LitterDetailRoute`, `SavedProductsRoute` and `ScanHistoryRoute` (both opened from Profile, and both listing food and litter), `CurrentFoodRoute` and `ResultRoute` (the tail of the onboarding cascade), `PaywallRoute` (custom slide-up + `opaque: false` transition)
- **Screen-view analytics** auto-emitted via `AnalyticsRouteObserver` (`lib/config/routes/analytics_route_observer.dart`). `OnBoardingRoute` and `CreateCatRoute` are excluded — they handle their own multi-step PageView tracking inside the bloc.

## Themes & Design System

`lib/config/themes/theme.dart` exposes design-system tokens — **prefer these over inline hex / magic numbers**. Brand pink `#ED67CA` is **demoted to logo/splash use only**; black + pastels do all the UI heavy lifting.

- **`DSColors`** — section tints (`tintLavender` / `tintSky` / `tintMint` / `tintCoral` / `tintSand` / `tintAsh`), ink (`inkPrimary` / `inkSecondary` / `inkTertiary` / `inkInverse`), surfaces (`surfaceCard` / `surfaceCardDim`), accents (`accentSuccess` / `accentSuccessSoft` / `accentDanger` / `accentInfo`), `coralAccent` for emphasis chips, `brandPink` (logo only).
- **`DSDimens`** — 4–64 px spacing scale (`sizeXxxs` → `size5xl`).
- **`DSRadii`** — `sm`/`md`/`lg`/`xl`/`pill`. **`DSShadows`** — `e1`/`e2`/`e3`. **`DSMotion`** — durations + curves.
- **`DSTextStyles`** — `displayHero` / `displayLg` / `headlineMd` (Bricolage Grotesque, wght 800 + wdth 75 condensed, via the bundled variable font); `titleMd`, `bodyLg` / `bodyMd`, `label`, `caption` (DM Sans via `google_fonts`).
- Material3 enabled.

Shared components live under `lib/presentation/components/`: `DSCard`, `DSPillButton` (variants `primary` / `secondary` / `danger`) + `DSTextLink`, `DSAppBar`, `DSStateView`, `DSConfirmDialog`, `DSOptionRow`, `DSBottomNav`, `DSChip`, `DSDotIndicator`, `DSStatPill`, `DSQuoteCard`, `LineChartCard`, `MascotSpeechBubble`, `MascotIllustration`, `OnboardingScaffold`, `WizardStepShell`, `CatAvatar`. Loading indicator: `lib/presentation/widgets/app_loading_widget.dart`. Tab shell: `lib/presentation/main/main_page.dart`. Confirmation popups go through `showDSConfirmDialog(...)` — never a raw Material `AlertDialog`.

**Empty / error / loading state illustrations use cat mascots, never raster GIFs.** `MascotIllustration` (cat SVG on a tinted circular halo, framed by gently-twinkling stars, with a native bob/twinkle animation) is the single source — `AppLoadingWidget` and both `DSStateView.error()` / `DSStateView.empty()` render through it. Callers pass a full cat figure (`cat-thinking` / `cat-laught` / `cat-rating`) plus a section `tint` that matches the state's mood (e.g. `tintCoral` for errors). The legacy `assets/images/Illustrations/*.gif` were removed.

**`docs/design.md`** is the design-system source of truth — token rationale (§2-7), component catalog (§8), onboarding flow (§9), open decisions (§12). Update §8 when adding a shared component.

## Firebase Configuration

Firebase is configured via `firebase_options.dart` (generated by FlutterFire CLI). The project uses:
- **Region**: us-central1 (for Functions)
- **Auth**: Anonymous sign-in only
- **Firestore**: cats live in a **top-level `cats` collection** with a `user` DocumentReference field (not a per-user subcollection); image-scan logs at `/scans/{requestId}`
- **Storage**: Cat profile images, plus `products/` (cached product images, shared across all users) and `scans/` (raw user scans, plus `{requestId}-display.jpeg` — a per-user image fallback shown only to the scanner when no web image was found; never promoted to `products/`)
- **Analytics**: Screen view tracking via custom RouteObserver
- **Remote Config**: one key — `onboarding_scan_enabled` (`RemoteConfigService`, default `true`, **fail-open**). A live kill switch: flipping it in the Firebase console drops the scan + result beats from onboarding with no build. 1 h minimum fetch interval

## Backend (Firebase Functions)

> **`functions/CLAUDE.md` is the source of truth for the backend** — the callables and
> their wire shapes, the scan pipeline and self-healing cache, prompts and tool schemas,
> model parameters, config, secrets, the one-off scripts, and known gaps.
> Read it before touching anything in `functions/`. What follows is the summary only.

The backend lives at `functions/` (TypeScript, Node 22), co-located with the Flutter app (single-repo, single deploy). It exposes **three Callable Functions** — `fetchProductByImageV2` (product image scan, food **and** cat litter), `generateCatNarrative` and `analyzeBrand` (both onboarding-only, and both degrade to `null` rather than throwing). Everything model-facing runs on **Claude Haiku 4.5** with forced tool-use for structured output, plus the `web_search_20250305` server-side tool on the analysis path.

Scan pipeline (`functions/src/index.ts`): **identify** (Haiku vision, no web search) → **Algolia cache lookup** against `products2`, with a small Haiku verifier for ambiguous matches → on a miss, **full analysis** (by default a 4-way parallel fan-out — three `web_search` sources plus a SerpAPI-fed manufacturer-page extractor — with the most complete result winning) → **image hosting to Storage + Algolia cache write + scan log to Firestore**. Cached entries self-heal at most once per 14 days.

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

**One plan, entered through a free trial.** The paywall shows a single **annual** plan with a **3-day free trial**. `PaywallBloc._onInitial` filters `availablePackages` to `PackageType.annual`; weekly and monthly still exist in the store and still bill existing subscribers, but are not surfaced. The trial is detected per-store by `utils/trial_info.dart` — Play exposes `SubscriptionOption.freePhase`, StoreKit folds trials and discounts into `introductoryPrice` where **only a zero price means a trial**. Eligibility resolves to `PaywallLoadedState.eligibleTrial`, and every trial claim in the UI is gated on it being non-null (fail-closed). iOS asks `Purchases.checkTrialOrIntroductoryPriceEligibility`; **Android cannot** — that API always returns `unknown` there, so Play's own server-side offer filtering is the signal, which makes the Play offer's "new customers only" setting load-bearing. Trials can only be exercised in store **sandbox** with a fresh tester account, and eligibility is permanent per store account per subscription group.

**The app is a hard paywall — there is no free tier.** Subscription is enforced at two non-limit gates: the final, non-dismissible beat of onboarding (`onboarding_bloc.dart`) and the splash screen for returning non-subscribers who finished onboarding (`splash_bloc.dart`). A trial counts as subscribed (`entitlement.isActive` is true throughout), so neither gate needed changing when the trial landed. Every active user is therefore a subscriber or a trialist.

Because of this, the old free-tier scan/cat limits are **no longer wired into any flow**. The two tracking services remain in `lib/services/` (`scan_tracking_service.dart`, `_maxFreeScans = 3`; `cat_tracking_service.dart`, `_maxFreeCats = 1`) and stay registered in `service_locator.dart`, but their gating methods (`canPerformScan`, `canCreateCat`, `getRemainingScans`, and the `Free Limit Hit` event they emit) are **not called** — kept intact only so a free tier can be re-enabled later. Both services now have **zero live callers** — `ScanTrackingService`'s last one was the scan streak, removed because it had no UI (it only fed a `Streak Milestone` event and a `current_streak` People property). Scanning and cat creation proceed unconditionally.

## Analytics

> **`docs/analytics.md` is the source of truth for analytics** — People properties, the full
> event catalog with per-event property lists, and the six named Mixpanel funnels.
> `docs/mixpanel-setup.md` covers project + dashboard setup. What follows is the summary only.

**Analytics is Mixpanel-primary.** `AnalyticsRepositoryImpl` takes **only** Mixpanel; the Firebase Analytics datasource is registered in DI and used nowhere. Events flow `LogEventUsecase → AnalyticsRepository → mixpanel.track(...)`, bound to the anonymous Firebase UID via `mixpanel.identify(uid)` (called at boot in `SplashBloc`, again in `HomeBloc`). The revamp writes to its own Mixpanel project and stamps every event with `tracking_version = v2`. Screen views are auto-tracked by `AnalyticsRouteObserver`. Event categories (see `docs/analytics.md` for the full list — don't enumerate by hand):

- **Onboarding lifecycle** — Started / Get Started Tapped / Step Viewed / Step Back / Attribution Selected + Skipped / Completed, plus a separate `Onboarding Scan Captured / Succeeded / Failed / Skipped` namespace for the onboarding scan (Home's scan uses different names for the same user action)
- **Cat lifecycle** — creation step started/completed/abandoned, Cat Wizard Step Viewed, Cat Created, profile viewed/updated/edit-started/deleted. `Cat Profile Updated` carries `fields_changed`, computed by a hand-written 11-field diff — a new `CatCreateModel` field must be added there or it silently never appears
- **Product & search** — Product Searched / Selected / Detail Viewed / Image Captured / Image Scan Failed, Search Results Viewed, Product Saved / Unsaved, plus Home-surface events (Home Saved Product Tapped, Home See All Saved Tapped, Home Cat Snapshot Tapped, Home Complete Profile Tapped, Home Active Cat Changed, Home See All Cats Tapped)
- **Paywall & gating** — Paywall Shown / Dismissed, Subscription Completed / Restored, Purchase & Restore Failed. `Subscription Completed` carries `is_trial` — a trial start moves no money, so revenue reporting must separate them. (`Free Limit Hit` and `Plan Selected` are defined but unreachable.)

⚠️ **Two `step_index` funnel contracts** — the `OnBoardingPhase` enum ordinal and the cat-create `_stepNames` index. Both are emitted as analytics dimensions, so reordering either silently renumbers every historical funnel step.

The base methods live on the analytics datasource: `logEvent`, `logScreenView`, `logLogin`, `logSignUp`, `logSearch`.

## Important Notes

- **iOS-first, Android shipping**: RevenueCat is initialized on both platforms (see `main.dart`), but iOS remains the primary target
- **Tests**: there is **no `test/` directory** — unit coverage is currently zero. `integration_test/onboarding_screenshots_test.dart` is the only test file in the repo. (Docs referencing `test/features/paywall/trial_info_test.dart` are describing a file that was removed.)
- **Localization**: every user-facing string goes through `gen_l10n` — **6 locales** (`en` template, `de`, `es`, `fr`, `hu`, `pt`) at 621 keys each, currently in parity. `l10n.yaml` sets `nullable-getter: false`; `pubspec.yaml` has `generate: true`, and the generated `app_localizations*.dart` are committed under `lib/l10n/`. A new string must be added to **all six** ARB files. Localized *art* goes through `localizedAssetPath(...)`; every call site passes all six locales explicitly, but the helper's own `available` **default** is a stale `{en, es, fr, hu}` — a new call site relying on it would silently serve English art to `de` and `pt`. Details in `docs/design.md` §13
- **Push notifications**: OneSignal (`NotificationService`), **iOS only**, and deliberately no permission prompt at init — the ask lives on the onboarding `reminders` screen. The `notifPrimer` screen before it is a mock that requests nothing
- **App Store review prompts**: `ReviewPromptService` gates on 5+ scans and 90+ days because Apple caps the native modal at 3 per 365 days. ⚠️ The onboarding `rating` screen bypasses that gate and calls `InAppReview.requestReview()` directly, spending one modal on every new user
- **Auto-route generation**: Always run `build_runner` after modifying routes
- **Mapper pattern**: Strict separation between domain entities and presentation models — entities never carry display-only fields (e.g. `calories` lives on `ProductDisplayModel`, not the `Product` entity). Note `ProductDisplayModel` itself breaks the layering in practice — see the warning under *saved_products* / *scan_history*
- **Analytics**: All screens auto-tracked via `AnalyticsRouteObserver`
- **Anonymous auth**: Users auto-signed in anonymously on first launch — awaited in `SplashBloc` **before** routing, because the cat wizard used to fail when sign-in only happened at Home
- **Test flags**: `lib/config/test_flags.dart` — `kTestBuildResetOnboarding` and `kTestBuildSkipPaywall`. Both must be `false` for release
- **Design tokens**: Use `DSColors` / `DSDimens` instead of inline hex values or magic numbers — and prefer the BitePal-aligned tokens over the legacy palette still in `theme.dart:6-29` (`DSColors.black` is a mid-grey, not `inkPrimary`). Catalog: `docs/design.md` §2

## Git Workflow - CRITICAL

**NEVER commit or push changes unless explicitly requested by the user.**

- Only commit when the user explicitly says "commit", "save changes", or uses similar language
- NEVER push to remote unless the user explicitly says "push"
- The user has a commit-push skill available - let them use it when they want
- Always ask before performing any git operations if unclear
