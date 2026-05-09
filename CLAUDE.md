# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

YuCat is a Flutter mobile application (iOS-focused) that helps cat owners evaluate cat food products. Users can scan product barcodes, search for products, create cat profiles, and receive personalized product assessments based on their cat's specific characteristics (age, weight, breed, health conditions, etc.).

## Technology Stack

- **Framework**: Flutter 3.32.8 with Dart 3.8.1
- **State Management**: BLoC pattern (`flutter_bloc ^9.1.1`); `provider ^6.1.5+1` is also used in DI for BlocProvider factories
- **Dependency Injection**: GetIt ^9.0.5
- **Navigation**: AutoRoute ^9.2.2
- **Backend Services**: Firebase (Auth, Firestore, Functions, Storage, Analytics)
- **Search**: Algolia (`algolia ^1.1.2`, `algoliasearch ^1.41.0`); search input debounced with `easy_debounce`
- **Subscriptions**: RevenueCat (`purchases_flutter`, iOS only) — custom paywall UI on top of the SDK; the `purchases_ui_flutter` drop-in is **not** used
- **Analytics**: Firebase Analytics + Mixpanel
- **Device features**: `mobile_scanner ^7.1.3` (barcode), `image_picker` (cat photos), `camera`
- **UI**: `google_fonts` (Sora display + Poppins body), `lottie` (animations), `smooth_page_indicator`, `url_launcher`

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
- **splash**: Bootstraps services and routes to onboarding or main
- **onboarding**: First-launch flow; completion persisted in SharedPreferences
- **bottom_navigation_bar**: Shared tab shell for the Main route
- **profile**: User profile screen (currently lightweight; mostly analytics hooks)

**Auth**
- **auth**: Anonymous Firebase authentication

**Cat lifecycle**
- **cat**: Cat profile CRUD (Firestore + Storage)
- **cat_create**: Multi-step cat profile creation wizard (see *Core domain* below)
- **cat_listing**: Lists the user's cats
- **cat_detail**: Single-cat detail view

**Product discovery**
- **home**: Barcode scanner entry point (`mobile_scanner`)
- **search** / **search_products**: Algolia-powered product/brand search
- **brand**: Data-only feature (no presentation layer) backing brand search
- **product**: Fetches product metadata by barcode via Firebase Functions
- **product_listing**: Product list (e.g. by brand or search results)
- **product_detail**: Product detail with cat-specific assessment

**Monetization**
- **paywall**: RevenueCat-driven subscription flow (custom slide-up route)

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
| `age` | `int?` | Years |
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

**Product entity** — nutrient fields used by the assessment: `protein`, `fat`, `carbs`, `fiber`, `moisture`, `ash` (`calories` lives on `ProductDisplayModel`, not the domain entity). Plus `name`, `brand`, `score`, `imageUrl`, `pros: List<String>`, `cons: List<String>`.

**Cat-create wizard** (`lib/features/cat_create/`) — the canonical step order is the `_stepNames` list in `cat_create_bloc.dart` (9 steps): **CatName → ProfilePhoto → Gender → Age → Activity → NeuteredStatus → Coat → HealthConditions → Breed**. Step widgets live in `widgets/steps/`. Step completion and abandonment are emitted as analytics events. The wizard has two contexts: first-launch onboarding (Phase D, anchored CTA "Create profile") and standalone re-edit (CTA "Save changes" — branched in `create_cat_page.dart` on `widget.cat != null`). The bloc detects edit mode via `_originalCat != null` and routes to `UpdateCatUsecase` instead of `CreateCatUsecase`.

### Product Assessment Logic

The core business logic is in `lib/features/product_detail/presentation/utils/cat_product_assessment.dart`. It produces the per-cat pros/cons shown on `ProductDetail` by evaluating products across **6 dimensions**:

