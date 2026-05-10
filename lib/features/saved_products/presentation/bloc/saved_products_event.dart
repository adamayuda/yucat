part of 'saved_products_bloc.dart';

sealed class SavedProductsEvent extends Equatable {
  const SavedProductsEvent();
}

class SavedProductsInitialEvent extends SavedProductsEvent {
  const SavedProductsInitialEvent();

  @override
  List<Object?> get props => [];
}

class SavedProductsRefreshEvent extends SavedProductsEvent {
  const SavedProductsRefreshEvent();

  @override
  List<Object?> get props => [];
}
