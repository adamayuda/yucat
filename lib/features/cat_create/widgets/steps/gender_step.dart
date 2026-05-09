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
        const MascotSpeechBubble(
          question: 'Is your cat a boy or a girl?',
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DSOptionRow(
                  label: 'Male',
                  leadingIcon: Icons.male_rounded,
                  selected: gender == 'male',
                  onTap: () => onGenderChanged('male'),
                ),
                const SizedBox(height: DSDimens.sizeXs),
                DSOptionRow(
                  label: 'Female',
                  leadingIcon: Icons.female_rounded,
                  selected: gender == 'female',
                  onTap: () => onGenderChanged('female'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
