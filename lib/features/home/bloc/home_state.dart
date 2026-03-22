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
  final int _timestamp;

  HomeLoadedState() : _timestamp = DateTime.now().microsecondsSinceEpoch;

  @override
  List<Object?> get props => [_timestamp];
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
