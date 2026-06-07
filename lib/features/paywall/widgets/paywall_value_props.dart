import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/paywall/paywall_colors.dart';

class PaywallValueProps extends StatelessWidget {
  const PaywallValueProps({super.key});

  static const _features = <_Feature>[
    _Feature(
      icon: Icons.document_scanner_outlined,
      title: 'Ingredient scanner',
      benefit: 'Scan any label in seconds',
    ),
    _Feature(
      icon: Icons.favorite_rounded,
      title: 'Personalized verdicts',
      benefit: "Matched to your cat's age, breed & health",
    ),
    _Feature(
      icon: Icons.all_inclusive_rounded,
      title: 'Unlimited scans',
      benefit: 'No daily caps, ever',
    ),
    _Feature(
      icon: Icons.notifications_active_rounded,
      title: 'Reformulation alerts',
      benefit: 'Know the moment a recipe changes',
    ),
    _Feature(
      icon: Icons.bookmark_rounded,
      title: 'Saved foods & history',
      benefit: "Every food you've checked, in one place",
    ),
    _Feature(
      icon: Icons.pets_rounded,
      title: 'Multi-cat profiles',
      benefit: 'A tailored profile for each of your cats',
    ),
  ];

  static const _tileSize = 36.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Everything you get',
            textAlign: TextAlign.center,
            style: DSTextStyles.displayLg,
          ),
        ),
        const SizedBox(height: DSDimens.sizeM),
        for (var i = 0; i < _features.length; i++) ...[
          if (i > 0)
            const Padding(
              // Inset so the divider aligns under the text column, not the tile.
              padding: EdgeInsets.only(left: _tileSize + DSDimens.sizeM),
              child: Divider(height: 1, thickness: 1, color: DSColors.border),
            ),
          _FeatureRow(feature: _features[i]),
        ],
      ],
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String benefit;

  const _Feature({
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
              color: kPaywallAccentSoft,
              borderRadius: BorderRadius.circular(DSRadii.md),
            ),
            child: Icon(feature.icon, color: kPaywallAccent, size: 18),
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
                const SizedBox(height: 2),
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
