import 'package:yucat/features/search/domain/repositories/recent_searches_repository.dart';

class GetRecentSearchesUsecase {
  final RecentSearchesRepository _repository;

  GetRecentSearchesUsecase({required RecentSearchesRepository repository})
      : _repository = repository;

  Future<List<String>> call() => _repository.getRecent();
}