- **Age group** (`kitten` / `adult` / `senior`) — e.g. kittens want protein > 35 %; seniors want kidney-friendly low phosphorus and joint support (glucosamine/chondroitin)
- **Weight category** — underweight rewards higher kcal; overweight/obese penalises kcal > 320/100 g and rewards fiber > 4 %
- **Activity level** — low-activity cats penalised for kcal > 360; high-activity rewarded for kcal > 380 and protein > 35 %
- **Neutered status** — neutered cats penalised for high kcal/fat; pregnant/lactating need protein > 35 %, fat > 20 %
- **Breed-specific rules** — Maine Coon, Persian, Siamese, Sphynx, British Shorthair, Bengal each have specialised nutrient/ingredient checks
- **Health conditions** — urinary, kidney, sensitive stomach, food/skin allergies, diabetes, dental, hairball

Decisions combine numeric thresholds on the nutrient fields above with keyword scans of the product's `pros`/`cons` text (e.g. "cranberry", "DL-methionine" for urinary support). For exact thresholds, read the file directly.

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

## Dependency Injection (service_locator.dart)

All dependencies are registered in `lib/service_locator.dart` using GetIt. The initialization order is critical:

1. Mixpanel (analytics)
2. SharedPreferences
3. Dio (HTTP client)
4. FirebaseFunctions (region `us-central1`)
5. DataSources — `BrandDataSource`, `AnalyticsDataSource`, `AlgoliaSearchDataSource`, `RemoteSearchDataSource`, `AuthDataSource`, `CatDataSource`
6. Mappers — Brand, Product (multiple variants), SearchProduct, Cat (entity ↔ document, entity ↔ model)
7. Repositories — Brand, Analytics, Product, Search, Cat, Auth, Subscription
8. UseCases — search/brand, log-event, fetch-product, cat CRUD, auth, subscription
9. Services — `ScanTrackingService`, `CatTrackingService` (free-tier counters + analytics)
10. BLoCs (registered as factories) — Splash, OnBoarding, Search, Home, Profile, ProductListing, ProductDetail, CatListing, CatDetail, CatCreate, Paywall

**Important**: BLoCs are registered using a custom `registerBloc` extension that creates both the BLoC factory and a matching `BlocProvider` factory (which is why `provider` is a direct dependency).

## Navigation

Uses AutoRoute with declarative routing in `lib/config/routes/router.dart`. Routes are generated into `router.gr.dart` — always rerun `build_runner` after route changes.

Structure:
- **Boot flow**: `SplashRoute` → `OnBoardingRoute` → `MainRoute`
- **`MainRoute`** is a tabbed shell with three children: `SearchRoute`, `HomeRoute` (dashboard), `CatListingRoute`. `MainPage` uses `extendBody: true` + transparent Scaffold bg so each tab's `tintLavender` extends behind the floating bottom nav.
- **Stacked / modal routes**: `ScannerRoute` (full-screen camera, opened from Home), `ProductDetailRoute`, `ProductListingRoute`, `CatDetailRoute`, `CreateCatRoute` (fullscreen dialog), `ProfileRoute`, `PaywallRoute` (custom slide-up + `opaque: false` transition)
- **Screen-view analytics** auto-emitted via `AnalyticsRouteObserver` (`lib/config/routes/analytics_route_observer.dart`). `OnBoardingRoute` and `CreateCatRoute` are excluded — they handle their own multi-step PageView tracking inside the bloc.

## Themes & Design System

`lib/config/themes/theme.dart` exposes design-system tokens — **prefer these over inline hex / magic numbers**. Brand pink `#ED67CA` is **demoted to logo/splash use only**; black + pastels do all the UI heavy lifting.

- **`DSColors`** — section tints (`tintLavender` / `tintSky` / `tintMint` / `tintCoral` / `tintSand` / `tintAsh`), ink (`inkPrimary` / `inkSecondary` / `inkTertiary` / `inkInverse`), surfaces (`surfaceCard` / `surfaceCardDim`), accents (`accentSuccess` / `accentSuccessSoft` / `accentDanger` / `accentInfo`), `coralAccent` for emphasis chips, `brandPink` (logo only).
- **`DSDimens`** — 4–64 px spacing scale (`sizeXxxs` → `size5xl`).
- **`DSRadii`** — `sm`/`md`/`lg`/`xl`/`pill`. **`DSShadows`** — `e1`/`e2`/`e3`. **`DSMotion`** — durations + curves.
- **`DSTextStyles`** — `displayHero` / `displayLg` (Sora ExtraBold), `headlineMd`, `titleMd`, `bodyLg` / `bodyMd`, `label`, `caption` (Poppins). Loaded via `google_fonts`.
- Material3 enabled.

