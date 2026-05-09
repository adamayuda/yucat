import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

sealed class PaywallState extends Equatable {
  const PaywallState();

  @override
  List<Object?> get props => [];
}

class PaywallInitialState extends PaywallState {
  const PaywallInitialState();
}

class PaywallLoadingState extends PaywallState {
  const PaywallLoadingState();
}

class PaywallLoadedState extends PaywallState {
  final Offering currentOffering;
  final List<Package> packages;
  final Package selectedPackage;
  final bool isPurchasing;

  /// One-shot transient error message for SnackBar (cleared after listener fires).
  /// Increments [errorTick] every time we want to re-fire the SnackBar so
  /// [BlocListener] sees a state change even if the message is the same.
  final String? transientError;
  final int errorTick;

  const PaywallLoadedState({
    required this.currentOffering,
    required this.packages,
    required this.selectedPackage,
    this.isPurchasing = false,
    this.transientError,
    this.errorTick = 0,
  });

  PaywallLoadedState copyWith({
    Package? selectedPackage,
    bool? isPurchasing,
    String? transientError,
    int? errorTick,
  }) {
    return PaywallLoadedState(
      currentOffering: currentOffering,
      packages: packages,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      transientError: transientError,
      errorTick: errorTick ?? this.errorTick,
    );
  }

  @override
  List<Object?> get props => [
        currentOffering.identifier,
        packages.map((p) => p.identifier).toList(),
        selectedPackage.identifier,
        isPurchasing,
        transientError,
        errorTick,
      ];
}

class PaywallSuccessState extends PaywallState {
  final bool purchasedSubscription;

  const PaywallSuccessState({required this.purchasedSubscription});

  @override
  List<Object?> get props => [purchasedSubscription];
}

class PaywallErrorState extends PaywallState {
  final String message;

  const PaywallErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class PaywallAlreadySubscribedState extends PaywallState {
  const PaywallAlreadySubscribedState();
}
