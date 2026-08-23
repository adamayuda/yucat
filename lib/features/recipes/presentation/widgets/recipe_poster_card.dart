import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yucat/features/recipes/presentation/models/recipe_display_model.dart';
import 'package:yucat/features/recipes/presentation/widgets/recipe_labels.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';

/// Vertical recipe tile for a horizontal lane: photo with a floating prep-time
/// badge, then the name and a difficulty dot.
///
/// The sibling [RecipeRowCard] is a `Row` with an unconstrained `Expanded`, so
/// it can't live in a lane — this is the poster variant. Both read the same
/// [RecipeDisplayModel] and the same copy extensions in `recipe_labels.dart`.
class RecipePosterCard extends StatelessWidget {
  final RecipeDisplayModel recipe;
  final VoidCallback onTap;

  const RecipePosterCard({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  static const double width = 208;
  static const double _imageHeight = 124;

  /// Lane height this card needs: image + the name/meta block below it.
  static const double laneHeight = _imageHeight + 82;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: width,
      child: DSCard(
        // DSCard already clips to DSRadii.xl, so the photo gets rounded top
        // corners without a ClipRRect of its own.
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _PosterImage(imageUrl: recipe.imageUrl),
                Positioned(
                  top: DSDimens.sizeXxs,
                  left: DSDimens.sizeXxs,
                  child: _TimeBadge(label: recipe.prepLabel(l10n)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(DSDimens.sizeS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: DSTextStyles.titleMd,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: DSDimens.sizeXxxs),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _difficultyColor(recipe.difficulty),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: DSDimens.sizeXxs),
                      Flexible(
                        child: Text(
                          recipe.difficulty.label(l10n),
                          style: DSTextStyles.bodyMd.copyWith(
                            color: DSColors.inkSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _difficultyColor(RecipeDifficulty difficulty) =>
      switch (difficulty) {
        RecipeDifficulty.easy => DSColors.accentSuccess,
        RecipeDifficulty.medium => DSColors.coralAccent,
        RecipeDifficulty.hard => DSColors.accentDanger,
      };
}

class _PosterImage extends StatelessWidget {
  final String? imageUrl;

  const _PosterImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    // Check for a URL first so a recipe with no photo never starts a network
    // request; the tint sits behind the image so there's no white flash.
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Container(
      width: double.infinity,
      height: RecipePosterCard._imageHeight,
      color: DSColors.tintSand,
      alignment: Alignment.center,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: RecipePosterCard._imageHeight,
              errorBuilder: (_, __, ___) => const _PosterPlaceholder(),
            )
          : const _PosterPlaceholder(),
    );
  }
}

/// Deliberately not `HatchedPlaceholder` — that paints a "no image" tag, which
/// is right for a product whose photo lookup failed but wrong for a recipe that
/// simply has no photo yet.
class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.ramen_dining_outlined,
        color: DSColors.inkTertiary,
        size: 36,
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  final String label;

  const _TimeBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXs,
        vertical: DSDimens.sizeXxxs,
      ),
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.pill),
        boxShadow: DSShadows.e1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 13,
            color: DSColors.inkPrimary,
          ),
          const SizedBox(width: DSDimens.sizeXxxs),
          Text(
            label,
            style: DSTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: DSColors.inkPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
