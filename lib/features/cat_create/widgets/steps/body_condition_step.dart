import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class BodyConditionStep extends StatelessWidget {
  final String? weightCategory;
  final ValueChanged<String?> onWeightCategoryChanged;

  // Values map to the assessment's `weightCategory` buckets
  // ('underweight' / 'normal' / 'overweight' / 'obese').
  static const List<
      ({String label, String value, String desc, IconData icon})> _options = [
    (
      label: 'Underweight',
      value: 'underweight',
      desc: 'Ribs and spine show, very little fat',
      icon: Icons.trending_down_rounded,
    ),
    (
      label: 'Just right',
      value: 'normal',
      desc: 'Ribs felt easily, visible waist',
      icon: Icons.check_circle_outline_rounded,
    ),
    (
      label: 'Overweight',
      value: 'overweight',
      desc: 'Ribs hard to feel, rounded belly',
      icon: Icons.trending_up_rounded,
    ),
    (
      label: 'Obese',
      value: 'obese',
      desc: 'Heavy fat cover, no waist',
      icon: Icons.warning_amber_rounded,
    ),
  ];

  const BodyConditionStep({
    super.key,
    required this.weightCategory,
    required this.onWeightCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MascotSpeechBubble(
          question: "What's your cat's body shape?",
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in _options) ...[
                  DSOptionRow(
                    label: option.label,
                    description: option.desc,
                    leadingIcon: option.icon,
                    selected: weightCategory == option.value,
                    onTap: () => onWeightCategoryChanged(option.value),
                  ),
                  const SizedBox(height: DSDimens.sizeXs),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
