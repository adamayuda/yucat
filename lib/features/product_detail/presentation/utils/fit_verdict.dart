import 'package:yucat/features/product_detail/presentation/utils/cat_product_assessment.dart';

/// The per-cat result, as a verdict rather than a second number.
///
/// The product keeps the only numeric score on the screen. What a cat's
/// profile adds is a *direction* — this food is a better or worse choice for
/// this cat than for the average one — and the findings that explain it. A
/// second 0–100 ring next to the first read as a competing grade (and its
/// neutral baseline of 70 rendered green), which is the confusion this
/// replaces. Same model the litter side uses: universal score, per-cat notes.
///
/// The numeric `CatProductAssessment.score` still exists and still ranks the
/// "Better for {cat}" alternatives; it just never reaches the UI.
enum FitVerdict {
  greatFit,
  goodFit,
  someCautions,
  notRecommended;

  /// Bands on the weighted delta, not on the clamped score, so the neutral
  /// baseline is exactly 0. A hard flag — a declared allergen in the food,
  /// kidney disease with high protein, diabetes with high carbs — overrides
  /// the arithmetic: no number of pros makes that food safe for that cat.
  static FitVerdict of(CatProductAssessment a) {
    if (a.hasHardFlag) return FitVerdict.notRecommended;
    if (a.delta >= 8) return FitVerdict.greatFit;
    if (a.delta >= 0) return FitVerdict.goodFit;
    if (a.delta > -10) return FitVerdict.someCautions;
    return FitVerdict.notRecommended;
  }

  /// Analytics value (`fit_band`).
  String get analyticsName => switch (this) {
        FitVerdict.greatFit => 'great_fit',
        FitVerdict.goodFit => 'good_fit',
        FitVerdict.someCautions => 'some_cautions',
        FitVerdict.notRecommended => 'not_recommended',
      };
}
