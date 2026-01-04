import 'package:yucat/features/analytics/data/sources/analytics_data_source.dart';
import 'package:yucat/features/analytics/domain/repository/analytics_repository.dart';
import 'package:yucat/features/auth/data/sources/auth_data_source.dart';
import 'package:yucat/service_locator.dart';
import 'package:yucat/features/analytics/domain/repository/analytics_repository.dart';

class AnalyticsRepositoryImpl extends AnalyticsRepository {
  final AnalyticsFirebaseDataSource _analyticsFirebaseDataSource;

  AnalyticsRepositoryImpl({
    required AnalyticsFirebaseDataSource analyticsFirebaseDataSource,
  }) : _analyticsFirebaseDataSource = analyticsFirebaseDataSource;

  @override
  Future<void> logEvent({
    required String eventName,
    required Map<String, Object> parameters,
  }) async {
    return await _analyticsFirebaseDataSource.logEvent(
      eventName: eventName,
      parameters: parameters,
    );
  }

  @override
  Future<void> logScreenView({required String screenName}) async {
    return await _analyticsFirebaseDataSource.logScreenView(
      screenName: screenName,
    );
  }

  @override
  Future<void> logLogin({required String method}) async {
    return await _analyticsFirebaseDataSource.logLogin(method: method);
  }

  @override
  Future<void> logSignUp({required String method}) async {
    return await _analyticsFirebaseDataSource.logSignUp(method: method);
  }

  @override
  Future<void> logSearch({required String searchTerm}) async {
    return await _analyticsFirebaseDataSource.logSearch(searchTerm: searchTerm);
  }
}
