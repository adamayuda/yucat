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

  /// Write [propertyName] only if the profile does not already have it
  /// (Mixpanel `$set_once`). For values that must record the *first* time
  /// something happened — `$created` above all — where a plain set would
  /// overwrite it on every launch.
  Future<void> setUserPropertyOnce({
    required String propertyName,
    required dynamic value,
  });

  /// Increment a numeric People property (e.g. a lifetime scan counter).
  Future<void> incrementUserProperty(String propertyName, double by);
}
