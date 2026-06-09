import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';

/// Single source of truth for turning a product's 0–[maxScore] score into a
/// display rating label and ring color. Used by every mapper that builds a
/// [ProductDisplayModel] (scan, search, listing, saved) so the score ring and
/// verdict headline are always consistent.
///
/// The lowercased label maps to a friendly headline in `verdict_headline.dart`
/// (`excellent` / `good` / `average` / `poor`).
String ratingTextForScore(int score, int maxScore) {
  if (maxScore <= 0) return '';
  final percentage = (score / maxScore) * 100;
  if (percentage >= 80) return 'Excellent';
  if (percentage >= 60) return 'Good';
  if (percentage >= 40) return 'Average';
  return 'Poor';
}

ProductRatingColor ratingColorForScore(int score, int maxScore) {
  if (maxScore <= 0) return ProductRatingColor.red;
  final percentage = (score / maxScore) * 100;
  if (percentage >= 70) return ProductRatingColor.green;
  if (percentage >= 40) return ProductRatingColor.yellow;
  return ProductRatingColor.red;
}
