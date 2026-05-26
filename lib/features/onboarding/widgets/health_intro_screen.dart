import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

/// Bridge screen into the cat-create wizard — frames the upcoming
/// questionnaire as a quick conversation about the cat's health.
class HealthIntroScreen extends StatelessWidget {
  final VoidCallback onAddCat;

  const HealthIntroScreen({
    super.key,
    required this.onAddCat,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      background: DSColors.tintSky,
      footer: DSPillButton(label: "Let's go", onPressed: onAddCat),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: DSDimens.sizeS),
              Text(
                'Now tell us\nabout your cat\'s\nhealth',
                textAlign: TextAlign.center,
                style: DSTextStyles.displayHero,
              ),
              const Spacer(flex: 2),
              const Text('😺', style: TextStyle(fontSize: 110)),
              const Spacer(flex: 1),
            ],
          ),
          const Positioned(
            top: 200,
            left: 30,
            child: _ThoughtBubble(emoji: '🎂'),
          ),
          const Positioned(
            top: 170,
            right: 24,
            child: _ThoughtBubble(emoji: '⚖️'),
          ),
          const Positioned(
            top: 280,
            left: 60,
            child: _ThoughtBubble(emoji: '🏥'),
          ),
        ],
      ),
    );
  }
}

class _ThoughtBubble extends StatelessWidget {
  final String emoji;
  const _ThoughtBubble({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 68,
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(34),
          topRight: Radius.circular(34),
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: DSShadows.e1,
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 28)),
    );
  }
}
