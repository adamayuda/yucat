import 'package:flutter/foundation.dart';
import 'package:yucat/features/product/domain/entities/product_entity.dart';
import 'package:yucat/features/product/data/datasources/product_remote_datasource.dart';
import 'package:yucat/features/product/data/mappers/product_to_domain_mapper.dart';
import 'package:yucat/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final RemoteSearchDataSource _remoteDataSource;
  final ProductToDomainMapper _productToDomainMapper;

  ProductRepositoryImpl({
    required RemoteSearchDataSource remoteDataSource,
    required ProductToDomainMapper productToDomainMapper,
  }) : _remoteDataSource = remoteDataSource,
       _productToDomainMapper = productToDomainMapper;

  @override
  Future<ProductEntity?> fetchProductByImage({
    required String imageBase64,
    required String mimeType,
  }) async {
    debugPrint('[ProductRepository] Fetching product by image');

    final remoteData = await _remoteDataSource.fetchProductByImage(
      imageBase64: imageBase64,
      mimeType: mimeType,
    );
    if (remoteData == null) {
      debugPrint('[ProductRepository] Product not found for image');
      return null;
    }
    debugPrint('[ProductRepository] Product found for image');
    final productDataRaw = remoteData['product'];
    if (productDataRaw == null || productDataRaw is! Map) {
      debugPrint(
        '[ProductRepository] Product data not found in image response',
      );
      return null;
    }
    final productData = Map<String, dynamic>.from(productDataRaw);
    return _productToDomainMapper(productData);
  }
}
