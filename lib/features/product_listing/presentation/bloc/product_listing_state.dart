part of 'product_listing_bloc.dart';

sealed class ProductListingState extends Equatable {
  const ProductListingState();
}

class ProductListingHiddenState extends ProductListingState {
  const ProductListingHiddenState();

  @override
  List<Object?> get props => [];
}

class ProductListingLoadingState extends ProductListingState {
  const ProductListingLoadingState();

  @override
  List<Object?> get props => [];
}

class ProductListingLoadedState extends ProductListingState {
  final List<ProductDisplayModel> products;

  const ProductListingLoadedState({this.products = const []});

  @override
  List<Object?> get props => [products];
}
