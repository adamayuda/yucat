import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class ActivityStep extends StatelessWidget {
  final String? activityLevel;
  final ValueChanged<String?> onActivityLevelChanged;

  static const List<({String label, String value, IconData icon})> _options = [
    (label: 'Low', value: 'low', icon: Icons.bedtime_rounded),
    (label: 'Medium', value: 'medium', icon: Icons.directions_walk_rounded),
    (label: 'High', value: 'high', icon: Icons.directions_run_rounded),
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
                    leadingIcon: option.icon,
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
