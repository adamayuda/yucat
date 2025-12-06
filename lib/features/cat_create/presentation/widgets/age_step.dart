import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class AgeStep extends StatelessWidget {
  final String? ageGroup;
  final ValueChanged<String?> onAgeGroupChanged;

  const AgeStep({
    super.key,
    required this.ageGroup,
    required this.onAgeGroupChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'How old is your cat?',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(),
            ),
          ),
          Center(
            child: Text(
              'Age affects nutritional needs and food ratings.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          SizedBox(height: DSDimens.sizeM),
          Row(
            children: [
              Expanded(
                child: _AgeGroupOption(
                  label: 'Kitten',
                  value: 'kitten',
                  isSelected: ageGroup == 'kitten',
                  onTap: () => onAgeGroupChanged('kitten'),
                ),
              ),
              SizedBox(width: DSDimens.sizeM),
              Expanded(
                child: _AgeGroupOption(
                  label: 'Adult',
                  value: 'adult',
                  isSelected: ageGroup == 'adult',
                  onTap: () => onAgeGroupChanged('adult'),
                ),
              ),
              SizedBox(width: DSDimens.sizeM),
              Expanded(
                child: _AgeGroupOption(
                  label: 'Senior',
                  value: 'senior',
                  isSelected: ageGroup == 'senior',
                  onTap: () => onAgeGroupChanged('senior'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgeGroupOption extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _AgeGroupOption({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: isSelected
              ? DSColors.primary.withOpacity(0.1)
              : DSColors.white,
          borderRadius: BorderRadius.circular(DSDimens.sizeXs),
          border: Border.all(
            color: isSelected ? DSColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isSelected ? DSColors.primary : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
