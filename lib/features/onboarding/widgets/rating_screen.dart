import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/onboarding_floating_button.dart';

/// Social-proof screen — App Store rating + a stack of reviews.
///
/// Presentational only. The native review modal is intentionally not
/// triggered here: Apple discourages onboarding-time prompts and the
/// app already has a scan-gated `ReviewPromptService` for high-intent
/// moments.
// TODO(feature): optionally wire a "Rate YuCat" deep-link to the App Store.
class RatingScreen extends StatelessWidget {
  final VoidCallback onNext;

  const RatingScreen({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Matches the cream gradient in onboarding-7-bg.png so the header art
      // (which fades to transparent at its base) blends into the background.
      backgroundColor: const Color(0xFFFFF8EA),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative header: mascot, scattered stars and the laurel wreaths
            // that flank the stats. Pinned full-width at the top.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/onboarding-7-bg.png',
                fit: BoxFit.fitWidth,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Clear the back chip + the mascot art at the top.
                  const SizedBox(height: 116),
                  Text(
                    'Help us grow',
                    style: DSTextStyles.caption.copyWith(
                      color: DSColors.inkSecondary,
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
                  // Stats sit between the laurel wreaths drawn in the header.
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: DSDimens.sizeXxl),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _StatBlock(value: '4.8', label: 'average rating'),
                        Spacer(),
                        _PeopleBlock(),
                      ],
                    ),
                  ),
                  const SizedBox(height: DSDimens.sizeXxl),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: DSDimens.sizeS),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _reviews.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: DSDimens.sizeS),
                      itemBuilder: (_, i) => _ReviewCard(review: _reviews[i]),
                    ),
                  ),
                  OnboardingFloatingButton(label: 'Next', onPressed: onNext),
                ],
              ),
            ),
          ],
        ),
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
        Text(value, style: DSTextStyles.displayLg),
        Text(
          label,
          textAlign: TextAlign.center,
          style: DSTextStyles.caption.copyWith(color: DSColors.inkSecondary),
        ),
      ],
    );
  }
}

class _PeopleBlock extends StatelessWidget {
  const _PeopleBlock();

  static const _faces = ['👩', '🧑', '👧'];

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
        const SizedBox(height: DSDimens.sizeXxxs),
        Text(
          '2M+ people',
          style: DSTextStyles.caption.copyWith(color: DSColors.inkSecondary),
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
        borderRadius: BorderRadius.circular(DSRadii.lg),
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
