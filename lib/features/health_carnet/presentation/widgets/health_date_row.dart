import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

/// Labelled, tappable date field: a dim pill showing the chosen date with a
/// calendar glyph. The tap opens whatever picker the caller wires up.
///
/// Shared by the add-record sheet and the first-open setup sheet so the two
/// read as one control — it was lifted out of the former when the latter
/// needed it.
class HealthDateRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  /// Renders [value] as a placeholder (secondary ink) rather than a chosen date.
  final bool placeholder;

  const HealthDateRow({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.placeholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DSTextStyles.label),
        const SizedBox(height: DSDimens.sizeXxs),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSDimens.sizeXs,
              vertical: DSDimens.sizeXs,
            ),
            decoration: BoxDecoration(
              color: DSColors.surfaceCardDim,
              borderRadius: BorderRadius.circular(DSRadii.md),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: placeholder
                        ? DSTextStyles.bodyLg.copyWith(
                            color: DSColors.inkSecondary,
                          )
                        : DSTextStyles.bodyLg,
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: DSColors.inkSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
