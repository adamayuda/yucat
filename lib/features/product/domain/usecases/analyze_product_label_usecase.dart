import 'package:yucat/features/product/domain/entities/label_target.dart';
import 'package:yucat/features/product/domain/entities/scan_result_entity.dart';
import 'package:yucat/features/product/domain/repositories/product_repository.dart';

/// The back-label rescue path — see [ProductRepository.analyzeProductLabel].
class AnalyzeProductLabelUsecase {
  final ProductRepository _productRepository;

  AnalyzeProductLabelUsecase({required ProductRepository productRepository})
    : _productRepository = productRepository;

  Future<ScanResultEntity> call({
    required String imageBase64,
    required String mimeType,
    required LabelTarget target,
    String? countryCode,
    String? locale,
  }) {
    return _productRepository.analyzeProductLabel(
      imageBase64: imageBase64,
      mimeType: mimeType,
      target: target,
      countryCode: countryCode,
      locale: locale,
    );
  }
}
