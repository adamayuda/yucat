import 'package:yucat/features/cat/domain/repositories/cat_repository.dart';

class UpdateCatWeightUsecase {
  final CatRepository _repository;

  UpdateCatWeightUsecase({required CatRepository repository})
      : _repository = repository;

  Future<void> call({required String catId, required double weight}) {
    return _repository.updateCatWeight(catId: catId, weight: weight);
  }
}
