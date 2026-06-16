import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';

/// Small stat tile sized to fit in a 2-column grid inside a DSCard.
/// Renders a soft-tinted icon disc + label + value. Supply either a colorful
/// [iconAsset] (SVG under `assets/images/`) or a Material [icon] fallback.
class CatStatTile extends StatelessWidget {
  final IconData? icon;

  /// Colorful attribute icon under `assets/images/` (e.g. `Activity.svg`).
  /// Takes precedence over [icon] when set.
  final String? iconAsset;
  final String label;
  final String value;
  final Color iconColor;

  const CatStatTile({
    super.key,
    this.icon,
    this.iconAsset,
    required this.label,
    required this.value,
    this.iconColor = DSColors.inkPrimary,
  }) : assert(icon != null || iconAsset != null,
            'CatStatTile needs an icon or iconAsset');

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: iconAsset != null
                ? SvgPicture.asset(
                    'assets/images/$iconAsset',
                    width: 32,
                    height: 32,
                  )
                : Icon(icon, color: iconColor, size: 24),
          ),
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
