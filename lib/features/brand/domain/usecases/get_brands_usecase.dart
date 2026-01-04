import 'package:yucat/features/brand/domain/entities/brand_entity.dart';
import 'package:yucat/features/brand/domain/repositories/brand_repository.dart';

class GetBrandsUsecase {
  final BrandRepository _repository;

  GetBrandsUsecase({required BrandRepository repository})
    : _repository = repository;

  Future<List<BrandEntity>> call() async {
    return await _repository.getBrands();
  }
}
