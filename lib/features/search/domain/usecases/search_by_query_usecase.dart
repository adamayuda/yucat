import 'package:yucat/features/product/domain/entities/product_entity.dart';
import 'package:yucat/features/search/domain/repositories/search_repository.dart';

class SearchByQueryUsecase {
  final SearchRepository _searchRepository;

  SearchByQueryUsecase({required SearchRepository searchRepository})
    : _searchRepository = searchRepository;

  Future<List<ProductEntity>> call({required String query}) async {
    return _searchRepository.searchByQuery(query);
  }
}
