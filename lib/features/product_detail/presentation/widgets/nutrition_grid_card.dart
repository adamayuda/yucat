import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/presentation/components/ds_card.dart';

class NutritionGridCard extends StatelessWidget {
  final ProductDisplayModel product;

  const NutritionGridCard({super.key, required this.product});

  /// A macro of exactly 0 means it was missing from the guaranteed analysis
  /// (the backend defaults unknown values to 0). Show an em-dash rather than a
  /// misleading "0.0%".
  static String _format(double value) =>
      value <= 0 ? '—' : '${value.toStringAsFixed(1)}%';

  @override
  Widget build(BuildContext context) {
    return DSCard(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeS,
        vertical: DSDimens.sizeS,
      ),
      child: Row(
        children: [
          Expanded(
            child: _MacroCell(
              iconAsset: 'assets/images/Icons/nutrient-protein.png',
              label: 'Protein',
              value: _format(product.protein),
            ),
          ),
          Expanded(
            child: _MacroCell(
              iconAsset: 'assets/images/Icons/nutrient-fat.png',
              label: 'Fat',
              value: _format(product.fat),
            ),
          ),
          Expanded(
            child: _MacroCell(
              iconAsset: 'assets/images/Icons/nutrient-moisture.png',
              label: 'Moisture',
              value: _format(product.moisture),
            ),
          ),
          Expanded(
            child: _MacroCell(
              iconAsset: 'assets/images/Icons/nutrient-fiber.png',
              label: 'Fiber',
              value: _format(product.fiber),
            ),
          ),
          Expanded(
            child: _MacroCell(
              iconAsset: 'assets/images/Icons/nutrient-carbs.png',
              label: 'Carbs',
              value: _format(product.carbs),
            ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: DSColors.tintLavender,
            borderRadius: BorderRadius.circular(DSRadii.sm),
          ),
          alignment: Alignment.center,
          child: Image.asset(iconAsset, width: 18, height: 18),
        ),
        const SizedBox(height: DSDimens.sizeXxxs),
        Text(
          value,
          style: DSTextStyles.caption.copyWith(
            color: DSColors.inkPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: DSTextStyles.caption.copyWith(
            color: DSColors.inkSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
