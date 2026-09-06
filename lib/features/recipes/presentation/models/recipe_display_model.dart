import 'package:equatable/equatable.dart';
import 'package:yucat/features/recipes/domain/entities/recipe_entity.dart';

/// What the recipe list and card render. Close to `RecipeEntity` today; it
/// exists as the seam the backend's wire → entity → model chain will use, per
/// the repo's mapper convention.
class RecipeDisplayModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final RecipeCategory category;
  final int prepMinutes;
  final bool requiresFreezing;
  final RecipeDifficulty difficulty;
  final RecipeCompatibility compatibility;
  final String? imageUrl;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;
  final String? tip;

  /// Allergen keys from the recipe's canonical English ingredients, for
  /// filtering against a cat's declared allergies. Never rendered.
  final List<String> allergenKeys;

  const RecipeDisplayModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.prepMinutes,
    required this.requiresFreezing,
    required this.difficulty,
    required this.compatibility,
    this.imageUrl,
    this.ingredients = const [],
    this.steps = const [],
    this.tip,
    this.allergenKeys = const [],
  });

  /// Lower-cased name + description, so the list's filter doesn't re-derive the
  /// casing rules at each call site.
  String get searchHaystack => '$name $description'.toLowerCase();

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        prepMinutes,
        requiresFreezing,
        difficulty,
        compatibility,
        imageUrl,
        ingredients,
        steps,
        tip,
        allergenKeys,
      ];
}
