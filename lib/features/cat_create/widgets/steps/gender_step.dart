import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DSOptionRow(
                  leadingEmoji: '👩',
                  label: 'Female',
                  selected: gender == 'female',
                  onTap: () => onGenderChanged('female'),
                ),
                const SizedBox(height: DSDimens.sizeXs),
                DSOptionRow(
                  leadingEmoji: '👨',
                  label: 'Male',
                  selected: gender == 'male',
                  onTap: () => onGenderChanged('male'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
