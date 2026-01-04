import 'package:flutter_bloc/flutter_bloc.dart';
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
  }) : _fetchProductByBarcodeUsecase = fetchProductByBarcodeUsecase,
       _productEntityToModelMapper = productEntityToModelMapper,
       _currentUserUsecase = currentUserUsecase,
       _signinAnonymouslyUsecase = signinAnonymouslyUsecase,
       _scanTrackingService = scanTrackingService,
       _logScreenViewUsecase = logScreenViewUsecase,
       super(HomeHiddenState()) {
    on<HomeInitialEvent>(_onHomeInitialEvent);
    on<CountryTapEvent>(_onCountryTapEvent);
    on<SearchByBarcodeEvent>(_onSearchByBarcodeEvent);
    on<BarcodeDetectedEvent>(_onBarcodeDetectedEvent);
    on<PaywallDismissedEvent>(_onPaywallDismissedEvent);
    on<ResetScannerEvent>(_onResetScannerEvent);
  }

  Future<void> _onHomeInitialEvent(
    HomeInitialEvent event,
    Emitter<HomeState> emit,
  ) async {
    _logScreenViewUsecase.call(screenName: 'HomeScreen');

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
    // Check subscription status first
    final hasSubscription = await _scanTrackingService.hasActiveSubscription();
    print('BarcodeDetectedEvent: hasSubscription = $hasSubscription');

    // Check if user can perform scan
    final canScan = await _scanTrackingService.canPerformScan();
    print('BarcodeDetectedEvent: canScan = $canScan');

    if (!canScan) {
      // User has reached free scan limit, need to show paywall
      print('BarcodeDetectedEvent: Scan limit reached, showing paywall');
      _pendingBarcode = event.barcode;
      emit(HomeScanLimitReachedState(barcode: event.barcode));
      return;
    }

    // User can scan - increment count if they don't have subscription
    if (!hasSubscription) {
      print(
        'BarcodeDetectedEvent: No subscription, incrementing free scan count',
      );
      await _scanTrackingService.incrementFreeScansCount();
    } else {
      print(
        'BarcodeDetectedEvent: User has subscription, skipping scan count increment',
      );
    }

    // Process the scan
    print(
      'BarcodeDetectedEvent: Processing scan for barcode: ${event.barcode}',
    );
    emit(HomeScanProcessedState(barcode: event.barcode));
  }

  Future<void> _onPaywallDismissedEvent(
    PaywallDismissedEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.purchasedSubscription && _pendingBarcode != null) {
      // User purchased subscription, process the scan immediately
      // User can scan - increment count if they don't have subscription
      final hasSubscription = await _scanTrackingService
          .hasActiveSubscription();
      if (!hasSubscription) {
        await _scanTrackingService.incrementFreeScansCount();
      }

      // Process the scan
      emit(HomeScanProcessedState(barcode: _pendingBarcode!));
      _pendingBarcode = null;
    } else {
      // User did not purchase, reset scanner for next scan
      _pendingBarcode = null;
      emit(HomeScanResetState());
    }
  }

  Future<void> _onResetScannerEvent(
    ResetScannerEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeScanResetState());
  }
}
