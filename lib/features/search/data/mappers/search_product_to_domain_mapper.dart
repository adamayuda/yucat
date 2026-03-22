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
        score: _parseDouble(hit['score']).toInt(),
        imageUrl: hit['imageUrl']?.toString() ?? '',
        protein: _parseDouble(hit['protein']),
        fat: _parseDouble(hit['fat']),
        carbs: _parseDouble(hit['carbs']),
        ash: _parseDouble(hit['ash']),
        fiber: _parseDouble(hit['fiber']),
        moisture: _parseDouble(hit['moisture']),
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

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
