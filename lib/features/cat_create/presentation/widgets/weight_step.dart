import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class WeightStep extends StatelessWidget {
  final String? weightCategory;
  final ValueChanged<String?> onWeightCategoryChanged;

  const WeightStep({
    super.key,
    required this.weightCategory,
    required this.onWeightCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'What\'s your cat\'s weight?',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(),
            ),
          ),
          Center(
            child: Text(
              'We use this to estimate healthy portions.',
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
                  label: 'Underweight',
                  value: 'underweight',
                  isSelected: weightCategory == 'underweight',
                  onTap: () => onWeightCategoryChanged('underweight'),
                ),
              ),
              SizedBox(width: DSDimens.sizeM),
              Expanded(
                child: _AgeGroupOption(
                  label: 'Normal',
                  value: 'normal',
                  isSelected: weightCategory == 'normal',
                  onTap: () => onWeightCategoryChanged('normal'),
                ),
              ),
            ],
          ),
          SizedBox(height: DSDimens.sizeM),
          Row(
            children: [
              Expanded(
                child: _AgeGroupOption(
                  label: 'Overweight',
                  value: 'overweight',
                  isSelected: weightCategory == 'overweight',
                  onTap: () => onWeightCategoryChanged('overweight'),
                ),
              ),
              SizedBox(width: DSDimens.sizeM),
              Expanded(
                child: _AgeGroupOption(
                  label: 'Obese',
                  value: 'obese',
                  isSelected: weightCategory == 'obese',
                  onTap: () => onWeightCategoryChanged('obese'),
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
