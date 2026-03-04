import 'package:yucat/features/cat/domain/repositories/cat_repository.dart';

class DeleteCatUsecase {
  final CatRepository _repository;

  DeleteCatUsecase({required CatRepository repository})
      : _repository = repository;

  Future<void> call({required String catId}) async {
    return _repository.deleteCat(catId: catId);
  }
}
