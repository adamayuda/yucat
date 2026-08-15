import 'package:yucat/features/litter/domain/entities/litter_entity.dart';
import 'package:yucat/features/product/domain/entities/product_entity.dart';

/// What a scan turned out to be.
///
/// The camera is a single entry point — the user photographs a package without
/// telling us what kind it is — so the backend classifies it and the client
/// branches here. Callers that only handle food (the onboarding current-food
/// beat) can pattern-match [ScanFoodResult] and treat anything else as an
/// unrecognized scan.
sealed class ScanResultEntity {
  const ScanResultEntity();
}

class ScanFoodResult extends ScanResultEntity {
  final ProductEntity product;

  const ScanFoodResult(this.product);
}

class ScanLitterResult extends ScanResultEntity {
  final LitterEntity litter;

  const ScanLitterResult(this.litter);
}
