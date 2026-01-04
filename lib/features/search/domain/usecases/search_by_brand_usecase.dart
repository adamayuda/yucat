import 'package:yucat/features/product/domain/entities/product_entity.dart';
import 'package:yucat/features/search/domain/repositories/search_repository.dart';

class SearchByBrandUsecase {
  final SearchRepository _searchRepository;

  SearchByBrandUsecase({required SearchRepository searchRepository})
    : _searchRepository = searchRepository;

  Future<List<ProductEntity>> call({required String brandName}) async {
    return _searchRepository.searchByBrand(brandName);
  }
}
