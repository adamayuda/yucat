/// Canonical names for analytics events and People-profile properties.
///
/// Every event name in the app lives here. Emitting a bare string literal is
/// how a typo ships silently — the event simply appears in Mixpanel under a
/// new name and no report ever picks it up — so route new events through a
/// constant rather than inlining the text at the call site.
///
/// See `docs/analytics.md` for the property list carried by each event.
class AnalyticsEvents {
  AnalyticsEvents._();

  // Session / lifecycle
  static const appOpened = 'App Opened';

  // Anonymous sign-in failed at boot. Every uid-dependent write downstream is
  // degraded when this fires — it is the upstream cause of `Cat Creation
  // Failed`, which ran at ~20% for months while this was silently swallowed.
  static const authSignInFailed = 'Auth Sign In Failed';
  // Session end. `App Opened` was the only lifecycle event, so session length
  // existed solely as Mixpanel's native `$ae_session` — nothing first-party and
  // nothing carrying app context.
  static const appBackgrounded = 'App Backgrounded';
  // Any uncaught Dart error, from the global `FlutterError.onError` and
  // `PlatformDispatcher.onError` handlers installed in main().
  //
  // Before this the app had no error observability at all: every `catch (_)` —
  // including the Firestore reads behind the Home content lanes, which make a
  // lane silently *vanish* rather than show an error — was invisible.
  static const appError = 'App Error';

  // Paywall funnel
  static const paywallShown = 'Paywall Shown';
  // Intent, logged before the store sheet opens. Without these the Apple/Play
  // sheet is a black box: a tap that never resolves (sheet fails to present,
  // hangs, app backgrounded) leaves no trace at all.
  static const paywallCtaTapped = 'Paywall CTA Tapped';
  static const paywallRestoreTapped = 'Paywall Restore Tapped';
  // Means "closed without converting" — it is deliberately NOT fired on
  // purchase/restore success. See the note in PaywallBloc._logPaywallDismissed.
  static const paywallDismissed = 'Paywall Dismissed';
  // Unreachable while the paywall offers a single plan; kept for when a second
  // plan comes back.
  static const planSelected = 'Plan Selected';
  static const subscriptionCompleted = 'Subscription Completed';
  static const subscriptionRestored = 'Subscription Restored';
  // Genuine store/platform errors ONLY. A user dismissing the StoreKit sheet
  // goes to [paywallPurchaseCancelled] instead — folding the two together
  // inflated the "failure" count ~6x over real errors and made the paywall
  // unreadable on any error dashboard.
  static const subscriptionPurchaseFailed = 'Subscription Purchase Failed';
  // Not an error: the user backed out of the store sheet.
  static const paywallPurchaseCancelled = 'Paywall Purchase Cancelled';
  static const subscriptionRestoreFailed = 'Subscription Restore Failed';
  // Restore ran and found nothing to restore — the expected outcome for a
  // first-time user, and previously reported as `Subscription Restore Failed`
  // with reason `no_active_subscription`, which was 100% of that event.
  static const paywallRestoreCompleted = 'Paywall Restore Completed';

  // Onboarding
  static const onboardingStarted = 'Onboarding Started';
  static const onboardingGetStartedTapped = 'Onboarding Get Started Tapped';
  static const onboardingStepViewed = 'Onboarding Step Viewed';
  static const onboardingStepBack = 'Onboarding Step Back';
  static const onboardingCompleted = 'Onboarding Completed';
  // Unreachable: phase 2 became `recipesArticles` and the attribution screen is
  // parked in widgets/attribution_screen.dart. Kept because the screen is
  // parked rather than deleted.
  static const onboardingAttributionSelected = 'Onboarding Attribution Selected';
  static const onboardingAttributionSkipped = 'Onboarding Attribution Skipped';

  // Onboarding scan funnel
  static const onboardingScanCaptured = 'Onboarding Scan Captured';
  static const onboardingScanSucceeded =
      'Onboarding Scan Succeeded'; // was 'Onboarding Scan Verdict'
  static const onboardingScanFailed = 'Onboarding Scan Failed';
  static const onboardingScanSkipped = 'Onboarding Scan Skipped';

