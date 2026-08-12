import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:yucat/features/paywall/utils/trial_info.dart';

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

  /// The free trial this user will actually receive on [selectedPackage], or
  /// null when the product has no trial or this user isn't eligible for it.
  ///
  /// Null is the fail-closed default: every trial claim on the paywall — the
  /// badge, the CTA, the disclosure — is gated on this being non-null, so a
  /// failed eligibility check degrades to the plain full-price paywall rather
  /// than promising a trial the store won't honour.
  final TrialInfo? eligibleTrial;

  /// One-shot transient error for a SnackBar (cleared after listener fires).
  /// Increments [errorTick] every time we want to re-fire the SnackBar so
  /// [BlocListener] sees a state change even if the kind is the same.
  final PaywallTransientError? transientError;
  final int errorTick;

  const PaywallLoadedState({
    required this.currentOffering,
    required this.packages,
    required this.selectedPackage,
    this.eligibleTrial,
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
      eligibleTrial: eligibleTrial,
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
        // [TrialInfo] isn't Equatable; the day count is the only part that
        // affects rendering, so compare on that rather than on identity.
        eligibleTrial?.days,
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
