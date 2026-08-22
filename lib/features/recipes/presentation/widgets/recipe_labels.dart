import 'package:yucat/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yucat/features/recipes/presentation/models/recipe_display_model.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// Localized copy for the recipe enums. Kept in one place so the card, the
/// filter strip and (later) the detail screen can't drift apart.
extension RecipeCategoryL10n on RecipeCategory {
  String label(AppLocalizations l10n) => switch (this) {
        RecipeCategory.biscuits => l10n.recipesCategoryBiscuits,
        RecipeCategory.cakes => l10n.recipesCategoryCakes,
        RecipeCategory.frozenTreats => l10n.recipesCategoryFrozenTreats,
        RecipeCategory.meals => l10n.recipesCategoryMeals,
        RecipeCategory.other => l10n.recipesCategoryOther,
      };
}

extension RecipeDifficultyL10n on RecipeDifficulty {
  String label(AppLocalizations l10n) => switch (this) {
        RecipeDifficulty.easy => l10n.recipesDifficultyEasy,
        RecipeDifficulty.medium => l10n.recipesDifficultyMedium,
        RecipeDifficulty.hard => l10n.recipesDifficultyHard,
      };
}

extension RecipeCompatibilityL10n on RecipeCompatibility {
  String label(AppLocalizations l10n) => switch (this) {
        RecipeCompatibility.compatible => l10n.recipesCompatible,
        RecipeCompatibility.caution => l10n.recipesCaution,
        RecipeCompatibility.incompatible => l10n.recipesIncompatible,
      };
}

extension RecipePrepTimeL10n on RecipeDisplayModel {
  /// "25 min", or "5 min + freezing" when the recipe also needs freezer time —
  /// a single total would misrepresent how long it actually takes.
  String prepLabel(AppLocalizations l10n) => requiresFreezing
      ? l10n.recipesPrepMinutesPlusFreezing(prepMinutes)
      : l10n.recipesPrepMinutes(prepMinutes);
}
