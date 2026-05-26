import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

class NutritionFactScreen extends StatelessWidget {
  final VoidCallback onNext;

  const NutritionFactScreen({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      background: DSColors.tintSky,
      footer: DSPillButton(label: "Let's go", onPressed: onNext),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: DSColors.surfaceCard,
            ),
            alignment: Alignment.center,
            child: const Text('⏱️', style: TextStyle(fontSize: 44)),
          ),
          const SizedBox(height: DSDimens.size3xl),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: DSTextStyles.displayLg,
              children: [
                const TextSpan(text: 'A kitten needs\n'),
                TextSpan(
                  text: '2.5× more protein',
                  style: DSTextStyles.displayLg.copyWith(
                    color: DSColors.accentInfo,
                  ),
                ),
                const TextSpan(text: '\nthan a senior cat'),
              ],
            ),
          ),
          const SizedBox(height: DSDimens.sizeL),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
            child: Text(
              "Life stage, weight, activity and health conditions all change "
              "what belongs in your cat's bowl.",
              textAlign: TextAlign.center,
              style: DSTextStyles.bodyMd,
            ),
          ),
          const Spacer(flex: 2),
          Container(
            padding: const EdgeInsets.all(DSDimens.sizeS),
            decoration: BoxDecoration(
              color: DSColors.surfaceCardDim,
              borderRadius: BorderRadius.circular(DSRadii.lg),
            ),
            child: Row(
              children: [
                const Text('📘', style: TextStyle(fontSize: 18)),
                const SizedBox(width: DSDimens.sizeXs),
                Expanded(
                  child: Text(
                    'Protein, taurine and phosphorus needs shift dramatically '
                    "across a cat's life.",
                    style: DSTextStyles.caption,
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
