import 'package:equatable/equatable.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';

sealed class HomeState extends Equatable {
  const HomeState();
}

class HomeLoadingState extends HomeState {
  const HomeLoadingState();

  @override
  List<Object?> get props => [];
}

class HomeHiddenState extends HomeState {
  @override
  List<Object?> get props => [];
}

class HomeLoadedState extends HomeState {
  const HomeLoadedState();

  @override
  List<Object?> get props => [];
}

class HomeSearchResultsState extends HomeState {
  final List<ProductDisplayModel> products;
  final String query;

  const HomeSearchResultsState({required this.products, required this.query});

  @override
  List<Object?> get props => [products, query];
}

class HomeErrorState extends HomeState {
  final String message;

  const HomeErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class HomeNavigateToProductDetailState extends HomeState {
  final ProductDisplayModel product;

  const HomeNavigateToProductDetailState({required this.product});

  @override
  List<Object?> get props => [product];
}

class HomeScanLimitReachedState extends HomeState {
  final String barcode;

  const HomeScanLimitReachedState({required this.barcode});

  @override
  List<Object?> get props => [barcode];
}

class HomeShowPaywallState extends HomeState {
  const HomeShowPaywallState();

  @override
  List<Object?> get props => [];
}

class HomeScanProcessedState extends HomeState {
  final String barcode;

  const HomeScanProcessedState({required this.barcode});

  @override
  List<Object?> get props => [barcode];
}

class HomeScanResetState extends HomeState {
  const HomeScanResetState();

  @override
  List<Object?> get props => [];
}
