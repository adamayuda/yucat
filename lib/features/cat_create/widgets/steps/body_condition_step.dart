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
      ({String label, String value, String desc, String asset})> _options = [
    (
      label: 'Underweight',
      value: 'underweight',
      desc: 'Ribs and spine show, very little fat',
      asset: 'assets/images/Under.svg',
    ),
    (
      label: 'Just right',
      value: 'normal',
      desc: 'Ribs felt easily, visible waist',
      asset: 'assets/images/right.svg',
    ),
    (
      label: 'Overweight',
      value: 'overweight',
      desc: 'Ribs hard to feel, rounded belly',
      asset: 'assets/images/Over.svg',
    ),
    (
      label: 'Obese',
      value: 'obese',
      desc: 'Heavy fat cover, no waist',
      asset: 'assets/images/Obese.svg',
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
                    leadingAsset: option.asset,
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
