import 'package:yucat/features/brand/domain/entities/brand_entity.dart';

abstract class BrandRepository {
  Future<List<BrandEntity>> getBrands();
}
