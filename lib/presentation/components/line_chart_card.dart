import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class LineChartCard extends StatelessWidget {
  final String yourLabel;
  final String theirsLabel;
  final String yourTagText;
  final String xAxisLabel;

  const LineChartCard({
    super.key,
    this.yourLabel = 'Your cat',
    this.theirsLabel = 'Generic food',
    this.yourTagText = 'YuCat',
    this.xAxisLabel = 'Time',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        boxShadow: DSShadows.e2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DSDimens.sizeXxs,
              vertical: DSDimens.sizeXxs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  yourLabel,
                  style: DSTextStyles.label.copyWith(
                    color: DSColors.inkPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  theirsLabel,
                  style: DSTextStyles.label.copyWith(
                    color: DSColors.accentDanger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSDimens.sizeXxs),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _LineChartPainter(tagText: yourTagText),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: DSDimens.sizeXxs, top: 4),
            child: Text(
              xAxisLabel,
              style: DSTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final String tagText;

  _LineChartPainter({required this.tagText});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Their line: starts low-ish, dips, then rebounds high (red dashed).
    final theirsPath = Path()
      ..moveTo(0, h * 0.35)
      ..cubicTo(w * 0.25, h * 0.15, w * 0.4, h * 0.85, w * 0.6, h * 0.55)
      ..cubicTo(w * 0.75, h * 0.35, w * 0.9, h * 0.15, w, h * 0.1);

    final theirsPaint = Paint()
      ..color = DSColors.accentDanger
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    _drawDashedPath(canvas, theirsPath, theirsPaint, dashWidth: 6, gap: 4);

    // Your line: gradual descent then plateau (solid green).
    final yoursPath = Path()
      ..moveTo(0, h * 0.4)
      ..cubicTo(w * 0.3, h * 0.55, w * 0.55, h * 0.75, w * 0.8, h * 0.78)
      ..lineTo(w, h * 0.78);

    final yoursPaint = Paint()
      ..color = DSColors.accentSuccess
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(yoursPath, yoursPaint);

    // Endpoint dot for "yours"
    canvas.drawCircle(
      Offset(w, h * 0.78),
      5,
      Paint()..color = DSColors.accentSuccess,
    );
    canvas.drawCircle(
      Offset(w, h * 0.78),
      3,
      Paint()..color = DSColors.surfaceCard,
    );

    // Tag near the end of "yours" line
    final tag = TextPainter(
      text: TextSpan(
        text: tagText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final tagPadH = 8.0;
    final tagPadV = 4.0;
    final tagW = tag.width + tagPadH * 2;
    final tagH = tag.height + tagPadV * 2;
    final tagOrigin = Offset(w - tagW - 6, h * 0.78 - tagH - 8);
    final tagRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tagOrigin.dx, tagOrigin.dy, tagW, tagH),
      const Radius.circular(6),
    );
    canvas.drawRRect(tagRect, Paint()..color = DSColors.accentSuccess);
    tag.paint(
      canvas,
      Offset(tagOrigin.dx + tagPadH, tagOrigin.dy + tagPadV),
    );
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashWidth,
    required double gap,
  }) {
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final segment = metric.extractPath(
          distance,
          distance + dashWidth,
        );
        canvas.drawPath(segment, paint);
        distance += dashWidth + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.tagText != tagText;
}
