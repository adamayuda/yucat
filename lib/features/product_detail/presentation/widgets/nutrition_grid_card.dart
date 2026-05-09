import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/presentation/components/ds_card.dart';

class NutritionGridCard extends StatelessWidget {
  final ProductDisplayModel product;

  const NutritionGridCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nutrition', style: DSTextStyles.titleMd),
          const SizedBox(height: DSDimens.sizeS),
          Row(
            children: [
              Expanded(
                child: _MacroCell(
                  iconAsset: 'assets/images/Icons/egg.png',
                  label: 'Protein',
                  value: '${product.protein.toStringAsFixed(1)}%',
                ),
              ),
              Expanded(
                child: _MacroCell(
                  iconAsset: 'assets/images/Icons/butter.png',
                  label: 'Fat',
                  value: '${product.fat.toStringAsFixed(1)}%',
                ),
              ),
              Expanded(
                child: _MacroCell(
                  iconAsset: 'assets/images/Icons/water.png',
                  label: 'Moisture',
                  value: '${product.moisture.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: DSDimens.sizeS),
          Row(
            children: [
              Expanded(
                child: _MacroCell(
                  iconAsset: 'assets/images/Icons/fire.png',
                  label: 'Fiber',
                  value: '${product.fiber.toStringAsFixed(1)}%',
                ),
              ),
              Expanded(
                child: _MacroCell(
                  iconAsset: 'assets/images/Icons/wheat.png',
                  label: 'Carbs',
                  value: '${product.carbs.toStringAsFixed(1)}%',
                ),
              ),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroCell extends StatelessWidget {
  final String iconAsset;
  final String label;
  final String value;

  const _MacroCell({
    required this.iconAsset,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: DSColors.tintLavender,
            borderRadius: BorderRadius.circular(DSRadii.md),
          ),
          alignment: Alignment.center,
          child: Image.asset(iconAsset, width: 24, height: 24),
        ),
        const SizedBox(height: DSDimens.sizeXxs),
        Text(
          value,
          style: DSTextStyles.bodyLg.copyWith(
            color: DSColors.inkPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: DSTextStyles.caption.copyWith(color: DSColors.inkSecondary),
        ),
      ],
    );
  }
}
