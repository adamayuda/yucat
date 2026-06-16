import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/entities/cat_narrative.dart';

/// A single structured dietary tip (nutrient + direction) used to ground the
/// generated narrative. Mirrors `DietRecommendation` but carries only the
/// language-neutral fields the backend needs.
class DietTip {
  final String nutrient;
  final String direction; // 'more' | 'less'

  const DietTip({required this.nutrient, required this.direction});
}

abstract class CatNarrativeRepository {
  /// Returns a short, personalized narrative (+ outlook) for [cat], grounded by
  /// [tips] and written in [locale]. Returns null when generation fails (caller
  /// falls back to a local template).
  Future<CatNarrative?> generateNarrative({
    required CatEntity cat,
    required List<DietTip> tips,
    required String locale,
  });
}
