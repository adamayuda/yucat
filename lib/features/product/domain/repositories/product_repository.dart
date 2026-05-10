import 'package:yucat/features/product/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<ProductEntity?> fetchProductByImage({
    required String imageBase64,
    required String mimeType,
  });
}
