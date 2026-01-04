import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class ActivityStep extends StatelessWidget {
  final String? activityLevel;
  final ValueChanged<String?> onActivityLevelChanged;

  const ActivityStep({
    super.key,
    required this.activityLevel,
    required this.onActivityLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'How active is your cat?',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(),
            ),
          ),
          Center(
            child: Text(
              'Activity helps us understand calorie needs.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          SizedBox(height: DSDimens.sizeM),
          Row(
            children: [
              Expanded(
                child: _ActivityOption(
                  label: 'Low',
                  value: 'low',
                  isSelected: activityLevel == 'low',
                  onTap: () => onActivityLevelChanged('low'),
                ),
              ),
              SizedBox(width: DSDimens.sizeM),
              Expanded(
                child: _ActivityOption(
                  label: 'Medium',
                  value: 'medium',
                  isSelected: activityLevel == 'medium',
                  onTap: () => onActivityLevelChanged('medium'),
                ),
              ),
              SizedBox(width: DSDimens.sizeM),
              Expanded(
                child: _ActivityOption(
                  label: 'High',
                  value: 'high',
                  isSelected: activityLevel == 'high',
                  onTap: () => onActivityLevelChanged('high'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityOption extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityOption({
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
