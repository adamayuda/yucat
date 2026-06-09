import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';

abstract class ScanHistoryRepository {
  Future<List<ProductDisplayModel>> getAll();
  Future<void> add(ProductDisplayModel product);
  Future<void> clear();
}
