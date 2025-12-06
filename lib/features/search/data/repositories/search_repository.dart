import 'package:yucat/features/product_detail/domain/entities/product_entity.dart';
import 'package:yucat/features/search/data/datasources/algolia_search_datasource.dart';
import 'package:yucat/features/search/data/mappers/product_to_domain_mapper.dart';
import 'package:yucat/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final AlgoliaSearchDataSource _dataSource;
  final ProductToDomainMapper _productToDomainMapper;

  SearchRepositoryImpl({
    required AlgoliaSearchDataSource dataSource,
    required ProductToDomainMapper productToDomainMapper,
  }) : _dataSource = dataSource,
       _productToDomainMapper = productToDomainMapper;

  @override
  Future<ProductEntity?> searchByBarcode(String barcode) async {
    final hit = await _dataSource.searchByBarcode(barcode);
    if (hit == null) {
      return null;
    }
    return _productToDomainMapper(hit as Map<String, dynamic>);
  }

  @override
  Future<List<ProductEntity>> searchByQuery(String query) async {
    final hits = await _dataSource.searchByQuery(query);
    return hits.map((hit) => _productToDomainMapper(hit)).toList();
  }
}
