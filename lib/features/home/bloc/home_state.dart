import 'package:equatable/equatable.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
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

  /// The user's cats. Drives the greeting, the active-cat selector, the
  /// snapshot card, and the per-cat scoring of saved products.
  final List<CatEntity> cats;

  /// Saved products, newest-first (the repository prepends on save).
  final List<ProductDisplayModel> savedProducts;

  HomeLoadedState({
    this.cats = const [],
    this.savedProducts = const [],
  }) : _timestamp = DateTime.now().microsecondsSinceEpoch;

  @override
  List<Object?> get props => [
        _timestamp,
        cats,
        savedProducts,
      ];
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
