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
    // Unselected chips show no visible outline (white border + soft shadow);
    // selecting only swaps the border + dot to coral — constant 1.5 width keeps
    // the chip size fixed so the others never reflow.
    final borderColor = selected ? DSColors.coralAccent : DSColors.surfaceCard;
    final dotColor = selected ? DSColors.coralAccent : DSColors.inputLightGrey;
    return Material(
      color: DSColors.surfaceCard,
      borderRadius: BorderRadius.circular(DSRadii.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(DSRadii.lg),
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
            borderRadius: BorderRadius.circular(DSRadii.lg),
            // Constant border width so selecting only changes the colour — a
            // width change would grow the chip (the border adds layout padding)
            // and reflow every other chip.
            border: Border.all(color: borderColor, width: 1.5),
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
