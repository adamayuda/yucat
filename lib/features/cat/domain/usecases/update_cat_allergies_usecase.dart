import 'package:yucat/features/cat/domain/repositories/cat_repository.dart';

class UpdateCatAllergiesUsecase {
  final CatRepository _repository;

  UpdateCatAllergiesUsecase({required CatRepository repository})
      : _repository = repository;

  Future<void> call({
    required String catId,
    required List<String> allergies,
  }) async {
    return await _repository.updateCatAllergies(
      catId: catId,
      allergies: allergies,
    );
  }
}
