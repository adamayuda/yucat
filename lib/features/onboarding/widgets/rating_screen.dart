import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/onboarding_floating_button.dart';

/// Social-proof screen — App Store rating + a stack of reviews.
///
/// Tapping "Next" requests the native App Store review popup
/// (`SKStoreReviewController` on iOS) before advancing the flow. The popup
/// is rate-limited by Apple and may not appear; onboarding advances either
/// way.
/// Muted warm-grey used for the supporting labels on this screen.
const _mutedLabel = Color(0xFFAAA498);

class RatingScreen extends StatelessWidget {
  final VoidCallback onNext;

  const RatingScreen({super.key, required this.onNext});

  /// Requests the native review popup, then advances. Never blocks the flow
  /// on a review-prompt failure or unavailability.
  Future<void> _handleNext() async {
    try {
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      }
    } catch (_) {
      // Ignore — advancing onboarding must not depend on the review prompt.
    }
    onNext();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reviews = _buildReviews(l10n);
    return Scaffold(
      // Placeholder cream background; decorative art (stars, cat, laurels) will
      // be layered back in as individual assets are provided.
      backgroundColor: DSColors.tintCream,
      body: Stack(
        children: [
          // Radial glow as a full-width background — pinned to the very top,
          // behind the status bar; height follows the asset's square ratio.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ExcludeSemantics(
              // AspectRatio (asset is 393×450) derives the height from the
              // constrained full width so the box matches the image exactly —
              // no empty strip that would look like a safe-area gap.
              child: AspectRatio(
                aspectRatio: 393 / 450,
                child: SvgPicture.asset(
                  'assets/images/highlight-rating.svg',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          // Decorative stars scattered around the header, flanking the cat.
          // ('star.svg' is the sharp glyph; 'star-blur.svg' is the blurred one.)
          const _Star(asset: 'star-blur.svg', size: 24, top: 96, left: 24),
          const _Star(asset: 'star.svg', size: 48, top: 96, right: 24),
          const _Star(asset: 'star.svg', size: 34, top: 170, left: 60),
          const _Star(asset: 'star-blur.svg', size: 24, top: 160, right: 60),
          SafeArea(
            child: Stack(
              children: [
                // The whole screen scrolls — header, stats and reviews together.
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    DSDimens.sizeL,
                    // Clear the back chip at the top.
                    64,
                    DSDimens.sizeL,
                    // Clear the floating Next button + fade so the last review
                    // can scroll fully above it.
                    150,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/cat-rating.svg',
                        height: 90,
                      ),
                      const SizedBox(height: DSDimens.sizeXxl),
                      Text(
                        l10n.onboardingRatingEyebrow,
                        style: DSTextStyles.caption.copyWith(
                          color: _mutedLabel,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: DSDimens.sizeXxs),
                      Text(
                        l10n.onboardingRatingTitle,
                        textAlign: TextAlign.center,
                        style: DSTextStyles.displayLg,
                      ),
                      const SizedBox(height: DSDimens.sizeXxl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.flip(
                            flipX: true,
                            child: SvgPicture.asset(
                              'assets/images/wheat.svg',
                              height: 64,
                            ),
                          ),
                          const SizedBox(width: DSDimens.sizeL),
                          _StatBlock(
                            value: l10n.onboardingRatingStatValue,
                            label: l10n.onboardingRatingStatLabel,
                          ),
                          const SizedBox(width: DSDimens.size4xl),
                          const _PeopleBlock(),
                          const SizedBox(width: DSDimens.sizeL),
                          SvgPicture.asset(
                            'assets/images/wheat.svg',
                            height: 64,
                          ),
                        ],
                      ),
                      const SizedBox(height: DSDimens.sizeXxl),
                      for (var i = 0; i < reviews.length; i++) ...[
                        if (i > 0) const SizedBox(height: DSDimens.sizeXxs),
                        _ReviewCard(review: reviews[i]),
                      ],
                    ],
                  ),
                ),
                // Fade behind the floating Next button (same effect as the
                // other onboarding screens).
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 150,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            DSColors.tintCream.withValues(alpha: 0),
                            DSColors.tintCream,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Floats centered over the bottom of the scrolling content.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: Center(
                      child: OnboardingFloatingButton(
                        label: l10n.commonNext,
                        onPressed: _handleNext,
                      ),
                    ),
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

/// Decorative star pinned to the header area (fixed, behind the content).
class _Star extends StatelessWidget {
  final String asset;
  final double size;
  final double? top;
  final double? left;
  final double? right;

  const _Star({
    required this.asset,
    required this.size,
    this.top,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: ExcludeSemantics(
        child: SvgPicture.asset('assets/images/$asset', width: size),
      ),
    );
  }
}

class _Review {
  final String headline;
  final String body;
  final String author;
  final String avatar;
  const _Review({
    required this.headline,
    required this.body,
    required this.author,
    required this.avatar,
  });
}

// TODO: replace placeholder reviews with real, attributed App Store reviews.
List<_Review> _buildReviews(AppLocalizations l10n) => [
  _Review(
    headline: l10n.onboardingReview1Headline,
    body: l10n.onboardingReview1Body,
    author: 'Felicia',
    avatar: 'assets/images/image.png',
  ),
  _Review(
    headline: l10n.onboardingReview2Headline,
    body: l10n.onboardingReview2Body,
    author: 'Joshua_la',
    avatar: 'assets/images/image2.png',
  ),
  _Review(
    headline: l10n.onboardingReview3Headline,
    body: l10n.onboardingReview3Body,
    author: 'Sophie',
    avatar: 'assets/images/image3.png',
  ),
  _Review(
    headline: l10n.onboardingReview4Headline,
    body: l10n.onboardingReview4Body,
    author: 'Marcus_T',
    avatar: 'assets/images/image5.png',
  ),
  _Review(
    headline: l10n.onboardingReview5Headline,
    body: l10n.onboardingReview5Body,
    author: 'Priya',
    avatar: 'assets/images/image4.png',
  ),
  _Review(
    headline: l10n.onboardingReview6Headline,
    body: l10n.onboardingReview6Body,
    author: 'Dani_R',
    avatar: 'assets/images/image6.jpeg',
  ),
];

class _StatBlock extends StatelessWidget {
  final String value;
  final String label;

  const _StatBlock({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value, style: DSTextStyles.displayHero),
        const SizedBox(height: DSDimens.sizeXxs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: DSTextStyles.caption.copyWith(color: _mutedLabel),
        ),
      ],
    );
  }
}

class _PeopleBlock extends StatelessWidget {
  const _PeopleBlock();

  static const _faces = [
    'assets/images/image.png',
    'assets/images/image2.png',
    'assets/images/image4.png',
    'assets/images/image5.png',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 36,
          width: 36.0 + (_faces.length - 1) * 22,
          child: Stack(
            children: [
              for (var i = 0; i < _faces.length; i++)
                Positioned(
                  left: i * 22.0,
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DSColors.surfaceCard,
                      border: Border.all(
                        color: const Color(0xFFFFF8EA),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        _faces[i],
                        width: 32,
                        height: 32,
                        cacheWidth: 96,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: DSDimens.sizeXxs),
        Text(
          l10n.onboardingRatingPeopleLabel,
          style: DSTextStyles.caption.copyWith(color: _mutedLabel),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final _Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSDimens.sizeM),
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.xl),
        boxShadow: DSShadows.e1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(review.headline, style: DSTextStyles.titleMd),
          const SizedBox(height: DSDimens.sizeXxs),
          Row(
            children: [
              ...List.generate(
                5,
                (_) => const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: DSColors.coralAccent,
                ),
              ),
              const SizedBox(width: DSDimens.sizeXs),
              ClipOval(
                child: Image.asset(
                  review.avatar,
                  width: 24,
                  height: 24,
                  cacheWidth: 72,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: DSDimens.sizeXxs),
              Text(
                review.author,
                style: DSTextStyles.caption.copyWith(
                  color: DSColors.inkSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSDimens.sizeXs),
          Text(
            review.body,
            style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkSecondary),
          ),
        ],
      ),
    );
  }
}
