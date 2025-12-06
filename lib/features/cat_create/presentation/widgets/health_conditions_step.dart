import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

/// Health conditions step.
///
/// Exposes one of the following values:
/// - "none"
/// - "urinary_issues"
/// - "kidney_disease"
/// - "sensitive_stomach"
/// - "skin_allergies"
/// - "food_allergies"
/// - "diabetes"
/// - "dental_problems"
/// - "hairball_issues"
/// - "heart_condition"
/// - "joint_issues"
class HealthConditionsStep extends StatelessWidget {
  /// Currently selected health condition values.
  ///
  /// Multiple values can be selected at the same time.
  final List<String> selectedHealthConditions;

  /// Callback when the selected health conditions change.
  final ValueChanged<List<String>> onHealthConditionsChanged;

  static const List<Map<String, String>> _options = [
    {'value': 'none', 'label': 'None'},
    {'value': 'urinary_issues', 'label': 'Urinary issues'},
    {'value': 'kidney_disease', 'label': 'Kidney disease'},
    {'value': 'sensitive_stomach', 'label': 'Sensitive stomach'},
    {'value': 'skin_allergies', 'label': 'Skin allergies'},
    {'value': 'food_allergies', 'label': 'Food allergies'},
    {'value': 'diabetes', 'label': 'Diabetes'},
    {'value': 'dental_problems', 'label': 'Dental problems'},
    {'value': 'hairball_issues', 'label': 'Hairball issues'},
    {'value': 'heart_condition', 'label': 'Heart condition'},
    {'value': 'joint_issues', 'label': 'Joint or mobility issues'},
  ];

  const HealthConditionsStep({
    super.key,
    required this.selectedHealthConditions,
    required this.onHealthConditionsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Any health considerations?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(),
          ),
          Text(
            'Allergies, sensitivities, or vet notes help refine scoring.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: DSDimens.sizeM),
          Column(
            children: _options.map((option) {
              final value = option['value']!;
              final isSelected = selectedHealthConditions.contains(value);
              final isLast = option == _options.last;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : DSDimens.sizeS),
                child: InkWell(
                  borderRadius: BorderRadius.circular(DSDimens.sizeXs),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    final current = List<String>.from(selectedHealthConditions);

                    if (value == 'none') {
                      // Selecting "none" clears all other conditions.
                      if (isSelected) {
                        current.remove(value);
                      } else {
                        current
                          ..clear()
                          ..add(value);
                      }
                    } else {
                      // Selecting any specific condition deselects "none".
                      current.remove('none');
                      if (isSelected) {
                        current.remove(value);
                      } else {
                        current.add(value);
                      }
                    }

                    onHealthConditionsChanged(current);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: DSDimens.sizeS,
                      vertical: DSDimens.sizeXs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(DSDimens.sizeXs),
                      border: Border.all(
                        color: isSelected
                            ? DSColors.primary
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option['label']!,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: isSelected
                                      ? DSColors.primary
                                      : Colors.grey[800],
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
