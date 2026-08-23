import 'package:equatable/equatable.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';

enum HomeErrorType { notFound, timeout, noInternet, generic }

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

  const HomeScanningState({required this.imageBase64});

  @override
  List<Object?> get props => [imageBase64];
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

  const HomeErrorState({required this.errorType});

  @override
  List<Object?> get props => [errorType];
}

class HomeNavigateToProductDetailState extends HomeState {
  final ProductDisplayModel product;

  const HomeNavigateToProductDetailState({required this.product});

  @override
  List<Object?> get props => [product];
}
