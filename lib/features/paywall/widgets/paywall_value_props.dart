import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';

class PaywallValueProps extends StatelessWidget {
  const PaywallValueProps({super.key});

  static List<_Feature> _features(AppLocalizations l10n) => [
    _Feature(
      icon: Icons.document_scanner_outlined,
      title: l10n.paywallFeatureIngredientScannerTitle,
      benefit: l10n.paywallFeatureIngredientScannerBenefit,
    ),
    _Feature(
      icon: Icons.favorite_rounded,
      title: l10n.paywallFeaturePersonalizedVerdictsTitle,
      benefit: l10n.paywallFeaturePersonalizedVerdictsBenefit,
    ),
    _Feature(
      icon: Icons.all_inclusive_rounded,
      title: l10n.paywallFeatureUnlimitedScansTitle,
      benefit: l10n.paywallFeatureUnlimitedScansBenefit,
    ),
    _Feature(
      icon: Icons.notifications_active_rounded,
      title: l10n.paywallFeatureReformulationAlertsTitle,
      benefit: l10n.paywallFeatureReformulationAlertsBenefit,
    ),
    _Feature(
      icon: Icons.bookmark_rounded,
      title: l10n.paywallFeatureSavedFoodsTitle,
      benefit: l10n.paywallFeatureSavedFoodsBenefit,
    ),
    _Feature(
      icon: Icons.pets_rounded,
      title: l10n.paywallFeatureMultiCatTitle,
      benefit: l10n.paywallFeatureMultiCatBenefit,
    ),
  ];

  static const _tileSize = 36.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final features = _features(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            l10n.paywallEverythingYouGet,
            textAlign: TextAlign.center,
            style: DSTextStyles.displayLg,
          ),
        ),
        const SizedBox(height: DSDimens.sizeM),
        for (var i = 0; i < features.length; i++) ...[
          if (i > 0)
            const Padding(
              // Inset so the divider aligns under the text column, not the tile.
              padding: EdgeInsets.only(left: _tileSize + DSDimens.sizeM),
              child: Divider(height: 1, thickness: 1, color: DSColors.border),
            ),
          _FeatureRow(feature: features[i]),
        ],
      ],
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String benefit;

  _Feature({
    required this.icon,
    required this.title,
    required this.benefit,
  });
}

class _FeatureRow extends StatelessWidget {
  final _Feature feature;

  const _FeatureRow({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSDimens.sizeXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: PaywallValueProps._tileSize,
            height: PaywallValueProps._tileSize,
            decoration: BoxDecoration(
              color: DSColors.paywallAccentSoft,
              borderRadius: BorderRadius.circular(DSRadii.md),
            ),
            child: Icon(feature.icon, color: DSColors.paywallAccent, size: 18),
          ),
          const SizedBox(width: DSDimens.sizeM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: DSTextStyles.bodyMd.copyWith(
                    color: DSColors.inkPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DSDimens.sizeXxxxs),
                Text(
                  feature.benefit,
                  style: DSTextStyles.caption.copyWith(
                    color: DSColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
