import 'package:flutter/foundation.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:mixpanel_flutter_session_replay/mixpanel_flutter_session_replay.dart';
import 'package:yucat/config/test_flags.dart';
import 'package:yucat/services/remote_config_service.dart';

/// Owns the Mixpanel Session Replay instance.
///
/// Replay is a second, standalone SDK alongside `mixpanel_flutter`: it does not
/// share the analytics SDK's native instance, so identity has to be forwarded
/// by hand (see [identify], called from `UserAnalyticsService.identify`) and the
/// replay id has to be stamped onto our own events (see
/// `AnalyticsRepositoryImpl`).
///
/// Like the rest of `lib/services/`, every method is fire-and-forget and
/// swallows errors — analytics must never break a user flow.
class SessionReplayService {
  final String _token;
  final Mixpanel _mixpanel;
  final RemoteConfigService _remoteConfig;

  MixpanelSessionReplay? _instance;

  /// Set when [identify] is called before [start] has resolved. `SplashBloc`
  /// identifies at boot and can win that race, so the id is buffered and
  /// applied once the SDK is up — otherwise the replay would be filed under the
  /// pre-sign-in anonymous distinct id while the events use the Firebase UID.
  String? _pendingDistinctId;

  bool _started = false;

  SessionReplayService({
    required String token,
    required Mixpanel mixpanel,
    required RemoteConfigService remoteConfig,
  }) : _token = token,
       _mixpanel = mixpanel,
       _remoteConfig = remoteConfig;

  /// The live SDK instance, or `null` when replay is off or not up yet.
  MixpanelSessionReplay? get instance => _instance;

  /// Replay id of the capture in flight, or `null` when nothing is recording.
  String? get replayId => _instance?.replayId;

  /// Recording is release-only by default so debug runs never burn replay quota,
  /// and is gated on the Remote Config kill switch in every build.
  bool get _shouldRecord =>
      (kReleaseMode || kTestBuildForceSessionReplay) &&
      _remoteConfig.sessionReplayEnabled &&
      _remoteConfig.sessionReplaySamplePercent > 0;

  /// Boots the replay SDK. Safe to call once; later calls are no-ops.
  ///
  /// Recording is not started here — the SDK starts it itself when
  /// `MixpanelSessionReplayWidget` sees the app foregrounded, sampling at
  /// [SessionReplayOptions.autoRecordSessionsPercent].
  Future<void> start() async {
    if (_started || !_shouldRecord) return;
    _started = true;
    try {
      // `mixpanel_flutter` 2.5.0 has no sync `distinctId` getter — the one the
      // Mixpanel docs show is from a different SDK. Seed replay with the same
      // id the analytics SDK is using so the two agree before sign-in lands.
      final distinctId = _pendingDistinctId ?? await _mixpanel.getDistinctId();

      final result = await MixpanelSessionReplay.initialize(
        token: _token,
        distinctId: distinctId,
        options: SessionReplayOptions(
          autoRecordSessionsPercent: _remoteConfig.sessionReplaySamplePercent,
          // Text stays readable so replays are worth watching; images are
          // masked because that is where the PII is (cat photos, scan
          // captures). Text *input* is masked by the SDK unconditionally.
          autoMaskedViews: const {AutoMaskedView.image},
          // Silent in release; in a forced debug run the console is the only
          // way to see sampling, capture and upload decisions.
          logLevel: kReleaseMode ? LogLevel.none : LogLevel.debug,
          // Release respects the SDK default (WiFi only) so replay never spends
          // a user's cellular data. In a forced debug/QA run upload regardless:
          // the simulator's connectivity check does not reliably report wifi or
          // ethernet, and a false negative queues captures forever — which
          // looks identical to replay being broken.
          platformOptions: PlatformOptions(
            mobile: MobileOptions(wifiOnly: kReleaseMode),
          ),
        ),
      );

      if (!result.success || result.instance == null) {
        debugPrint('SessionReplayService.start failed: ${result.error}');
        return;
      }

      _instance = result.instance;

      // A uid that arrived while `initialize` was in flight.
      final pending = _pendingDistinctId;
      if (pending != null) {
        _instance!.identify(pending);
        _pendingDistinctId = null;
      }
    } catch (e) {
      debugPrint('SessionReplayService.start error: $e');
    }
  }

  /// Point replay at the same distinct id the analytics SDK uses. Buffers when
  /// the SDK is not up yet; a no-op when replay is disabled for this build.
  void identify(String distinctId) {
    if (distinctId.isEmpty) return;
    final instance = _instance;
    if (instance == null) {
      _pendingDistinctId = distinctId;
      return;
    }
    try {
      instance.identify(distinctId);
    } catch (e) {
      debugPrint('SessionReplayService.identify error: $e');
    }
  }
}
