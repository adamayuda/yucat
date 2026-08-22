import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/recipes/presentation/models/recipe_display_model.dart';
import 'package:yucat/features/recipes/presentation/widgets/recipe_labels.dart';
import 'package:yucat/features/recipes/presentation/widgets/recipe_meta.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';

/// One row in the recipes list: thumbnail, name, two-line description, prep
/// time + difficulty, and the per-cat compatibility pill.
class RecipeRowCard extends StatelessWidget {
  final RecipeDisplayModel recipe;
  final VoidCallback onTap;

  const RecipeRowCard({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DSCard(
      onTap: onTap,
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RecipeThumb(imageUrl: recipe.imageUrl),
          const SizedBox(width: DSDimens.sizeS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: DSTextStyles.titleMd,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: DSDimens.sizeXxxs),
                Text(
                  recipe.description,
                  style: DSTextStyles.bodyMd.copyWith(
                    color: DSColors.inkSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: DSDimens.sizeXxs),
                RecipeMetaRow(
                  prep: recipe.prepLabel(l10n),
                  difficulty: recipe.difficulty.label(l10n),
                ),
                const SizedBox(height: DSDimens.sizeXxs),
                RecipeCompatibilityPill(
                  compatibility: recipe.compatibility,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeThumb extends StatelessWidget {
  final String? imageUrl;

  const _RecipeThumb({required this.imageUrl});

  static const double _size = 80;

  @override
  Widget build(BuildContext context) {
    // Check for a URL first so a recipe with no photo never starts a network
    // request; the tint sits behind the image so there's no white flash.
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: DSColors.tintSand,
        borderRadius: BorderRadius.circular(DSRadii.lg),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              width: _size,
              height: _size,
              errorBuilder: (_, __, ___) => const _ThumbPlaceholder(),
            )
          : const _ThumbPlaceholder(),
    );
  }
}

/// Deliberately not `HatchedPlaceholder` — that paints a "no image" tag, which
/// is right for a product whose photo lookup failed but wrong for a recipe that
/// simply has no photo yet.
class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.ramen_dining_rounded,
        color: DSColors.inkTertiary,
        size: 28,
      ),
    );
  }
}
