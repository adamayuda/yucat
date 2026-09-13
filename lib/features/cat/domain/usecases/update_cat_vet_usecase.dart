import 'package:yucat/features/cat/domain/entities/cat_vet_contact.dart';
import 'package:yucat/features/cat/domain/repositories/cat_repository.dart';

class UpdateCatVetUsecase {
  final CatRepository _repository;

  UpdateCatVetUsecase({required CatRepository repository})
      : _repository = repository;

  /// Null removes the contact.
  Future<void> call({required String catId, required CatVetContact? vet}) {
    return _repository.updateCatVet(catId: catId, vet: vet);
  }
}
