import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';

class RingScore extends StatelessWidget {
  final int score;
  final int maxScore;
  final ProductRatingColor ratingColor;
  final double size;

  const RingScore({
    super.key,
    required this.score,
    required this.maxScore,
    required this.ratingColor,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final progress = maxScore == 0 ? 0.0 : (score / maxScore).clamp(0.0, 1.0);
    final color = _accentFor(ratingColor);
    final stroke = (size / 10).clamp(4.0, 7.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: stroke,
              backgroundColor: DSColors.surfaceCardDim,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '$score',
            style: DSTextStyles.titleMd.copyWith(
              fontWeight: FontWeight.w700,
              color: DSColors.inkPrimary,
              fontSize: size * 0.32,
            ),
          ),
        ],
      ),
    );
  }

  Color _accentFor(ProductRatingColor rating) => switch (rating) {
        ProductRatingColor.green => DSColors.accentSuccess,
        ProductRatingColor.yellow => const Color(0xFFE0A028),
        ProductRatingColor.red => DSColors.accentDanger,
      };
}
