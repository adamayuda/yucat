import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// The six things a subscription buys, as a 2-column card grid.
///
/// Two media treatments: the capability benefits get a tinted square with an
/// icon, the content benefits (recipes / articles / food guide) get a pair of
/// overlapping photos. Those photos are **bundled assets**, downscaled copies
/// of the Storage originals — the paywall makes zero network image requests and
/// must render instantly, so it doesn't read Firestore for them.
class PaywallValueProps extends StatelessWidget {
  const PaywallValueProps({super.key});

  static List<_Feature> _features(AppLocalizations l10n) => [
    _Feature(
      media: const _IconMedia('assets/images/camera.svg', DSColors.tintSky),
      title: l10n.paywallFeatureUnlimitedScansTitle,
      benefit: l10n.paywallFeatureUnlimitedScansBenefit,
    ),
    _Feature(
      media: const _IconMedia('assets/images/Health.svg', DSColors.tintMint),
      title: l10n.paywallFeaturePersonalizedVerdictsTitle,
      benefit: l10n.paywallFeaturePersonalizedVerdictsBenefit,
    ),
    _Feature(
      media: const _PhotoMedia([
        'assets/images/paywall-recipe-1.jpg',
        'assets/images/paywall-recipe-2.jpg',
      ]),
      title: l10n.paywallFeatureRecipesTitle,
      benefit: l10n.paywallFeatureRecipesBenefit,
    ),
    _Feature(
      media: const _PhotoMedia([
        'assets/images/paywall-article-1.jpg',
        'assets/images/paywall-article-2.jpg',
      ]),
      title: l10n.paywallFeatureArticlesTitle,
      benefit: l10n.paywallFeatureArticlesBenefit,
    ),
    _Feature(
      media: const _PhotoMedia([
        'assets/images/paywall-guide-1.jpg',
        'assets/images/paywall-guide-2.jpg',
      ]),
      title: l10n.paywallFeatureFoodGuideTitle,
      benefit: l10n.paywallFeatureFoodGuideBenefit,
    ),
    _Feature(
      media: const _IconMedia('assets/images/cat-paw.svg', DSColors.tintSand),
      title: l10n.paywallFeatureMultiCatTitle,
      benefit: l10n.paywallFeatureMultiCatBenefit,
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
        const SizedBox(height: DSDimens.sizeM),
        // Rows of two rather than a Wrap or a GridView. A Wrap lets each child
        // keep its own height, so a two-line benefit next to a one-line one
        // leaves the pair ragged; IntrinsicHeight + stretch sizes both cards to
        // the taller of the two. No fixed height, so the longer German and
        // French strings just make a row taller.
        for (var i = 0; i < features.length; i += 2) ...[
          if (i > 0) const SizedBox(height: DSDimens.sizeS),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _FeatureCard(feature: features[i])),
                const SizedBox(width: DSDimens.sizeS),
                // Empty half-slot if the list ever goes odd, so the last card
                // keeps its column width instead of spanning the row.
                Expanded(
                  child: i + 1 < features.length
                      ? _FeatureCard(feature: features[i + 1])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Feature {
  final _Media media;
  final String title;
  final String benefit;

  const _Feature({
    required this.media,
    required this.title,
    required this.benefit,
  });
}

sealed class _Media extends StatelessWidget {
  const _Media();

  /// Every media variant occupies the same slot height so cards in a row line
  /// their text up regardless of which treatment they use.
  static const double size = 56;
}

class _IconMedia extends _Media {
  final String asset;
  final Color tint;

  const _IconMedia(this.asset, this.tint);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _Media.size,
      height: _Media.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(DSRadii.md),
      ),
      child: SvgPicture.asset(asset, width: 28, height: 28),
    );
  }
}

class _PhotoMedia extends _Media {
  final List<String> assets;

  const _PhotoMedia(this.assets);

  /// Leaves an 18px overlap between the two thumbnails.
  static const double _step = 38;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _Media.size,
      width: _Media.size + (assets.length - 1) * _step,
      child: Stack(
        children: [
          for (var i = 0; i < assets.length; i++)
            Positioned(
              left: i * _step,
              child: Container(
                width: _Media.size,
                height: _Media.size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DSRadii.md),
                  // The ring is the page colour, so it reads as a gap between
                  // the overlapping thumbnails rather than as a border.
                  border: Border.all(color: DSColors.surfaceCard, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DSRadii.md - 2),
                  child: Image.asset(
                    assets[i],
                    width: _Media.size - 4,
                    height: _Media.size - 4,
                    cacheWidth: 156,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      decoration: BoxDecoration(
        // No border — white card on a white page, so the elevation is the only
        // thing separating it. e2 rather than e1 for that reason.
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        boxShadow: DSShadows.e2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          feature.media,
          const SizedBox(height: DSDimens.sizeM),
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
            style: DSTextStyles.caption.copyWith(color: DSColors.inkSecondary),
          ),
        ],
      ),
    );
  }
}
