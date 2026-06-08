import 'package:purchases_flutter/purchases_flutter.dart';

/// Human-readable plan title from a [Package].
String periodTitleFor(Package pkg) {
  return switch (pkg.packageType) {
    PackageType.annual => 'Annual',
    PackageType.sixMonth => '6 months',
    PackageType.threeMonth => '3 months',
    PackageType.twoMonth => '2 months',
    PackageType.monthly => 'Monthly',
    PackageType.weekly => 'Weekly',
    PackageType.lifetime => 'Lifetime',
    _ => pkg.identifier,
  };
}

/// Per-month label for annual plans (e.g. "$2.50/mo"). Null otherwise.
String? perPeriodLabel(Package pkg) {
  if (pkg.packageType != PackageType.annual) return null;
  final monthly = pkg.storeProduct.price / 12;
  return '${_currencySymbolFor(pkg.storeProduct.priceString)}${monthly.toStringAsFixed(2)}/mo';
}

/// "Save X%" relative to the monthly package, if available.
String? savingsLabelFor(Package pkg, List<Package> all) {
  if (pkg.packageType != PackageType.annual) return null;
  final monthly = all.firstWhere(
    (p) => p.packageType == PackageType.monthly,
    orElse: () => pkg,
  );
  if (monthly.identifier == pkg.identifier) return null;
  final annualEquivalent = monthly.storeProduct.price * 12;
  if (annualEquivalent <= 0) return null;
  final saved = (1 - pkg.storeProduct.price / annualEquivalent) * 100;
  if (saved < 5) return null;
  return 'Save ${saved.round()}%';
}

/// Whether [pkg] carries an introductory offer (discounted first period).
bool hasIntroOffer(Package pkg) => pkg.storeProduct.introductoryPrice != null;

/// Formatted introductory price (e.g. "$39.99"), or null when there's no offer.
String? introPriceStringFor(Package pkg) =>
    pkg.storeProduct.introductoryPrice?.priceString;

/// Post-intro renewal line for a plan with an introductory offer
/// (e.g. "then $49.99/yr"). Null when there's no offer.
String? renewalLabelFor(Package pkg) {
  if (pkg.storeProduct.introductoryPrice == null) return null;
  return 'then ${pkg.storeProduct.priceString}/${_periodSuffixFor(pkg)}';
}

/// "Save X%" comparing the introductory price to the full price. Null when
/// there's no offer or the saving is negligible (< 5%).
String? introSavingsLabelFor(Package pkg) {
  final intro = pkg.storeProduct.introductoryPrice;
  final full = pkg.storeProduct.price;
  if (intro == null || full <= 0) return null;
  final saved = (1 - intro.price / full) * 100;
  if (saved < 5) return null;
  return 'Save ${saved.round()}%';
}

/// CTA label. No free trial: paying is immediate, so the label is fixed.
String ctaLabelFor(Package pkg) {
  return 'Unlock Yucat Plus';
}

String _periodSuffixFor(Package pkg) {
  return switch (pkg.packageType) {
    PackageType.annual => 'yr',
    PackageType.monthly => 'mo',
    PackageType.weekly => 'wk',
    _ => 'period',
  };
}

String _currencySymbolFor(String priceString) {
  for (final ch in priceString.runes) {
    final c = String.fromCharCode(ch);
    if (RegExp(r'[\d\s.,]').hasMatch(c)) continue;
    return c;
  }
  return '\$';
}
