import 'package:yucat/features/product/domain/entities/product_entity.dart';
import 'package:yucat/features/search/data/datasources/algolia_search_datasource.dart';
import 'package:yucat/features/search/domain/repositories/search_repository.dart';
import 'package:yucat/features/search/data/mappers/search_product_to_domain_mapper.dart';

class SearchRepositoryImpl implements SearchRepository {
  final AlgoliaSearchDataSource _algoliaDataSource;
  final SearchProductToDomainMapper _searchProductToDomainMapper;

  SearchRepositoryImpl({
    required AlgoliaSearchDataSource dataSource,
    required SearchProductToDomainMapper searchProductToDomainMapper,
  }) : _algoliaDataSource = dataSource,
       _searchProductToDomainMapper = searchProductToDomainMapper;

  @override
  Future<List<ProductEntity>> searchByQuery(String query) async {
    final hits = await _algoliaDataSource.searchByQuery(query);
    return hits.map((hit) => _searchProductToDomainMapper(hit)).toList();
  }

  @override
  Future<List<ProductEntity>> searchByBrand(String brandName) async {
    final hits = await _algoliaDataSource.searchByBrand(brandName);
    return hits.map((hit) => _searchProductToDomainMapper(hit)).toList();
  }
}
