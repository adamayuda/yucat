import 'package:yucat/features/product/domain/entities/product_entity.dart';

abstract class SearchProductToDomainMapper {
  ProductEntity call(Map<String, dynamic> hit);
}

class SearchProductToDomainMapperImpl extends SearchProductToDomainMapper {
  @override
  ProductEntity call(Map<String, dynamic> hit) {
    try {
      final pros = hit['pros'] != null
          ? List<String>.from(hit['pros'].map((e) => e.toString()))
          : <String>[];
      final cons = hit['cons'] != null
          ? List<String>.from(hit['cons'].map((e) => e.toString()))
          : <String>[];

      // Extract values from correct JSON paths
      final product = ProductEntity(
        name: hit['name']?.toString() ?? '',
        brand: hit['brand']?.toString() ?? '',
        score: _parseInt(hit['score'], 0),
        imageUrl: hit['imageUrl']?.toString() ?? '',
        protein: _parseInt(hit['protein'], 0),
        fat: _parseInt(hit['fat'], 0),
        carbs: _parseInt(hit['carbs'], 0),
        ash: _parseInt(hit['ash'], 0),
        fiber: _parseInt(hit['fiber'], 0),
        moisture: _parseInt(hit['moisture'], 0),
        pros: pros,
        cons: cons,
      );
      return product;
    } catch (e) {
      // Return a default entity if mapping fails to prevent app crash
      return ProductEntity(
        name: hit['name']?.toString() ?? 'Unknown Product',
        brand: hit['brand']?.toString() ?? 'Unknown Brand',
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
