part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();
}

class SearchInitialEvent extends SearchEvent {
  @override
  List<Object?> get props => [];
}

class SearchQueryEvent extends SearchEvent {
  final String query;

  const SearchQueryEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class ExecuteSearchEvent extends SearchEvent {
  final String query;

  const ExecuteSearchEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class NavigateToProductDetailEvent extends SearchEvent {
  final ProductModel product;
  final BuildContext context;

  const NavigateToProductDetailEvent({
    required this.product,
    required this.context,
  });

  @override
  List<Object?> get props => [product, context];
}
