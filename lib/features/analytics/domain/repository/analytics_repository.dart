abstract class AnalyticsRepository {
  void trackScreenView({required String screenName, int? index, String? name});

  Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? properties,
  });

  Future<void> setUserProperty({
    required String propertyName,
    required dynamic value,
  });

  Future<void> setUserProperties(Map<String, dynamic> properties);
}
