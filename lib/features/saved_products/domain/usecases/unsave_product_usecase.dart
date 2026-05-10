import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/saved_products/domain/repositories/saved_products_repository.dart';

class UnsaveProductUsecase {
  final SavedProductsRepository _repository;

  UnsaveProductUsecase({required SavedProductsRepository repository})
      : _repository = repository;

  Future<void> call(ProductDisplayModel product) =>
      _repository.unsave(product);
}
