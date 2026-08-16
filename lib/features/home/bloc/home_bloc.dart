import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/signin_anonymously_usecase.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/usecases/get_cats_usecase.dart';
import 'package:yucat/features/home/bloc/home_event.dart';
import 'package:yucat/features/home/bloc/home_state.dart';
import 'package:yucat/features/litter_detail/presentation/mappers/litter_entity_to_model_mapper.dart';
import 'package:yucat/features/product/domain/entities/scan_result_entity.dart';
import 'package:yucat/features/product/domain/usecases/fetch_product_by_image_usecase.dart';
import 'package:yucat/features/product_detail/presentation/mappers/product_entity_to_model_mapper.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/saved_products/domain/usecases/get_saved_products_usecase.dart';
import 'package:yucat/features/scan_history/domain/usecases/add_litter_to_history_usecase.dart';
import 'package:yucat/features/scan_history/domain/usecases/add_scan_to_history_usecase.dart';
import 'package:yucat/services/notification_service.dart';
import 'package:yucat/services/review_prompt_service.dart';
import 'package:yucat/services/user_analytics_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchProductByImageUsecase _fetchProductByImageUsecase;
  final ProductEntityToModelMapper _productEntityToModelMapper;
  final LitterEntityToModelMapper _litterEntityToModelMapper;
  final CurrentUserUsecase _currentUserUsecase;
  final SigninAnonymouslyUsecase _signinAnonymouslyUsecase;
  final ReviewPromptService _reviewPromptService;
  final GetCatsUsecase _getCatsUsecase;
  final GetSavedProductsUsecase _getSavedProductsUsecase;
  final AddScanToHistoryUsecase _addScanToHistoryUsecase;
  final AddLitterToHistoryUsecase _addLitterToHistoryUsecase;
  final LogEventUsecase _logEventUsecase;
  final NotificationService _notificationService;
  final UserAnalyticsService _userAnalyticsService;
  // ignore: unused_field
  final SharedPreferences _prefs;

  HomeBloc({
    required FetchProductByImageUsecase fetchProductByImageUsecase,
    required ProductEntityToModelMapper productEntityToModelMapper,
    required LitterEntityToModelMapper litterEntityToModelMapper,
    required CurrentUserUsecase currentUserUsecase,
    required SigninAnonymouslyUsecase signinAnonymouslyUsecase,
    required ReviewPromptService reviewPromptService,
    required GetCatsUsecase getCatsUsecase,
    required GetSavedProductsUsecase getSavedProductsUsecase,
    required AddScanToHistoryUsecase addScanToHistoryUsecase,
    required AddLitterToHistoryUsecase addLitterToHistoryUsecase,
    required LogEventUsecase logEventUsecase,
    required NotificationService notificationService,
    required UserAnalyticsService userAnalyticsService,
    required SharedPreferences prefs,
  }) : _fetchProductByImageUsecase = fetchProductByImageUsecase,
       _productEntityToModelMapper = productEntityToModelMapper,
       _litterEntityToModelMapper = litterEntityToModelMapper,
       _currentUserUsecase = currentUserUsecase,
       _signinAnonymouslyUsecase = signinAnonymouslyUsecase,
       _reviewPromptService = reviewPromptService,
       _getCatsUsecase = getCatsUsecase,
       _getSavedProductsUsecase = getSavedProductsUsecase,
       _addScanToHistoryUsecase = addScanToHistoryUsecase,
       _addLitterToHistoryUsecase = addLitterToHistoryUsecase,
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

    // Bind the anonymous Firebase UID as the Mixpanel distinct id so People
    // properties attach to a stable profile (idempotent per session).
    //
    // OneSignal.login used to happen here too; it moved to SplashBloc, which
    // runs before onboarding — Home is only reached by users who already
    // converted, so identifying here left every drop-off anonymous.
    if (user != null) {
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
        // Same correction for the OneSignal tag — cat_create only ever sets
        // has_cat = true, so this is where a delete gets reflected.
        unawaited(_notificationService.setTags({
          NotificationTags.hasCat: NotificationTags.boolValue(cats.isNotEmpty),
        }));
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

    debugPrint('CATDIAG home loaded cats='
        '${cats.map((c) => '${c.name}:breed=${c.breed}:health=${c.healthConditions}').toList()}');
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

    emit(HomeScanningState(imageBase64: event.imageBase64));

    try {
      final scan = await _fetchProductByImageUsecase.call(
        imageBase64: event.imageBase64,
        mimeType: event.mimeType,
        countryCode: event.countryCode,
        locale: event.locale,
      );

      if (scan == null) {
        _logEventUsecase.call(
          eventName: 'Product Image Scan Failed',
          properties: {
            'error_type': 'not_found',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        emit(const HomeErrorState(errorType: HomeErrorType.notFound));
        return;
      }

      // The camera is one entry point for both categories — the backend decides
      // which it was, and the two results have their own screens and stores.
      if (scan is ScanLitterResult) {
        await _onLitterScanned(scan, event);
        return;
      }

      final product = (scan as ScanFoodResult).product;
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

      unawaited(_userAnalyticsService.recordScan());
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
      emit(HomeErrorState(errorType: _toErrorType(e)));
    }
  }

  /// A scanned litter: record it in the litter history and open the litter
  /// screen. Deliberately symmetrical with the food path — a litter scan counts
  /// toward `total_scans` and the review-prompt gate exactly like a food one.
  Future<void> _onLitterScanned(
    ScanLitterResult scan,
    ImageCapturedEvent event,
  ) async {
    final litterModel = _litterEntityToModelMapper(scan.litter);

    // Best-effort: a persistence failure must never block the result screen.
    try {
      await _addLitterToHistoryUsecase(litterModel);
    } catch (_) {}

    _logEventUsecase.call(
      eventName: AnalyticsEvents.litterSelected,
      properties: {
        'litter_name': litterModel.name,
        'litter_brand': litterModel.brand,
        'litter_material': litterModel.material.wire,
        'source': 'image',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    unawaited(_userAnalyticsService.recordScan());
    await _reviewPromptService.recordScan();
    unawaited(_reviewPromptService.maybePrompt(trigger: 'post_scan'));

    event.router.push(LitterDetailRoute(litter: litterModel));
    add(HomeInitialEvent());
  }

  HomeErrorType _toErrorType(Object e) {
    final message = e.toString();
    if (e is FirebaseFunctionsException &&
            e.code == 'deadline-exceeded' ||
        message.contains('deadline-exceeded') ||
        message.contains('DEADLINE_EXCEEDED')) {
      return HomeErrorType.timeout;
    }
    if (message.contains('network') ||
        message.contains('SocketException') ||
        message.contains('Connection')) {
      return HomeErrorType.noInternet;
    }
    return HomeErrorType.generic;
  }
}
