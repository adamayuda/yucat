import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

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
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: DSDimens.sizeXs),
          Text(
            'Select your cat\'s gender',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: DSDimens.sizeM),
          Row(
            children: [
              Expanded(
                child: _GenderOption(
                  icon: Icons.male,
                  label: 'Male',
                  value: 'male',
                  isSelected: gender == 'male',
                  onTap: () => onGenderChanged('male'),
                ),
              ),
              SizedBox(width: DSDimens.sizeM),
              Expanded(
                child: _GenderOption(
                  icon: Icons.female,
                  label: 'Female',
                  value: 'female',
                  isSelected: gender == 'female',
                  onTap: () => onGenderChanged('female'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.icon,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? DSColors.primary : Colors.grey[600],
            ),
            SizedBox(height: DSDimens.sizeXs),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isSelected ? DSColors.primary : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
