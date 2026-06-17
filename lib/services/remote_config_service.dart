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
}
