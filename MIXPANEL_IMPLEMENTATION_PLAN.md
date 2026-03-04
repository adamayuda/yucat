# Mixpanel Event Tracking Implementation Plan

## Executive Summary

This document proposes a comprehensive event tracking strategy for YuCat to understand user behavior, optimize conversion funnels, and improve product decisions using Mixpanel.

**Current State**: Only tracking screen views
**Goal**: Track complete user journey from onboarding → product evaluation → subscription conversion

---

## 📊 Proposed Event Taxonomy

### Event Naming Convention
- **Format**: `[Feature] [Action]` (e.g., `Cat Created`, `Product Scanned`)
- **Use past tense** for completed actions
- **Be specific** but concise

---

## 🎯 Priority 1: Critical User Flows

### 1. Onboarding Funnel
**Objective**: Measure onboarding completion rate and drop-off points

#### Events

| Event Name | Trigger | Properties | Location |
|------------|---------|------------|----------|
| `Onboarding Started` | User lands on first onboarding screen | `source: 'first_launch' \| 'manual'` | `OnBoardingBloc._onOnBoardingInitialEvent()` |
| `Onboarding Step Viewed` | User swipes to next onboarding page | `step_index: int`, `step_name: string` | Already tracked via screen view |
| `Onboarding Completed` | User taps "Start" button | `total_time_seconds: int`, `steps_viewed: int` | `OnBoardingBloc._onOnBoardingCompletedEvent()` |
| `Onboarding Skipped` | User taps "Skip" | `step_index: int`, `step_name: string` | `OnBoardingBloc._onOnBoardingSkipEvent()` |

**Funnel**: `Onboarding Started` → `Onboarding Step Viewed` → `Onboarding Completed`

---

### 2. Cat Profile Management
**Objective**: Understand cat profile creation success rate and user engagement

#### Events

| Event Name | Trigger | Properties | Location |
|------------|---------|------------|----------|
| `Cat Creation Started` | User enters cat creation wizard | `source: 'onboarding' \| 'cat_listing' \| 'product_detail'` | `CatCreateBloc._onCatCreateInitialEvent()` |
| `Cat Creation Step Completed` | User progresses to next wizard step | `step_index: int`, `step_name: string`, `value: any` | `CatCreateBloc._onCatCreateGoToNextStepEvent()` |
| `Cat Creation Step Abandoned` | User goes back a step | `from_step: int`, `to_step: int` | `CatCreateBloc._onCatCreateStepChangedEvent()` |
| `Cat Created` | Cat profile successfully saved | `name: string`, `age_group: string`, `breed: string`, `has_health_conditions: bool`, `health_conditions: string[]`, `neutered: bool`, `has_photo: bool`, `total_cats: int`, `creation_time_seconds: int` | `CatCreateBloc._onCatCreateCatEvent()` |
| `Cat Creation Failed` | Error creating cat | `error_type: string`, `step_index: int` | Error handler in `CatCreateBloc._onCatCreateCatEvent()` |
| `Cat Profile Viewed` | User taps on cat from listing | `cat_id: string`, `source: 'listing' \| 'product_detail'` | Cat detail page (if exists) |
| `Cat Profile Edited` | User updates cat profile | `cat_id: string`, `fields_changed: string[]` | Cat edit functionality |
| `Cat Profile Deleted` | User deletes cat | `cat_id: string`, `total_cats_remaining: int` | Cat delete functionality |
| `Cat Switched` | User changes active cat | `from_cat_id: string`, `to_cat_id: string` | Cat selection functionality |

**Funnels**:
- Creation: `Cat Creation Started` → `Cat Creation Step Completed` → `Cat Created`
- Engagement: `Cat Created` → `Cat Profile Viewed` → `Cat Profile Edited`

---

### 3. Product Discovery Flow
**Objective**: Measure product search and scan success rates

#### Events

