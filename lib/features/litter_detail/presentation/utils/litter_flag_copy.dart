import 'package:yucat/features/litter_detail/presentation/utils/cat_litter_safety.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// Maps a [LitterFlagCode] to localized copy for [catName].
///
/// The rules engine deals only in codes so it stays free of display strings —
/// this is the single place a new flag needs copy wired up.
String litterFlagText(
  LitterFlagCode code,
  String catName,
  AppLocalizations l10n,
) {
  switch (code) {
    case LitterFlagCode.kittenClumpingClay:
      return l10n.litterFlagKittenClumpingClay(catName);
    case LitterFlagCode.kittenSilica:
      return l10n.litterFlagKittenSilica(catName);
    case LitterFlagCode.monitoringClumping:
      return l10n.litterFlagMonitoringClumping(catName);
    case LitterFlagCode.monitoringNonClumping:
      return l10n.litterFlagMonitoringNonClumping(catName);
    case LitterFlagCode.sensitiveScented:
      return l10n.litterFlagSensitiveScented(catName);
    case LitterFlagCode.sensitiveDust:
      return l10n.litterFlagSensitiveDust(catName);
    case LitterFlagCode.pawComfortCoarse:
      return l10n.litterFlagPawComfortCoarse(catName);
    case LitterFlagCode.pawComfortFine:
      return l10n.litterFlagPawComfortFine(catName);
    case LitterFlagCode.longCoatTracking:
      return l10n.litterFlagLongCoatTracking(catName);
  }
}
