import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Fatal paywall load failures (full-screen error). The UI maps these to
/// localized copy — no user-facing strings live in the bloc.
enum PaywallError { iosOnly, couldNotLoadPlans, noPlansAvailable }

/// One-shot non-fatal failures surfaced as a SnackBar over the loaded paywall.
enum PaywallTransientError {
  purchaseNotComplete,
  purchaseFailed,
  somethingWentWrong,
  noActiveSubscription,
  restoreFailed,
}

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

  /// Whether the current user is eligible for the annual plan's introductory
  /// offer. Gates the promo switch so we never advertise an intro price the
  /// user won't actually be charged.
  final bool introEligible;

  /// One-shot transient error for a SnackBar (cleared after listener fires).
  /// Increments [errorTick] every time we want to re-fire the SnackBar so
  /// [BlocListener] sees a state change even if the kind is the same.
  final PaywallTransientError? transientError;
  final int errorTick;

  const PaywallLoadedState({
    required this.currentOffering,
    required this.packages,
    required this.selectedPackage,
    this.introEligible = false,
    this.isPurchasing = false,
    this.transientError,
    this.errorTick = 0,
  });

  PaywallLoadedState copyWith({
    Package? selectedPackage,
    bool? isPurchasing,
    PaywallTransientError? transientError,
    int? errorTick,
  }) {
    return PaywallLoadedState(
      currentOffering: currentOffering,
      packages: packages,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      introEligible: introEligible,
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
        introEligible,
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
  final PaywallError kind;

  const PaywallErrorState({required this.kind});

  @override
  List<Object?> get props => [kind];
}

class PaywallAlreadySubscribedState extends PaywallState {
  const PaywallAlreadySubscribedState();
}
