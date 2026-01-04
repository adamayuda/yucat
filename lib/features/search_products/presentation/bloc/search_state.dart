part of 'search_bloc.dart';

sealed class SearchState extends Equatable {
  const SearchState();
}

class SearchLoadingState extends SearchState {
  const SearchLoadingState();

  @override
  List<Object?> get props => [];
}

class SearchDiscoverLoadingState extends SearchState {
  const SearchDiscoverLoadingState();

  @override
  List<Object?> get props => [];
}

class SearchDiscoverLoadedState extends SearchState {
  final List<BrandDisplayModel> brands;

  const SearchDiscoverLoadedState({required this.brands});

  @override
  List<Object?> get props => [brands];
}

class SearchHiddenState extends SearchState {
  @override
  List<Object?> get props => [];
}

class SearchLoadedState extends SearchState {
  final List<ProductDisplayModel> products;
  final String searchQuery;
  final bool isLoading;

  const SearchLoadedState({
    this.products = const [],
    this.searchQuery = '',
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [products, searchQuery, isLoading];
}

class SearchErrorState extends SearchState {
  @override
  List<Object?> get props => [];
}

class SearchNavigateToProductDetailState extends SearchState {
  final ProductEntity productEntity;

  const SearchNavigateToProductDetailState({required this.productEntity});

  @override
  List<Object?> get props => [productEntity];
}
