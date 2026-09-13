import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_allergen.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// The ingredients list as printed on the pack — the first thing a label
/// reader looks for and, until now, the one field the backend returned that
/// nothing rendered. The first [_lead] items are emphasised (ingredient order
/// is weight order, so they *are* the food); the rest sit behind "Show all".
///
/// Items matching an allergen declared on any of the user's cats are
/// highlighted, using the same `CatAllergen` needles the verdict engine
/// scans with, so the list and the "Not recommended" pill never disagree.
/// Renders nothing when the product carries no list.
class IngredientsCard extends StatefulWidget {
  final List<String> ingredients;
  final List<CatEntity> cats;

  const IngredientsCard({
    super.key,
    required this.ingredients,
    this.cats = const [],
  });

  @override
  State<IngredientsCard> createState() => _IngredientsCardState();
}

class _IngredientsCardState extends State<IngredientsCard> {
  static const _lead = 5;
  bool _expanded = false;

  Set<String> get _declaredKeys => {
        for (final cat in widget.cats)
          for (final a in CatAllergen.resolveAll(cat.allergies))
            if (a.kind == CatAllergenKind.food) a.key,
      };

  bool _flagged(String item, Set<String> declared) {
    if (declared.isEmpty) return false;
    final keys = detectFoodAllergenKeys(
      item.toLowerCase().replaceAll('-', ' '),
    );
    return keys.any(declared.contains);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.ingredients;
    if (items.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final declared = _declaredKeys;
    final flags = [for (final i in items) _flagged(i, declared)];
    final anyFlag = flags.any((f) => f);
    final showAll = _expanded || items.length <= _lead;
    final visible = showAll ? items.length : _lead;

    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.productDetailIngredientsTitle,
            style: DSTextStyles.caption.copyWith(
              color: DSColors.inkSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: DSDimens.sizeXs),
          Wrap(
            spacing: DSDimens.sizeXxs,
            runSpacing: DSDimens.sizeXxs,
            children: [
              for (var i = 0; i < visible; i++)
                _IngredientChip(
                  text: items[i],
                  lead: i < _lead,
                  flagged: flags[i],
                ),
            ],
          ),
          if (items.length > _lead) ...[
            const SizedBox(height: DSDimens.sizeXs),
            DSTextLink(
              label: _expanded
                  ? l10n.productDetailIngredientsShowLess
                  : l10n.productDetailIngredientsShowAll(items.length),
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ],
          const SizedBox(height: DSDimens.sizeXs),
          Text(
            anyFlag
                ? l10n.productDetailIngredientsFlaggedNote
                : l10n.productDetailIngredientsSource,
            style: DSTextStyles.caption.copyWith(
              color: anyFlag ? DSColors.accentDanger : DSColors.inkTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientChip extends StatelessWidget {
  final String text;
  final bool lead;
  final bool flagged;

  const _IngredientChip({
    required this.text,
    required this.lead,
    required this.flagged,
  });

  @override
  Widget build(BuildContext context) {
    final bg = flagged
        ? DSColors.coralSurface
        : lead
            ? DSColors.tintLavender
            : DSColors.surfaceCardDim;
    final fg = flagged ? DSColors.accentDanger : DSColors.inkPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXs,
        vertical: DSDimens.sizeXxxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(DSRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (flagged) ...[
            Icon(Icons.warning_amber_rounded, size: 12, color: fg),
            const SizedBox(width: DSDimens.sizeXxxs),
          ],
          Flexible(
            child: Text(
              text,
              style: DSTextStyles.caption.copyWith(
                color: fg,
                fontWeight: lead || flagged ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
