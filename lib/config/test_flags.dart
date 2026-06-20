/// Build-time toggles for QA / TestFlight builds.
///
/// IMPORTANT: both MUST be `false` for any production App Store release.
/// They exist so testers can repeatedly walk the onboarding funnel without
/// being stopped by the hard paywall.
library;

/// When true, the onboarding-completed flag is cleared on every cold launch,
/// so the full onboarding flow replays each time the app starts.
const bool kTestBuildResetOnboarding = true;

/// When true, both hard-paywall gates (end of onboarding + returning-user
/// splash) are bypassed and the user lands straight on Home.
const bool kTestBuildSkipPaywall = true;
