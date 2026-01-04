import 'package:yucat/features/brand/domain/entities/brand_entity.dart';
import 'package:yucat/features/search_products/presentation/models/brand_display_model.dart';

abstract class BrandToModelMapper {
  List<BrandDisplayModel> call(List<BrandEntity> brands);
}

class BrandToModelMapperImpl extends BrandToModelMapper {
  @override
  List<BrandDisplayModel> call(List<BrandEntity> brands) {
    return brands
        .map((brand) => BrandDisplayModel(name: brand.name, image: brand.image))
        .toList();
  }
}
