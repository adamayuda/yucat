import 'package:yucat/features/product/domain/entities/product_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/utils/product_rating.dart';

abstract class ProductEntityToModelMapper {
  ProductDisplayModel call(ProductEntity entity);
}

class ProductEntityToModelMapperImpl extends ProductEntityToModelMapper {
  static const int _maxScore = 100;

  @override
  ProductDisplayModel call(ProductEntity entity) {
    return ProductDisplayModel(
      name: entity.name,
      brand: entity.brand,
      score: entity.score,
      maxScore: _maxScore,
      ratingText: ratingTextForScore(entity.score, _maxScore),
      ratingColor: ratingColorForScore(entity.score, _maxScore),
      imageUrl: entity.imageUrl,
      pros: entity.pros,
      cons: entity.cons,
      protein: entity.protein,
      moisture: entity.moisture,
      fat: entity.fat,
      fiber: entity.fiber,
      carbs: _calculateCarbs(entity),
      isAiIdentified: entity.isAiIdentified,
      format: entity.format,
      packageSize: entity.packageSize,
      description: entity.description,
    );
  }

  /// Carbs is rarely on the label, so fall back to subtraction. Clamp to >= 0
  /// in case the other macros over-sum. `calories` derives from this on the
  /// model, so the two always agree.
  double _calculateCarbs(ProductEntity entity) {
    if (entity.carbs != 0) return entity.carbs;
    final derived = 100.0 -
        entity.protein -
        entity.fat -
        entity.fiber -
        entity.moisture -
        entity.ash;
    return derived < 0 ? 0.0 : derived;
  }
}
