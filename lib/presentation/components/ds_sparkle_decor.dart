import 'package:flutter/material.dart';

enum DSDecorKind { sparkle, heart, zap, dot }

class DSDecorItem {
  final double x;
  final double y;
  final DSDecorKind kind;
  final double size;
  final Color color;
  final double rotation;

  const DSDecorItem({
    required this.x,
    required this.y,
    required this.kind,
    this.size = 22,
    this.color = const Color(0xFF0E0E14),
    this.rotation = 0,
  });
}

class DSSparkleDecor extends StatelessWidget {
  final List<DSDecorItem> items;

  const DSSparkleDecor({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: items
            .map(
              (it) => Positioned(
                left: it.x,
                top: it.y,
                child: Transform.rotate(
                  angle: it.rotation * 3.1415926535 / 180,
                  child: _glyph(it),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _glyph(DSDecorItem it) {
    switch (it.kind) {
      case DSDecorKind.sparkle:
        return CustomPaint(
          size: Size(it.size, it.size),
          painter: _SparklePainter(color: it.color),
        );
      case DSDecorKind.heart:
        return Icon(Icons.favorite, color: it.color, size: it.size);
      case DSDecorKind.zap:
        return Icon(Icons.bolt, color: it.color, size: it.size);
      case DSDecorKind.dot:
        return Container(
          width: it.size,
          height: it.size,
          decoration: BoxDecoration(
            color: it.color,
            shape: BoxShape.circle,
          ),
        );
    }
  }
}

class _SparklePainter extends CustomPainter {
  final Color color;

  _SparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, h * 0.083)
      ..cubicTo(w * 0.525, h * 0.313, w * 0.687, h * 0.475, w * 0.917, h * 0.5)
      ..cubicTo(w * 0.687, h * 0.525, w * 0.525, h * 0.687, w * 0.5, h * 0.917)
      ..cubicTo(w * 0.475, h * 0.687, w * 0.313, h * 0.525, w * 0.083, h * 0.5)
      ..cubicTo(w * 0.313, h * 0.475, w * 0.475, h * 0.313, w * 0.5, h * 0.083)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      oldDelegate.color != color;
}
