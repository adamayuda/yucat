import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/ds_quote_card.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

// TODO(open #5): replace the source citation with a real reference
// (e.g. AVMA, WSAVA) once chosen. See design/design.md §12.

class DomainPitchScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const DomainPitchScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      background: DSColors.tintCoral,
      onBack: onBack,
      footer: DSPillButton(label: 'Let\'s go', onPressed: onNext),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: DSDimens.sizeS),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: DSTextStyles.displayLg,
              children: [
                const TextSpan(text: '1 in 3\ncats are\n'),
                TextSpan(
                  text: 'overweight',
                  style: DSTextStyles.displayLg.copyWith(
                    color: DSColors.accentDanger,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSDimens.sizeL),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
            child: Text(
              'Diet is the #1 factor cat parents can change. Choosing the right food makes a real difference.',
              textAlign: TextAlign.center,
              style: DSTextStyles.bodyLg.copyWith(
                color: DSColors.inkSecondary,
              ),
            ),
          ),
          const Spacer(),
          DSQuoteCard(
            sourceTitle: 'Veterinary research',
            body:
                'shows that personalized diets help maintain healthy weight and reduce diet-related issues.',
            sourceLinkLabel: 'Source of recommendations',
            onSourceTap: () {
              // Real link wired when source is finalized (open #5).
            },
          ),
          const SizedBox(height: DSDimens.sizeS),
        ],
      ),
    );
  }
}
