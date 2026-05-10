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
  final bool isAiIdentified;
  final String format;
  final String packageSize;
  final String description;

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
    this.isAiIdentified = false,
    this.format = '',
    this.packageSize = '',
    this.description = '',
  });
}
