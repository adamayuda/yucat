import 'package:yucat/features/litter/domain/entities/litter_entity.dart';
import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/product_detail/presentation/utils/product_rating.dart';

abstract class LitterEntityToModelMapper {
  LitterDisplayModel call(LitterEntity entity);
}

class LitterEntityToModelMapperImpl extends LitterEntityToModelMapper {
  static const int _maxScore = 100;

  @override
  LitterDisplayModel call(LitterEntity entity) {
    return LitterDisplayModel(
      name: entity.name,
      brand: entity.brand,
      score: entity.score,
      maxScore: _maxScore,
      ratingText: ratingTextForScore(entity.score, _maxScore),
      ratingColor: ratingColorForScore(entity.score, _maxScore),
      imageUrl: entity.imageUrl,
      material: entity.material,
      clumping: entity.clumping,
      dustLevel: entity.dustLevel,
      scented: entity.scented,
      trackingLevel: entity.trackingLevel,
      odorControl: entity.odorControl,
      flushable: entity.flushable,
      biodegradable: entity.biodegradable,
      additives: entity.additives,
      pros: entity.pros,
      cons: entity.cons,
      format: entity.format,
      packageSize: entity.packageSize,
      description: entity.description,
      localizedFormat: entity.localizedFormat,
      localizedPackageSize: entity.localizedPackageSize,
      localizedDescription: entity.localizedDescription,
      localizedPros: entity.localizedPros,
      localizedCons: entity.localizedCons,
      isAiIdentified: entity.isAiIdentified,
      // Score 0 is the backend's "no data found" sentinel, not a grade — show
      // the neutral state rather than a red verdict.
      dataUnavailable: entity.score <= 0,
    );
  }
}
