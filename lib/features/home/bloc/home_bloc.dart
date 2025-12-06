import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/signin_anonymously_usecase.dart';
import 'package:yucat/features/home/bloc/home_event.dart';
import 'package:yucat/features/home/bloc/home_state.dart';
import 'package:yucat/features/search/domain/usecases/search_by_barcode_usecase.dart';
import 'package:yucat/features/product_detail/presentation/mappers/product_entity_to_model_mapper.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SearchByBarcodeUsecase _searchByBarcodeUsecase;
  final ProductEntityToModelMapper _productEntityToModelMapper;
  final CurrentUserUsecase _currentUserUsecase;
  final SigninAnonymouslyUsecase _signinAnonymouslyUsecase;

  HomeBloc({
    required SearchByBarcodeUsecase searchByBarcodeUsecase,
    required ProductEntityToModelMapper productEntityToModelMapper,
    required CurrentUserUsecase currentUserUsecase,
    required SigninAnonymouslyUsecase signinAnonymouslyUsecase,
  }) : _searchByBarcodeUsecase = searchByBarcodeUsecase,
       _productEntityToModelMapper = productEntityToModelMapper,
       _currentUserUsecase = currentUserUsecase,
       _signinAnonymouslyUsecase = signinAnonymouslyUsecase,
       super(HomeHiddenState()) {
    on<HomeInitialEvent>(_onHomeInitialEvent);
    on<CountryTapEvent>(_onCountryTapEvent);
    on<SearchByBarcodeEvent>(_onSearchByBarcodeEvent);
  }

  Future<void> _onHomeInitialEvent(
    HomeInitialEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoadingState());

    final user = _currentUserUsecase();
    if (user == null) {
      await _signinAnonymouslyUsecase();
    }
    // await Future.delayed(const Duration(milliseconds: 100));

    emit(HomeLoadedState());
  }

  Future<void> _onCountryTapEvent(
    CountryTapEvent event,
    Emitter<HomeState> emit,
  ) async {
    print('pushing plan listing route');
    // event.context.router.push(
    //   PlanListingRoute(countryCode: event.countryCode),
    // );
    // final user = currentUserUsecase();
  }

  Future<void> _onSearchByBarcodeEvent(
    SearchByBarcodeEvent event,
    Emitter<HomeState> emit,
  ) async {
    print('searching by barcode: ${event.barcode}');
    emit(HomeLoadingState());

    try {
      final product = await _searchByBarcodeUsecase.call(
        barcode: event.barcode,
      );
      print('product found:');
      print('product: $product');

      if (product == null) {
        emit(HomeErrorState(message: 'Product not found'));
        return;
      }

      // Convert ProductEntity directly to ProductModel with all nutritional data
      final productDetailModel = _productEntityToModelMapper(product);

      // Navigate to product detail page
      emit(HomeNavigateToProductDetailState(product: productDetailModel));
    } catch (e) {
      emit(HomeErrorState(message: 'Failed to search by barcode: $e'));
    }
  }
}
