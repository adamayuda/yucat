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
  final String format;
  final String packageSize;
  final String description;

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
  });

  String get scoreDisplay => '$score/$maxScore';

  /// Metabolizable energy estimate (kcal / 100g) via the Atwater factors,
  /// derived from the displayed macros so it always matches [carbs].
  double get calories => protein * 4 + fat * 9 + carbs * 4;

  /// Subtitle segment for the hero card: "Wet pâté · 85g pouch", or just one
  /// of them, or empty when neither is set.
  String? get formatLine {
    final parts = [format, packageSize].where((s) => s.isNotEmpty).toList();
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
