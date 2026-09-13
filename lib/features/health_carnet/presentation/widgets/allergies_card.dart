import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_allergen.dart';
import 'package:yucat/features/cat/presentation/utils/cat_labels.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/ds_tag_chip.dart';

/// Declared allergies and sensitivities.
///
/// The footer states what the list actually does — flags products, hides
/// recipes — because a list that silently changes what the app shows elsewhere
/// is worse than no list at all.
class AllergiesCard extends StatelessWidget {
  final List<String> allergyKeys;
  final VoidCallback onEdit;

  const AllergiesCard({
    super.key,
    required this.allergyKeys,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final resolved = CatAllergen.resolveAll(allergyKeys);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.healthCarnetAllergiesTitle,
                style: DSTextStyles.titleMd,
              ),
            ),
            DSTextLink(
              label: l10n.healthCarnetAllergiesEdit,
              onPressed: onEdit,
            ),
          ],
        ),
        const SizedBox(height: DSDimens.sizeXxs),
        DSCard(
          padding: const EdgeInsets.all(DSDimens.sizeS),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (resolved.isEmpty)
                Text(
                  l10n.healthCarnetAllergiesEmpty,
                  style: DSTextStyles.bodyMd,
                )
              else
                Wrap(
                  spacing: DSDimens.sizeXxs,
                  runSpacing: DSDimens.sizeXxs,
                  children: [
                    for (final allergen in resolved)
                      DSTagChip(
                        label: catFormatAllergen(allergen.key, l10n),
                        // Environmental allergens are recorded but never matched
                        // against food, so they read neutral rather than as a
                        // warning that changes what the app shows.
                        background: allergen.kind == CatAllergenKind.food
                            ? const Color(0xFFFCE4E1)
                            : DSColors.tintAsh,
                        foreground: allergen.kind == CatAllergenKind.food
                            ? DSColors.accentDanger
                            : DSColors.inkSecondary,
                      ),
                  ],
                ),
              if (resolved.any((a) => a.kind == CatAllergenKind.food)) ...[
                const SizedBox(height: DSDimens.sizeXs),
                Text(
                  l10n.healthCarnetAllergiesFooter,
                  style: DSTextStyles.bodyMd.copyWith(
                    color: DSColors.inkTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Multi-select sheet returning the chosen allergen keys, or null if dismissed.
Future<List<String>?> showAllergiesSheet(
  BuildContext context,
  List<String> selected,
) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AllergiesSheet(initial: selected),
  );
}

class _AllergiesSheet extends StatefulWidget {
  final List<String> initial;

  const _AllergiesSheet({required this.initial});

  @override
  State<_AllergiesSheet> createState() => _AllergiesSheetState();
}

class _AllergiesSheetState extends State<_AllergiesSheet> {
  late final Set<String> _selected = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final media = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.85),
      decoration: const BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSRadii.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: DSDimens.sizeS),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: DSColors.surfaceCardDim,
                  borderRadius: BorderRadius.circular(DSRadii.pill),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  DSDimens.sizeL,
                  DSDimens.sizeL,
                  DSDimens.sizeL,
                  DSDimens.sizeS,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.healthCarnetAllergiesSheetTitle,
                      style: DSTextStyles.titleMd,
                    ),
                    const SizedBox(height: DSDimens.sizeS),
                    Text(
                      l10n.healthCarnetAllergiesSectionFood,
                      style: DSTextStyles.label,
                    ),
                    const SizedBox(height: DSDimens.sizeXxs),
                    _group(CatAllergen.food, l10n),
                    const SizedBox(height: DSDimens.sizeS),
                    Text(
                      l10n.healthCarnetAllergiesSectionEnvironment,
                      style: DSTextStyles.label,
                    ),
                    const SizedBox(height: DSDimens.sizeXxs),
                    _group(CatAllergen.environmental, l10n),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DSDimens.sizeL,
                DSDimens.sizeXxs,
                DSDimens.sizeL,
                DSDimens.sizeS,
              ),
              child: DSPillButton(
                label: l10n.healthCarnetAllergiesSave,
                showChevron: false,
                onPressed: () =>
                    Navigator.of(context).pop(_selected.toList()..sort()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _group(List<CatAllergen> allergens, AppLocalizations l10n) {
    return Wrap(
      spacing: DSDimens.sizeXxs,
      runSpacing: DSDimens.sizeXxs,
      children: [
        for (final allergen in allergens)
          _SelectableTag(
            label: catFormatAllergen(allergen.key, l10n),
            selected: _selected.contains(allergen.key),
            onTap: () => setState(() {
              if (!_selected.remove(allergen.key)) _selected.add(allergen.key);
            }),
          ),
      ],
    );
  }
}

class _SelectableTag extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableTag({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: DSMotion.durFast,
          curve: DSMotion.curveStandard,
          padding: const EdgeInsets.symmetric(
            horizontal: DSDimens.sizeS,
            vertical: DSDimens.sizeXxs,
          ),
          decoration: BoxDecoration(
            color: selected ? DSColors.tintCoralSoft : DSColors.surfaceCardDim,
            borderRadius: BorderRadius.circular(DSRadii.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(
                  Icons.check_rounded,
                  size: 15,
                  color: DSColors.accentDanger,
                ),
                const SizedBox(width: DSDimens.sizeXxxs),
              ],
              Text(
                label,
                style: DSTextStyles.label.copyWith(
                  color: selected
                      ? DSColors.accentDanger
                      : DSColors.inkSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
