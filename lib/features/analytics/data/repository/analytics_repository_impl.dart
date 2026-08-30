import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:yucat/features/analytics/domain/repository/analytics_repository.dart';

class AnalyticsRepositoryImpl extends AnalyticsRepository {
  final Mixpanel _mixpanel;

  /// Supplies the in-flight Session Replay id, or `null` when nothing is
  /// recording. Injected as a callback rather than a `SessionReplayService` so
  /// the data layer keeps no dependency on `lib/services/`.
  final String? Function()? _replayIdProvider;

  AnalyticsRepositoryImpl({
    required Mixpanel mixpanel,
    String? Function()? replayIdProvider,
  })  : _mixpanel = mixpanel,
        _replayIdProvider = replayIdProvider;

  /// Stamps `$mp_replay_id` onto an event so Mixpanel can jump from it to the
  /// replay it happened in. Session Replay ships as a separate, pure-Dart SDK
  /// with no bridge into `mixpanel_flutter`'s native `track`, so it cannot
  /// attach this itself — we do it here.
  Map<String, dynamic> _withReplayId(Map<String, dynamic> properties) {
    final replayId = _replayIdProvider?.call();
    if (replayId == null) return properties;
    return {...properties, r'$mp_replay_id': replayId};
  }

  @override
  void trackScreenView({required String screenName, int? index, String? name}) {
    _mixpanel.track(
      'Screen View',
      properties: _withReplayId({
        'screen_name': screenName,
        'index': index,
        'name': name,
      }),
    );
  }

  @override
  Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? properties,
  }) async {
    _mixpanel.track(eventName, properties: _withReplayId(properties ?? {}));
  }

  @override
  Future<void> identify(String distinctId) async {
    _mixpanel.identify(distinctId);
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

  @override
  Future<void> incrementUserProperty(String propertyName, double by) async {
    _mixpanel.getPeople().increment(propertyName, by);
  }
}
