import 'package:equatable/equatable.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/product/domain/entities/label_target.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';

/// [serviceBusy] is the backend's `resource-exhausted` — the model API's
/// balance ran out, an outage mode that is not the user's fault and not fixed
/// by tapping "Try again" immediately. [labelUnreadable] / [labelNoData] are
/// the two back-label rescue failures (Phase 2).
enum HomeErrorType {
  notFound,
  timeout,
  noInternet,
  serviceBusy,
  labelUnreadable,
  labelNoData,
  generic,
}

sealed class HomeState extends Equatable {
  const HomeState();
}

class HomeLoadingState extends HomeState {
  const HomeLoadingState();

  @override
  List<Object?> get props => [];
}

/// Loading state for an in-progress product scan — drives the playful scan
/// animation. Kept distinct from [HomeLoadingState] (the plain dashboard load)
/// so the scan theater never shows on ordinary loads.
class HomeScanningState extends HomeState {
  /// The just-captured photo (base64), shown under the sweeping scan line so
  /// the loading screen reflects what the user actually scanned.
  final String imageBase64;

  /// `pack` (front photo → identify + lookup + search) or `label` (back panel
  /// → one vision read). The theater's copy and time hint differ.
  final ScanMode mode;

  const HomeScanningState({
    required this.imageBase64,
    this.mode = ScanMode.pack,
  });

  @override
  List<Object?> get props => [imageBase64, mode];
}

class HomeHiddenState extends HomeState {
  @override
  List<Object?> get props => [];
}

class HomeLoadedState extends HomeState {
  final int _timestamp;

  /// The user's cats. Drives the greeting and the active-cat selector.
  final List<CatEntity> cats;

  HomeLoadedState({this.cats = const []})
      : _timestamp = DateTime.now().microsecondsSinceEpoch;

  @override
  List<Object?> get props => [_timestamp, cats];
}

class HomeErrorState extends HomeState {
  final HomeErrorType errorType;

  /// Phase-1 scan context, present only when the error is a scan outcome the
  /// backend classified (not a transport error). `outcome` is the wire value
  /// (`not_cat_product`, `unreadable`, `analysis_failed`,
  /// `litter_analysis_failed`); the rest is what a rescue path needs to name
  /// the product and attach data to it. Phase 2 renders exits from these.
  final String? outcome;
  final String? reason;
  final String? identifiedBrand;
  final String? identifiedName;
  final String? productKey;
  final String? gtin;

  const HomeErrorState({
    required this.errorType,
    this.outcome,
    this.reason,
    this.identifiedBrand,
    this.identifiedName,
    this.productKey,
    this.gtin,
  });

  @override
  List<Object?> get props => [
        errorType,
        outcome,
        reason,
        identifiedBrand,
        identifiedName,
        productKey,
        gtin,
      ];
}

class HomeNavigateToProductDetailState extends HomeState {
  final ProductDisplayModel product;

  const HomeNavigateToProductDetailState({required this.product});

  @override
  List<Object?> get props => [product];
}
