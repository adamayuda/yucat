import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yucat/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yucat/presentation/utils/supported_language.dart';

abstract class RecipeDocumentMapper {
  /// Maps a `recipes` document, rendering it in [language] where a translation
  /// exists and falling back to the canonical English otherwise.
  RecipeEntity call(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String? language,
  );
}

class RecipeDocumentMapperImpl implements RecipeDocumentMapper {
  const RecipeDocumentMapperImpl();

  @override
  RecipeEntity call(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String? language,
  ) {
    final data = doc.data();

    // `translations` never holds an "en" key — English is the flat fields.
    final lang = normalizeLanguage(language);
    final translations = data['translations'];
    final localized = (lang == null || lang == kCanonicalLanguage)
        ? null
        : (translations is Map<String, dynamic>
            ? translations[lang] as Map<String, dynamic>?
            : null);

    // Resolve field by field rather than picking one map wholesale, so a
    // partially-translated document still degrades per field instead of
    // dropping back to English entirely.
    String text(String key, String fallback) {
      final value = localized?[key];
      if (value is String && value.isNotEmpty) return value;
      final canonical = data[key];
      return canonical is String ? canonical : fallback;
    }

    return RecipeEntity(
      id: doc.id,
      name: text('name', ''),
      description: text('description', ''),
      category: RecipeCategory.fromWire(data['category'] as String?),
      prepMinutes: (data['prepMinutes'] as num?)?.toInt() ?? 0,
      requiresFreezing: data['requiresFreezing'] as bool? ?? false,
      difficulty: RecipeDifficulty.fromWire(data['difficulty'] as String?),
      compatibility:
          RecipeCompatibility.fromWire(data['compatibility'] as String?),
      imageUrl: data['imageUrl'] as String?,
      ingredients: _ingredients(
        localized?['ingredients'] ?? data['ingredients'],
      ),
      steps: _steps(localized?['steps'] ?? data['steps']),
      tip: _tip(text('tip', '')),
    );
  }

  /// Ingredients and steps are taken as a whole list, not merged field by
  /// field: the translation is guaranteed same-length and same-order by the
  /// backend's count guard, and interleaving two languages would be worse than
  /// showing one consistently.
  static List<RecipeIngredient> _ingredients(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => RecipeIngredient(
            name: item['name'] as String? ?? '',
            quantity: item['quantity'] as String? ?? '',
          ),
        )
        .toList();
  }

  static List<String> _steps(Object? raw) {
    if (raw is! List) return const [];
    return raw.whereType<String>().toList();
  }

  static String? _tip(String value) => value.isEmpty ? null : value;
}
