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

/// Color-buckets the assessment's numeric score into a `ProductRatingColor`
/// for the ring widget. The score itself is computed inside
/// `cat_product_assessment.dart` from the same rules that produce the
/// pros/cons text.
PerCatScore derivePerCatScore(CatProductAssessment assessment) {
  final score = assessment.score;
  final color = score >= 70
      ? ProductRatingColor.green
      : score >= 50
          ? ProductRatingColor.yellow
          : ProductRatingColor.red;
  return PerCatScore(score: score, maxScore: 100, ratingColor: color);
}
