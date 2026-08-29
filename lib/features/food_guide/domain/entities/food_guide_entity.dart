/// Whether a cat can eat this food.
///
/// [wire] is the value stored on the Firestore document. Unknown values degrade
/// to [caution] — never [safe] — so a typo or a value added server-side ahead of
/// the client can't render as a green light.
enum FoodSafety {
  safe('safe'),
  caution('caution'),
  unsafe('unsafe');

  const FoodSafety(this.wire);

  final String wire;

  static FoodSafety fromWire(String? value) {
    for (final s in FoodSafety.values) {
      if (s.wire == value) return s;
    }
    return FoodSafety.caution;
  }
}

/// One food category in the guide — "Fish", "Dairy", "Dangerous foods".
class FoodGuideEntity {
  final String id;

  /// Canonical **English** copy, like `RecipeEntity.name`. The seed script
  /// supplies translations alongside it; nothing here goes through the ARBs.
  final String name;
  final String description;

  /// The fallback glyph, rendered by [FoodGuideEmoji] wherever [imageUrl] is
  /// absent or fails to load. Never translated.
  final String emoji;

  final FoodSafety safety;

  /// The category photo, hosted at `foodGuide/{id}.jpeg` in Storage. Populated
  /// for every seeded entry today, but still nullable — the Home tile, the list
  /// row and the detail hero all fall back to [emoji] on a tint.
  final String? imageUrl;

  /// The three fact rows, each optional. A dangerous food has no [whyGood] and
  /// no [howToServe]; the detail screen renders only the rows that exist.
  ///
  /// The document stores an empty string for "doesn't apply"; the mapper
  /// normalizes that to null so callers can use a plain null check.
  final String? whyGood;
  final String? howToServe;
  final String? avoid;

  /// Optional closing tip. Canonical English.
  final String? tip;

  const FoodGuideEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.safety,
    this.imageUrl,
    this.whyGood,
    this.howToServe,
    this.avoid,
    this.tip,
  });
}