  // Cat-create wizard
  static const catWizardStepViewed = 'Cat Wizard Step Viewed';
  static const catCreationStarted = 'Cat Creation Started';
  static const catCreationStepCompleted = 'Cat Creation Step Completed';
  static const catCreationStepAbandoned = 'Cat Creation Step Abandoned';
  static const catCreated = 'Cat Created';
  static const catCreationFailed = 'Cat Creation Failed';
  // Cat profile (post-creation)
  //
  // `catEditStarted` duplicates `catProfileEditStarted` — the wizard emits the
  // former from an isEditMode ternary while cat_detail emits the latter for the
  // same user action. Prefer `catProfileEditStarted`; this one is hidden in the
  // Mixpanel Lexicon.
  static const catEditStarted = 'Cat Edit Started';
  static const catProfileViewed = 'Cat Profile Viewed';
  static const catProfileEditStarted = 'Cat Profile Edit Started';
  static const catProfileUpdated = 'Cat Profile Updated';
  static const catUpdateFailed = 'Cat Update Failed';
  static const catProfileDeleted = 'Cat Profile Deleted';
  static const catProfileDeleteFailed = 'Cat Profile Delete Failed';

  // Health carnet
  //
  // ⚠️ `healthTaskCompleted` carries `protocol_id` **and** `was_overdue`. That
  // pair is the point of the feature: a completion only means something
  // relative to whether the app surfaced the act in time. Break down by
  // `protocol_id`, never aggregate completions alone.
  static const healthCarnetViewed = 'Health Carnet Viewed';
  static const healthCarnetTabChanged = 'Health Carnet Tab Changed';
  static const healthTaskCompleted = 'Health Task Completed';
  static const healthTaskSnoozed = 'Health Task Snoozed';
  static const healthRecordAdded = 'Health Record Added';
  static const healthRecordDeleted = 'Health Record Deleted';
  static const healthAllergiesUpdated = 'Health Allergies Updated';
  static const healthCarnetLoadFailed = 'Health Carnet Load Failed';

  // Product & search
  // Resolved once per scanner open, after the first `initialize()`. Without it
  // a user whose camera permission is denied is invisible — `Product Image
  // Captured` is the first scan event and they never reach it.
  static const cameraAccessResult = 'Camera Access Result';
  // Scanner closed without taking a photo. The other half of the same blind
  // spot: opening the camera and backing out looked identical to never opening
  // it.
  static const scanCancelled = 'Scan Cancelled';
  static const productImageCaptured = 'Product Image Captured';
  static const productImageScanFailed = 'Product Image Scan Failed';
  static const productSelected = 'Product Selected';
  static const productDetailViewed = 'Product Detail Viewed';
  static const productSearched = 'Product Searched';
  static const searchResultsViewed = 'Search Results Viewed';
  static const productSaved = 'Product Saved';
  static const productUnsaved = 'Product Unsaved';

  // Profile & misc
  static const profileCatTapped = 'Profile Cat Tapped';
  static const scanHistoryViewed = 'Scan History Viewed';
  static const reviewPromptRequested = 'Review Prompt Requested';
  static const notificationsOptedIn = 'Notifications Opted In';
  static const notificationsOptedOut = 'Notifications Opted Out';
  // Unreachable under the hard paywall — the two tracking services are kept
  // registered so a free tier can be re-enabled without rewiring.
  static const freeLimitHit = 'Free Limit Hit';

  // Cat litter. The capture and failure events are shared with food
  // (`Product Image Captured` / `Product Image Scan Failed`) because the camera
  // is one entry point — only the outcome events split by category.
  static const litterSelected = 'Litter Selected';
  static const litterDetailViewed = 'Litter Detail Viewed';
  static const litterSaved = 'Litter Saved';
  static const litterUnsaved = 'Litter Unsaved';