Shared components live under `lib/presentation/components/`: `DSCard`, `DSPillButton` + `DSTextLink`, `DSAppBar`, `DSStateView`, `DSOptionRow`, `DSBottomNav`, `DSChip`, `DSDotIndicator`, `DSStatPill`, `DSQuoteCard`, `LineChartCard`, `MascotSpeechBubble`, `OnboardingScaffold`, `WizardStepShell`, `CatAvatar`. Loading indicator: `lib/presentation/widgets/app_loading_widget.dart`. Tab shell: `lib/presentation/main/main_page.dart`.

**`design/design.md`** is the design-system source of truth — token rationale (§2-7), component catalog (§8), onboarding flow (§9), open decisions (§12). Update §8 when adding a shared component.

## Firebase Configuration

Firebase is configured via `firebase_options.dart` (generated by FlutterFire CLI). The project uses:
- **Region**: us-central1 (for Functions)
- **Auth**: Anonymous sign-in only
- **Firestore**: Cat profiles stored per user
- **Storage**: Cat profile images
- **Analytics**: Screen view tracking via custom RouteObserver

## RevenueCat Integration & Free-Tier Limits

RevenueCat is configured **only for iOS** in `main.dart`:
- API Key: `appl_RLrrtMqNXWlaNlEXzZQxUcxkJxw`
- Subscription state is read via `HasActiveSubscriptionUseCase` → `SubscriptionRepository`
- The paywall UI is **custom** (`lib/features/paywall/widgets/paywall_loaded_widget.dart`) on top of `Purchases.getOfferings()` / `Purchases.purchase(PurchaseParams.package(...))` / `Purchases.restorePurchases()`. The `purchases_ui_flutter` drop-in (`RevenueCatUI.presentPaywall()`) is intentionally not used.

Free-tier ceilings (source of truth: `lib/services/`):
- **1 cat max** — `cat_tracking_service.dart` (`_maxFreeCats = 1`)
- **3 scans max** — `scan_tracking_service.dart` (`_maxFreeScans = 3`)

Counters are persisted in SharedPreferences. When a limit is hit, both services emit a `Free Limit Hit` analytics event with `limit_type` and `limit_value`, which the paywall flow uses for context.

## Analytics

Two implementations behind `AnalyticsDataSource`: Firebase Analytics (primary) and Mixpanel (mirror). Screen views are auto-tracked by `AnalyticsRouteObserver`. Event categories tracked (see `lib/features/analytics/` for the full list — don't enumerate by hand):

- **Onboarding lifecycle** — Started / Completed / Skipped
- **Cat lifecycle** — creation step started/completed/abandoned, Cat Created, profile viewed/updated/edit-started/deleted
- **Product & search** — Product Searched / Selected / Detail Viewed / Image Captured / Image Scan Failed, Search Results Viewed
- **Paywall & gating** — Paywall Shown / Dismissed, Subscription Completed / Restored, Free Limit Hit

The base methods live on the analytics datasource: `logEvent`, `logScreenView`, `logLogin`, `logSignUp`, `logSearch`.

## Important Notes

- **iOS-focused**: RevenueCat only initialized on iOS platform
- **Tests**: No project-specific tests yet (the default `widget_test.dart` was removed)
- **Auto-route generation**: Always run `build_runner` after modifying routes
- **Mapper pattern**: Strict separation between domain entities and presentation models — entities never carry display-only fields (e.g. `calories` lives on `ProductDisplayModel`, not the `Product` entity)
- **Analytics**: All screens auto-tracked via `AnalyticsRouteObserver`
- **Anonymous auth**: Users auto-signed in anonymously on first launch
- **Design tokens**: Use `DSColors` / `DSDimens` instead of inline hex values or magic numbers

## Git Workflow - CRITICAL

**NEVER commit or push changes unless explicitly requested by the user.**

- Only commit when the user explicitly says "commit", "save changes", or uses similar language
- NEVER push to remote unless the user explicitly says "push"
- The user has a commit-push skill available - let them use it when they want
- Always ask before performing any git operations if unclear
