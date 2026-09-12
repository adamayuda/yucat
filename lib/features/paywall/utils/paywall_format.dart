import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:yucat/features/paywall/utils/trial_info.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// Human-readable plan title from a [Package].
String periodTitleFor(Package pkg, AppLocalizations l10n) {
  return switch (pkg.packageType) {
    PackageType.annual => l10n.paywallPeriodAnnual,
    PackageType.sixMonth => l10n.paywallPeriod6Months,
    PackageType.threeMonth => l10n.paywallPeriod3Months,
    PackageType.twoMonth => l10n.paywallPeriod2Months,
    PackageType.monthly => l10n.paywallPeriodMonthly,
    PackageType.weekly => l10n.paywallPeriodWeekly,
    PackageType.lifetime => l10n.paywallPeriodLifetime,
    _ => pkg.identifier,
  };
}

/// Localized billing-period noun ("week" / "month" / "year") for price lines.
/// Null for packages with no natural suffix (e.g. lifetime), which callers
/// treat as "fall back to generic copy".
///
/// The reserved `$rc_*` package types answer directly. A **custom** package —
/// the second-chance `annual_offer` — carries no type, so it falls through to
/// the store product's own ISO-8601 period (`P1Y`, `P1M`, `P1W`); without that
/// the offer's disclosure lines silently lost their "then €29.99/year".
String? periodSuffixFor(Package pkg, AppLocalizations l10n) {
  return switch (pkg.packageType) {
    PackageType.annual => l10n.paywallPeriodSuffixAnnual,
    PackageType.monthly => l10n.paywallPeriodSuffixMonthly,
    PackageType.weekly => l10n.paywallPeriodSuffixWeekly,
    _ => switch (_isoPeriodUnit(pkg.storeProduct.subscriptionPeriod)) {
        'Y' => l10n.paywallPeriodSuffixAnnual,
        'M' => l10n.paywallPeriodSuffixMonthly,
        'W' => l10n.paywallPeriodSuffixWeekly,
        _ => null,
      },
  };
}

/// Unit letter of a single-unit ISO-8601 period ("P1Y" → "Y"); null for
/// anything else, including multi-unit periods like "P3M", which have no
/// one-word suffix.
String? _isoPeriodUnit(String? iso) {
  if (iso == null) return null;
  final m = RegExp(r'^P1([YMWD])$').firstMatch(iso);
  return m?.group(1);
}

/// Per-month breakdown for annual plans (e.g. "$4.17/month"). Null otherwise.
/// With a single annual plan this is the main softener on the sticker price.
String? perPeriodLabel(Package pkg, AppLocalizations l10n) {
  if (pkg.packageType != PackageType.annual) return null;
  final monthly = pkg.storeProduct.price / 12;
  final price =
      '${_currencySymbolFor(pkg.storeProduct.priceString)}${monthly.toStringAsFixed(2)}';
  return l10n.paywallPerPeriodPrice(price, l10n.paywallPeriodSuffixMonthly);
}

/// What the user pays once the trial ends (e.g. "then $49.99/year").
/// Null when the plan has no natural period suffix.
String? thenPriceLabelFor(Package pkg, AppLocalizations l10n) {
  final suffix = periodSuffixFor(pkg, l10n);
  if (suffix == null) return null;
  return l10n.paywallThenPrice(pkg.storeProduct.priceString, suffix);
}

/// CTA label. A trial-eligible selection leads with the trial ("Redeem 3 days
/// for free"); everything else keeps the neutral "Let's get started". The word
/// "free" rather than a formatted zero keeps this independent of whether the
/// store hands back a usable price string, and reads naturally in every locale.
String ctaLabelFor(
  Package pkg,
  AppLocalizations l10n, {
  TrialInfo? trial,
}) {
  if (trial == null) return l10n.paywallCtaUnlockPlus;
  return l10n.paywallCtaRedeemTrial(trial.days);
}

String _currencySymbolFor(String priceString) {
  for (final ch in priceString.runes) {
    final c = String.fromCharCode(ch);
    if (RegExp(r'[\d\s.,]').hasMatch(c)) continue;
    return c;
  }
  return '\$';
}
