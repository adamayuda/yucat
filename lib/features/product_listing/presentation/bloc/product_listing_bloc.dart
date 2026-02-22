import 'package:auto_route/auto_route.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/search/domain/usecases/search_by_brand_usecase.dart';
import 'package:yucat/features/search_products/presentation/mappers/product_to_model_mapper.dart';

part 'product_listing_event.dart';
part 'product_listing_state.dart';

class ProductListingBloc
    extends Bloc<ProductListingEvent, ProductListingState> {
  final SearchByBrandUsecase _searchByBrandUsecase;
  final ProductToModelMapper _productToModelMapper;
  final LogScreenViewUsecase _logScreenViewUsecase;

  ProductListingBloc({
    required SearchByBrandUsecase searchByBrandUsecase,
    required ProductToModelMapper productToModelMapper,
    required LogScreenViewUsecase logScreenViewUsecase,
  }) : _searchByBrandUsecase = searchByBrandUsecase,
       _productToModelMapper = productToModelMapper,
       _logScreenViewUsecase = logScreenViewUsecase,
       super(ProductListingHiddenState()) {
    on<ProductListingInitialEvent>(_onProductListingInitialEvent);
    on<NavigateToProductDetailEvent>(_onNavigateToProductDetailEvent);
  }

  Future<void> _onProductListingInitialEvent(
    ProductListingInitialEvent event,
    Emitter<ProductListingState> emit,
  ) async {
    // _logScreenViewUsecase.call(screenName: 'ProductListingScreen');

    emit(ProductListingLoadingState());

    final products = await _searchByBrandUsecase.call(
      brandName: event.brandName,
    );
    final mappedProducts = products
        .map((product) => _productToModelMapper(product))
        .toList();

    emit(ProductListingLoadedState(products: mappedProducts));
  }

  Future<void> _onNavigateToProductDetailEvent(
    NavigateToProductDetailEvent event,
    Emitter<ProductListingState> emit,
  ) async {
    event.context.router.push(ProductDetailRoute(product: event.product));
  }
}
