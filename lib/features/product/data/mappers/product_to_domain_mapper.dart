import 'package:yucat/features/product/domain/entities/product_entity.dart';

abstract class ProductToDomainMapper {
  ProductEntity call(Map<String, dynamic> product);
}

class ProductToDomainMapperImpl extends ProductToDomainMapper {
  @override
  ProductEntity call(Map<String, dynamic> product) {
    try {
      final pros = product['pros'] != null
          ? List<String>.from(product['pros'].map((e) => e.toString()))
          : <String>[];
      final cons = product['cons'] != null
          ? List<String>.from(product['cons'].map((e) => e.toString()))
          : <String>[];

      // Extract values from correct JSON paths
      return ProductEntity(
        name: product['name']?.toString() ?? '',
        brand: product['brand']?.toString() ?? '',
        score: _parseInt(product['score'], 0),
        imageUrl: product['imageUrl']?.toString() ?? '',
        protein: _parseInt(product['protein'], 0),
        fat: _parseInt(product['fat'], 0),
        carbs: _parseInt(product['carbs'], 0),
        ash: _parseInt(product['ash'], 0),
        fiber: _parseInt(product['fiber'], 0),
        moisture: _parseInt(product['moisture'], 0),
        pros: pros,
        cons: cons,
      );
    } catch (e) {
      // Return a default entity if mapping fails to prevent app crash
      return ProductEntity(
        name: product['name']?.toString() ?? 'Unknown Product',
        brand: product['brand']?.toString() ?? 'Unknown Brand',
        score: 0,
        imageUrl: '',
        pros: const [],
        cons: const [],
      );
    }
  }

  int _parseInt(dynamic value, [int? defaultValue]) {
    if (value == null) return defaultValue ?? 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue ?? 0;
    return defaultValue ?? 0;
  }
}
