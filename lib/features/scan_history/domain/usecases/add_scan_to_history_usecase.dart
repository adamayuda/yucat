import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/scan_history/domain/repositories/scan_history_repository.dart';

class AddScanToHistoryUsecase {
  final ScanHistoryRepository _repository;

  AddScanToHistoryUsecase({required ScanHistoryRepository repository})
      : _repository = repository;

  Future<void> call(ProductDisplayModel product) => _repository.add(product);
}
