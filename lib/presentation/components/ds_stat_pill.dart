import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class DSStatPill extends StatelessWidget {
  final String stat;
  final String description;
  final Color background;
  final IconData? icon;
  final Color? iconColor;

  const DSStatPill({
    super.key,
    required this.stat,
    required this.description,
    this.background = DSColors.accentSuccessSoft,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeS,
        vertical: DSDimens.sizeXs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(DSRadii.lg),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? DSColors.accentSuccess, size: 20),
            const SizedBox(width: DSDimens.sizeXs),
          ],
          Text(
            stat,
            style: DSTextStyles.headlineMd.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: DSDimens.sizeXs),
          Expanded(
            child: Text(
              description,
              style: DSTextStyles.bodyMd.copyWith(
                color: DSColors.inkPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
