import 'package:yucat/features/litter/domain/entities/litter_entity.dart';
import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';

/// The single JSON codec for a persisted [LitterDisplayModel].
///
/// Deliberately shared by both litter stores (saved litters and litter history)
/// rather than hand-rolled in each. The food equivalents each carry their own
/// copy of an 18-field codec, which is why adding a product field means editing
/// two unrelated features — and why `dataUnavailable` went unpersisted in both
/// for so long. One codec, one place to change.
///
/// Enums are stored by their stable [LitterMaterial.wire] string, never by
/// index: reordering an enum must not silently reinterpret saved rows.
Map<String, dynamic> litterToJson(LitterDisplayModel l) => {
      'name': l.name,
      'brand': l.brand,
      'score': l.score,
      'maxScore': l.maxScore,
      'ratingText': l.ratingText,
      'ratingColor': l.ratingColor.index,
      'imageUrl': l.imageUrl,
      'material': l.material.wire,
      'clumping': l.clumping.wire,
      'dustLevel': l.dustLevel.wire,
      'scented': l.scented.wire,
      'trackingLevel': l.trackingLevel.wire,
      'odorControl': l.odorControl.wire,
      'flushable': l.flushable.wire,
      'biodegradable': l.biodegradable.wire,
      'additives': l.additives,
      'pros': l.pros,
      'cons': l.cons,
      'format': l.format,
      'packageSize': l.packageSize,
      'description': l.description,
      // Translated copy, so a saved entry keeps rendering in the language it was
      // fetched in rather than silently reverting to English.
      'localizedFormat': l.localizedFormat,
      'localizedPackageSize': l.localizedPackageSize,
      'localizedDescription': l.localizedDescription,
      'localizedPros': l.localizedPros,
      'localizedCons': l.localizedCons,
      'isAiIdentified': l.isAiIdentified,
      'dataUnavailable': l.dataUnavailable,
    };

LitterDisplayModel litterFromJson(Map<String, dynamic> j) => LitterDisplayModel(
      name: j['name'] as String? ?? '',
      brand: j['brand'] as String? ?? '',
      score: (j['score'] as num?)?.toInt() ?? 0,
      maxScore: (j['maxScore'] as num?)?.toInt() ?? 100,
      ratingText: j['ratingText'] as String? ?? '',
      ratingColor: _decodeRatingColor(j['ratingColor']),
      imageUrl: j['imageUrl'] as String?,
      material: LitterMaterial.fromWire(j['material'] as String?),
      clumping: LitterTristate.fromWire(j['clumping'] as String?),
      dustLevel: LitterLevel.fromWire(j['dustLevel'] as String?),
      scented: LitterTristate.fromWire(j['scented'] as String?),
      trackingLevel: LitterLevel.fromWire(j['trackingLevel'] as String?),
      odorControl: LitterLevel.fromWire(j['odorControl'] as String?),
      flushable: LitterTristate.fromWire(j['flushable'] as String?),
      biodegradable: LitterTristate.fromWire(j['biodegradable'] as String?),
      additives: (j['additives'] as List?)?.cast<String>() ?? const [],
      pros: (j['pros'] as List?)?.cast<String>() ?? const [],
      cons: (j['cons'] as List?)?.cast<String>() ?? const [],
      format: j['format'] as String? ?? '',
      packageSize: j['packageSize'] as String? ?? '',
      description: j['description'] as String? ?? '',
      localizedFormat: j['localizedFormat'] as String?,
      localizedPackageSize: j['localizedPackageSize'] as String?,
      localizedDescription: j['localizedDescription'] as String?,
      localizedPros: (j['localizedPros'] as List?)?.cast<String>(),
      localizedCons: (j['localizedCons'] as List?)?.cast<String>(),
      isAiIdentified: j['isAiIdentified'] == true,
      dataUnavailable: j['dataUnavailable'] == true,
    );

/// Identity for dedupe and save/unsave — same `${brand}__${name}` convention as
/// the food stores, in its own key space (litter lives in separate stores).
String litterIdentityKey(LitterDisplayModel l) =>
    '${l.brand.trim().toLowerCase()}__${l.name.trim().toLowerCase()}';

ProductRatingColor _decodeRatingColor(dynamic value) {
  final i = (value as num?)?.toInt() ?? 0;
  if (i < 0 || i >= ProductRatingColor.values.length) {
    return ProductRatingColor.red;
  }
  return ProductRatingColor.values[i];
}
