import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class ActivityStep extends StatelessWidget {
  final String? activityLevel;
  final ValueChanged<String?> onActivityLevelChanged;

  const ActivityStep({
    super.key,
    required this.activityLevel,
    required this.onActivityLevelChanged,
  });

  // `value` is stable (drives the assessment); only label/desc are localized.
  List<({String label, String value, String desc, String asset})> _options(
    AppLocalizations l10n,
  ) =>
      [
        (
          label: l10n.activityLowLabel,
          value: 'low',
          desc: l10n.activityLowDesc,
          asset: 'assets/images/Low.svg',
        ),
        (
          label: l10n.activityMediumLabel,
          value: 'medium',
          desc: l10n.activityMediumDesc,
          asset: 'assets/images/Medium.svg',
        ),
        (
          label: l10n.activityHighLabel,
          value: 'high',
          desc: l10n.activityHighDesc,
          asset: 'assets/images/Hight.svg',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MascotSpeechBubble(
          question: l10n.activityQuestion,
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in _options(l10n)) ...[
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
