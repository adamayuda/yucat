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
  final int protein;
  final int moisture;
  final int fat;
  final int fiber;
  final int carbs;
  final int calories;

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
    this.protein = 0,
    this.moisture = 0,
    this.fat = 0,
    this.fiber = 0,
    this.carbs = 0,
    this.calories = 0,
  });

  String get scoreDisplay => '$score/$maxScore';
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
