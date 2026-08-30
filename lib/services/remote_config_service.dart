import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Thin wrapper around Firebase Remote Config exposing the app's runtime kill
/// switches. Fail-open by design: in-app defaults keep every feature enabled, so
/// a fetch failure, throttle, or first cold launch never breaks a flow.
class RemoteConfigService {
  /// When `false`, the post-cat-creation onboarding cascade (food scan +
  /// recommendation reveal) is skipped and the user goes straight to the
  /// paywall. Flip in the Firebase console to disable the Anthropic-backed scan
  /// for new onboarding sessions without shipping a build.
  static const String onboardingScanEnabledKey = 'onboarding_scan_enabled';

  /// When `false`, Mixpanel Session Replay never starts, whatever the build
  /// type. Lets us stop recording from the Firebase console without shipping a
  /// build — e.g. if replay quota runs low or a privacy question comes up.
  static const String sessionReplayEnabledKey = 'session_replay_enabled';

  /// Percentage of sessions to record (0–100). `0` is equivalent to disabling
  /// replay; the SDK asserts the value is in range, so the getter clamps.
  static const String sessionReplaySamplePercentKey =
      'session_replay_sample_percent';

  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  /// Sets in-app defaults, configures fetch behaviour, and pulls the latest
  /// values. Any failure is swallowed — the in-app defaults stand. Requires
  /// `Firebase.initializeApp` to have run first.
  Future<void> initialize() async {
    try {
      await _remoteConfig.setDefaults(const {
        onboardingScanEnabledKey: true,
        sessionReplayEnabledKey: true,
        sessionReplaySamplePercentKey: 100.0,
      });
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 8),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await _remoteConfig.fetchAndActivate();
    } catch (_) {
      // Fail open: defaults already registered, so the app keeps working.
    }
  }

  bool get onboardingScanEnabled =>
      _remoteConfig.getBool(onboardingScanEnabledKey);

  bool get sessionReplayEnabled =>
      _remoteConfig.getBool(sessionReplayEnabledKey);

  double get sessionReplaySamplePercent =>
      _remoteConfig.getDouble(sessionReplaySamplePercentKey).clamp(0, 100);
}
