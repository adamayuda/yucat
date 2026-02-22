import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/signin_anonymously_usecase.dart';
import 'package:yucat/features/home/bloc/home_event.dart';
import 'package:yucat/features/home/bloc/home_state.dart';
import 'package:yucat/features/product/domain/usecases/fetch_product_by_barcode_usecase.dart';
import 'package:yucat/features/product_detail/presentation/mappers/product_entity_to_model_mapper.dart';
import 'package:yucat/services/scan_tracking_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchProductByBarcodeUsecase _fetchProductByBarcodeUsecase;
  final ProductEntityToModelMapper _productEntityToModelMapper;
  final CurrentUserUsecase _currentUserUsecase;
  final SigninAnonymouslyUsecase _signinAnonymouslyUsecase;
  final ScanTrackingService _scanTrackingService;
  final LogScreenViewUsecase _logScreenViewUsecase;
  final SharedPreferences _prefs;
  // TODO: Replace with your actual entitlement ID from RevenueCat dashboard
  static const String entitlementID = 'yucat pro';

  String? _pendingBarcode;

  HomeBloc({
    required FetchProductByBarcodeUsecase fetchProductByBarcodeUsecase,
    required ProductEntityToModelMapper productEntityToModelMapper,
    required CurrentUserUsecase currentUserUsecase,
    required SigninAnonymouslyUsecase signinAnonymouslyUsecase,
    required ScanTrackingService scanTrackingService,
    required LogScreenViewUsecase logScreenViewUsecase,
    required SharedPreferences prefs,
  }) : _fetchProductByBarcodeUsecase = fetchProductByBarcodeUsecase,
       _productEntityToModelMapper = productEntityToModelMapper,
       _currentUserUsecase = currentUserUsecase,
       _signinAnonymouslyUsecase = signinAnonymouslyUsecase,
       _scanTrackingService = scanTrackingService,
       _logScreenViewUsecase = logScreenViewUsecase,
       _prefs = prefs,
       super(HomeHiddenState()) {
    on<HomeInitialEvent>(_onHomeInitialEvent);
    on<SearchByBarcodeEvent>(_onSearchByBarcodeEvent);
    on<BarcodeDetectedEvent>(_onBarcodeDetectedEvent);
    // on<PaywallDismissedEvent>(_onPaywallDismissedEvent);
    // on<ResetScannerEvent>(_onResetScannerEvent);
  }

  Future<void> _onHomeInitialEvent(
    HomeInitialEvent event,
    Emitter<HomeState> emit,
  ) async {
    // _prefs.clear();
    // _logScreenViewUsecase.call(screenName: 'HomeScreen');

    emit(HomeLoadingState());

    final user = _currentUserUsecase();
    if (user == null) {
      await _signinAnonymouslyUsecase();
    }
    // await Future.delayed(const Duration(milliseconds: 100));

    emit(HomeLoadedState());
  }

  Future<void> _onSearchByBarcodeEvent(
    SearchByBarcodeEvent event,
    Emitter<HomeState> emit,
  ) async {
    print('searching by barcode: ${event.barcode}');
    emit(HomeLoadingState());

    try {
      final product = await _fetchProductByBarcodeUsecase.call(
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

  Future<void> _onBarcodeDetectedEvent(
    BarcodeDetectedEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoadedState(hasScanned: true));
    // Check subscription status first
    // final hasSubscription = await _hasActiveSubscriptionUseCase();
    // print('BarcodeDetectedEvent: hasSubscription = $hasSubscription');

    // Check if user can perform scan
    final canScan = await _scanTrackingService.canPerformScan();
    print('BarcodeDetectedEvent: canScan = $canScan');

    if (!canScan) {
      // User has reached free scan limit, need to show paywall
      print('BarcodeDetectedEvent: Scan limit reached, showing paywall');
      _pendingBarcode = event.barcode;

      // Await paywall result
      final purchasedSubscription = await event.context.router.push<bool>(
        const PaywallRoute(),
      );

      print(
        'Paywall dismissed. Purchased subscription: $purchasedSubscription',
      );

      // If subscription was purchased, retry the scan
      if (purchasedSubscription == true && _pendingBarcode != null) {
        print(
          'Subscription purchased, retrying scan with barcode: $_pendingBarcode',
        );
        final barcodeToRetry = _pendingBarcode!;
        _pendingBarcode = null;

        emit(HomeLoadingState());

        try {
          final product = await _fetchProductByBarcodeUsecase.call(
            barcode: barcodeToRetry,
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
          event.context.router.push(
            ProductDetailRoute(product: productDetailModel),
          );
          emit(HomeLoadedState(hasScanned: false));
        } catch (e) {
          emit(HomeErrorState(message: 'Failed to search by barcode: $e'));
        }
      } else {
        // Paywall dismissed without purchase, reset scanner state
        emit(HomeLoadedState(hasScanned: false));
        _pendingBarcode = null;
      }
      return;
    }

    emit(HomeLoadingState());

    try {
      final product = await _fetchProductByBarcodeUsecase.call(
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
      event.context.router.push(
        ProductDetailRoute(product: productDetailModel),
      );
      emit(HomeLoadedState(hasScanned: false));
    } catch (e) {
      emit(HomeErrorState(message: 'Failed to search by barcode: $e'));
    }
  }
}
