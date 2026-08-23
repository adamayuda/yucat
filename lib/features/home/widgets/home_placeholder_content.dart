import 'package:yucat/l10n/app_localizations.dart';

// TODO(home): placeholder content for the Food guide swimlane — it has no store
// yet. Nothing here is persisted. (The recipe lane used to be stubbed here too;
// it now reads the real Firestore catalogue via `GetRecipesUsecase`.)

/// One tile in the Food guide swimlane.
class FoodGuideCategory {
  final String emoji;
  final String label;

  const FoodGuideCategory({required this.emoji, required this.label});
}

/// Built from `l10n` rather than declared `const` — the labels are localized.
List<FoodGuideCategory> foodGuideCategories(AppLocalizations l10n) => [
      FoodGuideCategory(emoji: '🍗', label: l10n.homeFoodGuideMeats),
      FoodGuideCategory(emoji: '🐟', label: l10n.homeFoodGuideFish),
      FoodGuideCategory(emoji: '🥚', label: l10n.homeFoodGuideEggs),
      FoodGuideCategory(
        emoji: '🥦',
        label: l10n.homeFoodGuideFruitsVegetables,
      ),
      FoodGuideCategory(emoji: '🧀', label: l10n.homeFoodGuideDairy),
      FoodGuideCategory(emoji: '🍫', label: l10n.homeFoodGuideDangerous),
    ];
