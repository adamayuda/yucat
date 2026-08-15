import 'package:yucat/features/product/domain/entities/scan_result_entity.dart';
import 'package:yucat/features/product/domain/repositories/product_repository.dart';

class FetchProductByImageUsecase {
  final ProductRepository _productRepository;

  FetchProductByImageUsecase({required ProductRepository productRepository})
    : _productRepository = productRepository;

  /// Returns a [ScanFoodResult] or a [ScanLitterResult] — the camera is one
  /// entry point for both categories — or null when nothing was recognized.
  Future<ScanResultEntity?> call({
    required String imageBase64,
    required String mimeType,
    String? countryCode,
    String? locale,
  }) async {
    return _productRepository.fetchProductByImage(
      imageBase64: imageBase64,
      mimeType: mimeType,
      countryCode: countryCode,
      locale: locale,
    );
  }
}
