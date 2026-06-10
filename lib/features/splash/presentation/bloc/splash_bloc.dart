import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/core/subscription/domain/usecases/has_active_subscription_usecase.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/services/user_analytics_service.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  final SharedPreferences _prefs;
  final HasActiveSubscriptionUseCase _hasActiveSubscriptionUseCase;
  final UserAnalyticsService _userAnalyticsService;

  SplashBloc({
    required SharedPreferences prefs,
    required HasActiveSubscriptionUseCase hasActiveSubscriptionUseCase,
    required UserAnalyticsService userAnalyticsService,
  })  : _prefs = prefs,
        _hasActiveSubscriptionUseCase = hasActiveSubscriptionUseCase,
        _userAnalyticsService = userAnalyticsService,
        super(SplashLoadingState()) {
    on<SplashInitialEvent>(_onSplashInitialEvent);
  }

  Future<void> _onSplashInitialEvent(
    SplashInitialEvent event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashLoadingState());
    final router = event.context.router;

    final isCompleted = _prefs.getBool(_onboardingCompletedKey) ?? false;

    // New users go through onboarding, which ends in the hard paywall.
    if (!isCompleted) {
      router.replace(const OnBoardingRoute());
      return;
    }

    // Subscriptions (and the gate) are iOS-only.
    if (!Platform.isIOS) {
      router.replace(const HomeRoute());
      return;
    }

    // Returning user: pay-to-enter. Anyone without an active subscription
    // (lapsed, force-quit at the paywall, reinstalled) is held at the hard
    // paywall until they subscribe or restore. RevenueCat caches the last
    // known entitlements, so existing subscribers launching offline still pass.
    final hasSubscription =
        await _hasActiveSubscriptionUseCase(forceRefresh: true);

    // Keep the People profile's subscription state fresh on every cold launch
    // of a returning user (handles lapses/renewals between sessions).
    _userAnalyticsService.syncSubscription(isSubscriber: hasSubscription);

    if (hasSubscription) {
      router.replace(const HomeRoute());
    } else {
      await router.push(
        PaywallRoute(
          dismissible: false,
          trigger: PaywallTrigger.returningUser,
        ),
      );
      router.replace(const HomeRoute());
    }
  }
}
