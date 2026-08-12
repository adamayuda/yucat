import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:yucat/core/subscription/domain/usecases/has_active_subscription_usecase.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/paywall/bloc/paywall_event.dart';
import 'package:yucat/features/paywall/bloc/paywall_state.dart';
import 'package:yucat/features/paywall/utils/trial_info.dart';
import 'package:yucat/services/user_analytics_service.dart';

class PaywallBloc extends Bloc<PaywallEvent, PaywallState> {
  final HasActiveSubscriptionUseCase _hasActiveSubscriptionUseCase;
  final LogEventUsecase _logEventUsecase;
  final UserAnalyticsService _userAnalyticsService;

  DateTime? _paywallShownTime;
  String _trigger = 'manual';

  PaywallBloc({
    required HasActiveSubscriptionUseCase hasActiveSubscriptionUseCase,
    required LogEventUsecase logEventUsecase,
    required UserAnalyticsService userAnalyticsService,
  })  : _hasActiveSubscriptionUseCase = hasActiveSubscriptionUseCase,
        _logEventUsecase = logEventUsecase,
        _userAnalyticsService = userAnalyticsService,
        super(const PaywallInitialState()) {
    on<PaywallInitialEvent>(_onInitial);
    on<PaywallPackageSelectedEvent>(_onPackageSelected);
    on<PaywallPurchaseEvent>(_onPurchase);
    on<PaywallRestoreEvent>(_onRestore);
    on<PaywallDismissEvent>(_onDismiss);
  }

