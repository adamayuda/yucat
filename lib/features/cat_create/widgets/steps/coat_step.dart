import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class CoatStep extends StatelessWidget {
  final String? coatType;
  final ValueChanged<String?> onCoatTypeChanged;

  static const List<({String label, String value})> _options = [
    (label: 'Short hair', value: 'short_hair'),
    (label: 'Long hair', value: 'long_hair'),
    (label: 'Hairless', value: 'hairless'),
  ];

  const CoatStep({
    super.key,
    required this.coatType,
    required this.onCoatTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MascotSpeechBubble(
          question: 'What type of coat?',
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in _options) ...[
                  DSOptionRow(
                    label: option.label,
                    selected: coatType == option.value,
                    onTap: () => onCoatTypeChanged(option.value),
                  ),
                  const SizedBox(height: DSDimens.sizeXs),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
