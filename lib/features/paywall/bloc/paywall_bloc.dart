import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:yucat/core/subscription/domain/usecases/has_active_subscription_usecase.dart';
import 'package:yucat/features/paywall/bloc/paywall_event.dart';
import 'package:yucat/features/paywall/bloc/paywall_state.dart';

class PaywallBloc extends Bloc<PaywallEvent, PaywallState> {
  final HasActiveSubscriptionUseCase _hasActiveSubscriptionUseCase;

  PaywallBloc({
    required HasActiveSubscriptionUseCase hasActiveSubscriptionUseCase,
  }) : _hasActiveSubscriptionUseCase = hasActiveSubscriptionUseCase,
       super(const PaywallInitialState()) {
    on<PaywallInitialEvent>(_onPaywallInitialEvent);
  }

  Future<void> _onPaywallInitialEvent(
    PaywallInitialEvent event,
    Emitter<PaywallState> emit,
  ) async {
    debugPrint('PaywallBloc _onPaywallInitialEvent');

    // Only show paywall on iOS
    if (!Platform.isIOS) {
      emit(
        const PaywallErrorState(message: 'Paywall is only available on iOS'),
      );
      return;
    }

    emit(const PaywallLoadingState());

    try {
      final hasActiveSubscription = await _hasActiveSubscriptionUseCase();

      if (hasActiveSubscription) {
        emit(const PaywallAlreadySubscribedState());
        return;
      }

      Offerings? offerings;
      try {
        offerings = await Purchases.getOfferings();
      } on PlatformException catch (e) {
        emit(PaywallErrorState(message: e.message ?? 'Unknown error occurred'));
        return;
      }

      // ignore: avoid_null_checks_equality_operators
      if (offerings == null) {
        emit(
          const PaywallErrorState(
            message: 'No offerings available at this time',
          ),
        );
        return;
      }

      final currentOffering = offerings.current;
      if (currentOffering == null) {
        emit(
          const PaywallErrorState(
            message: 'No offerings available at this time',
          ),
        );
        return;
      } else if (currentOffering.availablePackages.isEmpty) {
        emit(
          const PaywallErrorState(
            message:
                'No subscription packages available. Please configure products in RevenueCat dashboard.',
          ),
        );
        return;
      } else {
        // Current offering is available with packages, show paywall via RevenueCatUI
        // emit(const PaywallLoadedState());
        final paywallResult = await RevenueCatUI.presentPaywall();
        debugPrint('Paywall result: $paywallResult');

        // After paywall is dismissed, sync and check if user purchased subscription
        try {
          await Purchases.syncPurchases();
          // await Future.delayed(const Duration(milliseconds: 500));

          // final updatedCustomerInfo = await Purchases.getCustomerInfo();
          final hasActiveSubscription = await _hasActiveSubscriptionUseCase(
            forceRefresh: true,
          );
          emit(
            PaywallSuccessState(purchasedSubscription: hasActiveSubscription),
          );
        } catch (e) {
          debugPrint('Error checking subscription after paywall: $e');
          try {
            final hasActiveSubscription = await _hasActiveSubscriptionUseCase(
              forceRefresh: true,
            );
            emit(
              PaywallSuccessState(purchasedSubscription: hasActiveSubscription),
            );
          } catch (e2) {
            debugPrint('Error getting customer info: $e2');
            emit(PaywallSuccessState(purchasedSubscription: false));
          }
        }
      }
    } catch (e) {
      debugPrint('Error showing paywall: $e');
      emit(PaywallErrorState(message: 'Error: ${e.toString()}'));
    }
  }
}
