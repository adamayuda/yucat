import 'package:yucat/features/product/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<ProductEntity?> fetchProductByBarcode(String barcode);
}
