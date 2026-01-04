abstract class AnalyticsRepository {
  Future<void> logEvent({
    required String eventName,
    required Map<String, Object> parameters,
  });

  Future<void> logScreenView({
    required String screenName,
  });

  Future<void> logLogin({
    required String method,
  });

  Future<void> logSignUp({
    required String method,
  });

  Future<void> logSearch({
    required String searchTerm,
  });
}