  // Content discovery — recipes, articles, food guide. `Screen View` already
  // covers the routes (AnalyticsRouteObserver); these carry which item and,
  // via `source`, which surface it was opened from.
  static const recipeSelected = 'Recipe Selected';
  static const recipesSearched = 'Recipes Searched';
  static const recipesFiltered = 'Recipes Filtered';
  static const articleSelected = 'Article Selected';
  static const articlesSearched = 'Articles Searched';
  static const articlesFiltered = 'Articles Filtered';
  static const foodGuideItemSelected = 'Food Guide Item Selected';
  static const contentSeeAllTapped = 'Content See All Tapped';
  // The denominator for lane conversion. Without it a funnel has to use
  // `Screen View(HomeRoute)`, which over-counts every time a lane hides itself
  // on an empty or failed Firestore read — precisely the case worth measuring.
  static const contentLaneViewed = 'Content Lane Viewed';
  // Read depth on the article detail screen. `Article Selected` is a tap, not a
  // read; this is the only signal that says whether the editorial catalogue is
  // worth its seeding cost.
  static const articleRead = 'Article Read';
}

/// Values for the `source` property on content-discovery events — separates a
/// Home lane tap from one on the item's own list screen, which is what makes
/// lane conversion measurable.
class ContentSource {
  ContentSource._();

  static const homeLane = 'home_lane';
  static const homeNewsCard = 'home_news_card';
  static const recipesTab = 'recipes_tab';
  static const articlesList = 'articles_list';
  static const foodGuideList = 'food_guide_list';
}

/// Values for the `section` property on [AnalyticsEvents.contentSeeAllTapped].
class ContentSection {
  ContentSection._();

  static const recipes = 'recipes';
  static const articles = 'articles';
  static const foodGuide = 'food_guide';

  /// [AnalyticsEvents.contentLaneViewed] only. The news card is a distinct Home
  /// surface from the articles lane — it features one article and converts on
  /// its own "Learn more" — so it needs its own denominator. It is not a valid
  /// `section` for [AnalyticsEvents.contentSeeAllTapped]: the card has no
  /// "See all".
  static const newsCard = 'news_card';
}

/// Values for the `trigger` property on paywall events — lets Mixpanel funnels
/// separate the onboarding gate from the returning-user splash gate.
class PaywallTrigger {
  PaywallTrigger._();

  static const onboardingComplete = 'onboarding_complete';
  static const returningUser = 'returning_user';
}

/// Canonical Mixpanel People-profile property names.
class UserProps {
  UserProps._();

  static const platform = 'platform';
  static const isSubscriber = 'is_subscriber';
  static const subscriptionPlan = 'subscription_plan';
  static const subscriptionPrice = 'subscription_price';
  static const subscriptionCurrency = 'subscription_currency';
  static const catsCount = 'cats_count';
  static const hasCat = 'has_cat';
  static const primaryCatAgeGroup = 'primary_cat_age_group';
  static const totalScans = 'total_scans';
  static const lastScanAt = 'last_scan_at';
  static const attributionSource = 'attribution_source';
  static const onboardingCompleted = 'onboarding_completed';
  static const onboardingCompletedAt = 'onboarding_completed_at';
  static const notificationsEnabled = 'notifications_enabled';

  /// Mixpanel reserved. Set with `setOnce` at first identify, so it records the
  /// true first-seen date and later launches never overwrite it. Required for
  /// any "days since signup" segmentation.
  static const created = r'$created';

  /// App language (the locale the app resolved to, not the raw device locale) —
  /// six are shipped and nothing recorded which one a user actually saw.
  static const language = 'language';

  /// Device region, e.g. `ES`. Separate from [language]: a Spanish speaker in
  /// the US is a different market from one in Spain.
  static const country = 'country';

  /// Refreshed at every boot. Recency existed only as a OneSignal tag, so
  /// Mixpanel could not segment dormant users at all.
  static const lastActiveAt = 'last_active_at';

  /// Lifetime app opens. The companion to [totalScans] for engagement depth.
  static const totalSessions = 'total_sessions';

  /// Breed of the first cat. `cat_product_assessment.dart` has ~25 breed rules,
  /// and nothing recorded whether the breeds users actually own are among them.
  static const primaryCatBreed = 'primary_cat_breed';
}
