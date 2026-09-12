import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/test_flags.dart';
import 'package:yucat/core/subscription/domain/usecases/get_subscription_status_usecase.dart';
import 'package:yucat/core/subscription/domain/usecases/link_subscription_user_usecase.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/ensure_signed_in_usecase.dart';
import 'package:yucat/services/notification_service.dart';
import 'package:yucat/services/user_analytics_service.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  final SharedPreferences _prefs;
  final GetSubscriptionStatusUseCase _getSubscriptionStatusUseCase;
  final LinkSubscriptionUserUsecase _linkSubscriptionUserUsecase;
  final UserAnalyticsService _userAnalyticsService;
  final EnsureSignedInUsecase _ensureSignedInUsecase;
  final LogEventUsecase _logEventUsecase;
  final NotificationService _notificationService;

  SplashBloc({
    required SharedPreferences prefs,
    required GetSubscriptionStatusUseCase getSubscriptionStatusUseCase,
    required LinkSubscriptionUserUsecase linkSubscriptionUserUsecase,
    required UserAnalyticsService userAnalyticsService,
    required EnsureSignedInUsecase ensureSignedInUsecase,
    required LogEventUsecase logEventUsecase,
    required NotificationService notificationService,
  })  : _prefs = prefs,
        _getSubscriptionStatusUseCase = getSubscriptionStatusUseCase,
        _linkSubscriptionUserUsecase = linkSubscriptionUserUsecase,
        _userAnalyticsService = userAnalyticsService,
        _ensureSignedInUsecase = ensureSignedInUsecase,
        _logEventUsecase = logEventUsecase,
        _notificationService = notificationService,
        super(SplashLoadingState()) {
    on<SplashInitialEvent>(_onSplashInitialEvent);
  }

  Future<void> _onSplashInitialEvent(
    SplashInitialEvent event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashLoadingState());
    final router = event.context.router;

    // Bootstrap auth before routing anywhere. Every launch passes through here
    // first, so guaranteeing an anonymous Firebase session now means the uid is
    // ready for any downstream screen — including the cat-create wizard that
    // runs *inside* onboarding (which previously failed because anonymous
    // sign-in only happened once Home loaded).
    await _ensureSignedIn();

    // QA/TestFlight: replay onboarding on every launch.
    if (kTestBuildResetOnboarding) {
      await _prefs.remove(_onboardingCompletedKey);
    }

    final isCompleted = _prefs.getBool(_onboardingCompletedKey) ?? false;

    // New users go through onboarding, which ends in the hard paywall.
    if (!isCompleted) {
      router.replace(const OnBoardingRoute());
      return;
    }

    // Returning user: pay-to-enter. Anyone without an active subscription
    // (lapsed, force-quit at the paywall, reinstalled) is held at the hard
    // paywall until they subscribe or restore. RevenueCat caches the last
    // known entitlements, so existing subscribers launching offline still pass.
    final status = await _getSubscriptionStatusUseCase(forceRefresh: true);
    final hasSubscription = status.isActive;

    // Keep the People profile's subscription state fresh on every cold launch
    // of a returning user (handles lapses/renewals between sessions). The
    // OneSignal tag has to be refreshed here too, not just on purchase — a
    // churned subscriber would otherwise keep is_subscriber = true for ever and
    // never enter a win-back segment. `is_trial` rides along for the same
    // reason: it is what ends the trial Journey once the trial converts.
    _userAnalyticsService.syncSubscription(
      isSubscriber: hasSubscription,
      isTrial: status.isTrial,
    );
    _notificationService.setSubscriber(hasSubscription, isTrial: status.isTrial);

    if (hasSubscription || kTestBuildSkipPaywall) {
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

  /// Ensures an anonymous Firebase session exists and binds the Mixpanel
  /// profile, the OneSignal user and the RevenueCat customer to its uid.
  /// Awaited at boot so the uid is ready for every route — and so the
  /// RevenueCat link lands *before* the entitlement check below reads it.
  /// Safe to call repeatedly; never throws to the caller.
  ///
  /// OneSignal is identified *here* rather than at Home because Home is only
  /// reached after onboarding, cat creation and the paywall all succeed — i.e.
  /// only by users who converted. Identifying at boot means funnel tags written
  /// by users who drop out land on an identified user instead of an anonymous
  /// device record.
  Future<void> _ensureSignedIn() async {
    try {
      final user = await _ensureSignedInUsecase();
      if (user == null) {
        // Boot continues into onboarding either way, but every uid-dependent
        // screen downstream is now degraded — most sharply cat creation, which
        // cannot write without one. Emit it so the failure is visible instead
        // of surfacing later as a mystery crash at the end of the wizard.
        _logEventUsecase.call(
          eventName: AnalyticsEvents.authSignInFailed,
          properties: {
            'stage': 'splash',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        return;
      }

      await _userAnalyticsService.identify(user.uid);
      await _notificationService.login(user.uid);
      // One key across the three systems: RevenueCat's Mixpanel integration
      // posts trial/renewal/churn events onto whatever distinct id it holds,
      // and that has to be the same uid the app's own events use.
      await _linkSubscriptionUserUsecase(user.uid);
      // Every launch passes through here, including new users who return
      // early below — so this is the one place recency is guaranteed to be
      // stamped for everyone.
      await _notificationService.setLastActive();
    } catch (e) {
      debugPrint('SplashBloc._ensureSignedIn error: $e');
    }
  }
}
