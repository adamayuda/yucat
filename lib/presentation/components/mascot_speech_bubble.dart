import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class MascotSpeechBubble extends StatelessWidget {
  final String question;
  final String? mascotAsset;
  final IconData fallbackIcon;
  final Color avatarBackground;

  const MascotSpeechBubble({
    super.key,
    required this.question,
    this.mascotAsset,
    this.fallbackIcon = Icons.pets,
    this.avatarBackground = DSColors.tintLavender,
  });

  static const double _avatarSize = 44;
  static const double _tailWidth = 10;
  static const double _tailHeight = 12;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: _avatarSize,
          height: _avatarSize,
          decoration: BoxDecoration(
            color: avatarBackground,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: mascotAsset != null
              ? ClipOval(
                  child: Image.asset(
                    mascotAsset!,
                    width: _avatarSize,
                    height: _avatarSize,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(fallbackIcon, color: DSColors.inkPrimary, size: 22),
        ),
        const SizedBox(width: DSDimens.sizeXxs),
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSDimens.sizeS,
                  vertical: DSDimens.sizeS,
                ),
                decoration: BoxDecoration(
                  color: DSColors.surfaceCard,
                  borderRadius: BorderRadius.circular(DSRadii.lg),
                  boxShadow: DSShadows.e1,
                ),
                child: Text(
                  question,
                  style: DSTextStyles.headlineMd,
                ),
              ),
              Positioned(
                left: -_tailWidth + 1,
                top: (_avatarSize - _tailHeight) / 2,
                child: CustomPaint(
                  size: const Size(_tailWidth, _tailHeight),
                  painter: _BubbleTailPainter(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DSColors.surfaceCard
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height / 2)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
