part of 'product_listing_bloc.dart';

sealed class ProductListingEvent extends Equatable {
  const ProductListingEvent();
}

class ProductListingInitialEvent extends ProductListingEvent {
  final String brandName;

  const ProductListingInitialEvent({required this.brandName});

  @override
  List<Object?> get props => [brandName];
}

class NavigateToProductDetailEvent extends ProductListingEvent {
  final ProductDisplayModel product;
  final BuildContext context;

  const NavigateToProductDetailEvent({
    required this.product,
    required this.context,
  });

  @override
  List<Object?> get props => [product, context];
}
