import 'package:equatable/equatable.dart';
import 'package:yucat/features/food_guide/domain/entities/food_guide_entity.dart';

/// What the Home lane tile and the detail screen render.
///
/// Extends [Equatable] because it travels as an auto_route argument. Every
/// field is a scalar, so unlike `RecipeDisplayModel` nothing inside `props`
/// needs a hand-rolled `==`.
class FoodGuideDisplayModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final FoodSafety safety;
  final String? imageUrl;
  final String? whyGood;
  final String? howToServe;
  final String? avoid;
  final String? tip;

  const FoodGuideDisplayModel({
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

  /// True when at least one fact row has copy — the detail screen skips the
  /// whole card otherwise rather than rendering an empty shell.
  bool get hasFacts =>
      whyGood != null || howToServe != null || avoid != null;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        emoji,
        safety,
        imageUrl,
        whyGood,
        howToServe,
        avoid,
        tip,
      ];
}
