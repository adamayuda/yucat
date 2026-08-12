import 'package:purchases_flutter/purchases_flutter.dart';

/// A free-trial phase configured on a package's store product.
///
/// Presence of a [TrialInfo] means the *product* offers a trial — not that the
/// current user is eligible for it. Eligibility is resolved separately in
/// `PaywallBloc`, which is the only place allowed to decide what we advertise.
class TrialInfo {
  /// Trial length normalised to days (e.g. 3).
  final int days;

  /// Raw period unit, kept so a future "1 week free" phrasing can avoid the
  /// day conversion.
  final PeriodUnit unit;

  /// Raw number of [unit]s.
  final int unitCount;

  const TrialInfo({
    required this.days,
    required this.unit,
    required this.unitCount,
  });
}

/// Resolves the free trial configured on [pkg], or null when it has none.
///
/// The two stores model trials differently, so this checks both:
///
/// * **Google Play** exposes an explicit [SubscriptionOption.freePhase], and
///   keeps a *discounted* first period in a separate `introPhase`. Play also
///   filters offers server-side, so an option only reaches us when the user
///   qualifies for it.
/// * **StoreKit** folds trials and discounts into the single
///   [StoreProduct.introductoryPrice]. A zero price is what distinguishes the
///   two — a non-zero one is a discount and deliberately returns null here.
///
/// Returning null degrades the paywall to its plain full-price layout, which is
/// the behaviour we want whenever the store config is missing or half-migrated:
/// better to under-promise than to advertise a trial the store won't honour.
TrialInfo? trialInfoFor(Package pkg) {
  final product = pkg.storeProduct;

  // --- Google Play ---------------------------------------------------------
  // `defaultOption` is the offer Play will actually charge against, so it is
  // the source of truth. Fall back to scanning every option in case the default
  // resolves to a bare base plan while a trial offer sits alongside it.
  var option = product.defaultOption;
  if (option?.freePhase == null) {
    final options = product.subscriptionOptions;
    if (options != null) {
      for (final candidate in options) {
        // Prepaid plans don't auto-renew, so a trial on one can't convert.
        if (candidate.freePhase != null && !candidate.isPrepaid) {
          option = candidate;
          break;
        }
      }
    }
  }

  final freePhase = option?.freePhase;
  if (freePhase != null && freePhase.price.amountMicros == 0) {
    final trial = _trialFrom(
      freePhase.billingPeriod?.unit,
      freePhase.billingPeriod?.value,
      freePhase.billingCycleCount,
    );
    if (trial != null) return trial;
  }

  // --- StoreKit ------------------------------------------------------------
  final intro = product.introductoryPrice;
  if (intro != null && intro.price <= 0) {
    final trial = _trialFrom(
      intro.periodUnit,
      intro.periodNumberOfUnits,
      intro.cycles,
    );
    if (trial != null) return trial;
  }

  return null;
}

/// Builds a [TrialInfo] from a raw store period, or null when the period can't
/// be expressed in days.
TrialInfo? _trialFrom(PeriodUnit? unit, int? value, int? cycles) {
  if (unit == null || value == null || value <= 0) return null;
  final perCycle = _daysIn(unit, value);
  if (perCycle == null) return null;
  // Trials are single-cycle on both stores, but clamp rather than trust the
  // store so a misconfigured product can't render an absurd "3650 DAYS FREE".
  final repeats = (cycles == null || cycles <= 0) ? 1 : cycles.clamp(1, 12);
  return TrialInfo(days: perCycle * repeats, unit: unit, unitCount: value);
}

/// Period → days. Null for [PeriodUnit.unknown] so we never advertise a trial
/// length we can't actually compute.
int? _daysIn(PeriodUnit unit, int value) => switch (unit) {
      PeriodUnit.day => value,
      PeriodUnit.week => value * 7,
      PeriodUnit.month => value * 30,
      PeriodUnit.year => value * 365,
      PeriodUnit.unknown => null,
    };
