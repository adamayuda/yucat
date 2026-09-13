import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/product_detail/presentation/utils/fit_verdict.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// "Great fit" / "Good fit" / "Some cautions" / "Not recommended" — the
/// per-cat verdict as a coloured pill. Deliberately carries no number.
class FitVerdictPill extends StatelessWidget {
  final FitVerdict verdict;
  final bool compact;

  const FitVerdictPill({super.key, required this.verdict, this.compact = false});

  static String labelFor(FitVerdict verdict, AppLocalizations l10n) =>
      switch (verdict) {
        FitVerdict.greatFit => l10n.productDetailFitGreat,
        FitVerdict.goodFit => l10n.productDetailFitGood,
        FitVerdict.someCautions => l10n.productDetailFitCautions,
        FitVerdict.notRecommended => l10n.productDetailFitNotRecommended,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (bg, fg, icon) = switch (verdict) {
      FitVerdict.greatFit => (
          DSColors.accentSuccessSoft,
          DSColors.accentSuccess,
          Icons.favorite_rounded,
        ),
      FitVerdict.goodFit => (
          DSColors.tintSky,
          DSColors.accentInfoDeep,
          Icons.check_circle_rounded,
        ),
      FitVerdict.someCautions => (
          const Color(0xFFFFF3D6),
          const Color(0xFFB37800),
          Icons.warning_amber_rounded,
        ),
      FitVerdict.notRecommended => (
          DSColors.coralSurface,
          DSColors.accentDanger,
          Icons.block_rounded,
        ),
    };
    final label = labelFor(verdict, l10n);
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? DSDimens.sizeXs : DSDimens.sizeS,
          vertical: compact ? DSDimens.sizeXxxs : DSDimens.sizeXxs,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(DSRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: compact ? 12 : 14, color: fg),
            const SizedBox(width: DSDimens.sizeXxxs),
            Text(
              label,
              style: (compact ? DSTextStyles.caption : DSTextStyles.label)
                  .copyWith(color: fg, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
