import 'package:yucat/features/product/domain/entities/product_entity.dart';
import 'package:yucat/features/product/domain/repositories/product_repository.dart';

class FetchProductByImageUsecase {
  final ProductRepository _productRepository;

  FetchProductByImageUsecase({required ProductRepository productRepository})
    : _productRepository = productRepository;

  Future<ProductEntity?> call({
    required String imageBase64,
    required String mimeType,
  }) async {
    return _productRepository.fetchProductByImage(
      imageBase64: imageBase64,
      mimeType: mimeType,
    );
  }
}
