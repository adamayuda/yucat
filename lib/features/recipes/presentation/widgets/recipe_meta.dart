import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yucat/features/recipes/presentation/widgets/recipe_labels.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// "25 min · Easy" with a leading dot. Shared by the list card and the detail
/// screen so the two can't drift.
class RecipeMetaRow extends StatelessWidget {
  final String prep;
  final String difficulty;

  const RecipeMetaRow({
    super.key,
    required this.prep,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: DSColors.accentSuccess,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: DSDimens.sizeXxs),
        Flexible(
          child: Text(
            '$prep  ·  $difficulty',
            style: DSTextStyles.label.copyWith(color: DSColors.inkSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Whether the recipe suits the user's cat. Shared by the list card and the
/// detail screen.
class RecipeCompatibilityPill extends StatelessWidget {
  final RecipeCompatibility compatibility;

  const RecipeCompatibilityPill({super.key, required this.compatibility});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (background, foreground, icon) = switch (compatibility) {
      RecipeCompatibility.compatible => (
          DSColors.accentSuccessSoft,
          DSColors.accentSuccess,
          Icons.check_circle_outline_rounded,
        ),
      RecipeCompatibility.caution => (
          DSColors.coralSurface,
          DSColors.coralAccent,
          Icons.info_outline_rounded,
        ),
      RecipeCompatibility.incompatible => (
          DSColors.tintCoral,
          DSColors.accentDanger,
          Icons.block_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXs,
        vertical: DSDimens.sizeXxxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(DSRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: foreground),
          const SizedBox(width: DSDimens.sizeXxxs),
          Flexible(
            child: Text(
              compatibility.label(l10n),
              style: DSTextStyles.caption.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
