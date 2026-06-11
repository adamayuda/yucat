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
