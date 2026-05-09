import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class HatchedPlaceholder extends StatelessWidget {
  final double size;

  const HatchedPlaceholder({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: DSColors.tintLavender,
        borderRadius: BorderRadius.circular(DSRadii.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _HatchPainter(),
            ),
          ),
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSDimens.sizeXxs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: DSColors.surfaceCard,
                borderRadius: BorderRadius.circular(DSRadii.sm),
              ),
              child: Text(
                'PRODUCT',
                style: DSTextStyles.caption.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: DSColors.inkSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x14000000)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const spacing = 10.0;
    final diag = size.width + size.height;
    for (double offset = -size.height; offset < diag; offset += spacing) {
      canvas.drawLine(
        Offset(offset, 0),
        Offset(offset + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HatchPainter oldDelegate) => false;
}
