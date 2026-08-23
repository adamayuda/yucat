import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// Top-level section heading: a `headlineMd` title with an optional trailing
/// text action ("See all").
///
/// The title is a **fixed** size — deliberately not scaled to fit. An earlier
/// `FittedBox(scaleDown)` here made every section's title render at a different
/// size depending on how long its copy happened to be, which is exactly what a
/// shared header must not do. A title too long for one line wraps to a second
/// and then ellipsizes; it never shrinks.
class DSSectionHeader extends StatelessWidget {
  final String title;

  /// The action link only renders when both the label and the callback exist.
  final String? actionLabel;
  final VoidCallback? onAction;

  const DSSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    final action = onAction;
    final hasAction = label != null && action != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: DSTextStyles.headlineMd,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (hasAction) ...[
          const SizedBox(width: DSDimens.sizeXxs),
          DSTextLink(label: label, onPressed: action),
        ],
      ],
    );
  }
}
