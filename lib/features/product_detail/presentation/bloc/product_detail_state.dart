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
  final ProductDisplayModel product;
  final bool isSaved;

  const ProductDetailLoadedState({
    required this.product,
    this.isSaved = false,
  });

  ProductDetailLoadedState copyWith({bool? isSaved}) =>
      ProductDetailLoadedState(
        product: product,
        isSaved: isSaved ?? this.isSaved,
      );

  @override
  List<Object?> get props => [product, isSaved];
}

class ProductDetailErrorState extends ProductDetailState {
  @override
  List<Object?> get props => [];
}
