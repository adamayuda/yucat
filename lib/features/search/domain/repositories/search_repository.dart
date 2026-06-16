import 'package:yucat/features/product/domain/entities/product_entity.dart';

abstract class SearchRepository {
  Future<List<ProductEntity>> searchByQuery(String query, {int? hitsPerPage});
  Future<List<ProductEntity>> searchByBrand(String brandName);
}
