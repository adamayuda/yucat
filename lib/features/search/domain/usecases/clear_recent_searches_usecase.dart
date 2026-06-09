import 'package:yucat/features/search/domain/repositories/recent_searches_repository.dart';

class ClearRecentSearchesUsecase {
  final RecentSearchesRepository _repository;

  ClearRecentSearchesUsecase({required RecentSearchesRepository repository})
      : _repository = repository;

  Future<void> call() => _repository.clear();
}
