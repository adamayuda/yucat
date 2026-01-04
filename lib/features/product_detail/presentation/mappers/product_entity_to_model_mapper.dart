import 'package:yucat/features/product/domain/entities/product_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';

abstract class ProductEntityToModelMapper {
  ProductDisplayModel call(ProductEntity entity);
}

class ProductEntityToModelMapperImpl extends ProductEntityToModelMapper {
  @override
  ProductDisplayModel call(ProductEntity entity) {
    return ProductDisplayModel(
      name: entity.name,
      brand: entity.brand,
      score: entity.score,
      ratingColor: ProductRatingColor.red,
      imageUrl: entity.imageUrl,
      pros: entity.pros,
      cons: entity.cons,
      protein: entity.protein,
      moisture: entity.moisture,
      fat: entity.fat,
      fiber: entity.fiber,
      carbs: _calculateCarbs(entity),
      maxScore: 100,
      ratingText: '',
      calories: _calculateCalories(entity),
    );
  }

  int _calculateCarbs(ProductEntity entity) => entity.carbs == 0
      ? 100 -
            entity.protein -
            entity.fat -
            entity.fiber -
            entity.moisture -
            entity.ash
      : entity.carbs;

  int _calculateCalories(ProductEntity entity) =>
      entity.protein * 4 + entity.fat * 9 + entity.carbs * 4;
}
