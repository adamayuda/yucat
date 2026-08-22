import 'package:yucat/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yucat/features/recipes/presentation/models/recipe_display_model.dart';

class RecipeEntityToModelMapper {
  const RecipeEntityToModelMapper();

  RecipeDisplayModel call(RecipeEntity entity) => RecipeDisplayModel(
        id: entity.id,
        name: entity.name,
        description: entity.description,
        category: entity.category,
        prepMinutes: entity.prepMinutes,
        requiresFreezing: entity.requiresFreezing,
        difficulty: entity.difficulty,
        compatibility: entity.compatibility,
        imageUrl: entity.imageUrl,
        ingredients: entity.ingredients,
        steps: entity.steps,
        tip: entity.tip,
      );
}
