import 'package:auto_route/auto_route.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/signin_anonymously_usecase.dart';
import 'package:yucat/features/home/bloc/home_event.dart';
import 'package:yucat/features/home/bloc/home_state.dart';
import 'package:yucat/features/product/domain/usecases/fetch_product_by_image_usecase.dart';
import 'package:yucat/features/product_detail/presentation/mappers/product_entity_to_model_mapper.dart';
import 'package:yucat/services/scan_tracking_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchProductByImageUsecase _fetchProductByImageUsecase;
  final ProductEntityToModelMapper _productEntityToModelMapper;
  final CurrentUserUsecase _currentUserUsecase;
  final SigninAnonymouslyUsecase _signinAnonymouslyUsecase;
  final ScanTrackingService _scanTrackingService;
  // ignore: unused_field
  final LogScreenViewUsecase _logScreenViewUsecase;
  final LogEventUsecase _logEventUsecase;
  // ignore: unused_field
  final SharedPreferences _prefs;
  static const String entitlementID = 'yucat pro';

  HomeBloc({
    required FetchProductByImageUsecase fetchProductByImageUsecase,
    required ProductEntityToModelMapper productEntityToModelMapper,
    required CurrentUserUsecase currentUserUsecase,
    required SigninAnonymouslyUsecase signinAnonymouslyUsecase,
    required ScanTrackingService scanTrackingService,
    required LogScreenViewUsecase logScreenViewUsecase,
    required LogEventUsecase logEventUsecase,
    required SharedPreferences prefs,
  }) : _fetchProductByImageUsecase = fetchProductByImageUsecase,
       _productEntityToModelMapper = productEntityToModelMapper,
       _currentUserUsecase = currentUserUsecase,
       _signinAnonymouslyUsecase = signinAnonymouslyUsecase,
       _scanTrackingService = scanTrackingService,
       _logScreenViewUsecase = logScreenViewUsecase,
       _logEventUsecase = logEventUsecase,
       _prefs = prefs,
       super(HomeHiddenState()) {
    on<HomeInitialEvent>(_onHomeInitialEvent);
    on<ImageCapturedEvent>(_onImageCapturedEvent);
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

    emit(HomeLoadedState());
  }

  Future<void> _onImageCapturedEvent(
    ImageCapturedEvent event,
    Emitter<HomeState> emit,
  ) async {
    _logEventUsecase.call(
      eventName: 'Product Image Captured',
      properties: {
        'mime_type': event.mimeType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Check if user can perform scan
    final canScan = await _scanTrackingService.canPerformScan();

    if (!canScan) {
      final purchasedSubscription = await event.context.router.push<bool>(
        const PaywallRoute(),
      );

      if (purchasedSubscription != true) {
        emit(HomeLoadedState());
        return;
      }
    }

    emit(HomeLoadingState());

    try {
      final product = await _fetchProductByImageUsecase.call(
        imageBase64: event.imageBase64,
        mimeType: event.mimeType,
      );

      if (product == null) {
        _logEventUsecase.call(
          eventName: 'Product Image Scan Failed',
          properties: {
            'error_type': 'not_found',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        emit(HomeErrorState(message: 'Product not found'));
        return;
      }

      final productDetailModel = _productEntityToModelMapper(product);

      _logEventUsecase.call(
        eventName: 'Product Selected',
        properties: {
          'product_name': productDetailModel.name,
          'product_brand': productDetailModel.brand,
          'source': 'image',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      event.context.router.push(
        ProductDetailRoute(product: productDetailModel),
      );
      emit(HomeLoadedState());
    } catch (e) {
      _logEventUsecase.call(
        eventName: 'Product Image Scan Failed',
        properties: {
          'error_type': 'error',
          'error_message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      emit(HomeErrorState(message: _getUserFriendlyError(e)));
    }
  }

  String _getUserFriendlyError(Object e) {
    final message = e.toString();
    if (e is FirebaseFunctionsException &&
        e.code == 'deadline-exceeded' ||
        message.contains('deadline-exceeded') ||
        message.contains('DEADLINE_EXCEEDED')) {
      return 'The request took too long. Please try again.';
    }
    if (message.contains('network') ||
        message.contains('SocketException') ||
        message.contains('Connection')) {
      return 'No internet connection. Please check your network and try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
