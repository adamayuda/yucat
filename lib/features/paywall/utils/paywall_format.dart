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

/// CTA label. No free trial: paying is immediate, so the label is fixed.
String ctaLabelFor(Package pkg) {
  return 'Unlock Yucat Plus';
}

String _currencySymbolFor(String priceString) {
  for (final ch in priceString.runes) {
    final c = String.fromCharCode(ch);
    if (RegExp(r'[\d\s.,]').hasMatch(c)) continue;
    return c;
  }
  return '\$';
}
