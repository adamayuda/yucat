import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_chip.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class HealthConditionsStep extends StatelessWidget {
  final List<String> selectedHealthConditions;
  final ValueChanged<List<String>> onHealthConditionsChanged;

  static const List<({String label, String value})> _options = [
    (label: 'None', value: 'none'),
    (label: 'Urinary issues', value: 'urinary_issues'),
    (label: 'Kidney disease', value: 'kidney_disease'),
    (label: 'Sensitive stomach', value: 'sensitive_stomach'),
    (label: 'Skin allergies', value: 'skin_allergies'),
    (label: 'Food allergies', value: 'food_allergies'),
    (label: 'Diabetes', value: 'diabetes'),
    (label: 'Dental problems', value: 'dental_problems'),
    (label: 'Hairball issues', value: 'hairball_issues'),
    (label: 'Heart condition', value: 'heart_condition'),
    (label: 'Joint or mobility issues', value: 'joint_issues'),
  ];

  const HealthConditionsStep({
    super.key,
    required this.selectedHealthConditions,
    required this.onHealthConditionsChanged,
  });

  void _toggle(String value) {
    final isSelected = selectedHealthConditions.contains(value);
    final current = List<String>.from(selectedHealthConditions);

    if (value == 'none') {
      if (isSelected) {
        current.remove(value);
      } else {
        current
          ..clear()
          ..add(value);
      }
    } else {
      current.remove('none');
      if (isSelected) {
        current.remove(value);
      } else {
        current.add(value);
      }
    }

    onHealthConditionsChanged(current);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MascotSpeechBubble(
          question: 'Any health considerations?',
        ),
        const SizedBox(height: DSDimens.sizeL),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 96),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: DSDimens.sizeXxs,
              runSpacing: DSDimens.sizeXxs,
              children: [
                for (final option in _options)
                  DSChip(
                    label: option.label,
                    selected: selectedHealthConditions.contains(option.value),
                    onTap: () => _toggle(option.value),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
