import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/saved_products/domain/repositories/saved_products_repository.dart';

class IsProductSavedUsecase {
  final SavedProductsRepository _repository;

  IsProductSavedUsecase({required SavedProductsRepository repository})
      : _repository = repository;

  Future<bool> call(ProductDisplayModel product) =>
      _repository.isSaved(product);
}
