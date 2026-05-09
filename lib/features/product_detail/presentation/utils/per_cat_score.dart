import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/utils/cat_product_assessment.dart';

class PerCatScore {
  final int score;
  final int maxScore;
  final ProductRatingColor ratingColor;

  const PerCatScore({
    required this.score,
    required this.maxScore,
    required this.ratingColor,
  });
}

// TODO: replace this client-side derivation with a real per-cat score
// emitted by the assessment domain layer (CatProductAssessment.score).
PerCatScore derivePerCatScore(CatProductAssessment assessment) {
  final raw = 70 + assessment.pros.length * 6 - assessment.cons.length * 12;
  final clamped = raw.clamp(0, 100);
  final color = clamped >= 70
      ? ProductRatingColor.green
      : clamped >= 50
          ? ProductRatingColor.yellow
          : ProductRatingColor.red;
  return PerCatScore(score: clamped, maxScore: 100, ratingColor: color);
}
