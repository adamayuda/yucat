import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/saved_products/domain/repositories/saved_litters_repository.dart';

class GetSavedLittersUsecase {
  final SavedLittersRepository _repository;

  GetSavedLittersUsecase({required SavedLittersRepository repository})
      : _repository = repository;

  Future<List<LitterDisplayModel>> call() => _repository.getAll();
}
