# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

YuCat is a Flutter mobile application (iOS-focused) that helps cat owners evaluate cat food products. Users can scan product barcodes, search for products, create cat profiles, and receive personalized product assessments based on their cat's specific characteristics (age, weight, breed, health conditions, etc.).

## Technology Stack

- **Framework**: Flutter 3.32.8 with Dart 3.8.1
- **State Management**: BLoC pattern (flutter_bloc ^9.1.1)
- **Dependency Injection**: GetIt ^9.0.5
- **Navigation**: AutoRoute ^9.2.2
- **Backend Services**: Firebase (Auth, Firestore, Functions, Storage, Analytics)
- **Search**: Algolia for product search
- **Subscriptions**: RevenueCat (iOS only)
- **Analytics**: Firebase Analytics + Mixpanel

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

- **auth**: Anonymous Firebase authentication
- **cat**: Cat profile CRUD operations (Firestore + Storage)
- **cat_create**: Multi-step cat profile creation wizard
- **cat_listing**: Display user's cat profiles
- **product**: Product fetching by barcode (Firebase Functions)
- **search/search_products**: Algolia-powered product search
- **product_detail**: Product details with cat-specific assessment
- **paywall**: RevenueCat subscription management
- **home**: Main scanner/barcode entry screen
- **analytics**: Firebase Analytics + Mixpanel tracking

### Data Flow

1. **Entities** (domain layer) represent pure business objects
2. **Mappers** convert between layers (Document ↔ Entity ↔ Model)
3. **UseCases** execute single business operations
4. **BLoCs** manage UI state and orchestrate use cases
5. **Repositories** abstract data sources (Firestore, Functions, Algolia)

### Product Assessment Logic

The core business logic is in `lib/features/product_detail/presentation/utils/cat_product_assessment.dart`, which evaluates products based on:
- Cat age group (kitten, adult, senior)
- Weight category (underweight, normal, overweight, obese)
- Activity level (low, high)
- Breed-specific needs (Maine Coon, Persian, Siamese, etc.)
- Neutered status (neutered, pregnant, lactating)
- Health conditions (urinary, kidney, diabetes, allergies, etc.)

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
4. FirebaseFunctions
5. DataSources (Firebase, Algolia)
6. Mappers
7. Repositories
8. UseCases
9. Services
10. BLoCs (registered as factories)

**Important**: BLoCs are registered using a custom `registerBloc` extension that creates both the BLoC factory and BlocProvider factory.

## Navigation

Uses AutoRoute with declarative routing in `lib/config/routes/router.dart`. Routes are automatically generated in `router.gr.dart`.

The app has a nested navigation structure:
- Splash → OnBoarding → Main
- Main contains bottom tabs: Search, Home (scanner), Cats
- Modal routes: ProductDetail, ProductListing, CreateCat, Paywall

## Firebase Configuration

Firebase is configured via `firebase_options.dart` (generated by FlutterFire CLI). The project uses:
- **Region**: us-central1 (for Functions)
- **Auth**: Anonymous sign-in only
- **Firestore**: Cat profiles stored per user
- **Storage**: Cat profile images
- **Analytics**: Screen view tracking via custom RouteObserver

## RevenueCat Integration

RevenueCat is configured **only for iOS** in `main.dart`:
- API Key: `appl_RLrrtMqNXWlaNlEXzZQxUcxkJxw`
- Handles subscription checks for premium features
- Limits: Max 3 cats and 5 scans for free users

## Important Notes

- **iOS-focused**: RevenueCat only initialized on iOS platform
- **No tests**: The `test/` directory is empty
- **Auto-route generation**: Always run `build_runner` after modifying routes
- **Mapper pattern**: Strict separation between domain entities and presentation models
- **Analytics**: All screens auto-tracked via AnalyticsRouteObserver
- **Anonymous auth**: Users auto-signed in anonymously on first launch
- **Git workflow**: NEVER commit or push changes unless explicitly requested by the user
