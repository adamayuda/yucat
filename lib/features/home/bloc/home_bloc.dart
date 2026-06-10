import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/signin_anonymously_usecase.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/usecases/get_cats_usecase.dart';
import 'package:yucat/features/home/bloc/home_event.dart';
import 'package:yucat/features/home/bloc/home_state.dart';
import 'package:yucat/features/product/domain/usecases/fetch_product_by_image_usecase.dart';
import 'package:yucat/features/product_detail/presentation/mappers/product_entity_to_model_mapper.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/saved_products/domain/usecases/get_saved_products_usecase.dart';
import 'package:yucat/features/scan_history/domain/usecases/add_scan_to_history_usecase.dart';
import 'package:yucat/services/notification_service.dart';
import 'package:yucat/services/review_prompt_service.dart';
import 'package:yucat/services/scan_tracking_service.dart';
import 'package:yucat/services/user_analytics_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchProductByImageUsecase _fetchProductByImageUsecase;
  final ProductEntityToModelMapper _productEntityToModelMapper;
  final CurrentUserUsecase _currentUserUsecase;
  final SigninAnonymouslyUsecase _signinAnonymouslyUsecase;
  final ScanTrackingService _scanTrackingService;
  final ReviewPromptService _reviewPromptService;
  final GetCatsUsecase _getCatsUsecase;
  final GetSavedProductsUsecase _getSavedProductsUsecase;
  final AddScanToHistoryUsecase _addScanToHistoryUsecase;
  final LogEventUsecase _logEventUsecase;
  final NotificationService _notificationService;
  final UserAnalyticsService _userAnalyticsService;
  // ignore: unused_field
  final SharedPreferences _prefs;

  HomeBloc({
    required FetchProductByImageUsecase fetchProductByImageUsecase,
    required ProductEntityToModelMapper productEntityToModelMapper,
    required CurrentUserUsecase currentUserUsecase,
    required SigninAnonymouslyUsecase signinAnonymouslyUsecase,
    required ScanTrackingService scanTrackingService,
    required ReviewPromptService reviewPromptService,
    required GetCatsUsecase getCatsUsecase,
    required GetSavedProductsUsecase getSavedProductsUsecase,
    required AddScanToHistoryUsecase addScanToHistoryUsecase,
    required LogEventUsecase logEventUsecase,
    required NotificationService notificationService,
    required UserAnalyticsService userAnalyticsService,
    required SharedPreferences prefs,
  }) : _fetchProductByImageUsecase = fetchProductByImageUsecase,
       _productEntityToModelMapper = productEntityToModelMapper,
       _currentUserUsecase = currentUserUsecase,
       _signinAnonymouslyUsecase = signinAnonymouslyUsecase,
       _scanTrackingService = scanTrackingService,
       _reviewPromptService = reviewPromptService,
       _getCatsUsecase = getCatsUsecase,
       _getSavedProductsUsecase = getSavedProductsUsecase,
       _addScanToHistoryUsecase = addScanToHistoryUsecase,
       _logEventUsecase = logEventUsecase,
       _notificationService = notificationService,
       _userAnalyticsService = userAnalyticsService,
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

    final currentUser = _currentUserUsecase();
    if (currentUser == null) {
      await _signinAnonymouslyUsecase();
    }

    final user = _currentUserUsecase();

    // Attach the anonymous Firebase UID as the OneSignal external id so push
    // notifications can target this user. Fire-and-forget; iOS-only internally.
    // Also bind the same UID as the Mixpanel distinct id so People properties
    // attach to a stable profile (idempotent per session).
    if (user != null) {
      unawaited(_notificationService.login(user.uid));
      unawaited(_userAnalyticsService.identify(user.uid));
    }

    List<CatEntity> cats = const [];
    if (user != null) {
      try {
        cats = await _getCatsUsecase(userId: user.uid);
        // Authoritative cats sync — home loads on every return to the tab, so
        // this corrects the People profile after creates/deletes elsewhere.
        unawaited(_userAnalyticsService.syncCats(
          count: cats.length,
          primaryAgeGroup: cats.isNotEmpty ? cats.first.ageGroup : null,
        ));
      } catch (_) {
        // Header falls back to generic copy on read failure.
      }
    }

    List<ProductDisplayModel> savedProducts = const [];
    try {
      savedProducts = await _getSavedProductsUsecase();
    } catch (_) {
      // Preview hides on read failure.
    }

    emit(HomeLoadedState(cats: cats, savedProducts: savedProducts));
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

    emit(HomeScanningState());

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

      // Record every successful scan to local history (best-effort; a
      // persistence failure must never block navigation to the result).
      try {
        await _addScanToHistoryUsecase(productDetailModel);
      } catch (_) {}

      _logEventUsecase.call(
        eventName: 'Product Selected',
        properties: {
          'product_name': productDetailModel.name,
          'product_brand': productDetailModel.brand,
          'source': 'image',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      final streak = await _scanTrackingService.recordSuccessfulScan();
      unawaited(_userAnalyticsService.recordScan(currentStreak: streak));
      await _reviewPromptService.recordScan();
      // Fire-and-forget; the service applies its own gating.
      unawaited(
        _reviewPromptService.maybePrompt(trigger: 'post_scan'),
      );

      event.router.push(
        ProductDetailRoute(product: productDetailModel),
      );
      add(HomeInitialEvent());
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
