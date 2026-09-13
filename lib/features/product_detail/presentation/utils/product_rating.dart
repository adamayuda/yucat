import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/utils/score_bands.dart';

/// Turns a product's 0–[maxScore] score into the display rating label and
/// ring colour. Used by every mapper that builds a [ProductDisplayModel]
/// (scan, search, listing, saved, litter). Both are views of one [ScoreBand],
/// so the headline and the colour always agree.
///
/// The lowercased label maps to a friendly headline in `verdict_headline.dart`
/// (`excellent` / `good` / `average` / `poor`).
String ratingTextForScore(int score, int maxScore) {
  if (maxScore <= 0) return '';
  return ScoreBand.of(score, maxScore).key;
}

ProductRatingColor ratingColorForScore(int score, int maxScore) =>
    ScoreBand.of(score, maxScore).color;
