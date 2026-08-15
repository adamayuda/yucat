import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/saved_products/domain/repositories/saved_litters_repository.dart';

class SaveLitterUsecase {
  final SavedLittersRepository _repository;

  SaveLitterUsecase({required SavedLittersRepository repository})
      : _repository = repository;

  Future<void> call(LitterDisplayModel litter) => _repository.save(litter);
}
