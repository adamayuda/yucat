import 'package:yucat/features/product/domain/entities/scan_result_entity.dart';

abstract class ProductRepository {
  /// Scans a package photo. Returns a [ScanFoodResult] or a [ScanLitterResult]
  /// depending on what the backend recognized, or null when it recognized
  /// neither.
  Future<ScanResultEntity?> fetchProductByImage({
    required String imageBase64,
    required String mimeType,
    String? countryCode,
    String? locale,
  });
}
