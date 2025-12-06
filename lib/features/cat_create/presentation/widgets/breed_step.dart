import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class BreedStep extends StatelessWidget {
  final String? selectedBreed;
  final List<String> breeds;
  final ValueChanged<String> onBreedSelected;

  const BreedStep({
    super.key,
    required this.selectedBreed,
    required this.breeds,
    required this.onBreedSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s your cat\'s breed?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: DSDimens.sizeXs),
          Text(
            'Select from popular breeds or choose \'Other\'',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: DSDimens.sizeM),
          Wrap(
            spacing: DSDimens.sizeXs,
            runSpacing: DSDimens.sizeXs,
            children: breeds.map((breed) {
              final isSelected = selectedBreed == breed;
              return InkWell(
                onTap: () => onBreedSelected(breed),
                borderRadius: BorderRadius.circular(DSDimens.sizeL),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DSDimens.sizeS,
                    vertical: DSDimens.sizeXs,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? DSColors.primary : DSColors.white,
                    borderRadius: BorderRadius.circular(DSDimens.sizeL),
                    border: Border.all(
                      color: isSelected ? DSColors.primary : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    breed,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? DSColors.white : Colors.grey[800],
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
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
