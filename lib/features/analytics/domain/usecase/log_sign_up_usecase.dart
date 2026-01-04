import 'package:yucat/features/analytics/domain/repository/analytics_repository.dart';

class LogSignUpUsecase {
  final AnalyticsRepository repository;

  LogSignUpUsecase({required this.repository});

  Future<void> call({required String method}) async {
    return await repository.logSignUp(method: method);
  }
}
