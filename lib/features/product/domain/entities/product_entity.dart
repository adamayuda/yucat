class ProductEntity {
  final String name;
  final String brand;
  final int score;
  final String imageUrl;
  final double protein;
  final double fat;
  final double carbs;
  final double fiber;
  final double moisture;
  final double ash;
  final List<String> pros;
  final List<String> cons;

  const ProductEntity({
    required this.name,
    required this.brand,
    required this.score,
    required this.imageUrl,
    this.protein = 0.0,
    this.fat = 0.0,
    this.carbs = 0.0,
    this.fiber = 0.0,
    this.moisture = 0.0,
    this.ash = 0.0,
    this.pros = const [],
    this.cons = const [],
  });
}
