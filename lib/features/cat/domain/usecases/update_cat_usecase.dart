import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/repositories/cat_repository.dart';

class UpdateCatUsecase {
  final CatRepository _repository;

  UpdateCatUsecase({required CatRepository repository})
      : _repository = repository;

  Future<void> call({required CatEntity cat}) async {
    return _repository.updateCat(cat: cat);
  }
}
