import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

enum DSPillButtonVariant { primary, secondary }

class DSPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final DSPillButtonVariant variant;
  final bool showChevron;
  final bool loading;
  final IconData? leadingIcon;
  final double verticalPadding;

  const DSPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = DSPillButtonVariant.primary,
    this.showChevron = true,
    this.loading = false,
    this.leadingIcon,
    this.verticalPadding = DSDimens.sizeS,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == DSPillButtonVariant.primary;
    final bg = isPrimary ? DSColors.inkPrimary : DSColors.surfaceCard;
    final fg = isPrimary ? DSColors.inkInverse : DSColors.inkPrimary;
    final disabled = onPressed == null || loading;

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(DSRadii.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(DSRadii.pill),
          onTap: disabled ? null : onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: DSDimens.sizeXxl,
              vertical: verticalPadding,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, color: fg, size: 18),
                  const SizedBox(width: DSDimens.sizeXxs),
                ],
                if (loading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  )
                else
                  Text(
                    label,
                    style: DSTextStyles.bodyLg.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (showChevron && !loading) ...[
                  const SizedBox(width: DSDimens.sizeXxs),
                  Icon(Icons.chevron_right, color: fg, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DSTextLink extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const DSTextLink({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: DSColors.inkPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: DSDimens.sizeS,
          vertical: DSDimens.sizeXs,
        ),
      ),
      child: Text(
        label,
        style: DSTextStyles.bodyLg.copyWith(
          fontWeight: FontWeight.w600,
          color: DSColors.inkPrimary,
        ),
      ),
    );
  }
}
