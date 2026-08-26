import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yucat/features/articles/domain/entities/article_entity.dart';
import 'package:yucat/presentation/utils/supported_language.dart';

abstract class ArticleDocumentMapper {
  /// Maps an `articles` document, rendering it in [language] where a
  /// translation exists and falling back to the canonical English otherwise.
  ArticleEntity call(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String? language,
  );
}

class ArticleDocumentMapperImpl implements ArticleDocumentMapper {
  const ArticleDocumentMapperImpl();

  @override
  ArticleEntity call(
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

    // Resolve scalars field by field, so a partially-translated document
    // degrades per field instead of dropping back to English entirely.
    String text(String key) {
      final value = localized?[key];
      if (value is String && value.isNotEmpty) return value;
      final canonical = data[key];
      return canonical is String ? canonical : '';
    }

    return ArticleEntity(
      id: doc.id,
      title: text('title'),
      excerpt: text('excerpt'),
      category: ArticleCategory.fromWire(data['category'] as String?),
      readMinutes: (data['readMinutes'] as num?)?.toInt() ?? 0,
      imageUrl: data['imageUrl'] as String?,
      body: _body(localized?['body'] ?? data['body']),
    );
  }

  /// Paragraphs are taken as a whole list, not merged field by field: the
  /// translation is guaranteed same-length and same-order by the backend's
  /// count guard, and interleaving two languages mid-article would be worse
  /// than showing one consistently.
  static List<String> _body(Object? raw) {
    if (raw is! List) return const [];
    return raw.whereType<String>().toList();
  }
}
