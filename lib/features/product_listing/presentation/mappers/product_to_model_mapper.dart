import 'package:yucat/features/product/domain/entities/product_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/utils/product_rating.dart';

abstract class ProductToModelMapper {
  ProductDisplayModel call(ProductEntity product);
}

class ProductToModelMapperImpl extends ProductToModelMapper {
  static const int maxScore = 100;

  @override
  ProductDisplayModel call(ProductEntity product) {
    return ProductDisplayModel(
      name: product.name,
      brand: product.brand,
      score: product.score,
      maxScore: maxScore,
      ratingText: ratingTextForScore(product.score, maxScore),
      ratingColor: ratingColorForScore(product.score, maxScore),
      imageUrl: product.imageUrl,
      pros: product.pros,
      cons: product.cons,
      protein: product.protein,
      moisture: product.moisture,
      fat: product.fat,
      fiber: product.fiber,
      carbs: _calculateCarbs(product),
    );
  }

  double _calculateCarbs(ProductEntity product) {
    if (product.carbs != 0) return product.carbs;
    final derived = 100.0 -
        product.protein -
        product.fat -
        product.fiber -
        product.moisture -
        product.ash;
    return derived < 0 ? 0.0 : derived;
  }
}
