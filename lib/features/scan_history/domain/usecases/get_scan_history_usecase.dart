import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/scan_history/domain/repositories/scan_history_repository.dart';

class GetScanHistoryUsecase {
  final ScanHistoryRepository _repository;

  GetScanHistoryUsecase({required ScanHistoryRepository repository})
      : _repository = repository;

  Future<List<ProductDisplayModel>> call() => _repository.getAll();
}
