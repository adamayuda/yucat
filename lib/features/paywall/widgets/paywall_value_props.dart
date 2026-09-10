import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// The four things a subscription buys, as a single-column list.
///
/// Each row reads as one sentence — "**Unlimited scans**: no daily limit." —
/// so the title and the benefit are composed through [
/// AppLocalizations.paywallFeatureLine] rather than concatenated in code:
/// French puts a space before the colon and the other five locales do not.
class PaywallValueProps extends StatelessWidget {
  const PaywallValueProps({super.key});

  static List<_Feature> _features(AppLocalizations l10n) => [
    _Feature(
      asset: 'assets/images/camera.svg',
      tint: DSColors.tintSky,
      title: l10n.paywallFeatureUnlimitedScansTitle,
      benefit: l10n.paywallFeatureUnlimitedScansBenefit,
    ),
    _Feature(
      asset: 'assets/images/Health.svg',
      tint: DSColors.tintCoral,
      title: l10n.paywallFeaturePersonalizedVerdictsTitle,
      benefit: l10n.paywallFeaturePersonalizedVerdictsBenefit,
    ),
    _Feature(
      asset: 'assets/images/Cake.svg',
      tint: DSColors.tintSand,
      title: l10n.paywallFeatureRecipesArticlesTitle,
      benefit: l10n.paywallFeatureRecipesArticlesBenefit,
    ),
    _Feature(
      asset: 'assets/images/apple.svg',
      tint: DSColors.tintLavender,
      title: l10n.paywallFeatureFoodGuideTitle,
      benefit: l10n.paywallFeatureFoodGuideBenefit,
    ),
  ];

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
        const SizedBox(height: DSDimens.sizeL),
        for (var i = 0; i < features.length; i++) ...[
          if (i > 0) const SizedBox(height: DSDimens.sizeL),
          _FeatureRow(feature: features[i]),
        ],
      ],
    );
  }
}

class _Feature {
  final String asset;
  final Color tint;
  final String title;
  final String benefit;

  const _Feature({
    required this.asset,
    required this.tint,
    required this.title,
    required this.benefit,
  });
}

class _FeatureRow extends StatelessWidget {
  final _Feature feature;

  const _FeatureRow({required this.feature});

  static const double _iconSlot = 48;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final line = l10n.paywallFeatureLine(feature.title, feature.benefit);
    // The title is bolded in place rather than rendered as its own span, so a
    // locale that moves it within the pattern still bolds the right words.
    final idx = line.indexOf(feature.title);
    final before = idx >= 0 ? line.substring(0, idx) : '';
    final bold = idx >= 0 ? feature.title : line;
    final after = idx >= 0 ? line.substring(idx + feature.title.length) : '';
    final base = DSTextStyles.bodyLg;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: _iconSlot,
          height: _iconSlot,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: feature.tint,
            borderRadius: BorderRadius.circular(DSRadii.lg),
          ),
          child: SvgPicture.asset(feature.asset, width: 24, height: 24),
        ),
        const SizedBox(width: DSDimens.sizeS),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: base.copyWith(color: DSColors.inkSecondary),
              children: [
                TextSpan(text: before),
                TextSpan(
                  text: bold,
                  style: base.copyWith(
                    color: DSColors.inkPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: after),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
