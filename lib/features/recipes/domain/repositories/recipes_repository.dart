import 'package:yucat/features/recipes/domain/entities/recipe_entity.dart';

abstract class RecipesRepository {
  /// [language] is the app's resolved language code; an unsupported or null
  /// value yields the canonical English copy.
  Future<List<RecipeEntity>> getRecipes({String? language});
}
