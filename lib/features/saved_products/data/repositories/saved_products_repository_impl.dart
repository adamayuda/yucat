import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/saved_products/domain/repositories/saved_products_repository.dart';

const _storageKey = 'saved_products_v1';

class SavedProductsRepositoryImpl implements SavedProductsRepository {
  final SharedPreferences _prefs;

  SavedProductsRepositoryImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  @override
  Future<List<ProductDisplayModel>> getAll() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(_fromJson).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<bool> isSaved(ProductDisplayModel product) async {
    final all = await getAll();
    final key = _identityKey(product);
    return all.any((p) => _identityKey(p) == key);
  }

  @override
  Future<void> save(ProductDisplayModel product) async {
    final all = await getAll();
    final key = _identityKey(product);
    if (all.any((p) => _identityKey(p) == key)) return;
    final next = [product, ...all];
    await _persist(next);
  }

  @override
  Future<void> unsave(ProductDisplayModel product) async {
    final all = await getAll();
    final key = _identityKey(product);
    final next = all.where((p) => _identityKey(p) != key).toList();
    await _persist(next);
  }

  Future<void> _persist(List<ProductDisplayModel> products) async {
    final encoded = jsonEncode(products.map(_toJson).toList());
    await _prefs.setString(_storageKey, encoded);
  }

  String _identityKey(ProductDisplayModel p) =>
      '${p.brand.trim().toLowerCase()}__${p.name.trim().toLowerCase()}';

  Map<String, dynamic> _toJson(ProductDisplayModel p) => {
        'name': p.name,
        'brand': p.brand,
        'score': p.score,
        'maxScore': p.maxScore,
        'ratingText': p.ratingText,
        'ratingColor': p.ratingColor.index,
        'imageUrl': p.imageUrl,
        'pros': p.pros,
        'cons': p.cons,
        'protein': p.protein,
        'moisture': p.moisture,
        'fat': p.fat,
        'fiber': p.fiber,
        'carbs': p.carbs,
        'isAiIdentified': p.isAiIdentified,
        'format': p.format,
        'packageSize': p.packageSize,
        'description': p.description,
      };

  ProductDisplayModel _fromJson(Map<String, dynamic> j) => ProductDisplayModel(
        name: j['name'] as String? ?? '',
        brand: j['brand'] as String? ?? '',
        score: (j['score'] as num?)?.toInt() ?? 0,
        maxScore: (j['maxScore'] as num?)?.toInt() ?? 100,
        ratingText: j['ratingText'] as String? ?? '',
        ratingColor: _decodeRatingColor(j['ratingColor']),
        imageUrl: j['imageUrl'] as String?,
        pros: (j['pros'] as List?)?.cast<String>() ?? const [],
        cons: (j['cons'] as List?)?.cast<String>() ?? const [],
        protein: (j['protein'] as num?)?.toDouble() ?? 0.0,
        moisture: (j['moisture'] as num?)?.toDouble() ?? 0.0,
        fat: (j['fat'] as num?)?.toDouble() ?? 0.0,
        fiber: (j['fiber'] as num?)?.toDouble() ?? 0.0,
        carbs: (j['carbs'] as num?)?.toDouble() ?? 0.0,
        isAiIdentified: j['isAiIdentified'] == true,
        format: j['format'] as String? ?? '',
        packageSize: j['packageSize'] as String? ?? '',
        description: j['description'] as String? ?? '',
      );

  ProductRatingColor _decodeRatingColor(dynamic value) {
    final i = (value as num?)?.toInt() ?? 0;
    if (i < 0 || i >= ProductRatingColor.values.length) {
      return ProductRatingColor.red;
    }
    return ProductRatingColor.values[i];
  }
}
