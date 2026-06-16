import 'package:yucat/features/brand/domain/entities/brand_verdict.dart';

abstract class BrandVerdictRepository {
  /// Returns a quality verdict for [brand], grounded by [context] when present
  /// and written in [locale]. Returns null on failure.
  Future<BrandVerdict?> analyze({
    required String brand,
    String? catName,
    required String locale,
    BrandCatalogContext? context,
  });
}
