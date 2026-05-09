import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

/// Shared white-surface card. Rounded `DSRadii.xl`, soft `e2` shadow,
/// generous default padding. Optionally tappable with InkWell ripple.
class DSCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color background;

  const DSCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DSDimens.sizeL),
    this.onTap,
    this.background = DSColors.surfaceCard,
  });

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(DSRadii.xl);
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: shape,
        boxShadow: DSShadows.e2,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                child: Padding(padding: padding, child: child),
              )
            : Padding(padding: padding, child: child),
      ),
    );
  }
}
