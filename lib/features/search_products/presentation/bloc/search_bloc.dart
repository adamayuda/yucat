import 'package:auto_route/auto_route.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/search/domain/usecases/search_by_query_usecase.dart';
import 'package:yucat/features/search_products/presentation/mappers/brand_to_model_mapper.dart';
import 'package:yucat/features/search_products/presentation/mappers/product_to_model_mapper.dart';
import 'package:yucat/features/product/domain/entities/product_entity.dart';
import 'package:yucat/features/search_products/presentation/models/brand_display_model.dart';
import 'package:yucat/features/brand/domain/usecases/get_brands_usecase.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchByQueryUsecase _searchByQueryUsecase;
  final ProductToModelMapper _productToModelMapper;
  final LogScreenViewUsecase _logScreenViewUsecase;
  final GetBrandsUsecase _getBrandsUsecase;
  final BrandToModelMapper _brandToModelMapper;
  // Store ProductEntity list to preserve nutritional data
  List<ProductEntity> _productEntities = [];
  // Store brands list to show initial state when query is too short
  List<BrandDisplayModel> _brands = [];

  SearchBloc({
    required SearchByQueryUsecase searchByQueryUsecase,
    required ProductToModelMapper productToModelMapper,
    required LogScreenViewUsecase logScreenViewUsecase,
    required GetBrandsUsecase getBrandsUsecase,
    required BrandToModelMapper brandToModelMapper,
  }) : _searchByQueryUsecase = searchByQueryUsecase,
       _productToModelMapper = productToModelMapper,
       _logScreenViewUsecase = logScreenViewUsecase,
       _getBrandsUsecase = getBrandsUsecase,
       _brandToModelMapper = brandToModelMapper,
       super(SearchHiddenState()) {
    on<SearchInitialEvent>(_onSearchInitialEvent);
    on<SearchQueryEvent>(_onSearchQueryEvent);
    on<ExecuteSearchEvent>(_onExecuteSearchEvent);
    on<NavigateToProductDetailEvent>(_onNavigateToProductDetailEvent);
  }

  Future<void> _onSearchInitialEvent(
    SearchInitialEvent event,
    Emitter<SearchState> emit,
  ) async {
    _logScreenViewUsecase.call(screenName: 'SearchScreen');
    emit(SearchDiscoverLoadingState());
    final brands = await _getBrandsUsecase.call();
    final mappedBrands = _brandToModelMapper(brands);
    _brands = mappedBrands;
    emit(SearchDiscoverLoadedState(brands: mappedBrands));
    // final products = await _searchByQueryUsecase.call(query: '');

    // emit(
    //   SearchLoadedState(
    //     products: products
    //         .map((product) => _productToModelMapper(product))
    //         .toList(),
    //   ),
    // );
  }

  Future<void> _onSearchQueryEvent(
    SearchQueryEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      EasyDebounce.cancel('search_query');
      emit(const SearchLoadedState());
      return;
    }

    // If query is less than 3 characters, show initial discover state
    if (event.query.length < 3) {
      EasyDebounce.cancel('search_query');
      if (_brands.isNotEmpty) {
        emit(SearchDiscoverLoadedState(brands: _brands));
      }
      return;
    }

    // Don't emit loading state here - keep the search bar visible
    // The debounce will wait 300ms before executing the search
    // Capture query value for use in the debounce callback
    final query = event.query;

    EasyDebounce.debounce(
      'search_query',
      const Duration(milliseconds: 300),
      () {
        // Dispatch a new event to execute the search
        add(ExecuteSearchEvent(query: query));
      },
    );
  }

  Future<void> _onExecuteSearchEvent(
    ExecuteSearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    // Emit loading state with search bar visible
    emit(SearchLoadedState(searchQuery: event.query, isLoading: true));

    try {
      final products = await _searchByQueryUsecase.call(query: event.query);
      // Store ProductEntity list for later use in navigation
      _productEntities = products;
      final mappedProducts = products
          .map((product) => _productToModelMapper(product))
          .toList();
      emit(
        SearchLoadedState(
          products: mappedProducts,
          searchQuery: event.query,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(SearchErrorState());
    }
  }

  Future<void> _onNavigateToProductDetailEvent(
    NavigateToProductDetailEvent event,
    Emitter<SearchState> emit,
  ) async {
    event.context.router.push(ProductDetailRoute(product: event.product));
  }

  @override
  Future<void> close() {
    EasyDebounce.cancel('search_query');
    return super.close();
  }
}
