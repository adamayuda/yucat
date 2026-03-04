import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:yucat/features/analytics/domain/repository/analytics_repository.dart';

class AnalyticsRepositoryImpl extends AnalyticsRepository {
  final Mixpanel _mixpanel;

  AnalyticsRepositoryImpl({required Mixpanel mixpanel}) : _mixpanel = mixpanel;

  @override
  void trackScreenView({required String screenName, int? index, String? name}) {
    _mixpanel.track(
      'Screen View',
      properties: {'screen_name': screenName, 'index': index, 'name': name},
    );
  }

  @override
  Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? properties,
  }) async {
    _mixpanel.track(eventName, properties: properties);
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
}
