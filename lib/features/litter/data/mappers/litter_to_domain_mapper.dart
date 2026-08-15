import 'package:yucat/features/litter/domain/entities/litter_entity.dart';

abstract class LitterToDomainMapper {
  /// [localizedText] is the callable response's `litterLocalizedText` object —
  /// the backend's translation of the five renderable fields for the requested
  /// app language. Null on English, on older backends, or when translation
  /// failed; the entity then carries English only.
  ///
  /// [userPhotoFallbackUrl] is the sibling response field: a hosted copy of
  /// *this user's* scan photo, returned only when no product image was found on
  /// the web. Per-user and never part of the shared catalog record, so it is
  /// applied here rather than server-side.
  LitterEntity call(
    Map<String, dynamic> litter, {
    Map<String, dynamic>? localizedText,
    String? userPhotoFallbackUrl,
  });
}

class LitterToDomainMapperImpl extends LitterToDomainMapper {
  @override
  LitterEntity call(
    Map<String, dynamic> litter, {
    Map<String, dynamic>? localizedText,
    String? userPhotoFallbackUrl,
  }) {
    try {
      final l = localizedText;

      List<String> stringList(dynamic raw) {
        if (raw is! List) return const [];
        return raw.map((e) => e.toString()).toList();
      }

      List<String>? localizedList(String key) {
        final raw = l?[key];
        if (raw is! List) return null;
        return raw.map((e) => e.toString()).toList();
      }

      String? localizedString(String key) {
        final raw = l?[key];
        if (raw == null) return null;
        final value = raw.toString();
        return value.isEmpty ? null : value;
      }

      return LitterEntity(
        name: litter['name']?.toString() ?? '',
        brand: litter['brand']?.toString() ?? '',
        score: _parseInt(litter['score']),
        imageUrl: _resolveImageUrl(
          litter['imageUrl']?.toString(),
          userPhotoFallbackUrl,
        ),
        material: LitterMaterial.fromWire(litter['material']?.toString()),
        clumping: LitterTristate.fromWire(litter['clumping']?.toString()),
        dustLevel: LitterLevel.fromWire(litter['dustLevel']?.toString()),
        scented: LitterTristate.fromWire(litter['scented']?.toString()),
        trackingLevel: LitterLevel.fromWire(litter['trackingLevel']?.toString()),
        odorControl: LitterLevel.fromWire(litter['odorControl']?.toString()),
        flushable: LitterTristate.fromWire(litter['flushable']?.toString()),
        biodegradable:
            LitterTristate.fromWire(litter['biodegradable']?.toString()),
        additives: stringList(litter['additives']),
        pros: stringList(litter['pros']),
        cons: stringList(litter['cons']),
        format: litter['format']?.toString() ?? '',
        packageSize: litter['packageSize']?.toString() ?? '',
        description: litter['description']?.toString() ?? '',
        localizedFormat: localizedString('format'),
        localizedPackageSize: localizedString('packageSize'),
        localizedDescription: localizedString('description'),
        localizedPros: localizedList('pros'),
        localizedCons: localizedList('cons'),
        isAiIdentified: litter['isAiIdentified'] == true,
      );
    } catch (_) {
      // Degrade to a name-only entity rather than crashing the scan, matching
      // the product mapper. Score 0 puts it in the neutral "no data" state.
      return LitterEntity(
        name: litter['name']?.toString() ?? '',
        brand: litter['brand']?.toString() ?? '',
        score: 0,
        imageUrl: userPhotoFallbackUrl ?? '',
      );
    }
  }

  String _resolveImageUrl(String? imageUrl, String? userPhotoFallbackUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) return imageUrl;
    return userPhotoFallbackUrl ?? '';
  }

  int _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
