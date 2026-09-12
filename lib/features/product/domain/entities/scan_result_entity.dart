import 'package:yucat/features/litter/domain/entities/litter_entity.dart';
import 'package:yucat/features/product/domain/entities/product_entity.dart';

/// What the backend read off the pack (or resolved from the barcode) before
/// it looked anything up. Present on failures too, so the error screen can
/// name the product and a later rescue path can attach data to it.
class ScanIdentification {
  final String brand;
  final String name;
  final String? foodType;

  const ScanIdentification({
    required this.brand,
    required this.name,
    this.foodType,
  });
}

/// What a scan turned out to be.
///
/// The camera is a single entry point — the user photographs a package without
/// telling us what kind it is — so the backend classifies it and the client
/// branches here. Every variant carries the backend's `path` (the same string
/// it logs in "scan timings") so analytics can tell a barcode hit from a full
/// analysis, and the normalised `gtin` when the client read one.
///
/// Before Phase 1 the repository returned null for every failure, which is why
/// "not a cat product", "couldn't read the pack" and "analysis found nothing"
/// all rendered as "Product not found".
sealed class ScanResultEntity {
  final String path;
  final String? gtin;

  /// The models the backend used (`models.identify` / `models.analyze` on the
  /// wire), for the Phase 3 identify/label A/B: reported on the outcome events
  /// so `Product Image Scan Failed { error_type: unreadable }` can be broken
  /// down by `identify_model`. Null from a pre-Phase-1 backend.
  final String? identifyModel;
  final String? analyzeModel;

  const ScanResultEntity({
    required this.path,
    this.gtin,
    this.identifyModel,
    this.analyzeModel,
  });
}

class ScanFoodResult extends ScanResultEntity {
  final ProductEntity product;

  const ScanFoodResult(
    this.product, {
    required super.path,
    super.gtin,
    super.identifyModel,
    super.analyzeModel,
  });
}

class ScanLitterResult extends ScanResultEntity {
  final LitterEntity litter;

  const ScanLitterResult(
    this.litter, {
    required super.path,
    super.gtin,
    super.identifyModel,
    super.analyzeModel,
  });
}

/// The identify step rejected the photo. [notCatProduct] separates "this is
/// dog food / a mug" (nothing to retry) from "the pack was unreadable" (retry,
/// or photograph the label). [reason] is the backend's finer enum
/// (`dog_food`, `human_food`, `other_item`, `no_product`, `unreadable`,
/// `no_tool`) for analytics.
class ScanNotIdentified extends ScanResultEntity {
  final bool notCatProduct;
  final String? reason;

  const ScanNotIdentified({
    required this.notCatProduct,
    required super.path,
    this.reason,
    super.gtin,
    super.identifyModel,
    super.analyzeModel,
  });
}

/// A back-label capture that produced no usable analysis. [noData] separates
/// "the panel was read but held no figures" (`label_no_data`) from "the photo
/// could not be read at all" (`unreadable`). A successful label read comes
/// back as a plain [ScanFoodResult] with `path == 'label'`.
class ScanLabelFailed extends ScanResultEntity {
  final bool noData;
  final ScanIdentification? identification;
  final String? productKey;

  const ScanLabelFailed({
    required this.noData,
    required super.path,
    this.identification,
    this.productKey,
    super.gtin,
    super.identifyModel,
    super.analyzeModel,
  });
}

/// The pack was identified but the analysis produced nothing usable. The
/// [identification] is what the error screen can show, and [productKey] (when
/// the backend cached a placeholder row) is what a label rescue attaches to.
class ScanAnalysisFailed extends ScanResultEntity {
  final ScanIdentification? identification;
  final String? productKey;
  final bool isLitter;

  const ScanAnalysisFailed({
    required this.isLitter,
    required super.path,
    this.identification,
    this.productKey,
    super.gtin,
    super.identifyModel,
    super.analyzeModel,
  });
}
