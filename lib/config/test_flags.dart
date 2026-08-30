/// Build-time toggles for QA / TestFlight builds.
///
/// IMPORTANT: all three MUST be `false` for any production App Store release.
/// They exist so testers can repeatedly walk the onboarding funnel without
/// being stopped by the hard paywall, and so replay can be eyeballed locally.
library;

/// When true, the onboarding-completed flag is cleared on every cold launch,
/// so the full onboarding flow replays each time the app starts.
const bool kTestBuildResetOnboarding = false;

/// When true, both hard-paywall gates (end of onboarding + returning-user
/// splash) are bypassed and the user lands straight on Home.
const bool kTestBuildSkipPaywall = false;

/// When true, Mixpanel Session Replay also records in debug/profile builds.
/// Off in production so local runs never burn replay quota or pollute the v2
/// project with hot-restart sessions. Recording still additionally requires the
/// `session_replay_enabled` Remote Config flag.
const bool kTestBuildForceSessionReplay = false;
