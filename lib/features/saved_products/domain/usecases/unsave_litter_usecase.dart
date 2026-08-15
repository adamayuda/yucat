import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/saved_products/domain/repositories/saved_litters_repository.dart';

class UnsaveLitterUsecase {
  final SavedLittersRepository _repository;

  UnsaveLitterUsecase({required SavedLittersRepository repository})
      : _repository = repository;

  Future<void> call(LitterDisplayModel litter) => _repository.unsave(litter);
}
