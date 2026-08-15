part of 'saved_products_bloc.dart';

sealed class SavedProductsState extends Equatable {
  const SavedProductsState();
}

class SavedProductsLoadingState extends SavedProductsState {
  const SavedProductsLoadingState();

  @override
  List<Object?> get props => [];
}

class SavedProductsLoadedState extends SavedProductsState {
  final List<ProductDisplayModel> products;
  final List<LitterDisplayModel> litters;

  const SavedProductsLoadedState({
    required this.products,
    this.litters = const [],
  });

  bool get isEmpty => products.isEmpty && litters.isEmpty;

  @override
  List<Object?> get props => [products, litters];
}
