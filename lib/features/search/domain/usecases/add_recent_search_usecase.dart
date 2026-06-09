import 'package:yucat/features/search/domain/repositories/recent_searches_repository.dart';

class AddRecentSearchUsecase {
  final RecentSearchesRepository _repository;

  AddRecentSearchUsecase({required RecentSearchesRepository repository})
      : _repository = repository;

  Future<void> call(String query) => _repository.add(query);
}
