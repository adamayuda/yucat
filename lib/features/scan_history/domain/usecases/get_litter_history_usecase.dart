import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/scan_history/domain/repositories/litter_history_repository.dart';

class GetLitterHistoryUsecase {
  final LitterHistoryRepository _repository;

  GetLitterHistoryUsecase({required LitterHistoryRepository repository})
      : _repository = repository;

  Future<List<LitterDisplayModel>> call() => _repository.getAll();
}
