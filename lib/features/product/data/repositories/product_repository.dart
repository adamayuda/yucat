import 'package:flutter/foundation.dart';
import 'package:yucat/features/product/domain/entities/product_entity.dart';
import 'package:yucat/features/product/data/datasources/product_remote_datasource.dart';
import 'package:yucat/features/product/data/mappers/product_to_domain_mapper.dart';
import 'package:yucat/features/product/domain/repositories/product_repository.dart';
import 'package:yucat/features/search/data/datasources/algolia_search_datasource.dart';
import 'package:yucat/features/search/data/mappers/search_product_to_domain_mapper.dart';

class ProductRepositoryImpl implements ProductRepository {
  final RemoteSearchDataSource _remoteDataSource;
  final AlgoliaSearchDataSource _algoliaDataSource;
  final ProductToDomainMapper _productToDomainMapper;
  final SearchProductToDomainMapper _searchProductToDomainMapper;

  ProductRepositoryImpl({
    required RemoteSearchDataSource remoteDataSource,
    required AlgoliaSearchDataSource algoliaDataSource,
    required ProductToDomainMapper productToDomainMapper,
    required SearchProductToDomainMapper searchProductToDomainMapper,
  }) : _remoteDataSource = remoteDataSource,
       _algoliaDataSource = algoliaDataSource,
       _productToDomainMapper = productToDomainMapper,
       _searchProductToDomainMapper = searchProductToDomainMapper;

  @override
  Future<ProductEntity?> fetchProductByBarcode(String barcode) async {
    // Try Algolia first
    debugPrint('[ProductRepository] Searching Algolia for barcode: $barcode');
    final algoliaData = await _algoliaDataSource.searchByBarcode(barcode);
    if (algoliaData != null) {
      debugPrint(
        '[ProductRepository] Product found in Algolia for barcode: $barcode',
      );
      return _searchProductToDomainMapper(algoliaData as Map<String, dynamic>);
    }
    debugPrint(
      '[ProductRepository] Product not found in Algolia, trying remote data source for barcode: $barcode',
    );

    final remoteData = await _remoteDataSource.fetchProductByBarcode(barcode);
    if (remoteData == null) {
      debugPrint(
        '[ProductRepository] Product not found in remote data source for barcode: $barcode',
      );
      return null;
    }
    debugPrint(
      '[ProductRepository] Product found in remote data source for barcode: $barcode',
    );
    final productDataRaw = remoteData['product'];
    if (productDataRaw == null || productDataRaw is! Map) {
      debugPrint(
        '[ProductRepository] Product data not found in remote response for barcode: $barcode',
      );
      return null;
    }
    final productData = Map<String, dynamic>.from(productDataRaw);
    return _productToDomainMapper(productData);
  }
}
