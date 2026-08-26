import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/articles/domain/entities/article_entity.dart';
import 'package:yucat/features/articles/presentation/widgets/article_labels.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// Horizontal single-select category filter. Leading chip is "All"
/// (`selected == null`).
///
/// Same shape as `RecipeCategoryStrip` — blue-tinted, dotless, horizontally
/// scrolled — rather than `DSChip`, which hardcodes a coral selection dot for
/// the cat wizard's `Wrap`-based multi-select.
class ArticleCategoryStrip extends StatelessWidget {
  final ArticleCategory? selected;
  final ValueChanged<ArticleCategory?> onSelected;

  const ArticleCategoryStrip({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // Full-bleed with its own insets so chips scroll under the screen edges
      // while the first one lines up with the page content.
      padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
      child: Row(
        children: [
          _CategoryChip(
            label: l10n.articlesCategoryAll,
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final category in ArticleCategory.filterable) ...[
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
