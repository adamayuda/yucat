import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/saved_products/domain/repositories/saved_litters_repository.dart';

class IsLitterSavedUsecase {
  final SavedLittersRepository _repository;

  IsLitterSavedUsecase({required SavedLittersRepository repository})
      : _repository = repository;

  Future<bool> call(LitterDisplayModel litter) => _repository.isSaved(litter);
}
