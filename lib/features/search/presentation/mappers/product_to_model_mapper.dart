import 'package:yucat/features/product_detail/domain/entities/product_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_model.dart';

abstract class ProductToModelMapper {
  ProductModel call(ProductEntity product);
}

class ProductToModelMapperImpl extends ProductToModelMapper {
  static const int maxScore = 100;

  @override
  ProductModel call(ProductEntity product) {
    final ratingText = _getRatingText(product.score, maxScore);
    final ratingColor = _getRatingColor(product.score, maxScore);

    return ProductModel(
      name: product.name,
      brand: product.brand,
      score: product.score,
      maxScore: maxScore,
      ratingText: ratingText,
      ratingColor: ratingColor,
      imageUrl: product.imageUrl,
      pros: product.pros,
      cons: product.cons,
      protein: product.proteins,
      moisture: product.moisture,
      fat: product.fats,
      fiber: product.fiber,
      carbs: product.carbs == 0
          ? 100 -
                product.proteins -
                product.fats -
                product.fiber -
                product.moisture -
                product.ash
          : product.carbs,
      caloriesPer100g: product.caloriesPer100g,
    );
  }

  String _getRatingText(int score, int maxScore) {
    if (maxScore == 0) return 'Unknown';
    final percentage = (score / maxScore) * 100;
    if (percentage >= 80) {
      return 'Excellent';
    } else if (percentage >= 60) {
      return 'Good';
    } else if (percentage >= 40) {
      return 'Fair';
    } else if (percentage >= 20) {
      return 'Poor';
    } else {
      return 'Very Poor';
    }
  }

  ProductRatingColor _getRatingColor(int score, int maxScore) {
    if (maxScore == 0) return ProductRatingColor.red;
    final percentage = (score / maxScore) * 100;
    if (percentage >= 70) {
      return ProductRatingColor.green;
    } else if (percentage >= 40) {
      return ProductRatingColor.yellow;
    } else {
      return ProductRatingColor.red;
    }
  }
}
