import 'package:yucat/features/product/domain/entities/product_entity.dart';

abstract class ProductToDomainMapper {
  /// [localizedText] is the sibling `localizedText` object from the callable
  /// response — the backend's translation of the five renderable fields for the
  /// requested app language. Null on English, on older backends, or when the
  /// translation failed; the entity then carries English only.
  /// [userPhotoFallbackUrl] is the sibling field from the callable response:
  /// a hosted copy of *this user's* scan photo, returned only when the backend
  /// found no product image on the web. It is per-user and never part of the
  /// shared catalog record, so it is applied here rather than server-side.
  ProductEntity call(
    Map<String, dynamic> product, {
    Map<String, dynamic>? localizedText,
    String? userPhotoFallbackUrl,
  });
}

class ProductToDomainMapperImpl extends ProductToDomainMapper {
  @override
  ProductEntity call(
    Map<String, dynamic> product, {
    Map<String, dynamic>? localizedText,
    String? userPhotoFallbackUrl,
  }) {
    try {
      final pros = product['pros'] != null
          ? List<String>.from(product['pros'].map((e) => e.toString()))
          : <String>[];
      final cons = product['cons'] != null
          ? List<String>.from(product['cons'].map((e) => e.toString()))
          : <String>[];

      final l = localizedText;
      List<String>? localizedList(String key) {
        final raw = l?[key];
        if (raw is! List) return null;
        return List<String>.from(raw.map((e) => e.toString()));
      }

      String? localizedString(String key) {
        final raw = l?[key];
        if (raw == null) return null;
        final value = raw.toString();
        return value.isEmpty ? null : value;
      }

      // Extract values from correct JSON paths
      return ProductEntity(
        name: product['name']?.toString() ?? '',
        brand: product['brand']?.toString() ?? '',
        score: _parseDouble(product['score']).toInt(),
        // Backend leaves this empty when neither the analyze step nor SerpAPI
        // produced a usable image; fall back to the user's own scan photo.
        imageUrl: _resolveImageUrl(
          product['imageUrl']?.toString(),
          userPhotoFallbackUrl,
        ),
        protein: _parseDouble(product['protein']),
        fat: _parseDouble(product['fat']),
        carbs: _parseDouble(product['carbs']),
        ash: _parseDouble(product['ash']),
        fiber: _parseDouble(product['fiber']),
        moisture: _parseDouble(product['moisture']),
        pros: pros,
        cons: cons,
        isAiIdentified: product['isAiIdentified'] == true,
        format: product['format']?.toString() ?? '',
        packageSize: product['packageSize']?.toString() ?? '',
        description: product['description']?.toString() ?? '',
        localizedFormat: localizedString('format'),
        localizedPackageSize: localizedString('packageSize'),
        localizedDescription: localizedString('description'),
        localizedPros: localizedList('pros'),
        localizedCons: localizedList('cons'),
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

  String _resolveImageUrl(String? imageUrl, String? userPhotoFallbackUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) return imageUrl;
    return userPhotoFallbackUrl ?? '';
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