  Future<void> _onInitial(
    PaywallInitialEvent event,
    Emitter<PaywallState> emit,
  ) async {
    _trigger = event.trigger;
    emit(const PaywallLoadingState());

    if (await _hasActiveSubscriptionUseCase()) {
      emit(const PaywallAlreadySubscribedState());
      return;
    }

    final Offerings offerings;
    try {
      offerings = await Purchases.getOfferings();
    } on PlatformException catch (_) {
      emit(const PaywallErrorState(kind: PaywallError.couldNotLoadPlans));
      return;
    }

    final current = offerings.current;
    if (current == null || current.availablePackages.isEmpty) {
      emit(const PaywallErrorState(kind: PaywallError.noPlansAvailable));
      return;
    }

    // The paywall offers a single annual plan. Weekly is still published in the
    // offering (and still billed for existing subscribers), it's just not shown
    // — flip this filter to bring it back.
    final annualOnly = current.availablePackages
        .where((p) => p.packageType == PackageType.annual)
        .toList();
    // Fall back to the first available package if the offering is
    // misconfigured, so the paywall never renders empty.
    final packages =
        annualOnly.isNotEmpty ? annualOnly : [current.availablePackages.first];
    final selected = packages.first;

    // The trial this user will actually receive — null when the product has no
    // trial configured or the store says they've already used one.
    final eligibleTrial = await _eligibleTrialFor(selected);

    _paywallShownTime = DateTime.now();
    _logEventUsecase.call(
      eventName: AnalyticsEvents.paywallShown,
      properties: {
        'trigger': _trigger,
        'offering': current.identifier,
        'trial_eligible': eligibleTrial != null,
        'trial_days': eligibleTrial?.days,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    emit(PaywallLoadedState(
      currentOffering: current,
      packages: packages,
      selectedPackage: selected,
      eligibleTrial: eligibleTrial,
    ));
  }

  /// The free trial [pkg] will actually grant this user, or null.
  ///
  /// The two stores need different eligibility signals:
  ///
  /// * **iOS** — RevenueCat computes StoreKit eligibility for us. We fail closed
  ///   on unknown/ineligible/error/timeout so an ineligible user is never shown
  ///   a trial they can't get.
  /// * **Android** — `checkTrialOrIntroductoryPriceEligibility` *always* returns
  ///   unknown (see the SDK doc on that method), so it's useless here. Google
  ///   Play instead filters offers server-side: an offer restricted to new
  ///   customers simply isn't returned to an ineligible user. So the presence of
  ///   a `freePhase` on the product IS the eligibility signal. This depends on
  ///   the Play offer being configured "new customers only" — see the store
  ///   setup notes in CLAUDE.md.
  Future<TrialInfo?> _eligibleTrialFor(Package pkg) async {
    final trial = trialInfoFor(pkg);
    if (trial == null) return null;

    if (Platform.isAndroid) return trial;

    try {
      final result = await Purchases.checkTrialOrIntroductoryPriceEligibility(
        [pkg.storeProduct.identifier],
      ).timeout(const Duration(seconds: 5));
      final status = result[pkg.storeProduct.identifier]?.status;
      return status == IntroEligibilityStatus.introEligibilityStatusEligible
          ? trial
          : null;
    } catch (e) {
      debugPrint('PaywallBloc.trialEligibility error: $e');
      return null;
    }
  }

  void _onPackageSelected(
    PaywallPackageSelectedEvent event,
    Emitter<PaywallState> emit,
  ) {
    final current = state;
    if (current is! PaywallLoadedState) return;
    if (current.selectedPackage.identifier != event.package.identifier) {
      _logEventUsecase.call(
        eventName: AnalyticsEvents.planSelected,
        properties: {
          'package_id': event.package.identifier,
          'package_type': event.package.packageType.name,
          'trigger': _trigger,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
    emit(current.copyWith(selectedPackage: event.package));
  }

  Future<void> _onPurchase(
    PaywallPurchaseEvent event,
    Emitter<PaywallState> emit,
  ) async {
    final current = state;
    if (current is! PaywallLoadedState || current.isPurchasing) return;

    emit(current.copyWith(isPurchasing: true));

    try {
      await Purchases.purchase(
        PurchaseParams.package(current.selectedPackage),
      );
      await Purchases.syncPurchases();

      final isActive =
          await _hasActiveSubscriptionUseCase(forceRefresh: true);

      if (isActive) {
        _logEventUsecase.call(
          eventName: AnalyticsEvents.subscriptionCompleted,
          properties: {
            'package_id': current.selectedPackage.identifier,
            'package_type': current.selectedPackage.packageType.name,
            'price': current.selectedPackage.storeProduct.price,
            'currency':
                current.selectedPackage.storeProduct.currencyCode,
            'trigger': _trigger,
            // Trial starts bill nothing today — downstream revenue reporting
            // needs to tell them apart from immediate purchases.
            'is_trial': current.eligibleTrial != null,
            'trial_days': current.eligibleTrial?.days,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        _userAnalyticsService.syncSubscription(
          isSubscriber: true,
          plan: current.selectedPackage.packageType.name,
          price: current.selectedPackage.storeProduct.price,
          currency: current.selectedPackage.storeProduct.currencyCode,
        );
        _logPaywallDismissed(ctaTapped: true);
        emit(const PaywallSuccessState(purchasedSubscription: true));
      } else {
        _logPurchaseFailed(reason: 'not_active', packageType: current.selectedPackage.packageType.name);
        emit(current.copyWith(
          isPurchasing: false,
          transientError: PaywallTransientError.purchaseNotComplete,
          errorTick: current.errorTick + 1,
        ));
      }
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        _logPurchaseFailed(
          reason: 'cancelled',
          packageType: current.selectedPackage.packageType.name,
        );
        emit(current.copyWith(isPurchasing: false));
        return;
      }
      _logPurchaseFailed(
        reason: 'platform_error',
        errorMessage: e.message,
        packageType: current.selectedPackage.packageType.name,
      );
      emit(current.copyWith(
        isPurchasing: false,
        transientError: PaywallTransientError.purchaseFailed,
        errorTick: current.errorTick + 1,
      ));
    } catch (e) {
      debugPrint('PaywallBloc.purchase error: $e');
      _logPurchaseFailed(
        reason: 'unknown',
        errorMessage: e.toString(),
        packageType: current.selectedPackage.packageType.name,
      );
      emit(current.copyWith(
        isPurchasing: false,
        transientError: PaywallTransientError.somethingWentWrong,
        errorTick: current.errorTick + 1,
      ));
    }
  }

  void _logPurchaseFailed({
    required String reason,
    String? errorMessage,
    String? packageType,
  }) {
    _logEventUsecase.call(
      eventName: AnalyticsEvents.subscriptionPurchaseFailed,
      properties: {
        'reason': reason,
        if (errorMessage != null) 'error_message': errorMessage,
        if (packageType != null) 'package_type': packageType,
        'trigger': _trigger,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> _onRestore(
    PaywallRestoreEvent event,
    Emitter<PaywallState> emit,
  ) async {
    final current = state;
    if (current is! PaywallLoadedState || current.isPurchasing) return;

    emit(current.copyWith(isPurchasing: true));

    try {
      await Purchases.restorePurchases();
      final isActive =
          await _hasActiveSubscriptionUseCase(forceRefresh: true);

      if (isActive) {
        _logEventUsecase.call(
          eventName: AnalyticsEvents.subscriptionRestored,
          properties: {
            'trigger': _trigger,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        _userAnalyticsService.syncSubscription(isSubscriber: true);
        _logPaywallDismissed(ctaTapped: true);
        emit(const PaywallSuccessState(purchasedSubscription: true));
      } else {
        _logRestoreFailed(reason: 'no_active_subscription');
        emit(current.copyWith(
          isPurchasing: false,
          transientError: PaywallTransientError.noActiveSubscription,
          errorTick: current.errorTick + 1,
        ));
      }
    } catch (e) {
      debugPrint('PaywallBloc.restore error: $e');
      _logRestoreFailed(reason: 'error', errorMessage: e.toString());
      emit(current.copyWith(
        isPurchasing: false,
        transientError: PaywallTransientError.restoreFailed,
        errorTick: current.errorTick + 1,
      ));
    }
  }

  void _logRestoreFailed({required String reason, String? errorMessage}) {
    _logEventUsecase.call(
      eventName: AnalyticsEvents.subscriptionRestoreFailed,
      properties: {
        'reason': reason,
        if (errorMessage != null) 'error_message': errorMessage,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  void _onDismiss(
    PaywallDismissEvent event,
    Emitter<PaywallState> emit,
  ) {
    _logPaywallDismissed(ctaTapped: false);
    emit(const PaywallSuccessState(purchasedSubscription: false));
  }

  void _logPaywallDismissed({required bool ctaTapped}) {
    final timeViewedSeconds = _paywallShownTime != null
        ? DateTime.now().difference(_paywallShownTime!).inSeconds
        : null;
    _logEventUsecase.call(
      eventName: 'Paywall Dismissed',
      properties: {
        'time_viewed_seconds': timeViewedSeconds,
        'cta_tapped': ctaTapped,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
