import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yucat/features/food_guide/domain/entities/food_guide_entity.dart';
import 'package:yucat/presentation/utils/supported_language.dart';

abstract class FoodGuideDocumentMapper {
  /// Maps a `foodGuide` document, rendering it in [language] where a
  /// translation exists and falling back to the canonical English otherwise.
  FoodGuideEntity call(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String? language,
  );
}

class FoodGuideDocumentMapperImpl implements FoodGuideDocumentMapper {
  const FoodGuideDocumentMapperImpl();

  @override
  FoodGuideEntity call(
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
    // dropping back to English entirely. Every translatable field here is a
    // scalar, so there is no list branch as there is for recipes.
    String text(String key) {
      final value = localized?[key];
      if (value is String && value.isNotEmpty) return value;
      final canonical = data[key];
      return canonical is String ? canonical : '';
    }

    // An empty string on the document means "this row doesn't apply" — that is
    // how a dangerous food drops its `whyGood` and `howToServe` rows.
    String? optional(String key) {
      final value = text(key);
      return value.isEmpty ? null : value;
    }

    return FoodGuideEntity(
      id: doc.id,
      name: text('name'),
      description: text('description'),
      emoji: data['emoji'] as String? ?? '',
      safety: FoodSafety.fromWire(data['safety'] as String?),
      imageUrl: data['imageUrl'] as String?,
      whyGood: optional('whyGood'),
      howToServe: optional('howToServe'),
      avoid: optional('avoid'),
      tip: optional('tip'),
    );
  }
}
