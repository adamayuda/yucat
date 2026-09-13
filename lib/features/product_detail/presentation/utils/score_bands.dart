import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';

/// The one band table for the product's 0–100 quality score.
///
/// Label and colour used to come from two different threshold sets
/// (`Good` started at 60 while green started at 70), so a 65 was headlined
/// "A solid everyday pick" beside a yellow ring. Every surface that shows the
/// score — the detail card, search rows, saved lists, litter, the picks list —
/// now derives both from this enum, so they can no longer disagree.
enum ScoreBand {
  excellent,
  good,
  average,
  poor;

  static ScoreBand of(int score, int maxScore) {
    if (maxScore <= 0) return ScoreBand.poor;
    final pct = (score / maxScore) * 100;
    if (pct >= 80) return ScoreBand.excellent;
    if (pct >= 60) return ScoreBand.good;
    if (pct >= 40) return ScoreBand.average;
    return ScoreBand.poor;
  }

  /// English lookup key — the value `ProductDisplayModel.ratingText` carries.
  /// Display copy comes from `verdict_headline.dart`, never from this string.
  String get key => switch (this) {
        ScoreBand.excellent => 'Excellent',
        ScoreBand.good => 'Good',
        ScoreBand.average => 'Average',
        ScoreBand.poor => 'Poor',
      };

  /// Analytics value (`rating_band`).
  String get analyticsName => name;

  ProductRatingColor get color => switch (this) {
        ScoreBand.excellent || ScoreBand.good => ProductRatingColor.green,
        ScoreBand.average => ProductRatingColor.yellow,
        ScoreBand.poor => ProductRatingColor.red,
      };
}
