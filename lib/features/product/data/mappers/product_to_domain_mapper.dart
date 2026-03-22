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
        score: _parseDouble(product['score']).toInt(),
        imageUrl: product['imageUrl']?.toString() ?? '',
        protein: _parseDouble(product['protein']),
        fat: _parseDouble(product['fat']),
        carbs: _parseDouble(product['carbs']),
        ash: _parseDouble(product['ash']),
        fiber: _parseDouble(product['fiber']),
        moisture: _parseDouble(product['moisture']),
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

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
