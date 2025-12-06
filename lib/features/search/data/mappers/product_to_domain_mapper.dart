import 'package:yucat/features/product_detail/domain/entities/product_entity.dart';

abstract class ProductToDomainMapper {
  ProductEntity call(Map<String, dynamic> hit);
}

class ProductToDomainMapperImpl extends ProductToDomainMapper {
  @override
  ProductEntity call(Map<String, dynamic> hit) {
    try {
      // Extract score from nested structure (score.overall) or direct value
      final scoreValue = hit['score'];
      final int score;
      if (scoreValue is Map) {
        score = _parseInt(scoreValue['overall'], 0);
      } else {
        score = _parseInt(scoreValue, 0);
      }

      // Extract nutritional info from nested structure
      final nutritionalInfo = hit['nutritionalInfo'] as Map<String, dynamic>?;

      // Extract recommendations (pros and cons) from score.recommendations
      final scoreMap = hit['score'] as Map<String, dynamic>?;
      final recommendations =
          scoreMap?['recommendations'] as Map<String, dynamic>?;
      final prosList = recommendations?['pros'] as List<dynamic>?;
      final consList = recommendations?['cons'] as List<dynamic>?;
      final pros = prosList?.map((e) => e.toString()).toList() ?? [];
      final cons = consList?.map((e) => e.toString()).toList() ?? [];

      // Extract values from correct JSON paths
      return ProductEntity(
        name: hit['name']?.toString() ?? '',
        brand: hit['brand']?.toString() ?? '',
        score: score,
        imageUrl: _getImageUrl(hit['images']?['product']),
        proteins: _getDoubleValue(nutritionalInfo?['protein']) ?? 0,
        fats: _getDoubleValue(nutritionalInfo?['fat']) ?? 0,
        carbs: _getDoubleValue(nutritionalInfo?['carbs']) ?? 0,
        ash: _getDoubleValue(nutritionalInfo?['ash']) ?? 0,
        healthScore: _getIntValue(hit['healthScore']) ?? 0,
        fiber: _getDoubleValue(nutritionalInfo?['fiber']) ?? 0,
        moisture: _getDoubleValue(nutritionalInfo?['moisture']) ?? 0,
        caloriesPer100g: _getDoubleValue(nutritionalInfo?['calories']) ?? 0,
        pros: pros,
        cons: cons,
      );
    } catch (e) {
      // Return a default entity if mapping fails to prevent app crash
      return ProductEntity(
        name: hit['name']?.toString() ?? 'Unknown Product',
        brand: hit['brand']?.toString() ?? 'Unknown Brand',
        score: 0,
        pros: const [],
        cons: const [],
      );
    }
  }

  int? _getIntValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  double? _getDoubleValue(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  int _parseInt(dynamic value, [int? defaultValue]) {
    if (value == null) return defaultValue ?? 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue ?? 0;
    return defaultValue ?? 0;
  }

  String? _getImageUrl(dynamic value) {
    if (value == null) return null;
    final url = value.toString().trim();
    return url.isEmpty ? null : url;
  }
}
