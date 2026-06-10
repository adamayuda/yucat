import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:yucat/core/subscription/domain/usecases/has_active_subscription_usecase.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/paywall/bloc/paywall_event.dart';
import 'package:yucat/features/paywall/bloc/paywall_state.dart';
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
    on<PaywallPromoToggledEvent>(_onPromoToggled);
  }

  Future<void> _onInitial(
    PaywallInitialEvent event,
    Emitter<PaywallState> emit,
  ) async {
    if (!Platform.isIOS) {
      emit(const PaywallErrorState(
        message: 'Subscriptions are only available on iOS.',
      ));
      return;
    }

    _trigger = event.trigger;
    emit(const PaywallLoadingState());

    if (await _hasActiveSubscriptionUseCase()) {
      emit(const PaywallAlreadySubscribedState());
      return;
    }

    final Offerings offerings;
    try {
      offerings = await Purchases.getOfferings();
    } on PlatformException catch (e) {
      emit(PaywallErrorState(message: e.message ?? 'Could not load plans.'));
      return;
    }

    final current = offerings.current;
    if (current == null || current.availablePackages.isEmpty) {
      emit(const PaywallErrorState(
        message: 'No subscription plans are available right now.',
      ));
      return;
    }

    final allowed = current.availablePackages
        .where((p) =>
            p.packageType == PackageType.weekly ||
            p.packageType == PackageType.annual)
        .toList();
    // Fall back to the raw list if the offering is misconfigured, so the
    // paywall never renders empty.
    final packages = allowed.isNotEmpty ? allowed : current.availablePackages;
    final annual = packages.firstWhere(
      (p) => p.packageType == PackageType.annual,
      orElse: () => packages.first,
    );

    // Whether this user can actually receive the annual plan's introductory
    // offer. `storeProduct.introductoryPrice` reflects the product config, not
    // per-user eligibility, so we check explicitly before advertising the promo.
    final introEligible = await _isIntroEligible(annual);

    _paywallShownTime = DateTime.now();
    _logEventUsecase.call(
      eventName: AnalyticsEvents.paywallShown,
      properties: {
        'trigger': _trigger,
        'offering': current.identifier,
        'intro_eligible': introEligible,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    emit(PaywallLoadedState(
      currentOffering: current,
      packages: packages,
      selectedPackage: annual,
      introEligible: introEligible,
    ));
  }

  /// Returns true only when [pkg] has a configured introductory offer AND this
  /// user is eligible for it. On any error/unknown status we fail closed
  /// (no promo) so we never show a discount the user won't be charged.
  Future<bool> _isIntroEligible(Package pkg) async {
    if (pkg.storeProduct.introductoryPrice == null) return false;
    try {
      final result = await Purchases.checkTrialOrIntroductoryPriceEligibility(
        [pkg.storeProduct.identifier],
      );
      final status = result[pkg.storeProduct.identifier]?.status;
      return status == IntroEligibilityStatus.introEligibilityStatusEligible;
    } catch (e) {
      debugPrint('PaywallBloc.introEligibility error: $e');
      return false;
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
          transientError: 'Purchase did not complete. Please try again.',
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
        transientError: e.message ?? 'Purchase failed. Please try again.',
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
        transientError: 'Something went wrong. Please try again.',
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
          transientError: 'No active subscription found.',
          errorTick: current.errorTick + 1,
        ));
      }
    } catch (e) {
      debugPrint('PaywallBloc.restore error: $e');
      _logRestoreFailed(reason: 'error', errorMessage: e.toString());
      emit(current.copyWith(
        isPurchasing: false,
        transientError: 'Could not restore purchases. Please try again.',
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

  void _onPromoToggled(
    PaywallPromoToggledEvent event,
    Emitter<PaywallState> emit,
  ) {
    _logEventUsecase.call(
      eventName: AnalyticsEvents.paywallPromoToggled,
      properties: {
        'promo_on': event.promoOn,
        'trigger': _trigger,
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
