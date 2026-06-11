import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MascotSpeechBubble(question: l10n.genderQuestion),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DSOptionRow(
                  leadingAsset: 'assets/images/Female.svg',
                  label: l10n.genderFemale,
                  selected: gender == 'female',
                  onTap: () => onGenderChanged('female'),
                ),
                const SizedBox(height: DSDimens.sizeXs),
                DSOptionRow(
                  leadingAsset: 'assets/images/Male.svg',
                  label: l10n.genderMale,
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
