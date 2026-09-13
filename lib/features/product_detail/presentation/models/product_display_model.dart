import 'package:flutter/material.dart';

class ProductDisplayModel {
  final String name;
  final String brand;
  final int score;
  final int maxScore;
  final String ratingText;
  final ProductRatingColor ratingColor;
  final String? imageUrl;
  final List<String> pros;
  final List<String> cons;
  final double protein;
  final double moisture;
  final double fat;
  final double fiber;
  final double carbs;

  /// Crude ash (minerals), as fed. 0 when not on the label — the grid shows a
  /// dash, and the carbs subtraction already treated it as 0.
  final double ash;
  final bool isAiIdentified;

  /// Canonical **English** text. `cat_product_assessment.dart` keyword-scans
  /// [pros]/[cons]/[name]/[brand] against English needles to build the per-cat
  /// verdict, so these must stay English. Render the `display*` getters instead.
  final String format;
  final String packageSize;
  final String description;

  /// Backend-translated copy for the current app language, when available.
  final String? localizedFormat;
  final String? localizedPackageSize;
  final String? localizedDescription;
  final List<String>? localizedPros;
  final List<String>? localizedCons;

  /// True when no guaranteed analysis could be found for this product (score 0,
  /// all macros missing). Drives a neutral "no info yet" state instead of a
  /// misleading red score-0 "Best to skip this one" verdict.
  final bool dataUnavailable;

  /// Backend record identity — the Algolia objectID and the pack's EAN-13 when
  /// known. ⚠️ Deliberately **not** serialised by the saved-products and
  /// scan-history codecs: a rehydrated row has neither, which is fine because
  /// they exist only to let a fresh scan result be rescued (Phase 2) and for
  /// analytics. Null on every locally-persisted product.
  final String? cacheKey;
  final String? gtin;

  /// `wet` / `dry` / `treat` / `topper` / `supplement`, or null when unknown
  /// (older cached rows, pre-field persisted rows). See [isComplementary].
  final String? foodType;

  /// Ingredients as printed, in order; empty when never found. Canonical text
  /// the rules engine scans — never translated.
  final List<String> ingredients;

  const ProductDisplayModel({
    required this.name,
    required this.brand,
    required this.score,
    required this.maxScore,
    required this.ratingText,
    required this.ratingColor,
    this.imageUrl,
    this.pros = const [],
    this.cons = const [],
    this.protein = 0.0,
    this.moisture = 0.0,
    this.fat = 0.0,
    this.fiber = 0.0,
    this.carbs = 0.0,
    this.ash = 0.0,
    this.isAiIdentified = false,
    this.format = '',
    this.packageSize = '',
    this.description = '',
    this.localizedFormat,
    this.localizedPackageSize,
    this.localizedDescription,
    this.localizedPros,
    this.localizedCons,
    this.dataUnavailable = false,
    this.cacheKey,
    this.gtin,
    this.foodType,
    this.ingredients = const [],
  });

  /// A treat, topper or supplement — something that goes *with* a complete
  /// food, not instead of one. Its 0–100 score means "how good a treat", which
  /// the hero badge and the analysis card say out loud, and which keeps it
  /// out of the "Better for {cat}" list under a complete food (and vice
  /// versa). Unknown food types count as complete so old rows behave as
  /// before.
  bool get isComplementary => switch (foodType) {
        'treat' || 'topper' || 'supplement' => true,
        _ => false,
      };

  // --- Display accessors -------------------------------------------------
  // Always render these, never the canonical fields: they fall back to English
  // whenever a translation is absent.

  String get displayFormat => localizedFormat ?? format;
  String get displayPackageSize => localizedPackageSize ?? packageSize;
  String get displayDescription => localizedDescription ?? description;
  List<String> get displayPros => localizedPros ?? pros;
  List<String> get displayCons => localizedCons ?? cons;

  String get scoreDisplay => '$score/$maxScore';

  /// Metabolizable energy estimate, kcal per 100 g **as fed**, via the
  /// modified Atwater factors (3.5 / 8.5 / 3.5) that AAFCO and FEDIAF use for
  /// pet food — the plain 4 / 9 / 4 human factors overstate pet-food energy by
  /// roughly 10 %. Derived from the displayed macros so it always matches
  /// [carbs]. The rules engine converts it to a dry-matter basis itself.
  double get calories => protein * 3.5 + fat * 8.5 + carbs * 3.5;

  /// `100 / (100 − moisture)`: multiply an as-fed figure by this to get its
  /// dry-matter equivalent. Same clamp the rules engine uses.
  double get dryMatterFactor => 100.0 / (100.0 - moisture.clamp(0.0, 95.0));

  /// Subtitle segment for the hero card: "Wet pâté · 85g pouch", or just one
  /// of them, or empty when neither is set.
  String? get formatLine {
    final parts = [
      displayFormat,
      displayPackageSize,
    ].where((s) => s.isNotEmpty).toList();
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

enum ProductRatingColor { red, yellow, green }

extension ProductRatingColorExtension on ProductRatingColor {
  Color get color {
    switch (this) {
      case ProductRatingColor.red:
        return Colors.red;
      case ProductRatingColor.yellow:
        return Colors.amber;
      case ProductRatingColor.green:
        return Colors.green;
    }
  }
}
