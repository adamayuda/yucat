import 'package:yucat/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yucat/features/recipes/domain/repositories/recipes_repository.dart';

class GetRecipesUsecase {
  final RecipesRepository _repository;

  GetRecipesUsecase({required RecipesRepository repository})
      : _repository = repository;

  Future<List<RecipeEntity>> call() => _repository.getRecipes();
}
