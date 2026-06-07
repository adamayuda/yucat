import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/core/subscription/domain/usecases/has_active_subscription_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/signin_anonymously_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/get_cats_usecase.dart';
import 'package:yucat/features/home/bloc/home_event.dart';
import 'package:yucat/features/home/bloc/home_state.dart';
import 'package:yucat/features/product/domain/usecases/fetch_product_by_image_usecase.dart';
import 'package:yucat/features/product_detail/presentation/mappers/product_entity_to_model_mapper.dart';
import 'package:yucat/services/review_prompt_service.dart';
import 'package:yucat/services/scan_tracking_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchProductByImageUsecase _fetchProductByImageUsecase;
  final ProductEntityToModelMapper _productEntityToModelMapper;
  final CurrentUserUsecase _currentUserUsecase;
  final SigninAnonymouslyUsecase _signinAnonymouslyUsecase;
  final ScanTrackingService _scanTrackingService;
  final ReviewPromptService _reviewPromptService;
  final HasActiveSubscriptionUseCase _hasActiveSubscriptionUseCase;
  final GetCatsUsecase _getCatsUsecase;
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
    required ReviewPromptService reviewPromptService,
    required HasActiveSubscriptionUseCase hasActiveSubscriptionUseCase,
    required GetCatsUsecase getCatsUsecase,
    required LogEventUsecase logEventUsecase,
    required SharedPreferences prefs,
  }) : _fetchProductByImageUsecase = fetchProductByImageUsecase,
       _productEntityToModelMapper = productEntityToModelMapper,
       _currentUserUsecase = currentUserUsecase,
       _signinAnonymouslyUsecase = signinAnonymouslyUsecase,
       _scanTrackingService = scanTrackingService,
       _reviewPromptService = reviewPromptService,
       _hasActiveSubscriptionUseCase = hasActiveSubscriptionUseCase,
       _getCatsUsecase = getCatsUsecase,
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

    final currentUser = _currentUserUsecase();
    if (currentUser == null) {
      await _signinAnonymouslyUsecase();
    }

    final user = _currentUserUsecase();

    final isPremium = await _hasActiveSubscriptionUseCase();

    String? primaryCatName;
    String? primaryCatPhotoUrl;
    if (user != null) {
      try {
        final cats = await _getCatsUsecase(userId: user.uid);
        if (cats.isNotEmpty) {
          primaryCatName = cats.first.name;
          primaryCatPhotoUrl = cats.first.profileImageUrl;
        }
      } catch (_) {
        // Greeting falls back to generic copy on read failure.
      }
    }

    final currentStreak = _scanTrackingService.getCurrentStreak();

    emit(HomeLoadedState(
      isPremium: isPremium,
      primaryCatName: primaryCatName,
      primaryCatPhotoUrl: primaryCatPhotoUrl,
      currentStreak: currentStreak,
    ));
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

      await _scanTrackingService.recordSuccessfulScan();
      await _reviewPromptService.recordScan();
      // Fire-and-forget; the service applies its own gating.
      unawaited(
        _reviewPromptService.maybePrompt(trigger: 'post_scan'),
      );

      event.context.router.push(
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
