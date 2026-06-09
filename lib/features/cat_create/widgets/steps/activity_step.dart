import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class ActivityStep extends StatelessWidget {
  final String? activityLevel;
  final ValueChanged<String?> onActivityLevelChanged;

  static const List<
      ({String label, String value, String desc, String asset})> _options = [
    (
      label: 'Low',
      value: 'low',
      desc: 'Mostly naps, rarely chases',
      asset: 'assets/images/Low.svg',
    ),
    (
      label: 'Medium',
      value: 'medium',
      desc: 'Plays a few times a day',
      asset: 'assets/images/Medium.svg',
    ),
    (
      label: 'High',
      value: 'high',
      desc: 'Climbs, sprints, hunts toys',
      asset: 'assets/images/Hight.svg',
    ),
  ];

  const ActivityStep({
    super.key,
    required this.activityLevel,
    required this.onActivityLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MascotSpeechBubble(
          question: 'How active is your cat?',
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
                    selected: activityLevel == option.value,
                    onTap: () => onActivityLevelChanged(option.value),
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
