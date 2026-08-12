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

  /// Canonical **English** text. The per-cat rules engine
  /// (`cat_product_assessment.dart`) keyword-scans [pros]/[cons]/[name]/[brand]
  /// against English needles, so these must never hold translated copy — the
  /// localized equivalents live in the `localized*` fields below.
  final List<String> pros;
  final List<String> cons;
  final bool isAiIdentified;
  final String format;
  final String packageSize;
  final String description;

  /// Backend-translated copy for the requested app language, when available.
  /// Null on English, on older cached rows, or when translation failed — in all
  /// of which cases the canonical fields above are displayed instead.
  final String? localizedFormat;
  final String? localizedPackageSize;
  final String? localizedDescription;
  final List<String>? localizedPros;
  final List<String>? localizedCons;

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
    this.localizedFormat,
    this.localizedPackageSize,
    this.localizedDescription,
    this.localizedPros,
    this.localizedCons,
  });
}
