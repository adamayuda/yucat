import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_lifestyle.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// "Lifestyle" — indoor or outdoor, and what that changes in the schedule.
///
/// The footer says what the answer does (outdoor: the FeLV booster and
/// monthly deworming get scheduled), for the same reason the allergies card
/// does: a profile fact that silently changes the schedule is worse than none.
class LifestyleCard extends StatelessWidget {
  final String catName;
  final String? lifestyle;
  final VoidCallback onChange;

  const LifestyleCard({
    super.key,
    required this.catName,
    required this.lifestyle,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final known = CatLifestyle.normalize(lifestyle);
    final outdoor = CatLifestyle.isOutdoor(known);

    final (String value, String note, IconData icon) = switch (known) {
      CatLifestyle.outdoor => (
          l10n.healthLifestyleOutdoor,
          l10n.healthLifestyleOutdoorNote,
          Icons.park_outlined,
        ),
      CatLifestyle.indoor => (
          l10n.healthLifestyleIndoor,
          l10n.healthLifestyleIndoorNote,
          Icons.home_outlined,
        ),
      _ => (
          l10n.healthLifestyleUnset,
          l10n.healthLifestyleUnsetNote(catName),
          Icons.help_outline_rounded,
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.healthLifestyleTitle, style: DSTextStyles.titleMd),
            ),
            DSTextLink(label: l10n.healthLifestyleChange, onPressed: onChange),
          ],
        ),
        const SizedBox(height: DSDimens.sizeXxs),
        DSCard(
          padding: const EdgeInsets.all(DSDimens.sizeS),
          onTap: onChange,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: outdoor ? DSColors.tintMintSoft : DSColors.tintAsh,
                  borderRadius: BorderRadius.circular(DSRadii.md),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color:
                      outdoor ? DSColors.accentSuccess : DSColors.inkSecondary,
                ),
              ),
              const SizedBox(width: DSDimens.sizeXs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: DSTextStyles.titleMd),
                    const SizedBox(height: DSDimens.sizeXxxs),
                    Text(
                      note,
                      style: DSTextStyles.bodyMd.copyWith(
                        color: DSColors.inkTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The two options, shared by the setup sheet's fourth step and the change
/// sheet so the wording and order cannot drift.
class LifestyleOptions extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const LifestyleOptions({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        DSOptionRow(
          leadingIcon: Icons.home_outlined,
          label: l10n.healthLifestyleIndoor,
          selected: selected == CatLifestyle.indoor,
          onTap: () => onSelect(CatLifestyle.indoor),
        ),
        const SizedBox(height: DSDimens.sizeXxs),
        DSOptionRow(
          leadingIcon: Icons.park_outlined,
          label: l10n.healthLifestyleOutdoor,
          selected: selected == CatLifestyle.outdoor,
          onTap: () => onSelect(CatLifestyle.outdoor),
        ),
      ],
    );
  }
}

/// Change sheet. Returns the chosen lifestyle, or null when dismissed.
Future<String?> showLifestyleSheet(
  BuildContext context, {
  required String catName,
  String? initial,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _LifestyleSheet(
      catName: catName,
      initial: CatLifestyle.normalize(initial),
    ),
  );
}

class _LifestyleSheet extends StatefulWidget {
  final String catName;
  final String? initial;

  const _LifestyleSheet({required this.catName, required this.initial});

  @override
  State<_LifestyleSheet> createState() => _LifestyleSheetState();
}

class _LifestyleSheetState extends State<_LifestyleSheet> {
  late String? _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSRadii.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DSDimens.sizeL,
            DSDimens.sizeS,
            DSDimens.sizeL,
            DSDimens.sizeL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: DSDimens.sizeL),
              Text(
                l10n.healthLifestyleQuestion(widget.catName),
                style: DSTextStyles.titleMd,
              ),
              const SizedBox(height: DSDimens.sizeS),
              LifestyleOptions(
                selected: _selected,
                onSelect: (v) => setState(() => _selected = v),
              ),
              const SizedBox(height: DSDimens.sizeL),
              DSPillButton(
                label: l10n.healthVetSave,
                showChevron: false,
                onPressed: _selected == null
                    ? null
                    : () => Navigator.of(context).pop(_selected),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
