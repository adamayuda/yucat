import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/saved_products/domain/repositories/saved_products_repository.dart';

class GetSavedProductsUsecase {
  final SavedProductsRepository _repository;

  GetSavedProductsUsecase({required SavedProductsRepository repository})
      : _repository = repository;

  Future<List<ProductDisplayModel>> call() => _repository.getAll();
}
