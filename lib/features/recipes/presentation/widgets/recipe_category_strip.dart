import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yucat/features/recipes/presentation/widgets/recipe_labels.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// Horizontal single-select category filter. Leading chip is "All"
/// (`selected == null`).
///
/// Not `DSChip`: that component hardcodes a coral selection dot and an
/// always-white background for the `Wrap`-based multi-select survey in the cat
/// wizard. These pills are blue-tinted, dotless and horizontally scrolled, so
/// they follow the hand-rolled strip pattern already used by `HomeCatSelector`
/// and the cat selector in `cat_assessment_card.dart`.
class RecipeCategoryStrip extends StatelessWidget {
  final RecipeCategory? selected;
  final ValueChanged<RecipeCategory?> onSelected;

  const RecipeCategoryStrip({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = RecipeCategory.filterable;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // Full-bleed with its own insets so chips scroll under the screen edges
      // while the first one lines up with the page content.
      padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
      child: Row(
        children: [
          _CategoryChip(
            label: l10n.recipesCategoryAll,
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final category in categories) ...[
            const SizedBox(width: DSDimens.sizeXxs),
            _CategoryChip(
              label: category.label(l10n),
              selected: selected == category,
              onTap: () => onSelected(category),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
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
            vertical: DSDimens.sizeXs,
          ),
          decoration: BoxDecoration(
            color: selected ? DSColors.tintBlueSoft : DSColors.surfaceCard,
            borderRadius: BorderRadius.circular(DSRadii.pill),
            boxShadow: selected ? null : DSShadows.e1,
          ),
          child: Text(
            label,
            style: DSTextStyles.bodyLg.copyWith(
              color: selected ? DSColors.accentInfo : DSColors.inkSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
