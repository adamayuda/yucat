abstract class AnalyticsRepository {
  void trackScreenView({required String screenName, int? index, String? name});

  Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? properties,
  });

  /// Bind this device's events to a stable People profile keyed by
  /// [distinctId] (the anonymous Firebase UID). Required before any
  /// People property reliably attaches to a unified profile.
  Future<void> identify(String distinctId);

  Future<void> setUserProperty({
    required String propertyName,
    required dynamic value,
  });

  Future<void> setUserProperties(Map<String, dynamic> properties);

  /// Increment a numeric People property (e.g. a lifetime scan counter).
  Future<void> incrementUserProperty(String propertyName, double by);
}
