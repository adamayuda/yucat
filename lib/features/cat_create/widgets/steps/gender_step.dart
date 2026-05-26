import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class GenderStep extends StatelessWidget {
  final String? gender;
  final ValueChanged<String?> onGenderChanged;

  const GenderStep({
    super.key,
    required this.gender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MascotSpeechBubble(question: "What's your cat's gender?"),
        Expanded(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _GenderCard(
                    emoji: '♀️',
                    label: 'Female',
                    selected: gender == 'female',
                    onTap: () => onGenderChanged('female'),
                  ),
                ),
                const SizedBox(width: DSDimens.sizeS),
                Expanded(
                  child: _GenderCard(
                    emoji: '♂️',
                    label: 'Male',
                    selected: gender == 'male',
                    onTap: () => onGenderChanged('male'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: DSMotion.durFast,
        padding: const EdgeInsets.symmetric(
          vertical: DSDimens.size3xl,
          horizontal: DSDimens.sizeS,
        ),
        decoration: BoxDecoration(
          color: selected
              ? DSColors.accentSuccessSoft
              : DSColors.surfaceCard,
          borderRadius: BorderRadius.circular(DSRadii.xl),
          border: Border.all(
            color: selected
                ? DSColors.accentSuccess
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: selected ? null : DSShadows.e1,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: DSDimens.sizeXxs),
            Text(label, style: DSTextStyles.titleMd),
          ],
        ),
      ),
    );
  }
}
