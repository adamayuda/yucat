part of 'product_detail_bloc.dart';

sealed class ProductDetailState extends Equatable {
  const ProductDetailState();
}

class ProductDetailLoadingState extends ProductDetailState {
  const ProductDetailLoadingState();

  @override
  List<Object?> get props => [];
}

class ProductDetailHiddenState extends ProductDetailState {
  @override
  List<Object?> get props => [];
}

class ProductDetailLoadedState extends ProductDetailState {
  final ProductModel product;

  const ProductDetailLoadedState({required this.product});

  @override
  List<Object?> get props => [product];
}

class ProductDetailErrorState extends ProductDetailState {
  @override
  List<Object?> get props => [];
}
