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
  });

  // --- Display accessors -------------------------------------------------
  // Always render these, never the canonical fields: they fall back to English
  // whenever a translation is absent.

  String get displayFormat => localizedFormat ?? format;
  String get displayPackageSize => localizedPackageSize ?? packageSize;
  String get displayDescription => localizedDescription ?? description;
  List<String> get displayPros => localizedPros ?? pros;
  List<String> get displayCons => localizedCons ?? cons;

  String get scoreDisplay => '$score/$maxScore';

  /// Metabolizable energy estimate (kcal / 100g) via the Atwater factors,
  /// derived from the displayed macros so it always matches [carbs].
  double get calories => protein * 4 + fat * 9 + carbs * 4;

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
