import 'package:yucat/features/recipes/data/datasources/recipe_seed_datasource.dart';
import 'package:yucat/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yucat/features/recipes/domain/repositories/recipes_repository.dart';

class RecipesRepositoryImpl implements RecipesRepository {
  final RecipeSeedDataSource _dataSource;

  RecipesRepositoryImpl({required RecipeSeedDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<List<RecipeEntity>> getRecipes() => _dataSource.getRecipes();
}