| Event Name | Trigger | Properties | Location |
|------------|---------|------------|----------|
| `Barcode Scan Initiated` | User taps camera icon or enters barcode screen | `source: 'home_tab' \| 'search_tab'` | `HomePage` scan button |
| `Barcode Scanned` | Barcode successfully read | `barcode: string`, `scan_method: 'camera' \| 'manual'` | Barcode scanner result |
| `Barcode Scan Failed` | Scan failed or invalid barcode | `error_type: 'invalid_format' \| 'not_found' \| 'camera_error'`, `barcode: string?` | Barcode scanner error |
| `Product Searched` | User submits search query | `query: string`, `query_length: int`, `results_count: int` | `SearchProductsBloc` after Algolia search |
| `Search Results Viewed` | Search results displayed | `query: string`, `results_count: int`, `has_results: bool` | `SearchProductsBloc` success state |
| `Product Selected` | User taps on product | `product_id: string`, `product_name: string`, `source: 'search' \| 'scan'`, `position: int?` | Product selection handler |

**Funnels**:
- Scan: `Barcode Scan Initiated` → `Barcode Scanned` → `Product Selected`
- Search: `Product Searched` → `Search Results Viewed` → `Product Selected`

---

### 4. Product Evaluation Flow
**Objective**: Understand how users interact with product assessments

#### Events

| Event Name | Trigger | Properties | Location |
|------------|---------|------------|----------|
| `Product Detail Viewed` | Product detail page opened | `product_id: string`, `product_name: string`, `has_cat_profile: bool`, `source: 'scan' \| 'search'` | `ProductDetailPage` initState |
| `Product Assessment Viewed` | User views cat-specific assessment | `product_id: string`, `cat_id: string`, `assessment_score: string`, `has_warnings: bool`, `warnings_count: int` | Assessment widget rendered |
| `Product Assessment Expanded` | User taps to see full assessment details | `product_id: string`, `cat_id: string`, `section: string` | Assessment expansion handler |
| `Product Ingredient Viewed` | User checks ingredients list | `product_id: string`, `ingredient_count: int` | Ingredients section |
| `Product Nutrition Viewed` | User checks nutrition info | `product_id: string` | Nutrition section |
| `Product Shared` | User shares product | `product_id: string`, `share_method: string` | Share button (if exists) |

**Funnel**: `Product Detail Viewed` → `Product Assessment Viewed` → `Product Assessment Expanded`

---

### 5. Subscription & Paywall Flow
**Objective**: Optimize conversion from free to paid users

#### Events

| Event Name | Trigger | Properties | Location |
|------------|---------|------------|----------|
| `Paywall Shown` | Paywall displayed to user | `trigger: 'max_cats' \| 'max_scans' \| 'manual'`, `cats_count: int`, `scans_count: int`, `source_screen: string` | `PaywallPage` initState |
| `Paywall Dismissed` | User closes paywall | `trigger: string`, `time_viewed_seconds: int`, `cta_tapped: bool` | `PaywallPage` dispose/pop |
| `Subscription Started` | User initiates purchase flow | `package_id: string`, `price: string`, `billing_period: string` | RevenueCat purchase initiated |
| `Subscription Completed` | Purchase successful | `package_id: string`, `price: string`, `revenue: float`, `is_trial: bool` | RevenueCat success callback |
| `Subscription Failed` | Purchase failed | `error_type: string`, `package_id: string` | RevenueCat error callback |
| `Subscription Restored` | User restores previous purchase | `package_id: string` | RevenueCat restore |
| `Free Limit Hit` | User reaches free tier limit | `limit_type: 'cats' \| 'scans'`, `limit_value: int` | `CatTrackingService` / `ScanTrackingService` |

**Funnel**: `Free Limit Hit` → `Paywall Shown` → `Subscription Started` → `Subscription Completed`

---

## 🎯 Priority 2: Engagement & Retention

### 6. Feature Usage Events

| Event Name | Trigger | Properties |
|------------|---------|------------|
| `Tab Switched` | User changes bottom nav tab | `from_tab: string`, `to_tab: string` |
| `App Opened` | App launched | `is_first_launch: bool`, `days_since_install: int` |
| `Session Started` | User becomes active | `session_number: int` |
| `Error Occurred` | Any error shown to user | `error_type: string`, `screen: string`, `message: string` |

