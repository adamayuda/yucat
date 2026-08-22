/// What kind of treat a recipe makes.
///
/// [wire] mirrors the value the backend will send once recipes are served
/// remotely; unknown values degrade to [other] rather than throwing.
enum RecipeCategory {
  biscuits('biscuits'),
  cakes('cakes'),
  frozenTreats('frozen-treats'),
  other('other');

  const RecipeCategory(this.wire);

  final String wire;

  static RecipeCategory fromWire(String? value) {
    for (final c in RecipeCategory.values) {
      if (c.wire == value) return c;
    }
    return RecipeCategory.other;
  }

  /// The categories offered as filters, in display order. [other] is a
  /// fallback bucket, never a chip.
  static const List<RecipeCategory> filterable = [
    RecipeCategory.biscuits,
    RecipeCategory.cakes,
    RecipeCategory.frozenTreats,
  ];
}

/// How much work the recipe is. Unknown values degrade to [medium] — a neutral
/// claim is safer than promising "easy".
enum RecipeDifficulty {
  easy('easy'),
  medium('medium'),
  hard('hard');

  const RecipeDifficulty(this.wire);

  final String wire;

  static RecipeDifficulty fromWire(String? value) {
    for (final d in RecipeDifficulty.values) {
      if (d.wire == value) return d;
    }
    return RecipeDifficulty.medium;
  }
}

/// Whether the recipe suits the user's cat.
///
/// Seeded per recipe today; the backend will compute it per cat later. Unknown
/// values degrade to [caution] so a bad match never reads as a green light.
enum RecipeCompatibility {
  compatible('compatible'),
  caution('caution'),
  incompatible('incompatible');

  const RecipeCompatibility(this.wire);

  final String wire;

  static RecipeCompatibility fromWire(String? value) {
    for (final c in RecipeCompatibility.values) {
      if (c.wire == value) return c;
    }
    return RecipeCompatibility.caution;
  }
}

/// One line of a recipe's ingredient list.
class RecipeIngredient {
  /// Canonical **English**, like the rest of a recipe's copy.
  final String name;

  /// A display string ("80 g", "1 tbsp", "a pinch") rather than an amount plus
  /// a unit enum — real quantities aren't all numeric, and the backend will
  /// translate the whole phrase alongside [name].
  final String quantity;

  const RecipeIngredient({required this.name, required this.quantity});

  // Value equality by hand: entities in this codebase don't extend Equatable,
  // but this type ends up inside RecipeDisplayModel.props, where identity
  // comparison would report two structurally identical lists as different.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeIngredient &&
          other.name == name &&
          other.quantity == quantity;

  @override
  int get hashCode => Object.hash(name, quantity);
}

/// A home-made cat treat recipe.
class RecipeEntity {
  final String id;

  /// Canonical **English** copy, like `ProductEntity.name`/`description`. The
  /// backend will supply translations alongside it; nothing here goes through
  /// the ARB files.
  final String name;
  final String description;

  final RecipeCategory category;

  /// Hands-on time. Combined with [requiresFreezing] for the display line.
  final int prepMinutes;

  /// True when the recipe needs freezing time on top of [prepMinutes] — the
  /// meta line then reads "5 min + freezing" rather than a misleading total.
  final bool requiresFreezing;

  final RecipeDifficulty difficulty;
  final RecipeCompatibility compatibility;

  /// Null until the backend hosts recipe photos; the card and the detail hero
  /// render a tinted placeholder in the meantime.
  final String? imageUrl;

  /// Ingredient list, in the order it should be read. Canonical English.
  final List<RecipeIngredient> ingredients;

  /// Preparation steps, in order. The detail screen numbers them from 1, so
  /// they must not carry their own numbering. Canonical English.
  final List<String> steps;

  /// Optional closing tip. Canonical English.
  final String? tip;

  const RecipeEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.prepMinutes,
    required this.difficulty,
    required this.compatibility,
    this.requiresFreezing = false,
    this.imageUrl,
    this.ingredients = const [],
    this.steps = const [],
    this.tip,
  });
}
