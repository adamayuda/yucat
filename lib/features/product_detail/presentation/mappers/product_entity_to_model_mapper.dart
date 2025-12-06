import 'package:yucat/features/product_detail/domain/entities/product_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_model.dart';

abstract class ProductEntityToModelMapper {
  ProductModel call(ProductEntity entity);
}

class ProductEntityToModelMapperImpl extends ProductEntityToModelMapper {
  @override
  ProductModel call(ProductEntity entity) {
    return ProductModel(
      name: entity.name,
      brand: entity.brand,
      score: entity.score,
      ratingColor: ProductRatingColor.red,
      imageUrl: entity.imageUrl,
      pros: entity.pros,
      cons: entity.cons,
      protein: entity.proteins,
      moisture: entity.moisture,
      fat: entity.fats,
      fiber: entity.fiber,
      carbs: entity.carbs == 0
          ? 100 -
                entity.proteins -
                entity.fats -
                entity.fiber -
                entity.moisture -
                entity.ash
          : entity.carbs,
      maxScore: 100,
      ratingText: '',
      caloriesPer100g: entity.caloriesPer100g == 0
          ? (entity.proteins * 3.5) + (entity.fats * 8.5) + (entity.carbs * 3.5)
          : entity.caloriesPer100g,
    );
  }
}
