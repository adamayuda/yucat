import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';

abstract class SavedProductsRepository {
  Future<List<ProductDisplayModel>> getAll();
  Future<bool> isSaved(ProductDisplayModel product);
  Future<void> save(ProductDisplayModel product);
  Future<void> unsave(ProductDisplayModel product);
}
