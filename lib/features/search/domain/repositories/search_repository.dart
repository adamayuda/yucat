import 'package:yucat/features/product_detail/domain/entities/product_entity.dart';

abstract class SearchRepository {
  Future<ProductEntity?> searchByBarcode(String barcode);
  Future<List<ProductEntity>> searchByQuery(String query);
}
