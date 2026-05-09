import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

/// Small stat tile sized to fit in a 2-column grid inside a DSCard.
/// Renders a soft-tinted icon disc + label + value.
class CatStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconBackground;
  final Color iconColor;

  const CatStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconBackground = DSColors.tintLavender,
    this.iconColor = DSColors.inkPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(DSRadii.md),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: DSDimens.sizeXs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: DSTextStyles.caption.copyWith(
                  color: DSColors.inkSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: DSTextStyles.bodyMd.copyWith(
                  color: DSColors.inkPrimary,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
