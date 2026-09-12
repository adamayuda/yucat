import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:yucat/features/paywall/utils/intro_offer_info.dart';
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

  /// The discounted plan offered **once**, after the user backs out of the
  /// store sheet — the offering's `annual_offer` package (same yearly plan with
  /// a pay-up-front first year), or null when the offering has none *or this
  /// user isn't eligible for its introductory offer*, in which case the sheet
  /// never shows. Resolved at load alongside [packages]; deliberately *not* in
  /// [packages], so the main paywall keeps rendering a single plan.
  final Package? secondChancePackage;

  /// The verified-eligible discount on [secondChancePackage]; non-null exactly
  /// when [secondChancePackage] is. Carried so the sheet can quote the store's
  /// own intro price without re-reading the product.
  final IntroOfferInfo? secondChanceIntro;

  /// When the offer stops being available in *this paywall session* — set
  /// the first time the sheet is presented (`PaywallBloc.secondChanceWindow`
  /// later), in memory only. The countdown counts to it; at zero the sheet
  /// closes and [withoutSecondChance] drops the offer and the close chip for
  /// the rest of the session. The next session starts a fresh window, which
  /// is what lets the "dropped at paywall" push a day later still be honest.
  final DateTime? secondChanceDeadline;

  /// The free trial this user will actually receive on [selectedPackage], or
  /// null when the product has no trial or this user isn't eligible for it.
  ///
  /// Null is the fail-closed default: every trial claim on the paywall — the
  /// badge, the CTA, the disclosure — is gated on this being non-null, so a
  /// failed eligibility check degrades to the plain full-price paywall rather
  /// than promising a trial the store won't honour.
  ///
  /// Tied to [selectedPackage]: changing the selection goes through
  /// [withSelection], which re-resolves it, never through [copyWith].
  final TrialInfo? eligibleTrial;

  /// The paid introductory offer this user will actually receive on
  /// [selectedPackage], or null. Same fail-closed contract as [eligibleTrial];
  /// the two are mutually exclusive on a given product.
  final IntroOfferInfo? eligibleIntro;

  /// One-shot transient error for a SnackBar (cleared after listener fires).
  /// Increments [errorTick] every time we want to re-fire the SnackBar so
  /// [BlocListener] sees a state change even if the kind is the same.
  final PaywallTransientError? transientError;
  final int errorTick;

  /// One-shot signal to present the second-chance sheet, on the same pattern
  /// as [errorTick]: the page remembers the last tick it acted on and shows
  /// the sheet whenever a new one arrives.
  final int secondChanceTick;

  const PaywallLoadedState({
    required this.currentOffering,
    required this.packages,
    required this.selectedPackage,
    this.secondChancePackage,
    this.secondChanceIntro,
    this.secondChanceDeadline,
    this.eligibleTrial,
    this.eligibleIntro,
    this.isPurchasing = false,
    this.transientError,
    this.errorTick = 0,
    this.secondChanceTick = 0,
  });

  /// Everything except the selection. [transientError] is a one-shot and
  /// self-clears unless passed explicitly.
  PaywallLoadedState copyWith({
    bool? isPurchasing,
    PaywallTransientError? transientError,
    int? errorTick,
    int? secondChanceTick,
    DateTime? secondChanceDeadline,
  }) {
    return PaywallLoadedState(
      currentOffering: currentOffering,
      packages: packages,
      selectedPackage: selectedPackage,
      secondChancePackage: secondChancePackage,
      secondChanceIntro: secondChanceIntro,
      secondChanceDeadline: secondChanceDeadline ?? this.secondChanceDeadline,
      eligibleTrial: eligibleTrial,
      eligibleIntro: eligibleIntro,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      transientError: transientError,
      errorTick: errorTick ?? this.errorTick,
      secondChanceTick: secondChanceTick ?? this.secondChanceTick,
    );
  }

  /// The offer's window ran out this session: drop it, which also removes
  /// the delayed close chip (it only renders while a package is present).
  PaywallLoadedState withoutSecondChance() {
    return PaywallLoadedState(
      currentOffering: currentOffering,
      packages: packages,
      selectedPackage: selectedPackage,
      eligibleTrial: eligibleTrial,
      eligibleIntro: eligibleIntro,
      isPurchasing: isPurchasing,
      errorTick: errorTick,
      secondChanceTick: secondChanceTick,
    );
  }

  /// Switch the selected plan. The offers travel with the package — the
  /// discounted yearly must not inherit the standard yearly's trial, or the
  /// CTA, the disclosure and `Subscription Completed { is_trial }` all lie.
  PaywallLoadedState withSelection({
    required Package package,
    required TrialInfo? eligibleTrial,
    required IntroOfferInfo? eligibleIntro,
  }) {
    return PaywallLoadedState(
      currentOffering: currentOffering,
      packages: packages,
      selectedPackage: package,
      secondChancePackage: secondChancePackage,
      secondChanceIntro: secondChanceIntro,
      secondChanceDeadline: secondChanceDeadline,
      eligibleTrial: eligibleTrial,
      eligibleIntro: eligibleIntro,
      isPurchasing: false,
      errorTick: errorTick,
      secondChanceTick: secondChanceTick,
    );
  }

  @override
  List<Object?> get props => [
        currentOffering.identifier,
        packages.map((p) => p.identifier).toList(),
        selectedPackage.identifier,
        secondChancePackage?.identifier,
        secondChanceIntro?.priceString,
        secondChanceDeadline,
        // [TrialInfo] isn't Equatable; the day count is the only part that
        // affects rendering, so compare on that rather than on identity.
        eligibleTrial?.days,
        eligibleIntro?.priceString,
        isPurchasing,
        transientError,
        errorTick,
        secondChanceTick,
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
