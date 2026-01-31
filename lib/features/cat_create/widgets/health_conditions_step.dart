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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E8FF),
                  borderRadius: BorderRadius.circular(DSDimens.sizeXxs),
                ),
                width: 40,
                height: 40,
                child: Image.asset(
                  'assets/images/heart.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: DSDimens.sizeS),
              Expanded(
                child: Text(
                  'Any health considerations?',

                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: DSDimens.sizeS),
          Center(
            child: Text(
              'Allergies, sensitivities, or vet notes help refine scoring.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          SizedBox(height: DSDimens.sizeS),

          Column(
            children: _options.map((option) {
              final value = option['value']!;
              final isSelected = selectedHealthConditions.contains(value);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
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
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFEF5FE)
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      option['label']!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF334156),
                        fontWeight: FontWeight.w500,
                      ),
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
