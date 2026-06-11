import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class BodyConditionStep extends StatelessWidget {
  final String? weightCategory;
  final ValueChanged<String?> onWeightCategoryChanged;

  const BodyConditionStep({
    super.key,
    required this.weightCategory,
    required this.onWeightCategoryChanged,
  });

  // Values map to the assessment's `weightCategory` buckets
  // ('underweight' / 'normal' / 'overweight' / 'obese') and stay stable; only
  // the label/desc are localized.
  List<({String label, String value, String desc, String asset})> _options(
    AppLocalizations l10n,
  ) =>
      [
        (
          label: l10n.bodyUnderweightLabel,
          value: 'underweight',
          desc: l10n.bodyUnderweightDesc,
          asset: 'assets/images/Under.svg',
        ),
        (
          label: l10n.bodyNormalLabel,
          value: 'normal',
          desc: l10n.bodyNormalDesc,
          asset: 'assets/images/right.svg',
        ),
        (
          label: l10n.bodyOverweightLabel,
          value: 'overweight',
          desc: l10n.bodyOverweightDesc,
          asset: 'assets/images/Over.svg',
        ),
        (
          label: l10n.bodyObeseLabel,
          value: 'obese',
          desc: l10n.bodyObeseDesc,
          asset: 'assets/images/Obese.svg',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MascotSpeechBubble(
          question: l10n.bodyConditionQuestion,
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
