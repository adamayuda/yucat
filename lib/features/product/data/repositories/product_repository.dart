import 'package:flutter/foundation.dart';
import 'package:yucat/features/litter/data/mappers/litter_to_domain_mapper.dart';
import 'package:yucat/features/product/domain/entities/label_target.dart';
import 'package:yucat/features/product/domain/entities/scan_result_entity.dart';
import 'package:yucat/features/product/data/datasources/product_remote_datasource.dart';
import 'package:yucat/features/product/data/mappers/product_to_domain_mapper.dart';
import 'package:yucat/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final RemoteSearchDataSource _remoteDataSource;
  final ProductToDomainMapper _productToDomainMapper;
  final LitterToDomainMapper _litterToDomainMapper;

  ProductRepositoryImpl({
    required RemoteSearchDataSource remoteDataSource,
    required ProductToDomainMapper productToDomainMapper,
    required LitterToDomainMapper litterToDomainMapper,
  }) : _remoteDataSource = remoteDataSource,
       _productToDomainMapper = productToDomainMapper,
       _litterToDomainMapper = litterToDomainMapper;

  @override
  Future<ScanResultEntity> fetchProductByImage({
    required String imageBase64,
    required String mimeType,
    String? countryCode,
    String? locale,
    String? gtin,
  }) async {
    debugPrint('[ProductRepository] Fetching product by image');

    final remoteData = await _remoteDataSource.fetchProductByImage(
      imageBase64: imageBase64,
      mimeType: mimeType,
      countryCode: countryCode,
      locale: locale,
      gtin: gtin,
    );
    return _parseScanResponse(remoteData, sentGtin: gtin);
  }

  @override
  Future<ScanResultEntity> analyzeProductLabel({
    required String imageBase64,
    required String mimeType,
    required LabelTarget target,
    String? countryCode,
    String? locale,
  }) async {
    debugPrint('[ProductRepository] Analyzing product label');

    final remoteData = await _remoteDataSource.analyzeProductLabel(
      imageBase64: imageBase64,
      mimeType: mimeType,
      target: target,
      countryCode: countryCode,
      locale: locale,
    );
    return _parseScanResponse(remoteData, sentGtin: target.gtin);
  }

  /// One parser for both callables: they share the `ScanResponse` wire shape,
  /// and a successful label read is just a food result with `path: 'label'`.
  ScanResultEntity _parseScanResponse(
    Map<String, dynamic>? remoteData, {
    String? sentGtin,
  }) {
    final gtin = sentGtin;
    if (remoteData == null) {
      debugPrint('[ProductRepository] Empty response');
      return const ScanNotIdentified(notCatProduct: false, path: 'no-response');
    }

    // --- Phase 1 wire fields. A backend older than Phase 1 sends none of
    // them; the legacy branches below then reconstruct the old behaviour.
    final outcome = remoteData['outcome'] as String?;
    final path = (remoteData['path'] as String?) ?? _legacyPath(remoteData);
    final reason = remoteData['reason'] as String?;
    final wireGtin = _nonEmpty(remoteData['gtin']) ?? gtin;
    final productKey = _nonEmpty(remoteData['productKey']);
    final identification = _identification(remoteData['identification']);
    final modelsRaw = remoteData['models'];
    final identifyModel =
        modelsRaw is Map ? _nonEmpty(modelsRaw['identify']) : null;
    final analyzeModel =
        modelsRaw is Map ? _nonEmpty(modelsRaw['analyze']) : null;

    final fallbackRaw = remoteData['userPhotoFallbackUrl'];
    final userPhotoFallbackUrl = fallbackRaw is String && fallbackRaw.isNotEmpty
        ? fallbackRaw
        : null;

    // Label-path failures: the panel was read but empty, or unreadable.
    if (path == 'label' &&
        (outcome == 'label_no_data' || outcome == 'unreadable')) {
      debugPrint('[ProductRepository] Label failed ($outcome)');
      return ScanLabelFailed(
        noData: outcome == 'label_no_data',
        identification: identification,
        productKey: productKey,
        path: path,
        gtin: wireGtin,
        identifyModel: identifyModel,
        analyzeModel: analyzeModel,
      );
    }

    if (outcome == 'not_cat_product' || outcome == 'unreadable') {
      debugPrint('[ProductRepository] Not identified ($outcome/$reason)');
      return ScanNotIdentified(
        notCatProduct: outcome == 'not_cat_product',
        reason: reason,
        path: path,
        gtin: wireGtin,
        identifyModel: identifyModel,
        analyzeModel: analyzeModel,
      );
    }

    // `category` is absent on responses from a backend older than litter
    // support; falling through to the product branch keeps those working.
    if (remoteData['category'] == 'litter') {
      final litterRaw = remoteData['litter'];
      if (litterRaw == null || litterRaw is! Map) {
        debugPrint('[ProductRepository] Litter data missing from response');
        return ScanAnalysisFailed(
          isLitter: true,
          identification: identification,
          productKey: productKey,
          path: path,
          gtin: wireGtin,
        );
      }
      final localizedRaw = remoteData['litterLocalizedText'];
      debugPrint('[ProductRepository] Litter found for image');
      return ScanLitterResult(
        _litterToDomainMapper(
          Map<String, dynamic>.from(litterRaw),
          localizedText: localizedRaw is Map
              ? Map<String, dynamic>.from(localizedRaw)
              : null,
          userPhotoFallbackUrl: userPhotoFallbackUrl,
        ),
        path: path,
        gtin: wireGtin,
        identifyModel: identifyModel,
        analyzeModel: analyzeModel,
      );
    }

    final productDataRaw = remoteData['product'];
    if (productDataRaw == null || productDataRaw is! Map) {
      // Legacy backends return `category: null, product: null` for a
      // not-identified scan; only a Phase-1 backend can say "identified but
      // the analysis failed". Without an identification there is nothing to
      // attach a rescue to, so treat it as not identified.
      if (remoteData['category'] == null && identification == null) {
        debugPrint('[ProductRepository] Nothing recognized in image');
        return ScanNotIdentified(
          notCatProduct: false,
          reason: reason,
          path: path,
          gtin: wireGtin,
        );
      }
      debugPrint('[ProductRepository] Analysis failed for identified product');
      return ScanAnalysisFailed(
        isLitter: false,
        identification: identification,
        productKey: productKey,
        path: path,
        gtin: wireGtin,
        identifyModel: identifyModel,
        analyzeModel: analyzeModel,
      );
    }
    debugPrint('[ProductRepository] Product found for image');
    final productData = Map<String, dynamic>.from(productDataRaw);
    final localizedRaw = remoteData['localizedText'];
    return ScanFoodResult(
      _productToDomainMapper(
        productData,
        localizedText: localizedRaw is Map
            ? Map<String, dynamic>.from(localizedRaw)
            : null,
        userPhotoFallbackUrl: userPhotoFallbackUrl,
      ),
      path: path,
      gtin: wireGtin,
      identifyModel: identifyModel,
      analyzeModel: analyzeModel,
    );
  }

  /// Reconstructs a `path` for a pre-Phase-1 backend from what it did send.
  String _legacyPath(Map<String, dynamic> data) {
    if (data['category'] == null) return 'not-identified';
    final message = data['message']?.toString() ?? '';
    return message.contains('cache') ? 'cache-hit' : 'full-analysis';
  }

  String? _nonEmpty(dynamic raw) =>
      raw is String && raw.isNotEmpty ? raw : null;

  ScanIdentification? _identification(dynamic raw) {
    if (raw is! Map) return null;
    final brand = raw['brand']?.toString() ?? '';
    final name = raw['name']?.toString() ?? '';
    if (brand.isEmpty && name.isEmpty) return null;
    return ScanIdentification(
      brand: brand,
      name: name,
      foodType: _nonEmpty(raw['foodType']),
    );
  }
}
