import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_card.dart';

class StreakCard extends StatelessWidget {
  final int currentStreak;

  const StreakCard({super.key, required this.currentStreak});

  @override
  Widget build(BuildContext context) {
    final (leading, title, subtitle) = _content();
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: DSColors.tintSand,
              borderRadius: BorderRadius.circular(DSRadii.lg),
            ),
            alignment: Alignment.center,
            child: Text(leading, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: DSDimens.sizeS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: DSTextStyles.titleMd),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: DSTextStyles.bodyMd.copyWith(
                    color: DSColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (String, String, String) _content() {
    if (currentStreak == 0) {
      return (
        '✨',
        'Start a streak today',
        'Scan one cat food to begin',
      );
    }
    if (currentStreak == 1) {
      return (
        '🔥',
        'Day 1 streak',
        'Scan again tomorrow to keep it going',
      );
    }
    return (
      '🔥',
      '$currentStreak-day streak',
      'Scan again tomorrow to keep it going',
    );
  }
}
