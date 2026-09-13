import 'package:yucat/features/cat/domain/repositories/cat_repository.dart';

class UpdateCatLifestyleUsecase {
  final CatRepository _repository;

  UpdateCatLifestyleUsecase({required CatRepository repository})
      : _repository = repository;

  /// `CatLifestyle.indoor` / `.outdoor`; null clears the field.
  Future<void> call({required String catId, required String? lifestyle}) {
    return _repository.updateCatLifestyle(catId: catId, lifestyle: lifestyle);
  }
}
