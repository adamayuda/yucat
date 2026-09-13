/// The allergen catalogue.
///
/// Allergies are recorded on `CatEntity.allergies` as these **stable snake_case
/// keys**, never as free text. That is what makes them usable beyond display: a
/// key can be matched against canonical-English product and recipe text, while
/// the label the owner reads comes from the ARBs. Free text would be
/// unmatchable in five of the app's six locales.
///
/// ⚠️ Keys are persisted to Firestore. Renaming one silently orphans every cat
/// that declared it.
library;

/// Whether an allergen can appear in food at all.
///
/// Environmental allergens are worth recording — they belong in a health record
/// and they matter at the vet — but matching "dust" against an ingredient list
/// would only produce noise, so they carry no needles and are never scanned.
enum CatAllergenKind { food, environmental }

enum CatAllergen {
  chicken('chicken', CatAllergenKind.food, ['chicken', 'poultry']),
  turkey('turkey', CatAllergenKind.food, ['turkey']),
  beef('beef', CatAllergenKind.food, ['beef']),
  lamb('lamb', CatAllergenKind.food, ['lamb', 'mutton']),
  pork('pork', CatAllergenKind.food, ['pork', 'bacon', 'ham']),
  duck('duck', CatAllergenKind.food, ['duck']),

  // ⚠️ `fish` matches inside `fish oil`. That false positive is inherited
  // deliberately from `_kCommonAllergens` in `cat_product_assessment.dart`,
  // which has always matched by plain substring with no word boundary. Fixing
  // it here and not there would make the two disagree on the same product,
  // which is worse than a known, documented over-report on an allergy warning —
  // where over-reporting is the safer direction anyway.
  fish('fish', CatAllergenKind.food, ['fish', 'whitefish', 'haddock', 'cod']),
  salmon('salmon', CatAllergenKind.food, ['salmon']),
  tuna('tuna', CatAllergenKind.food, ['tuna']),
  shellfish('shellfish', CatAllergenKind.food,
      ['shellfish', 'shrimp', 'prawn', 'crab']),

  dairy('dairy', CatAllergenKind.food,
      ['dairy', 'milk', 'cheese', 'lactose', 'yoghurt', 'yogurt', 'cream']),
  egg('egg', CatAllergenKind.food, ['egg']),
  grain('grain', CatAllergenKind.food,
      ['grain', 'wheat', 'gluten', 'corn', 'maize', 'barley']),
  soy('soy', CatAllergenKind.food, ['soy', 'soya']),

  dust('dust', CatAllergenKind.environmental, []),
  pollen('pollen', CatAllergenKind.environmental, []),
  grass('grass', CatAllergenKind.environmental, []),
  mould('mould', CatAllergenKind.environmental, []),
  fleaBite('flea_bite', CatAllergenKind.environmental, []);

  /// Persisted value. ⚠️ Never rename.
  final String key;

  final CatAllergenKind kind;

  /// Lowercase English substrings that indicate this allergen's presence.
  /// Empty for environmental allergens, which are never matched.
  final List<String> needles;

  const CatAllergen(this.key, this.kind, this.needles);

  static CatAllergen? fromKey(String? key) {
    for (final a in CatAllergen.values) {
      if (a.key == key) return a;
    }
    return null;
  }

  static List<CatAllergen> get food =>
      CatAllergen.values.where((a) => a.kind == CatAllergenKind.food).toList();

  static List<CatAllergen> get environmental => CatAllergen.values
      .where((a) => a.kind == CatAllergenKind.environmental)
      .toList();

  /// Resolves persisted keys to catalogue entries, dropping any it no longer
  /// recognises rather than throwing — an old cat may carry a retired key.
  static List<CatAllergen> resolveAll(List<String>? keys) {
    if (keys == null) return const [];
    return keys
        .map(CatAllergen.fromKey)
        .whereType<CatAllergen>()
        .toList(growable: false);
  }
}

/// Which food allergens from the catalogue appear in [text].
///
/// [text] must be **canonical English** and already lowercased — the needles are
/// English, and the whole point of keying allergens is that matching happens
/// against untranslated source text.
Set<String> detectFoodAllergenKeys(String text) {
  final found = <String>{};
  for (final allergen in CatAllergen.values) {
    if (allergen.needles.isEmpty) continue;
    for (final needle in allergen.needles) {
      if (text.contains(needle)) {
        found.add(allergen.key);
        break;
      }
    }
  }
  return found;
}
