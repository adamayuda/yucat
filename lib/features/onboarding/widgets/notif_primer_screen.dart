import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

/// Push-notification warm-up screen.
///
/// MOCK ONLY — this previews the value of alerts but does not request the
/// iOS notification permission or register for push.
// TODO(feature): wire real notification permission + push delivery.
class NotifPrimerScreen extends StatelessWidget {
  final VoidCallback onNext;

  const NotifPrimerScreen({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      background: DSColors.tintCoral,
      footer: DSPillButton(label: 'Set up reminders', onPressed: onNext),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DSDimens.sizeS),
              Text(
                "We'll ping you\nwhen something\nchanges",
                style: DSTextStyles.displayLg,
              ),
              const SizedBox(height: DSDimens.sizeXxl),
              const _MockNotification(),
              const Spacer(),
            ],
          ),
          // rainbow arc background
          Positioned(
            bottom: 0,
            left: -32,
            right: -32,
            child: SizedBox(
              height: 180,
              child: CustomPaint(
                painter: _RainbowArcPainter(),
                size: const Size.fromHeight(180),
              ),
            ),
          ),
          // mascot above arc
          const Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Center(child: Text('🐱', style: TextStyle(fontSize: 90))),
          ),
        ],
      ),
    );
  }
}

class _RainbowArcPainter extends CustomPainter {
  static const _colors = [
    Color(0xFFFF6E5C),
    Color(0xFFFF9D5C),
    Color(0xFFFFD25C),
    Color(0xFF9CE07B),
    Color(0xFF7AC0E8),
    Color(0xFFA697E8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < _colors.length; i++) {
      final paint = Paint()
        ..color = _colors[i]
        ..strokeWidth = 14
        ..style = PaintingStyle.stroke;
      final offset = i * 14.0;
      final path = Path()
        ..moveTo(0, size.height - offset)
        ..quadraticBezierTo(
          size.width / 2,
          30 - offset,
          size.width,
          size.height - offset,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MockNotification extends StatelessWidget {
  const _MockNotification();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        boxShadow: DSShadows.e2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DSColors.tintLavender,
              borderRadius: BorderRadius.circular(DSRadii.sm),
            ),
            child: const Icon(
              Icons.pets_rounded,
              size: 22,
              color: DSColors.inkPrimary,
            ),
          ),
          const SizedBox(width: DSDimens.sizeXs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YUCAT · now',
                  style: DSTextStyles.caption.copyWith(
                    color: DSColors.inkTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: DSDimens.sizeXxxs),
                Text(
                  'Your cat\'s food just changed formula — a fresh verdict is ready.',
                  style: DSTextStyles.bodyMd.copyWith(
                    color: DSColors.inkPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
