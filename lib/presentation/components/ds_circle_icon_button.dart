import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

/// Circular white-disc icon button with an `e1` lift.
///
/// Used for actions that float over content rather than sitting in a header
/// row: Product Detail's bookmark and overflow buttons, and the Recipe Detail
/// hero's back button.
class DSCircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  /// Diameter of the disc. The icon scales to half of it.
  final double size;

  const DSCircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DSColors.surfaceCard,
      shape: const CircleBorder(),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: DSColors.surfaceCard,
          shape: BoxShape.circle,
          boxShadow: DSShadows.e1,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              color: iconColor ?? DSColors.inkPrimary,
              size: size / 2,
            ),
          ),
        ),
      ),
    );
  }
}
