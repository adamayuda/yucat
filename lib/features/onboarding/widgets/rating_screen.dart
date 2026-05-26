import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_dot_indicator.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

/// Social-proof screen — App Store rating + a carousel of reviews.
///
/// Presentational only. The native review modal is intentionally not
/// triggered here: Apple discourages onboarding-time prompts and the
/// app already has a scan-gated `ReviewPromptService` for high-intent
/// moments.
// TODO(feature): optionally wire a "Rate YuCat" deep-link to the App Store.
class RatingScreen extends StatefulWidget {
  final VoidCallback onNext;

  const RatingScreen({
    super.key,
    required this.onNext,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
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
        'Switched brands the same week.',
    author: 'Felicia',
  ),
  _Review(
    headline: 'A senior-cat lifesaver',
    body:
        "YuCat narrowed down a senior food that's gentle on Lulu's stomach "
        'in one afternoon.',
    author: 'Sophie',
  ),
  _Review(
    headline: 'Finally, a clear answer',
    body:
        "Two cats, two very different needs. Now I know which food actually "
        'fits each of them.',
    author: 'Priya',
  ),
];

class _RatingScreenState extends State<RatingScreen> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      background: DSColors.tintSand,
      footer: DSPillButton(label: 'Next', onPressed: widget.onNext),
      child: Stack(
        children: [
          // hero emoji at top
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(child: Text('🤩', style: TextStyle(fontSize: 72))),
          ),
          // scattered star decorations
          const Positioned(
            top: 12,
            left: 16,
            child: Text('⭐', style: TextStyle(fontSize: 22)),
          ),
          const Positioned(
            top: 60,
            right: 30,
            child: Text('⭐', style: TextStyle(fontSize: 16)),
          ),
          const Positioned(
            top: 100,
            left: 24,
            child: Text('⭐', style: TextStyle(fontSize: 14)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 96),
              Text(
                'Help us grow',
                style: DSTextStyles.caption.copyWith(
                  color: DSColors.inkSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: DSDimens.sizeXxs),
              Text(
                'Give us a rating',
                textAlign: TextAlign.center,
                style: DSTextStyles.displayLg,
              ),
              const SizedBox(height: DSDimens.size3xl),
              Row(
                children: const [
                  Expanded(
                    child: _StatBlock(value: '4.8', label: 'average rating'),
                  ),
                  SizedBox(width: DSDimens.sizeS),
                  Expanded(
                    child: _StatBlock(value: '2M+', label: 'cat parents'),
                  ),
                ],
              ),
              const SizedBox(height: DSDimens.sizeS),
              SizedBox(
                height: 170,
                child: PageView(
                  controller: _controller,
                  children: [
                    for (final r in _reviews) _ReviewCard(review: r),
                  ],
                ),
              ),
              const SizedBox(height: DSDimens.sizeXs),
              Center(
                child: DSDotIndicator(
                  controller: _controller,
                  count: _reviews.length,
                ),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String value;
  final String label;

  const _StatBlock({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: DSDimens.sizeL,
        horizontal: DSDimens.sizeS,
      ),
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.xl),
        boxShadow: DSShadows.e2,
      ),
      child: Column(
        children: [
          Text(value, style: DSTextStyles.displayLg),
          const SizedBox(height: DSDimens.sizeXxxs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: DSTextStyles.caption.copyWith(
              color: DSColors.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final _Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        boxShadow: DSShadows.e1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (_) => const Icon(
                Icons.star_rounded,
                size: 16,
                color: DSColors.coralAccent,
              ),
            ),
          ),
          const SizedBox(height: DSDimens.sizeXxs),
          Text(
            review.headline,
            style: DSTextStyles.titleMd,
          ),
          const SizedBox(height: DSDimens.sizeXxxs),
          Expanded(
            child: Text(
              review.body,
              style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkSecondary),
            ),
          ),
          const SizedBox(height: DSDimens.sizeXxxs),
          Text(
            review.author,
            style: DSTextStyles.caption.copyWith(
              color: DSColors.inkTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
