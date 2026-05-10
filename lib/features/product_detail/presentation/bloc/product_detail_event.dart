part of 'product_detail_bloc.dart';

sealed class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();
}

class ProductDetailInitialEvent extends ProductDetailEvent {
  final ProductDisplayModel? product;

  const ProductDetailInitialEvent({this.product});

  @override
  List<Object?> get props => [product];
}

class ProductDetailToggleSavedEvent extends ProductDetailEvent {
  const ProductDetailToggleSavedEvent();

  @override
  List<Object?> get props => [];
}
