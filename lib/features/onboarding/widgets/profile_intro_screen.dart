import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

class ProfileIntroScreen extends StatelessWidget {
  final VoidCallback onNext;

  const ProfileIntroScreen({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      background: DSColors.tintAsh,
      footer: DSPillButton(label: 'Next', onPressed: onNext),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('👋', style: TextStyle(fontSize: 56)),
              Text('👋', style: TextStyle(fontSize: 56)),
            ],
          ),
          const SizedBox(height: DSDimens.size3xl),
          Text(
            "Let's set up\nyour cat's profile",
            textAlign: TextAlign.center,
            style: DSTextStyles.displayHero,
          ),
          const Spacer(flex: 2),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSDimens.sizeS,
              vertical: DSDimens.sizeXs,
            ),
            decoration: BoxDecoration(
              color: DSColors.surfaceCardDim,
              borderRadius: BorderRadius.circular(DSRadii.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '2 min',
                  style: DSTextStyles.displayLg.copyWith(fontSize: 22),
                ),
                const SizedBox(width: DSDimens.sizeXs),
                Flexible(
                  child: Text(
                    'A quick profile unlocks\ntailored verdicts on every bag',
                    style: DSTextStyles.bodyMd,
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
