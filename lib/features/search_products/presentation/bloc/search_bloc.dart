import 'package:auto_route/auto_route.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/product/domain/entities/product_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/search/domain/usecases/add_recent_search_usecase.dart';
import 'package:yucat/features/search/domain/usecases/clear_recent_searches_usecase.dart';
import 'package:yucat/features/search/domain/usecases/get_recent_searches_usecase.dart';
import 'package:yucat/features/search/domain/usecases/search_by_query_usecase.dart';
import 'package:yucat/features/search_products/presentation/mappers/brand_to_model_mapper.dart';
import 'package:yucat/features/search_products/presentation/mappers/product_to_model_mapper.dart';
import 'package:yucat/features/search_products/presentation/models/brand_display_model.dart';
import 'package:yucat/features/brand/domain/usecases/get_brands_usecase.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchByQueryUsecase _searchByQueryUsecase;
  final ProductToModelMapper _productToModelMapper;
  final LogEventUsecase _logEventUsecase;
  final GetBrandsUsecase _getBrandsUsecase;
  final BrandToModelMapper _brandToModelMapper;
  final GetRecentSearchesUsecase _getRecentSearchesUsecase;
  final AddRecentSearchUsecase _addRecentSearchUsecase;
  final ClearRecentSearchesUsecase _clearRecentSearchesUsecase;

  List<BrandDisplayModel> _brands = [];
  List<String> _recentSearches = [];

  SearchBloc({
    required SearchByQueryUsecase searchByQueryUsecase,
    required ProductToModelMapper productToModelMapper,
    required LogEventUsecase logEventUsecase,
    required GetBrandsUsecase getBrandsUsecase,
    required BrandToModelMapper brandToModelMapper,
    required GetRecentSearchesUsecase getRecentSearchesUsecase,
    required AddRecentSearchUsecase addRecentSearchUsecase,
    required ClearRecentSearchesUsecase clearRecentSearchesUsecase,
  }) : _searchByQueryUsecase = searchByQueryUsecase,
       _productToModelMapper = productToModelMapper,
       _logEventUsecase = logEventUsecase,
       _getBrandsUsecase = getBrandsUsecase,
       _brandToModelMapper = brandToModelMapper,
       _getRecentSearchesUsecase = getRecentSearchesUsecase,
       _addRecentSearchUsecase = addRecentSearchUsecase,
       _clearRecentSearchesUsecase = clearRecentSearchesUsecase,
       super(SearchHiddenState()) {
    on<SearchInitialEvent>(_onSearchInitialEvent);
    on<SearchQueryEvent>(_onSearchQueryEvent);
    on<ExecuteSearchEvent>(_onExecuteSearchEvent);
    on<NavigateToProductDetailEvent>(_onNavigateToProductDetailEvent);
    on<SubmitSearchEvent>(_onSubmitSearchEvent);
    on<RecentSearchSelectedEvent>(_onRecentSearchSelectedEvent);
    on<ClearRecentSearchesEvent>(_onClearRecentSearchesEvent);
  }

  Future<void> _onSearchInitialEvent(
    SearchInitialEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchDiscoverLoadingState());

    _recentSearches = await _getRecentSearchesUsecase();

    final brands = await _getBrandsUsecase.call();
    final mappedBrands = _brandToModelMapper(brands);
    _brands = mappedBrands;
    emit(SearchDiscoverLoadedState(
      brands: mappedBrands,
      recentSearches: _recentSearches,
    ));
  }

  Future<void> _onSearchQueryEvent(
    SearchQueryEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty || event.query.length < 3) {
      EasyDebounce.cancel('search_query');
      if (_brands.isNotEmpty) {
        emit(SearchDiscoverLoadedState(
          brands: _brands,
          recentSearches: _recentSearches,
        ));
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
    emit(SearchLoadedState(
      searchQuery: event.query,
      isLoading: true,
    ));

    try {
      final products = await _searchByQueryUsecase.call(query: event.query);
      final mappedProducts = products
          .map((product) => _productToModelMapper(product))
          .toList();

      _logEventUsecase.call(
        eventName: 'Product Searched',
        properties: {
          'query': event.query,
          'query_length': event.query.length,
          'results_count': products.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _logEventUsecase.call(
        eventName: 'Search Results Viewed',
        properties: {
          'query': event.query,
          'results_count': products.length,
          'has_results': products.isNotEmpty,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

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
    _logEventUsecase.call(
      eventName: 'Product Selected',
      properties: {
        'product_name': event.product.name,
        'product_brand': event.product.brand,
        'source': 'search',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Opening a result is a strong "this search mattered" signal — remember it.
    final current = state;
    if (current is SearchLoadedState) {
      await _rememberSearch(current.searchQuery);
    }

    event.context.router.push(ProductDetailRoute(product: event.product));
  }

  Future<void> _onSubmitSearchEvent(
    SubmitSearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    EasyDebounce.cancel('search_query');
    if (event.query.trim().length < 3) return;
    await _rememberSearch(event.query);
    add(ExecuteSearchEvent(query: event.query));
  }

  Future<void> _onRecentSearchSelectedEvent(
    RecentSearchSelectedEvent event,
    Emitter<SearchState> emit,
  ) async {
    // Run the tapped recent search immediately, bypassing the keystroke
    // debounce, and move it back to the front of the recents list.
    EasyDebounce.cancel('search_query');
    await _rememberSearch(event.query);
    add(ExecuteSearchEvent(query: event.query));
  }

  /// Persists [query] to recent searches (deduped, most-recent first). Only
  /// called on explicit commits — submitting, tapping a result, or tapping a
  /// recent chip — never on live keystrokes.
  Future<void> _rememberSearch(String query) async {
    if (query.trim().isEmpty) return;
    await _addRecentSearchUsecase(query);
    _recentSearches = await _getRecentSearchesUsecase();
  }

  Future<void> _onClearRecentSearchesEvent(
    ClearRecentSearchesEvent event,
    Emitter<SearchState> emit,
  ) async {
    await _clearRecentSearchesUsecase();
    _recentSearches = const [];
    emit(SearchDiscoverLoadedState(
      brands: _brands,
      recentSearches: _recentSearches,
    ));
  }

  @override
  Future<void> close() {
    EasyDebounce.cancel('search_query');
    return super.close();
  }
}
