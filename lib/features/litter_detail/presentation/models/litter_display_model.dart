import 'package:yucat/features/litter/domain/entities/litter_entity.dart';
// ProductRatingColor is the shared score-ring palette, not a food-specific
// concept — reused here so a litter score ring reads identically to a food one.
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';

class LitterDisplayModel {
  final String name;
  final String brand;
  final int score;
  final int maxScore;
  final String ratingText;
  final ProductRatingColor ratingColor;
  final String? imageUrl;

  final LitterMaterial material;
  final LitterTristate clumping;
  final LitterLevel dustLevel;
  final LitterTristate scented;
  final LitterLevel trackingLevel;
  final LitterLevel odorControl;
  final LitterTristate flushable;
  final LitterTristate biodegradable;
  final List<String> additives;

  /// Canonical **English** copy. Render the `display*` getters instead — they
  /// fall back to English whenever a translation is absent.
  final List<String> pros;
  final List<String> cons;
  final String format;
  final String packageSize;
  final String description;

  final String? localizedFormat;
  final String? localizedPackageSize;
  final String? localizedDescription;
  final List<String>? localizedPros;
  final List<String>? localizedCons;

  final bool isAiIdentified;

  /// True when the backend could not establish anything about this litter
  /// (score 0). Drives a neutral "no info yet" state instead of a misleading
  /// red score-0 verdict — the same contract as `ProductDisplayModel`.
  final bool dataUnavailable;

  const LitterDisplayModel({
    required this.name,
    required this.brand,
    required this.score,
    required this.maxScore,
    required this.ratingText,
    required this.ratingColor,
    this.imageUrl,
    this.material = LitterMaterial.other,
    this.clumping = LitterTristate.unknown,
    this.dustLevel = LitterLevel.unknown,
    this.scented = LitterTristate.unknown,
    this.trackingLevel = LitterLevel.unknown,
    this.odorControl = LitterLevel.unknown,
    this.flushable = LitterTristate.unknown,
    this.biodegradable = LitterTristate.unknown,
    this.additives = const [],
    this.pros = const [],
    this.cons = const [],
    this.format = '',
    this.packageSize = '',
    this.description = '',
    this.localizedFormat,
    this.localizedPackageSize,
    this.localizedDescription,
    this.localizedPros,
    this.localizedCons,
    this.isAiIdentified = false,
    this.dataUnavailable = false,
  });

  // --- Display accessors -------------------------------------------------

  String get displayFormat => localizedFormat ?? format;
  String get displayPackageSize => localizedPackageSize ?? packageSize;
  String get displayDescription => localizedDescription ?? description;
  List<String> get displayPros => localizedPros ?? pros;
  List<String> get displayCons => localizedCons ?? cons;

  String get scoreDisplay => '$score/$maxScore';

  /// Subtitle segment for the hero card: "Clumping clay · 10 L bag", or just
  /// one of them, or null when neither is set.
  String? get formatLine {
    final parts = [
      displayFormat,
      displayPackageSize,
    ].where((s) => s.isNotEmpty).toList();
    return parts.isEmpty ? null : parts.join(' · ');
  }
}