---

## 🎯 Priority 3: Advanced Analytics

### 7. User Properties (Set once, updated over time)

| Property Name | Description | Source |
|---------------|-------------|--------|
| `total_cats` | Number of cat profiles created | Cat creation/deletion |
| `total_scans` | Lifetime scan count | Product scan |
| `total_searches` | Lifetime search count | Product search |
| `subscription_status` | `free`, `premium`, `expired` | RevenueCat |
| `cats_with_health_conditions` | Count of cats with health issues | Cat profiles |
| `primary_cat_age_group` | Most common age group | Cat profiles |
| `signup_date` | First app use date | First launch |
| `onboarding_completed` | Boolean | Onboarding completion |
| `days_since_last_scan` | Days since last product scan | Product scan |

---

## 🏗️ Implementation Architecture

### Current Structure
```
lib/features/analytics/
├── domain/
│   ├── repository/analytics_repository.dart
│   └── usecase/
│       ├── log_screen_view_usecase.dart ✅ Active
│       ├── log_event_usecase.dart ⚠️ Stubbed
│       └── [other disabled usecases]
└── data/
    ├── repository/analytics_repository_impl.dart
    └── sources/analytics_data_source.dart
```

### Proposed Changes

#### Step 1: Enable Generic Event Tracking

**File**: `lib/features/analytics/domain/repository/analytics_repository.dart`

```dart
abstract class AnalyticsRepository {
  // ✅ Existing
  Future<void> trackScreenView({
    required String screenName,
    int? index,
    String? name,
  });

  // 🆕 Add this
  Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? properties,
  });

  // 🆕 Add this
  Future<void> setUserProperty({
    required String propertyName,
    required dynamic value,
  });

  // 🆕 Add this
  Future<void> setUserProperties(Map<String, dynamic> properties);
}
```

**File**: `lib/features/analytics/data/repository/analytics_repository_impl.dart`

```dart
@override
Future<void> trackEvent({
  required String eventName,
  Map<String, dynamic>? properties,
}) async {
  _mixpanel.track(eventName, properties: properties);
}

@override
Future<void> setUserProperty({
  required String propertyName,
  required dynamic value,
}) async {
  _mixpanel.getPeople().set(propertyName, value);
}

@override
Future<void> setUserProperties(Map<String, dynamic> properties) async {
  properties.forEach((key, value) {
    _mixpanel.getPeople().set(key, value);
  });
}
```

**File**: `lib/features/analytics/domain/usecase/log_event_usecase.dart`

```dart
class LogEventUsecase {
  final AnalyticsRepository repository;

  LogEventUsecase({required this.repository});

  Future<void> call({
    required String eventName,
    Map<String, dynamic>? properties,
  }) async {
    return repository.trackEvent(
      eventName: eventName,
      properties: properties,
    );
  }
}
```

**File**: Create `lib/features/analytics/domain/usecase/set_user_properties_usecase.dart`

```dart
import 'package:yucat/features/analytics/domain/repository/analytics_repository.dart';

class SetUserPropertiesUsecase {
  final AnalyticsRepository repository;

  SetUserPropertiesUsecase({required this.repository});

  Future<void> call(Map<String, dynamic> properties) async {
    return repository.setUserProperties(properties);
  }

  Future<void> setSingle(String propertyName, dynamic value) async {
    return repository.setUserProperty(
      propertyName: propertyName,
      value: value,
    );
  }
}
```

#### Step 2: Register New Usecases

**File**: `lib/service_locator.dart`

```dart
// In the usecases registration section
sl.registerLazySingleton(() => LogEventUsecase(repository: sl()));
sl.registerLazySingleton(() => SetUserPropertiesUsecase(repository: sl()));
```

#### Step 3: Add Events to BLoCs

**Example: Cat Creation Events**

**File**: `lib/features/cat_create/bloc/cat_create_bloc.dart`

