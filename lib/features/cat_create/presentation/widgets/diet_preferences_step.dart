import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

/// Diet preferences step.
///
/// Exposes one of the following values:
/// - "none"
/// - "grain_free"
/// - "wet_only"
/// - "dry_only"
/// - "mixed_diet"
/// - "high_protein_preferred"
/// - "chicken_allergy"
/// - "fish_allergy"
/// - "beef_allergy"
class DietPreferencesStep extends StatelessWidget {
  /// Currently selected diet preference value.
  final String? dietPreference;

  /// Callback when a diet preference is selected.
  final ValueChanged<String?> onDietPreferenceChanged;

  static const List<Map<String, String>> _options = [
    {'value': 'none', 'label': 'No specific preference'},
    {'value': 'grain_free', 'label': 'Grain-free'},
    {'value': 'wet_only', 'label': 'Wet food only'},
    {'value': 'dry_only', 'label': 'Dry food only'},
    {'value': 'mixed_diet', 'label': 'Mixed wet & dry diet'},
    {'value': 'high_protein_preferred', 'label': 'High protein preferred'},
    {'value': 'chicken_allergy', 'label': 'Chicken allergy'},
    {'value': 'fish_allergy', 'label': 'Fish allergy'},
    {'value': 'beef_allergy', 'label': 'Beef allergy'},
  ];

  const DietPreferencesStep({
    super.key,
    required this.dietPreference,
    required this.onDietPreferenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Diet preferences',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: DSDimens.sizeXs),
          Text(
            'Select the option that best matches your cat\'s diet or sensitivities.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: DSDimens.sizeM),
          Column(
            children: _options.map((option) {
              final isSelected = dietPreference == option['value'];
              final isLast = option == _options.last;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : DSDimens.sizeS),
                child: InkWell(
                  borderRadius: BorderRadius.circular(DSDimens.sizeXs),
                  onTap: () => onDietPreferenceChanged(option['value']),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: DSDimens.sizeS,
                      vertical: DSDimens.sizeXs,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? DSColors.primary.withOpacity(0.08)
                          : Colors.transparent,
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
