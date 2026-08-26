/// What an article is about.
///
/// [wire] is the value stored on the Firestore document. Unknown values degrade
/// to [other] rather than throwing, so a category added server-side ahead of a
/// client release shows up in "All" instead of crashing.
enum ArticleCategory {
  nutrition('nutrition'),
  health('health'),
  behaviour('behaviour'),
  other('other');

  const ArticleCategory(this.wire);

  final String wire;

  static ArticleCategory fromWire(String? value) {
    for (final c in ArticleCategory.values) {
      if (c.wire == value) return c;
    }
    return ArticleCategory.other;
  }

  /// The categories offered as filter chips, in display order. [other] is a
  /// fallback bucket, never a chip — same rule as `RecipeCategory.filterable`.
  static const List<ArticleCategory> filterable = [
    ArticleCategory.nutrition,
    ArticleCategory.health,
    ArticleCategory.behaviour,
  ];
}

/// One editorial article — "Why do cats drink so little?".
class ArticleEntity {
  final String id;

  /// Canonical **English** copy, like `RecipeEntity.name`. The seed script
  /// supplies translations alongside it; nothing here goes through the ARBs.
  final String title;

  /// The one-sentence summary the Home card renders.
  ///
  /// A real field rather than a clipped [body] paragraph: the card wants a
  /// short complete sentence, and truncating prose at a character count cuts
  /// mid-word.
  final String excerpt;

  /// The article text, one entry per paragraph, in order. Canonical English.
  final List<String> body;

  final ArticleCategory category;

  /// Authored reading time in minutes, like `RecipeEntity.prepMinutes` — not
  /// derived from word count, so an author can override it.
  final int readMinutes;

  /// Null until a photo is uploaded; the card and the (future) hero render a
  /// tinted placeholder in the meantime.
  final String? imageUrl;

  const ArticleEntity({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.category,
    required this.readMinutes,
    this.body = const [],
    this.imageUrl,
  });
}
