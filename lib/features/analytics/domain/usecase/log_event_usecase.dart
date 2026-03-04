import 'package:yucat/features/analytics/domain/repository/analytics_repository.dart';

class LogEventUsecase {
  final AnalyticsRepository repository;

  LogEventUsecase({required this.repository});

  Future<void> call({
    required String eventName,
    Map<String, dynamic>? properties,
  }) async {
    return await repository.trackEvent(
      eventName: eventName,
      properties: properties,
    );
  }
}
