import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/product/domain/entities/product_entity.dart';
import 'package:yucat/features/product_detail/presentation/mappers/product_entity_to_model_mapper.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/utils/cat_product_assessment.dart';
import 'package:yucat/features/search/domain/usecases/search_by_query_usecase.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/service_locator.dart';

/// A single recommended product with its per-cat fit and the headline reason.
class ProductPick {
  final ProductDisplayModel product;

  /// Per-cat fit score (0-100) from [evaluateCatProduct] — what drives the
  /// ranking and the badge (distinct from the product's own quality score).
  final int fit;

  /// The top matching reason (e.g. "Renal-targeted formulation"), or null.
  final String? why;

  /// The dimension the reason came from (for an icon/tint), or null.
  final CatAssessmentDimension? dim;

  /// How many of the cat's distinct health needs this food addresses (used to
  /// rank multi-benefit foods above single-benefit ones).
  final int coverage;

  const ProductPick({
    required this.product,
    required this.fit,
    this.why,
    this.dim,
    this.coverage = 0,
  });
}

/// Only recommend products that are a genuinely good food in general
/// (`_minBaseScore`, post-rescore quality) and not actively wrong for this cat
/// (`_minFit`). For a cat with no special needs every product sits near the
/// neutral 70, so the fit floor is "not bad" rather than "great"; ranking then
/// leans on quality. For a cat with conditions, poor-fit foods fall well below
/// the floor and drop out.
// Only recommend genuinely good-quality foods. After the ingredient-quality
// re-score, real therapeutic/vet diets land at 72+ (so they pass on their own),
// while cheap foods with good-looking macros (e.g. sugary, plant-protein
// Whiskas) sit ~52 and are correctly excluded.
const _minBaseScore = 70;
const _minFit = 68;
const _poolPerQuery = 40;
const _poolCacheSize = 10;

/// In-memory cache of computed picks, keyed by cat id, so navigating between
/// surfaces within a session doesn't refetch.
final Map<String, List<ProductPick>> _cache = {};

/// Recommends real catalog products for [cat], ranked by per-cat fit.
///
/// Pulls candidates from Algolia (need-based queries + a broad query), maps to
/// display models, scores each with [evaluateCatProduct], keeps only decent +
/// well-fitting foods, and returns the best [limit]. Offline/failure-safe:
/// returns `[]`.
Future<List<ProductPick>> recommendProductsForCat(
  CatEntity cat,
  AppLocalizations l10n, {
  int limit = 5,
}) async {
  final cacheKey = cat.id;
  if (cacheKey != null && _cache.containsKey(cacheKey)) {
    return _cache[cacheKey]!.take(limit).toList();
  }

  try {
    final usecase = sl<SearchByQueryUsecase>();
    final mapper = sl<ProductEntityToModelMapper>();

    final queries = <String>{'', ..._needTerms(cat).take(2)};
    final results = await Future.wait(
      queries.map((q) => usecase.call(query: q, hitsPerPage: _poolPerQuery)),
    );

    // Dedupe by brand+name (mirrors the saved-products identity).
    final seen = <String>{};
    final candidates = <ProductEntity>[];
    for (final list in results) {
      for (final e in list) {
        if (e.score < _minBaseScore) continue; // quality floor
        final key = '${e.brand}__${e.name}'.trim().toLowerCase();
        if (seen.add(key)) candidates.add(e);
      }
    }

    // The generic "wet food is easier to eat" line — every wet food earns it
    // for a dental cat, so we prefer a more specific reason when one exists.
    final genericWhy = l10n.assessmentDentalHighMoisture;

    // Score → keep good fits → capture the headline reason + coverage.
    final picks = <ProductPick>[];
    for (final e in candidates) {
      final model = mapper(e);
      final a = evaluateCatProduct(cat, model, l10n);
      if (a.score < _minFit) continue;
      final reason = _pickReason(a.pros, genericWhy);
      final coverage =
          a.pros.where((p) => p.dimension == CatAssessmentDimension.health).length;
      picks.add(
        ProductPick(
          product: model,
          fit: a.score,
          why: reason?.text,
          dim: reason?.dimension,
          coverage: coverage,
        ),
      );
    }
    // Rank by suitability first (matches the displayed fit badge), then by how
    // many needs the food covers (surfaces multi-benefit foods), then quality.
    picks.sort((x, y) {
      final byFit = y.fit.compareTo(x.fit);
      if (byFit != 0) return byFit;
      final byCoverage = y.coverage.compareTo(x.coverage);
      if (byCoverage != 0) return byCoverage;
      return y.product.score.compareTo(x.product.score);
    });

    final top = picks.take(_poolCacheSize).toList();
    if (cacheKey != null) _cache[cacheKey] = top;
    return top.take(limit).toList();
  } catch (_) {
    return const [];
  }
}

/// Drops any cached picks for [catId] (call after editing a cat profile).
void invalidateProductPicksCache(String? catId) {
  if (catId != null) _cache.remove(catId);
}

/// Chooses the headline reason: prefer a specific benefit over the generic
/// "wet food is easier to eat" line, and a health-targeted reason when present,
/// so picks don't all show the same moisture line.
CatProductFinding? _pickReason(
  List<CatProductFinding> pros,
  String genericWhy,
) {
  if (pros.isEmpty) return null;
  final specific = pros.where((p) => p.text != genericWhy).toList();
  final pool = specific.isNotEmpty ? specific : pros;
  for (final p in pool) {
    if (p.dimension == CatAssessmentDimension.health) return p;
  }
  return pool.first;
}

/// Search terms drawn from the cat's most important needs, highest priority
/// first. Only needs that map to real product-name vocabulary are included;
/// everything else is covered by the broad pool + the scorer.
List<String> _needTerms(CatEntity cat) {
  final terms = <String>[];
  final conditions = (cat.healthConditions ?? const [])
      .map((c) => c.trim().toLowerCase())
      .toSet();

  if (conditions.contains('kidney_disease')) terms.add('renal');
  if (conditions.contains('urinary_issues')) terms.add('urinary');
  if (conditions.contains('hairball_issues')) terms.add('hairball');
  if (conditions.contains('sensitive_stomach')) terms.add('sensitive');

  final weight = cat.weightCategory?.trim().toLowerCase();
  if (weight == 'overweight' || weight == 'obese') terms.add('weight');

  final stage = (cat.ageGroup ?? ageGroupFromMonths(cat.age))?.toLowerCase();
  if (stage == 'kitten') terms.add('kitten');
  if (stage == 'senior') terms.add('senior');

  return terms;
}
