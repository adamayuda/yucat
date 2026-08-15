import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/scan_history/domain/repositories/litter_history_repository.dart';

class AddLitterToHistoryUsecase {
  final LitterHistoryRepository _repository;

  AddLitterToHistoryUsecase({required LitterHistoryRepository repository})
      : _repository = repository;

  Future<void> call(LitterDisplayModel litter) => _repository.add(litter);
}
