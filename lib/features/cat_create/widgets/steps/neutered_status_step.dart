import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class NeuteredStatusStep extends StatelessWidget {
  /// One of: "intact", "neutered", "pregnant", "lactating"
  final String? status;
  final String? gender;
  final ValueChanged<String?> onStatusChanged;

  const NeuteredStatusStep({
    super.key,
    required this.status,
    required this.gender,
    required this.onStatusChanged,
  });

  // `value` is stable; only `label` is localized. asset/emoji stay fixed.
  List<({String label, String value, String? asset, String? emoji})>
      _baseOptions(AppLocalizations l10n) => [
            (
              label: l10n.neuteredIntact,
              value: 'intact',
              asset: 'assets/images/Male.svg',
              emoji: null,
            ),
            (
              label: l10n.neuteredNeutered,
              value: 'neutered',
              asset: 'assets/images/Beauty.svg',
              emoji: null,
            ),
          ];

  List<({String label, String value, String? asset, String? emoji})>
      _femaleOnlyOptions(AppLocalizations l10n) => [
            // No matching icon for "pregnant" yet — falls back to its emoji.
            (
              label: l10n.neuteredPregnant,
              value: 'pregnant',
              asset: null,
              emoji: '🤰',
            ),
            (
              label: l10n.neuteredLactating,
              value: 'lactating',
              asset: 'assets/images/Baby.svg',
              emoji: null,
            ),
          ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = [
      ..._baseOptions(l10n),
      if (gender == 'female') ..._femaleOnlyOptions(l10n),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MascotSpeechBubble(question: l10n.neuteredQuestion),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in options) ...[
                  DSOptionRow(
                    label: option.label,
                    leadingAsset: option.asset,
                    leadingEmoji: option.emoji,
                    selected: status == option.value,
                    onTap: () => onStatusChanged(option.value),
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
