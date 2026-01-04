import 'package:firebase_analytics/firebase_analytics.dart';

abstract class AnalyticsFirebaseDataSource {
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

class AnalyticsFirebaseDataSourceImpl extends AnalyticsFirebaseDataSource {
  @override
  Future<void> logEvent({
    required String eventName,
    required Map<String, Object> parameters,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  @override
  Future<void> logScreenView({
    required String screenName,
  }) async {
    await FirebaseAnalytics.instance.logScreenView(
      screenName: screenName,
    );
  }

  @override
  Future<void> logLogin({
    required String method,
  }) async {
    await FirebaseAnalytics.instance.logLogin(
      loginMethod: method,
    );
  }

  @override
  Future<void> logSignUp({
    required String method,
  }) async {
    await FirebaseAnalytics.instance.logSignUp(
      signUpMethod: method,
    );
  }

  @override
  Future<void> logSearch({
    required String searchTerm,
  }) async {
    try {
      final result = await FirebaseAnalytics.instance.logSearch(
        searchTerm: searchTerm,
      );
      print('result');
    } catch (e) {
      print(e);
    }
  }
}