```dart
class CatCreateBloc extends Bloc<CatCreateEvent, CatCreateState> {
  final CreateCatUsecase _createCatUsecase;
  final CurrentUserUsecase _currentUserUsecase;
  final LogScreenViewUsecase _logScreenViewUsecase;
  final LogEventUsecase _logEventUsecase; // 🆕 Add this

  DateTime? _creationStartTime; // 🆕 Track creation time

  CatCreateBloc({
    required CreateCatUsecase createCatUsecase,
    required CurrentUserUsecase currentUserUsecase,
    required LogScreenViewUsecase logScreenViewUsecase,
    required LogEventUsecase logEventUsecase, // 🆕 Add this
  }) : // ... initialization

  Future<void> _onCatCreateInitialEvent(
    CatCreateInitialEvent event,
    Emitter<CatCreateState> emit,
  ) async {
    _creationStartTime = DateTime.now(); // 🆕 Track start time

    // 🆕 Track event
    _logEventUsecase.call(
      eventName: 'Cat Creation Started',
      properties: {
        'source': event.source ?? 'unknown',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    emit(const CatCreateLoadedState(
      currentStep: 0,
      cat: CatCreateModel(name: '', neutered: false),
    ));
  }

  void _onCatCreateGoToNextStepEvent(
    CatCreateGoToNextStepEvent event,
    Emitter<CatCreateState> emit,
  ) {
    final currentState = state;
    if (currentState is CatCreateLoadedState && currentState.currentStep < 8) {
      final nextStep = event.step + 1;

      // 🆕 Track step completion
      _logEventUsecase.call(
        eventName: 'Cat Creation Step Completed',
        properties: {
          'step_index': event.step,
          'step_name': _stepNames[event.step],
          'next_step_index': nextStep,
          'next_step_name': _stepNames[nextStep],
        },
      );

      emit(CatCreateLoadedState(currentStep: nextStep, cat: currentState.cat));
      _logScreenViewUsecase.call(
        screenName: _createCatScreenName,
        index: nextStep,
        name: _stepNames[nextStep],
      );
    }
  }

  Future<void> _onCatCreateCatEvent(
    CatCreateCatEvent event,
    Emitter<CatCreateState> emit,
  ) async {
    try {
      final user = _currentUserUsecase();

      await _createCatUsecase(/* ... existing params ... */);

      // 🆕 Track successful creation
      final creationTimeSeconds = _creationStartTime != null
          ? DateTime.now().difference(_creationStartTime!).inSeconds
          : null;

      _logEventUsecase.call(
        eventName: 'Cat Created',
        properties: {
          'name': event.cat.name,
          'age_group': event.cat.ageGroup,
          'breed': event.cat.breed,
          'has_health_conditions': event.cat.healthConditions?.isNotEmpty ?? false,
          'health_conditions': event.cat.healthConditions,
          'neutered': event.cat.neutered,
          'has_photo': event.cat.profileImageFile != null,
          'creation_time_seconds': creationTimeSeconds,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      event.context.router.push(const CatListingRoute());
    } catch (e) {
      // 🆕 Track failure
      _logEventUsecase.call(
        eventName: 'Cat Creation Failed',
        properties: {
          'error_type': e.runtimeType.toString(),
          'error_message': e.toString(),
          'step_index': (state as CatCreateLoadedState).currentStep,
        },
      );
    }
  }
}
```

**Update service_locator.dart registration:**

```dart
sl.registerBloc(
  () => CatCreateBloc(
    createCatUsecase: sl(),
    currentUserUsecase: sl(),
    logScreenViewUsecase: sl(),
    logEventUsecase: sl(), // 🆕 Add this
  ),
);
```

---

## 📈 Key Mixpanel Funnels to Create

### 1. Onboarding Funnel
```
Onboarding Started →
Onboarding Step Viewed (step_index: 1) →
Onboarding Step Viewed (step_index: 2) →
Onboarding Step Viewed (step_index: 3) →
Onboarding Completed
```

### 2. Cat Creation Funnel
```
Cat Creation Started →
Cat Creation Step Completed (step_index: 0-7) →
Cat Created
```

