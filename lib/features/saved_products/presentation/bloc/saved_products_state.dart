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

  const SavedProductsLoadedState({required this.products});

  @override
  List<Object?> get props => [products];
}
