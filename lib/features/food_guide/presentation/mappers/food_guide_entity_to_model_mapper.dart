import 'package:yucat/features/food_guide/domain/entities/food_guide_entity.dart';
import 'package:yucat/features/food_guide/presentation/models/food_guide_display_model.dart';

class FoodGuideEntityToModelMapper {
  const FoodGuideEntityToModelMapper();

  FoodGuideDisplayModel call(FoodGuideEntity entity) => FoodGuideDisplayModel(
        id: entity.id,
        name: entity.name,
        description: entity.description,
        emoji: entity.emoji,
        safety: entity.safety,
        imageUrl: entity.imageUrl,
        whyGood: entity.whyGood,
        howToServe: entity.howToServe,
        avoid: entity.avoid,
        tip: entity.tip,
      );
}
