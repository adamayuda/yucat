import 'package:yucat/features/analytics/domain/repository/analytics_repository.dart';

class LogScreenViewUsecase {
  final AnalyticsRepository repository;

  LogScreenViewUsecase({required this.repository});

  Future<void> call({
    required String screenName,
    int? index,
    String? name,
  }) async {
    return repository.trackScreenView(
      screenName: screenName,
      index: index,
      name: name,
    );
  }
}
