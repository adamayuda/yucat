import 'package:yucat/features/product/domain/entities/product_entity.dart';
import 'package:yucat/features/product/domain/repositories/product_repository.dart';

class FetchProductByBarcodeUsecase {
  final ProductRepository _productRepository;

  FetchProductByBarcodeUsecase({required ProductRepository productRepository})
    : _productRepository = productRepository;

  Future<ProductEntity?> call({required String barcode}) async {
    return _productRepository.fetchProductByBarcode(barcode);
  }
}
