import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

/// Circular cat avatar. Renders the network photo if available,
/// otherwise falls back to a paw icon on a `tintLavender` disc.
class CatAvatar extends StatelessWidget {
  final String? photoUrl;
  final double size;
  final Color background;

  const CatAvatar({
    super.key,
    this.photoUrl,
    this.size = 56,
    this.background = DSColors.tintLavender,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.5;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: photoUrl != null && photoUrl!.isNotEmpty
          ? Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.pets_rounded,
                color: DSColors.inkPrimary,
                size: iconSize,
              ),
            )
          : Icon(
              Icons.pets_rounded,
              color: DSColors.inkPrimary,
              size: iconSize,
            ),
    );
  }
}
