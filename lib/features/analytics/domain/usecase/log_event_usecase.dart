import 'package:yucat/features/analytics/domain/repository/analytics_repository.dart';

class LogEventUsecase {
  final AnalyticsRepository repository;

  LogEventUsecase({required this.repository});

  Future<void> call({
    required String eventName,
    required Map<String, Object> parameters,
  }) async {
    return await repository.logEvent(
      eventName: eventName,
      parameters: parameters,
    );
  }
}
