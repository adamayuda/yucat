import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

/// Compact read-only pill for a piece of profile data — a health condition, an
/// allergy.
///
/// Extracted from `_ConditionChip`, which was private to `cat_detail_page.dart`
/// until the health carnet needed the same shape for allergy tags.
///
/// ⚠️ This is **not** `DSChip`. That one is the cat wizard's multi-select
/// control: card radius, a leading selection dot, a 1.5px border, sized for a
/// `Wrap` of tappable options. This is a tag — pill radius, tinted fill, no
/// affordance — and the two should not be swapped for each other.
class DSTagChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  const DSTagChip({
    super.key,
    required this.label,
    this.background = const Color(0xFFFCE4E1),
    this.foreground = DSColors.accentDanger,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeS,
        vertical: DSDimens.sizeXxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(DSRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: DSDimens.sizeXxxs),
          ],
          Text(
            label,
            style: DSTextStyles.label.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
