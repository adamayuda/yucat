import 'package:yucat/features/analytics/domain/repository/analytics_repository.dart';

class LogScreenViewUsecase {
  final AnalyticsRepository repository;

  LogScreenViewUsecase({required this.repository});

  Future<void> call({required String screenName}) async {
    return await repository.logScreenView(screenName: screenName);
  }
}
