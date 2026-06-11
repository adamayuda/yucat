import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_chip.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class HealthConditionsStep extends StatelessWidget {
  final List<String> selectedHealthConditions;
  final ValueChanged<List<String>> onHealthConditionsChanged;

  // `value` is stable (drives the per-cat assessment); only `label` is
  // localized.
  List<({String label, String value})> _options(AppLocalizations l10n) => [
        (label: l10n.healthNone, value: 'none'),
        (label: l10n.healthUrinaryIssues, value: 'urinary_issues'),
        (label: l10n.healthKidneyDisease, value: 'kidney_disease'),
        (label: l10n.healthSensitiveStomach, value: 'sensitive_stomach'),
        (label: l10n.healthSkinAllergies, value: 'skin_allergies'),
        (label: l10n.healthFoodAllergies, value: 'food_allergies'),
        (label: l10n.healthDiabetes, value: 'diabetes'),
        (label: l10n.healthDentalProblems, value: 'dental_problems'),
        (label: l10n.healthHairballIssues, value: 'hairball_issues'),
        (label: l10n.healthHeartCondition, value: 'heart_condition'),
        (label: l10n.healthJointIssues, value: 'joint_issues'),
      ];

  const HealthConditionsStep({
    super.key,
    required this.selectedHealthConditions,
    required this.onHealthConditionsChanged,
  });

  void _toggle(String value) {
    final isSelected = selectedHealthConditions.contains(value);
    final current = List<String>.from(selectedHealthConditions);

    if (value == 'none') {
      if (isSelected) {
        current.remove(value);
      } else {
        current
          ..clear()
          ..add(value);
      }
    } else {
      current.remove('none');
      if (isSelected) {
        current.remove(value);
      } else {
        current.add(value);
      }
    }

    onHealthConditionsChanged(current);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MascotSpeechBubble(
          question: l10n.healthQuestion,
        ),
        const SizedBox(height: DSDimens.sizeL),
        Expanded(
          // Centre the chip block vertically; the ConstrainedBox keeps it
          // centred when it fits and lets it scroll (clearing the floating CTA)
          // if it ever overflows.
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DSDimens.sizeL,
                    0,
                    DSDimens.sizeL,
                    96,
                  ),
                  child: Center(
                    // The Wrap fills the width and centres each row, so the
                    // block sits horizontally centred too.
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: DSDimens.sizeXxxs,
                      runSpacing: DSDimens.sizeXxxs,
                      children: [
                        for (final option in _options(l10n))
                          DSChip(
                            label: option.label,
                            selected: selectedHealthConditions
                                .contains(option.value),
                            onTap: () => _toggle(option.value),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
