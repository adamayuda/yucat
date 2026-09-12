import 'package:purchases_flutter/purchases_flutter.dart';

/// A *paid* introductory offer configured on a package's store product — a
/// discounted first period, as opposed to a free trial ([TrialInfo]).
///
/// Presence means the product offers the discount, not that this user can
/// have it; eligibility is resolved in `PaywallBloc`, the one place allowed
/// to decide what the paywall advertises. On Apple, one introductory offer per
/// subscription group per customer — so a user who has already taken the
/// yearly plan's trial is ineligible here too, and the bloc drops the offer.
class IntroOfferInfo {
  /// The store's own formatted price ("€19.99") — never format a number
  /// yourself; symbol, placement and separators are all locale-dependent.
  final String priceString;
  final double price;

  /// Raw period of the discounted phase, kept for analytics and copy.
  final PeriodUnit unit;
  final int unitCount;

  const IntroOfferInfo({
    required this.priceString,
    required this.price,
    required this.unit,
    required this.unitCount,
  });
}

/// Resolves the paid introductory offer on [pkg], or null when it has none.
///
/// Mirrors `trialInfoFor`: StoreKit folds trials and discounts into
/// [StoreProduct.introductoryPrice], so a **non-zero** price is what makes it
/// a discount here (a zero price is the trial and returns null). Google Play
/// keeps a discounted first period in `introPhase`, separate from `freePhase`.
IntroOfferInfo? introOfferFor(Package pkg) {
  final product = pkg.storeProduct;

  // --- Google Play ---------------------------------------------------------
  final phase = product.defaultOption?.introPhase;
  if (phase != null && phase.price.amountMicros > 0) {
    final period = phase.billingPeriod;
    if (period != null && period.value > 0) {
      return IntroOfferInfo(
        priceString: phase.price.formatted,
        price: phase.price.amountMicros / 1000000,
        unit: period.unit,
        unitCount: period.value,
      );
    }
  }

  // --- StoreKit ------------------------------------------------------------
  final intro = product.introductoryPrice;
  if (intro != null && intro.price > 0 && intro.periodNumberOfUnits > 0) {
    return IntroOfferInfo(
      priceString: intro.priceString,
      price: intro.price,
      unit: intro.periodUnit,
      unitCount: intro.periodNumberOfUnits,
    );
  }

  return null;
}
