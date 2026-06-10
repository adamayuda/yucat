/// Canonical names for analytics events and People-profile properties.
///
/// New tracking introduced for the funnel/drop-off review references these
/// constants instead of string literals to avoid name drift between the code
/// and the Mixpanel dashboard. The ~40 pre-existing events still use inline
/// literals (see `design/analytics.md` for the full catalog); migrating them
/// is a follow-up, not required for these constants to be useful.
class AnalyticsEvents {
  AnalyticsEvents._();

  // Session / lifecycle
  static const appOpened = 'App Opened';

  // Paywall funnel
  static const paywallShown = 'Paywall Shown';
  static const planSelected = 'Plan Selected';
  static const paywallPromoToggled = 'Paywall Promo Toggled';
  static const subscriptionCompleted = 'Subscription Completed';
  static const subscriptionRestored = 'Subscription Restored';
  static const subscriptionPurchaseFailed = 'Subscription Purchase Failed';
  static const subscriptionRestoreFailed = 'Subscription Restore Failed';

  // Onboarding
  static const onboardingStepViewed = 'Onboarding Step Viewed';
  static const onboardingStepBack = 'Onboarding Step Back';

  // Cat-create wizard
  static const catWizardStepViewed = 'Cat Wizard Step Viewed';
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
  static const currentStreak = 'current_streak';
  static const lastScanAt = 'last_scan_at';
  static const attributionSource = 'attribution_source';
  static const onboardingCompleted = 'onboarding_completed';
  static const onboardingCompletedAt = 'onboarding_completed_at';
  static const notificationsEnabled = 'notifications_enabled';
}
