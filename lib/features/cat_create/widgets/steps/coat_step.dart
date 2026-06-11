import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class CoatStep extends StatelessWidget {
  final String? coatType;
  final ValueChanged<String?> onCoatTypeChanged;

  const CoatStep({
    super.key,
    required this.coatType,
    required this.onCoatTypeChanged,
  });

  // `value` is stable; only `label` is localized.
  List<({String label, String value})> _options(AppLocalizations l10n) => [
        (label: l10n.coatShortHair, value: 'short_hair'),
        (label: l10n.coatLongHair, value: 'long_hair'),
        (label: l10n.coatHairless, value: 'hairless'),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MascotSpeechBubble(
          question: l10n.coatQuestion,
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in _options(l10n)) ...[
                  DSOptionRow(
                    label: option.label,
                    selected: coatType == option.value,
                    onTap: () => onCoatTypeChanged(option.value),
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
