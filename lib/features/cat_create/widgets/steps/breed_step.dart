import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

const _mixedBreedValue = 'Other';

class BreedStep extends StatelessWidget {
  final String? selectedBreed;
  final List<String> breeds;
  final ValueChanged<String> onBreedSelected;

  const BreedStep({
    super.key,
    required this.selectedBreed,
    required this.breeds,
    required this.onBreedSelected,
  });

  /// Real breeds (everything except "Other") alphabetized; "Other" surfaces
  /// as a separate "Mixed / unknown" affordance below the list.
  List<String> get _alphabetized {
    return breeds.where((b) => b != _mixedBreedValue).toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  Map<String, List<String>> _grouped(List<String> breeds) {
    final groups = <String, List<String>>{};
    for (final breed in breeds) {
      final letter = breed[0].toUpperCase();
      groups.putIfAbsent(letter, () => []).add(breed);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groups = _grouped(_alphabetized);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MascotSpeechBubble(question: l10n.breedQuestion),
        const SizedBox(height: DSDimens.sizeS),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              for (final letter in groups.keys) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSDimens.sizeXs,
                    vertical: DSDimens.sizeXxs,
                  ),
                  child: Text(
                    letter,
                    style: DSTextStyles.caption.copyWith(
                      color: DSColors.inkTertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                for (final breed in groups[letter]!) ...[
                  DSOptionRow(
                    label: breed,
                    selected: selectedBreed == breed,
                    onTap: () => onBreedSelected(breed),
                  ),
                  const SizedBox(height: DSDimens.sizeXxs),
                ],
              ],
              const SizedBox(height: DSDimens.sizeS),
              Center(
                child: TextButton(
                  onPressed: () => onBreedSelected(_mixedBreedValue),
                  child: Text.rich(
                    TextSpan(
                      text: l10n.breedUnknownPrefix,
                      style: DSTextStyles.bodyMd.copyWith(
                        color: DSColors.inkSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: l10n.breedMixedUnknown,
                          style: DSTextStyles.bodyMd.copyWith(
                            color: DSColors.inkPrimary,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
