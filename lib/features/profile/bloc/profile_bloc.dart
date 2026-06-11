import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/core/subscription/domain/usecases/has_active_subscription_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/usecases/get_cats_usecase.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/profile/bloc/profile_event.dart';
import 'package:yucat/features/profile/bloc/profile_state.dart';
import 'package:yucat/features/saved_products/domain/usecases/get_saved_products_usecase.dart';
import 'package:yucat/features/scan_history/domain/usecases/get_scan_history_usecase.dart';
import 'package:yucat/l10n/app_localizations.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  final SharedPreferences _prefs;
  final HasActiveSubscriptionUseCase _hasActiveSubscriptionUseCase;
  final GetCatsUsecase _getCatsUsecase;
  final GetSavedProductsUsecase _getSavedProductsUsecase;
  final GetScanHistoryUsecase _getScanHistoryUsecase;
  final CurrentUserUsecase _currentUserUsecase;
  final LogEventUsecase _logEventUsecase;

  ProfileBloc({
    required SharedPreferences prefs,
    required HasActiveSubscriptionUseCase hasActiveSubscriptionUseCase,
    required GetCatsUsecase getCatsUsecase,
    required GetSavedProductsUsecase getSavedProductsUsecase,
    required GetScanHistoryUsecase getScanHistoryUsecase,
    required CurrentUserUsecase currentUserUsecase,
    required LogEventUsecase logEventUsecase,
  })  : _prefs = prefs,
        _hasActiveSubscriptionUseCase = hasActiveSubscriptionUseCase,
        _getCatsUsecase = getCatsUsecase,
        _getSavedProductsUsecase = getSavedProductsUsecase,
        _getScanHistoryUsecase = getScanHistoryUsecase,
        _currentUserUsecase = currentUserUsecase,
        _logEventUsecase = logEventUsecase,
        super(ProfileHiddenState()) {
    on<ProfileInitialEvent>(_onProfileInitialEvent);
    on<ResetOnboardingTapEvent>(_onResetOnboardingTapEvent);
    on<RestorePurchasesTapEvent>(_onRestorePurchasesTapEvent);
  }

  Future<void> _onProfileInitialEvent(
    ProfileInitialEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadingState());

    List<CatEntity> cats = const [];
    final user = _currentUserUsecase();
    if (user != null) {
      try {
        cats = await _getCatsUsecase(userId: user.uid);
      } catch (_) {
        // The cats section falls back to empty on read failure.
      }
    }

    List<ProductDisplayModel> savedProducts = const [];
    try {
      savedProducts = await _getSavedProductsUsecase();
    } catch (_) {
      // Library preview falls back to empty on read failure.
    }

    List<ProductDisplayModel> scanHistory = const [];
    try {
      scanHistory = await _getScanHistoryUsecase();
    } catch (_) {
      // Library preview falls back to empty on read failure.
    }

    emit(ProfileLoadedState(
      cats: cats,
      savedProducts: savedProducts,
      scanHistory: scanHistory,
    ));
  }

  Future<void> _onResetOnboardingTapEvent(
    ResetOnboardingTapEvent event,
    Emitter<ProfileState> emit,
  ) async {
    await _prefs.remove(_onboardingCompletedKey);
    if (event.context.mounted) {
      event.context.router.replaceAll([const OnBoardingRoute()]);
    }
  }

  Future<void> _onRestorePurchasesTapEvent(
    RestorePurchasesTapEvent event,
    Emitter<ProfileState> emit,
  ) async {
    _logEventUsecase.call(
      eventName: 'Subscription Restore Tapped',
      properties: {'timestamp': DateTime.now().toIso8601String()},
    );

    // Capture the messenger and l10n before any await so we never touch a stale context.
    final messenger = ScaffoldMessenger.of(event.context);
    final l10n = AppLocalizations.of(event.context);
    void snack(String message) =>
        messenger.showSnackBar(SnackBar(content: Text(message)));

    // RevenueCat is only configured on iOS (see main.dart).
    if (!Platform.isIOS) {
      snack(l10n.profileRestoreNotAvailable);
      return;
    }

    try {
      await Purchases.restorePurchases();
      final isActive = await _hasActiveSubscriptionUseCase(forceRefresh: true);

      if (isActive) {
        _logEventUsecase.call(
          eventName: 'Subscription Restored',
          properties: {'timestamp': DateTime.now().toIso8601String()},
        );
        snack(l10n.profileRestoreSuccess);
      } else {
        snack(l10n.profileNoSubscriptionFound);
      }
    } catch (e) {
      debugPrint('ProfileBloc.restore error: $e');
      snack(l10n.profileRestoreError);
    }
  }
}
