import 'package:yucat/features/recipes/domain/entities/recipe_entity.dart';

abstract class RecipesRepository {
  Future<List<RecipeEntity>> getRecipes();
}
