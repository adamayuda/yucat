class ProductEntity {
  final String name;
  final String brand;
  final int score;
  final String imageUrl;
  final int protein;
  final int fat;
  final int carbs;
  final int fiber;
  final int moisture;
  final int ash;
  final List<String> pros;
  final List<String> cons;

  const ProductEntity({
    required this.name,
    required this.brand,
    required this.score,
    required this.imageUrl,
    this.protein = 0,
    this.fat = 0,
    this.carbs = 0,
    this.fiber = 0,
    this.moisture = 0,
    this.ash = 0,
    this.pros = const [],
    this.cons = const [],
  });
}
