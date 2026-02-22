import 'package:yucat/features/analytics/domain/repository/analytics_repository.dart';

class LogSearchUsecase {
  final AnalyticsRepository repository;

  LogSearchUsecase({required this.repository});

  Future<void> call({required String searchTerm}) async {
    // return await repository.logSearch(searchTerm: searchTerm);
  }
}
