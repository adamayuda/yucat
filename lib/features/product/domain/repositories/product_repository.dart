import 'package:yucat/features/product/domain/entities/label_target.dart';
import 'package:yucat/features/product/domain/entities/scan_result_entity.dart';

abstract class ProductRepository {
  /// Scans a package photo. Always returns one of the [ScanResultEntity]
  /// variants — a success ([ScanFoodResult] / [ScanLitterResult]) or a typed
  /// failure ([ScanNotIdentified] / [ScanAnalysisFailed]). Transport and
  /// backend errors throw a `ScanException`.
  ///
  /// [gtin] is the normalised barcode read off the still, when any — the
  /// backend uses it for an exact cache lookup before identify, and as a
  /// fallback identity when the photo itself is unreadable.
  Future<ScanResultEntity> fetchProductByImage({
    required String imageBase64,
    required String mimeType,
    String? countryCode,
    String? locale,
    String? gtin,
  });

  /// The back-label rescue: sends a photo of the ingredients / analysis panel
  /// and what is known about the product ([target]); the backend reads the
  /// nutrition off the label and merges it into the record. Returns a
  /// [ScanFoodResult] (`path == 'label'`) or a [ScanLabelFailed].
  Future<ScanResultEntity> analyzeProductLabel({
    required String imageBase64,
    required String mimeType,
    required LabelTarget target,
    String? countryCode,
    String? locale,
  });
}
