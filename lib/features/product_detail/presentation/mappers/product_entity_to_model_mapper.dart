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
      localizedFormat: entity.localizedFormat,
      localizedPackageSize: entity.localizedPackageSize,
      localizedDescription: entity.localizedDescription,
      localizedPros: entity.localizedPros,
      localizedCons: entity.localizedCons,
      // A score of 0 means the backend found no guaranteed analysis — show the
      // neutral "no info" state rather than a red "Poor" verdict.
      dataUnavailable: entity.score <= 0,
    );
  }

  /// Carbs is rarely on the label, so fall back to subtraction. Clamp to >= 0
  /// in case the other macros over-sum. `calories` derives from this on the
  /// model, so the two always agree.
  double _calculateCarbs(ProductEntity entity) {
    if (entity.carbs != 0) return entity.carbs;
    // When the backend found no guaranteed analysis it defaults every macro to
    // 0. Subtracting from 100 would then yield a misleading carbs=100%, so bail
    // out and let the macro render as an em-dash like the others.
    final hasMacroData = entity.protein != 0 ||
        entity.fat != 0 ||
        entity.fiber != 0 ||
        entity.moisture != 0 ||
        entity.ash != 0;
    if (!hasMacroData) return 0.0;
    final derived = 100.0 -
        entity.protein -
        entity.fat -
        entity.fiber -
        entity.moisture -
        entity.ash;
    return derived < 0 ? 0.0 : derived;
  }
}
