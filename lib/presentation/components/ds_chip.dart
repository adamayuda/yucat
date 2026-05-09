import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class DSChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const DSChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? DSColors.coralAccent : DSColors.border;
    final dotColor = selected ? DSColors.coralAccent : DSColors.inputLightGrey;
    return Material(
      color: DSColors.surfaceCard,
      borderRadius: BorderRadius.circular(DSRadii.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(DSRadii.pill),
        onTap: onTap,
        child: AnimatedContainer(
          duration: DSMotion.durFast,
          curve: DSMotion.curveStandard,
          padding: const EdgeInsets.symmetric(
            horizontal: DSDimens.sizeS,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: DSColors.surfaceCard,
            borderRadius: BorderRadius.circular(DSRadii.pill),
            border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
            boxShadow: selected ? null : DSShadows.e1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: DSDimens.sizeXxs),
              Text(label, style: DSTextStyles.bodyLg),
            ],
          ),
        ),
      ),
    );
  }
}
