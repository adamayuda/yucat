import 'package:yucat/l10n/app_localizations.dart';

String verdictHeadlineFor(String ratingText, AppLocalizations l10n) {
  switch (ratingText.toLowerCase()) {
    case 'excellent':
      return l10n.productDetailVerdictExcellent;
    case 'good':
      return l10n.productDetailVerdictGood;
    case 'average':
      return l10n.productDetailVerdictAverage;
    case 'poor':
      return l10n.productDetailVerdictPoor;
    default:
      return ratingText;
  }
}

/// Short localized label for a compact score pill ("Excellent", "Bon", …).
///
/// [ratingText] is the English key produced by `ratingTextForScore` — it is a
/// lookup key, never display copy. Rendering it raw is what left English pills
/// on the search and cat-picks lists.
String ratingLabelFor(String ratingText, AppLocalizations l10n) {
  switch (ratingText.toLowerCase()) {
    case 'excellent':
      return l10n.ratingLabelExcellent;
    case 'good':
      return l10n.ratingLabelGood;
    case 'average':
      return l10n.ratingLabelAverage;
    case 'poor':
      return l10n.ratingLabelPoor;
    default:
      return ratingText;
  }
}
