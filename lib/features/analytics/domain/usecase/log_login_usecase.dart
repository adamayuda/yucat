import 'package:yucat/features/analytics/domain/repository/analytics_repository.dart';

class LogLoginUsecase {
  final AnalyticsRepository repository;

  LogLoginUsecase({required this.repository});

  Future<void> call({required String method}) async {
    // return await repository.logLogin(method: method);
  }
}
