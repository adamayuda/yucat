import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:yucat/core/subscription/domain/usecases/has_active_subscription_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/paywall/bloc/paywall_event.dart';
import 'package:yucat/features/paywall/bloc/paywall_state.dart';

class PaywallBloc extends Bloc<PaywallEvent, PaywallState> {
  final HasActiveSubscriptionUseCase _hasActiveSubscriptionUseCase;
  final LogEventUsecase _logEventUsecase;

  DateTime? _paywallShownTime;

  PaywallBloc({
    required HasActiveSubscriptionUseCase hasActiveSubscriptionUseCase,
    required LogEventUsecase logEventUsecase,
  })  : _hasActiveSubscriptionUseCase = hasActiveSubscriptionUseCase,
        _logEventUsecase = logEventUsecase,
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
    if (!Platform.isIOS) {
      emit(const PaywallErrorState(
        message: 'Subscriptions are only available on iOS.',
      ));
      return;
    }

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
      eventName: 'Paywall Shown',
      properties: {
        'trigger': 'manual',
        'offering': current.identifier,
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
          eventName: 'Subscription Completed',
          properties: {
            'package_id': current.selectedPackage.identifier,
            'package_type': current.selectedPackage.packageType.name,
            'price': current.selectedPackage.storeProduct.price,
            'currency':
                current.selectedPackage.storeProduct.currencyCode,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        _logPaywallDismissed(ctaTapped: true);
        emit(const PaywallSuccessState(purchasedSubscription: true));
      } else {
        emit(current.copyWith(
          isPurchasing: false,
          transientError: 'Purchase did not complete. Please try again.',
          errorTick: current.errorTick + 1,
        ));
      }
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        emit(current.copyWith(isPurchasing: false));
        return;
      }
      emit(current.copyWith(
        isPurchasing: false,
        transientError: e.message ?? 'Purchase failed. Please try again.',
        errorTick: current.errorTick + 1,
      ));
    } catch (e) {
      debugPrint('PaywallBloc.purchase error: $e');
      emit(current.copyWith(
        isPurchasing: false,
        transientError: 'Something went wrong. Please try again.',
        errorTick: current.errorTick + 1,
      ));
    }
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
          eventName: 'Subscription Restored',
          properties: {
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        _logPaywallDismissed(ctaTapped: true);
        emit(const PaywallSuccessState(purchasedSubscription: true));
      } else {
        emit(current.copyWith(
          isPurchasing: false,
          transientError: 'No active subscription found.',
          errorTick: current.errorTick + 1,
        ));
      }
    } catch (e) {
      debugPrint('PaywallBloc.restore error: $e');
      emit(current.copyWith(
        isPurchasing: false,
        transientError: 'Could not restore purchases. Please try again.',
        errorTick: current.errorTick + 1,
      ));
    }
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
