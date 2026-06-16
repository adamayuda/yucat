import 'package:yucat/features/brand/domain/entities/brand_verdict.dart';
import 'package:yucat/features/brand/domain/repositories/brand_verdict_repository.dart';
import 'package:yucat/features/product/domain/entities/product_entity.dart';
import 'package:yucat/features/search/domain/usecases/search_by_brand_usecase.dart';

/// Produces a brand quality verdict for the onboarding critique. Grounds the
/// LLM with our own catalog data for the brand (average re-graded score + most
/// common cons) when we have it. Offline/failure-safe: returns null.
class AnalyzeBrandUsecase {
  final BrandVerdictRepository _repository;
  final SearchByBrandUsecase _searchByBrand;

  AnalyzeBrandUsecase({
    required BrandVerdictRepository repository,
    required SearchByBrandUsecase searchByBrand,
  })  : _repository = repository,
        _searchByBrand = searchByBrand;

  Future<BrandVerdict?> call({
    required String brand,
    String? catName,
    required String locale,
  }) async {
    BrandCatalogContext? context;
    try {
      final products = await _searchByBrand.call(brandName: brand);
      if (products.isNotEmpty) context = _buildContext(products);
    } catch (_) {
      // No grounding — the LLM falls back to its own knowledge.
    }

    try {
      return await _repository.analyze(
        brand: brand,
        catName: catName,
        locale: locale,
        context: context,
      );
    } catch (_) {
      return null;
    }
  }

  BrandCatalogContext _buildContext(List<ProductEntity> products) {
    final scored = products.where((p) => p.score > 0).toList();
    final base = scored.isNotEmpty ? scored : products;
    final avg = base.isEmpty
        ? 0.0
        : base.map((p) => p.score).reduce((a, b) => a + b) / base.length;

    // Most frequent cons across the brand's products.
    final counts = <String, int>{};
    for (final p in base) {
      for (final c in p.cons) {
        final key = c.trim();
        if (key.isEmpty) continue;
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }
    final topCons = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));

    return BrandCatalogContext(
      avgScore: avg,
      productCount: base.length,
      topCons: topCons.take(5).toList(),
    );
  }
}
