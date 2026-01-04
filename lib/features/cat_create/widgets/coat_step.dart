import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class CoatStep extends StatelessWidget {
  final String? coatType;
  final ValueChanged<String?> onCoatTypeChanged;

  const CoatStep({
    super.key,
    required this.coatType,
    required this.onCoatTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What type of coat does your cat have?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(),
          ),
          Text(
            'Coat health can guide ingredient recommendations.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: DSDimens.sizeM),
          Row(
            children: [
              Expanded(
                child: _CoatOption(
                  label: 'Short hair',
                  value: 'short_hair',
                  isSelected: coatType == 'short_hair',
                  onTap: () => onCoatTypeChanged('short_hair'),
                ),
              ),
              SizedBox(width: DSDimens.sizeM),
              Expanded(
                child: _CoatOption(
                  label: 'Long hair',
                  value: 'long_hair',
                  isSelected: coatType == 'long_hair',
                  onTap: () => onCoatTypeChanged('long_hair'),
                ),
              ),
              SizedBox(width: DSDimens.sizeM),
              Expanded(
                child: _CoatOption(
                  label: 'Hairless',
                  value: 'hairless',
                  isSelected: coatType == 'hairless',
                  onTap: () => onCoatTypeChanged('hairless'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoatOption extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _CoatOption({
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
