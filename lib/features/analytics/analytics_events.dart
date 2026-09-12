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
  // Fires on one path only: accepting the second-chance sheet switches the
  // selection to the `annual_offer` package. No plan picker is rendered.
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
  // The discounted-first-year sheet (`annual_offer` package) offered once after
  // the first store-sheet cancel, only to users still eligible for an intro
  // offer. `Shown` is the denominator; `Tapped` leads to `Plan Selected`,
  // `Paywall CTA Tapped` and `Subscription Completed { is_intro_offer: true }`.
  static const paywallSecondChanceShown = 'Paywall Second Chance Shown';
  static const paywallSecondChanceTapped = 'Paywall Second Chance Tapped';
  static const paywallSecondChanceDismissed = 'Paywall Second Chance Dismissed';
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
  static const onboardingAttributionSelected =
      'Onboarding Attribution Selected';
  static const onboardingAttributionSkipped = 'Onboarding Attribution Skipped';

  // The `Onboarding Scan Captured / Succeeded / Failed / Skipped` namespace
  // was deleted with the onboarding scan beat (2026-09-12); historical rows
  // remain in Mixpanel.

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

  // Product & search
  // Resolved once per scanner open, after the first `initialize()`. Without it
  // a user whose camera permission is denied is invisible — `Product Image
  // Captured` is the first scan event and they never reach it.
  static const cameraAccessResult = 'Camera Access Result';
  // Scanner closed without taking a photo. The other half of the same blind
  // spot: opening the camera and backing out looked identical to never opening
  // it.
  static const scanCancelled = 'Scan Cancelled';
  // Scanner opened, before any photo exists. `Product Image Captured` only
  // fires *after* a capture, so without this the two entry points — the Home
  // header CTA and the nav's Scan slot — are indistinguishable, and an
  // opened-then-abandoned scanner is attributable to neither.
  static const scanStarted = 'Scan Started';
  static const productImageCaptured = 'Product Image Captured';
  static const productImageScanFailed = 'Product Image Scan Failed';
  // Back-label rescue (scan-pipeline Phase 2). `Started` fires on the CTA tap
  // (`source`: `product_detail` no-data card, or `scan_error` view);
  // `Completed` on the callable's return with `outcome` (`product` /
  // `label_no_data` / `unreadable` / a callable error code).
  static const labelScanStarted = 'Label Scan Started';
  static const labelScanCompleted = 'Label Scan Completed';
  // The user left the loading screen via Cancel while the callable was still
  // running (the backend finishes and caches anyway; the result is dropped).
  // Distinct from `Scan Cancelled`, which is closing the camera before a photo.
  static const scanAbandoned = 'Scan Abandoned';
  // Which of the three exits on the scan error view was tapped
  // (`exit`: `scan_again` / `scan_label` / `search`), with the `outcome`.
  static const scanErrorExitTapped = 'Scan Error Exit Tapped';
  static const productSelected = 'Product Selected';
  static const productDetailViewed = 'Product Detail Viewed';
  static const productSearched = 'Product Searched';
  static const searchResultsViewed = 'Search Results Viewed';
  static const productSaved = 'Product Saved';
  static const productUnsaved = 'Product Unsaved';
  // The "Better for {cat}" list under a verdict. `Shown` fires only when at
  // least one better food rendered — a great product ends at its verdict and
  // must not count as an ignored list. Emitted from the widget, which is the
  // only layer that knows the selected cat.
  static const alternativesShown = 'Alternatives Shown';
  static const alternativeTapped = 'Alternative Tapped';

  // Profile & misc
  static const profileCatTapped = 'Profile Cat Tapped';
  static const scanHistoryViewed = 'Scan History Viewed';
  static const reviewPromptRequested = 'Review Prompt Requested';
  static const notificationsOptedIn = 'Notifications Opted In';
  static const notificationsOptedOut = 'Notifications Opted Out';
  // A push was tapped. OneSignal's own dashboard counts delivered/clicked,
  // but without this nothing in Mixpanel ties an app open to a Journey —
  // `template_name` is the Journey step that brought them back.
  static const pushOpened = 'Push Opened';
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

/// Values for the `source` property on [AnalyticsEvents.scanStarted] — which
/// surface opened the camera. The onboarding scan keeps its own
/// `Onboarding Scan *` namespace and does not emit this event.
class ScanSource {
  ScanSource._();

  static const homeHeader = 'home_header';
  static const bottomNav = 'bottom_nav';

  /// `Label Scan Started` sources — the no-data card on product detail, and
  /// the scan error view's "photograph the back label" exit.
  static const productDetail = 'product_detail';
  static const scanError = 'scan_error';

  /// `Scan Started` from the error view's "Scan again" exit.
  static const scanErrorRetry = 'scan_error_retry';
}

/// Values for the `source` property on content-discovery events — separates a
/// Home lane tap from one on the item's own list screen, which is what makes
/// lane conversion measurable.
class ContentSource {
  ContentSource._();

  static const homeLane = 'home_lane';

  /// ⚠️ **Unreachable since YUC-24** — `HomeNewsCard` was unmounted from Home
  /// (parked in `lib/features/home/widgets/`, not deleted). Kept so a re-mount
  /// resumes the historical name instead of minting a second one.
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

  /// [AnalyticsEvents.contentLaneViewed] only — the news card had its own
  /// denominator because it featured one article and converted on its own
  /// "Learn more". Never a valid `section` for
  /// [AnalyticsEvents.contentSeeAllTapped]: the card has no "See all".
  ///
  /// ⚠️ **Unreachable since YUC-24**, with [ContentSource.homeNewsCard] — the
  /// card is parked, not deleted. Kept for the same reason.
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

  /// Whether the active entitlement is in its free-trial period. Written on
  /// purchase and refreshed on every splash gate from the entitlement itself,
  /// so it turns false on its own when the trial converts or lapses.
  static const isTrial = 'is_trial';

  /// When the trial began. Trial→paid lives in RevenueCat, not here; this is
  /// the cohort key for "what did trialists do on day 1 / 2 / 3".
  static const trialStartedAt = 'trial_started_at';
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