### 3. Product Discovery Funnel (Scan)
```
Barcode Scan Initiated →
Barcode Scanned →
Product Selected →
Product Detail Viewed →
Product Assessment Viewed
```

### 4. Product Discovery Funnel (Search)
```
Product Searched →
Search Results Viewed →
Product Selected →
Product Detail Viewed →
Product Assessment Viewed
```

### 5. Subscription Conversion Funnel
```
Free Limit Hit →
Paywall Shown →
Subscription Started →
Subscription Completed
```

### 6. Power User Funnel
```
Cat Created →
Product Scanned (count >= 3) →
Product Assessment Viewed (count >= 3) →
Subscription Started
```

---

## 🎬 Implementation Roadmap

### Phase 1: Foundation (Week 1)
- [ ] Enable `LogEventUsecase` in repository
- [ ] Add `SetUserPropertiesUsecase`
- [ ] Register usecases in service locator
- [ ] Test basic event tracking

### Phase 2: Critical Flows (Week 2)
- [ ] Implement Cat Creation events (5 events)
- [ ] Implement Onboarding events (4 events)
- [ ] Implement Subscription/Paywall events (7 events)
- [ ] Test funnels in Mixpanel dashboard

### Phase 3: Product Discovery (Week 3)
- [ ] Implement Product Scan events (3 events)
- [ ] Implement Product Search events (3 events)
- [ ] Implement Product Detail events (6 events)
- [ ] Test product funnels

### Phase 4: User Properties & Engagement (Week 4)
- [ ] Implement user property tracking
- [ ] Add session tracking
- [ ] Add error tracking
- [ ] Create Mixpanel dashboards

---

## 🧪 Testing Strategy

1. **Local Testing**: Use Mixpanel's Live View to verify events in real-time
2. **Property Validation**: Ensure all properties are correctly typed and populated
3. **Funnel Testing**: Create test funnels in Mixpanel and verify step-through rates
4. **User Property Testing**: Verify user properties are set and updated correctly

---

## 📊 Success Metrics

After implementation, track these KPIs:

1. **Onboarding Completion Rate**: Target > 70%
2. **Cat Creation Success Rate**: Target > 85%
3. **Product Scan → Assessment View**: Target > 60%
4. **Free → Paid Conversion**: Baseline → +20%
5. **Average Time to First Scan**: Baseline → -30%
6. **7-Day Retention**: Baseline → +15%

---

## 🚨 Implementation Notes

### Best Practices

1. **Always include timestamp**: For time-based analysis
2. **Avoid PII**: Don't track actual cat names, use hashed IDs if needed
3. **Keep properties flat**: Avoid nested objects, flatten to `property_subproperty`
4. **Use consistent typing**: String for enums, int for counts, bool for flags
5. **Track both success and failure**: Critical for debugging user issues

### Common Pitfalls to Avoid

1. ❌ Tracking events in UI widgets → ✅ Track in BLoCs
2. ❌ Using inconsistent property names → ✅ Create constants
3. ❌ Forgetting to track errors → ✅ Always track failure paths
4. ❌ Over-tracking everything → ✅ Focus on conversion events
5. ❌ Not tracking user properties → ✅ Enrich user profiles

---

## 📚 Resources

- **Mixpanel Docs**: https://docs.mixpanel.com/
- **Event Naming Guide**: https://mixpanel.com/blog/event-naming-conventions/
- **Funnels Guide**: https://help.mixpanel.com/hc/en-us/articles/115004561246

---

## 🔗 Related Files

- `lib/features/analytics/` - Analytics feature module
- `lib/service_locator.dart` - Dependency injection
- `lib/features/cat_create/bloc/cat_create_bloc.dart` - Cat creation
- `lib/features/onboarding/bloc/onboarding_bloc.dart` - Onboarding
- `lib/features/paywall/` - Subscription flow
- `lib/services/scan_tracking_service.dart` - Scan limits
- `lib/services/cat_tracking_service.dart` - Cat limits
