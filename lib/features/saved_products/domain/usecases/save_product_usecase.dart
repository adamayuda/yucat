import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/saved_products/domain/repositories/saved_products_repository.dart';

class SaveProductUsecase {
  final SavedProductsRepository _repository;

  SaveProductUsecase({required SavedProductsRepository repository})
      : _repository = repository;

  Future<void> call(ProductDisplayModel product) => _repository.save(product);
}
