import 'package:flutter/foundation.dart';
import 'package:yucat/features/litter/data/mappers/litter_to_domain_mapper.dart';
import 'package:yucat/features/product/domain/entities/scan_result_entity.dart';
import 'package:yucat/features/product/data/datasources/product_remote_datasource.dart';
import 'package:yucat/features/product/data/mappers/product_to_domain_mapper.dart';
import 'package:yucat/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final RemoteSearchDataSource _remoteDataSource;
  final ProductToDomainMapper _productToDomainMapper;
  final LitterToDomainMapper _litterToDomainMapper;

  ProductRepositoryImpl({
    required RemoteSearchDataSource remoteDataSource,
    required ProductToDomainMapper productToDomainMapper,
    required LitterToDomainMapper litterToDomainMapper,
  }) : _remoteDataSource = remoteDataSource,
       _productToDomainMapper = productToDomainMapper,
       _litterToDomainMapper = litterToDomainMapper;

  @override
  Future<ScanResultEntity?> fetchProductByImage({
    required String imageBase64,
    required String mimeType,
    String? countryCode,
    String? locale,
  }) async {
    debugPrint('[ProductRepository] Fetching product by image');

    final remoteData = await _remoteDataSource.fetchProductByImage(
      imageBase64: imageBase64,
      mimeType: mimeType,
      countryCode: countryCode,
      locale: locale,
    );
    if (remoteData == null) {
      debugPrint('[ProductRepository] Nothing recognized in image');
      return null;
    }

    final fallbackRaw = remoteData['userPhotoFallbackUrl'];
    final userPhotoFallbackUrl = fallbackRaw is String && fallbackRaw.isNotEmpty
        ? fallbackRaw
        : null;

    // `category` is absent on responses from a backend older than litter
    // support; falling through to the product branch keeps those working.
    if (remoteData['category'] == 'litter') {
      final litterRaw = remoteData['litter'];
      if (litterRaw == null || litterRaw is! Map) {
        debugPrint('[ProductRepository] Litter data missing from response');
        return null;
      }
      final localizedRaw = remoteData['litterLocalizedText'];
      debugPrint('[ProductRepository] Litter found for image');
      return ScanLitterResult(
        _litterToDomainMapper(
          Map<String, dynamic>.from(litterRaw),
          localizedText: localizedRaw is Map
              ? Map<String, dynamic>.from(localizedRaw)
              : null,
          userPhotoFallbackUrl: userPhotoFallbackUrl,
        ),
      );
    }

    final productDataRaw = remoteData['product'];
    if (productDataRaw == null || productDataRaw is! Map) {
      debugPrint(
        '[ProductRepository] Product data not found in image response',
      );
      return null;
    }
    debugPrint('[ProductRepository] Product found for image');
    final productData = Map<String, dynamic>.from(productDataRaw);
    final localizedRaw = remoteData['localizedText'];
    return ScanFoodResult(
      _productToDomainMapper(
        productData,
        localizedText: localizedRaw is Map
            ? Map<String, dynamic>.from(localizedRaw)
            : null,
        userPhotoFallbackUrl: userPhotoFallbackUrl,
      ),
    );
  }
}
