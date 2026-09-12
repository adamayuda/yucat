import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Thin wrapper around Firebase Remote Config exposing the app's runtime kill
/// switches. Fail-open by design: in-app defaults keep every feature enabled, so
/// a fetch failure, throttle, or first cold launch never breaks a flow.
///
/// `onboarding_scan_enabled` used to live here too; the onboarding scan it
/// gated was removed on 2026-09-12, so the console key is now inert.
class RemoteConfigService {
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

  bool get sessionReplayEnabled =>
      _remoteConfig.getBool(sessionReplayEnabledKey);

  double get sessionReplaySamplePercent =>
      _remoteConfig.getDouble(sessionReplaySamplePercentKey).clamp(0, 100);
}
