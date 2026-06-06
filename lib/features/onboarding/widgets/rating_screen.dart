import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/onboarding_floating_button.dart';

/// Social-proof screen — App Store rating + a stack of reviews.
///
/// Presentational only. The native review modal is intentionally not
/// triggered here: Apple discourages onboarding-time prompts and the
/// app already has a scan-gated `ReviewPromptService` for high-intent
/// moments.
// TODO(feature): optionally wire a "Rate YuCat" deep-link to the App Store.
/// Muted warm-grey used for the supporting labels on this screen.
const _mutedLabel = Color(0xFFAAA498);

class RatingScreen extends StatelessWidget {
  final VoidCallback onNext;

  const RatingScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Placeholder cream background; decorative art (stars, cat, laurels) will
      // be layered back in as individual assets are provided.
      backgroundColor: const Color(0xFFFFF4DC),
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
                    // Clear the floating Next button so the last review can
                    // scroll above it.
                    96,
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
                        'Help us grow',
                        style: DSTextStyles.caption.copyWith(
                          color: _mutedLabel,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: DSDimens.sizeXxs),
                      Text(
                        'Give us rating',
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
                          const _StatBlock(
                            value: '4.8',
                            label: 'average rating',
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
                      for (var i = 0; i < _reviews.length; i++) ...[
                        if (i > 0) const SizedBox(height: DSDimens.sizeXxs),
                        _ReviewCard(review: _reviews[i]),
                      ],
                    ],
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
                        label: 'Next',
                        onPressed: onNext,
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
  const _Review({
    required this.headline,
    required this.body,
    required this.author,
  });
}

// TODO: replace placeholder reviews with real, attributed App Store reviews.
const _reviews = [
  _Review(
    headline: 'Exactly what I needed!',
    body:
        "I scanned my cat's kibble and finally understood what was in it. "
        'Switched brands the same week and never looked back.',
    author: 'Felicia',
  ),
  _Review(
    headline: 'Loving this app!!!',
    body:
        'Amazing app, so easy to use. I just upload pictures of the food and '
        'it tells me everything great!',
    author: 'Joshua_la',
  ),
  _Review(
    headline: 'A senior-cat lifesaver',
    body:
        "YuCat narrowed down a senior food that's gentle on Lulu's stomach "
        'in one afternoon.',
    author: 'Sophie',
  ),
  _Review(
    headline: 'Finally feel confident',
    body:
        'I used to just grab whatever was on sale. Now I actually know which '
        "foods match my kitten's needs. Total peace of mind.",
    author: 'Marcus_T',
  ),
  _Review(
    headline: 'So simple to use',
    body:
        'Snap a photo and you get a clear breakdown in seconds. My vet was '
        'even impressed when I showed her.',
    author: 'Priya',
  ),
  _Review(
    headline: 'Two cats, two diets',
    body:
        'Managing food for an overweight tabby and a picky Siamese was a '
        'nightmare. YuCat made it effortless for both.',
    author: 'Dani_R',
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

  static const _faces = ['👩', '🧑', '👧', '🧑‍🦰'];

  @override
  Widget build(BuildContext context) {
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
                    child: Text(
                      _faces[i],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: DSDimens.sizeXxs),
        Text(
          '2M+ people',
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
