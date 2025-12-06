class ProductEntity {
  final String name;
  final String brand;
  final int score;
  final String? imageUrl;
  final double proteins;
  final double fats;
  final double carbs;
  final double ash;
  final double fiber;
  final double moisture;
  final int healthScore;
  final List<String> pros;
  final List<String> cons;
  final double caloriesPer100g;

  const ProductEntity({
    required this.name,
    required this.brand,
    required this.score,
    this.imageUrl,
    this.proteins = 0,
    this.fats = 0,
    this.carbs = 0,
    this.ash = 0,
    this.healthScore = 0,
    this.fiber = 0,
    this.moisture = 0,
    this.pros = const [],
    this.cons = const [],
    this.caloriesPer100g = 0,
  });
}
