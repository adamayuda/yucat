import 'dart:math' as math;

import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';

/// How much of this food the cat should eat in a day — the one number a
/// nutrition card can give that changes what the owner does at the bowl.
///
/// Pure and Flutter-free so it is unit-tested. Maintenance energy is the
/// textbook RER × factor: `RER = 70 × kg^0.75`, with the factor set by life
/// stage, then reproduction, then weight goal, then neuter status ± activity
/// (NRC 2006 / WSAVA ranges). It is an estimate — body condition and the vet
/// win — and the card says so.
class DailyPortion {
  /// Maintenance energy for the cat, kcal/day.
  final int kcalPerDay;

  /// Grams of this food that deliver [kcalPerDay] — or, for a complementary
  /// product, the grams that fit inside the 10 % treat budget.
  final int gramsPerDay;

  /// Number of pack units ([unitLabel]) per day, when the pack size parses as
  /// a single-serve unit (pouch, can, tin, tray, sachet ≤ 500 g). Null for bags
  /// and unparseable sizes.
  final double? unitsPerDay;
  final String? unitLabel;

  /// True when the product is a treat / topper / supplement, in which case
  /// [kcalPerDay] is the whole-day energy need and [gramsPerDay] the treat
  /// budget (10 % of it) expressed in this product.
  final bool isTreatBudget;

  const DailyPortion({
    required this.kcalPerDay,
    required this.gramsPerDay,
    required this.isTreatBudget,
    this.unitsPerDay,
    this.unitLabel,
  });
}

/// Share of daily energy that treats may take (the common veterinary rule).
const treatBudgetShare = 0.10;

/// Null when the cat has no weight, or the product has no usable energy.
DailyPortion? computeDailyPortion(CatEntity cat, ProductDisplayModel product) {
  final kg = cat.weight;
  if (kg == null || kg <= 0) return null;
  final kcalPer100g = product.calories;
  if (product.dataUnavailable || kcalPer100g <= 0) return null;

  final rer = 70 * math.pow(kg, 0.75);
  final factor = maintenanceFactor(cat);
  final kcalDay = rer * factor;

  final treat = product.isComplementary;
  final kcalOfThis = treat ? kcalDay * treatBudgetShare : kcalDay;
  final grams = kcalOfThis / kcalPer100g * 100;

  final unit = treat ? null : parsePackUnit(product.packageSize);
  return DailyPortion(
    kcalPerDay: kcalDay.round(),
    gramsPerDay: grams.round(),
    isTreatBudget: treat,
    unitsPerDay: unit == null ? null : grams / unit.grams,
    unitLabel: unit?.label,
  );
}

/// Multiplier on RER. Exposed for the tests; order of precedence matters and
/// is documented on the class.
double maintenanceFactor(CatEntity cat) {
  final stage = (cat.ageGroup ?? ageGroupFromMonths(cat.age))?.toLowerCase();
  if (stage == 'kitten') return 2.5;

  final status = cat.neuteredStatus?.trim().toLowerCase();
  if (status == 'pregnant') return 1.8;
  if (status == 'lactating') return 2.5;

  final weight = cat.weightCategory?.trim().toLowerCase();
  if (weight == 'obese') return 0.8;
  if (weight == 'overweight') return 1.0;

  final neutered = status == 'neutered' || cat.neutered;
  var factor = neutered ? 1.2 : 1.4;
  if (stage == 'senior') factor = neutered ? 1.1 : 1.2;

  final activity = cat.activityLevel?.trim().toLowerCase();
  if (activity == 'high') factor += 0.2;
  if (activity == 'low') factor -= 0.1;
  if (weight == 'underweight') factor += 0.2;
  return factor;
}

class PackUnit {
  final double grams;
  final String label;
  const PackUnit({required this.grams, required this.label});
}

final _unitWords = RegExp(
  r'\b(pouch|pouches|can|cans|tin|tins|tray|trays|sachet|sachets|cup|cups)\b',
  caseSensitive: false,
);
final _weight = RegExp(r'(\d+(?:[.,]\d+)?)\s*(g|gr|grams?|kg|oz)\b',
    caseSensitive: false);

/// "85g pouch" → 85 g "85g pouch"; "12 x 85g" → 85 g; "3 kg bag" → null
/// (a bag is not a serving); "5.5 oz can" → 156 g. Only single-serve
/// containers up to 500 g count as a unit.
PackUnit? parsePackUnit(String packageSize) {
  if (packageSize.isEmpty) return null;
  if (!_unitWords.hasMatch(packageSize)) return null;
  // With a multipack ("12 x 85g"), the *last* weight is the unit weight.
  final matches = _weight.allMatches(packageSize).toList();
  if (matches.isEmpty) return null;
  final m = matches.last;
  final raw = double.tryParse(m.group(1)!.replaceAll(',', '.'));
  if (raw == null || raw <= 0) return null;
  final unit = m.group(2)!.toLowerCase();
  final grams = switch (unit) {
    'kg' => raw * 1000,
    'oz' => raw * 28.35,
    _ => raw,
  };
  if (grams > 500) return null;
  return PackUnit(grams: grams, label: packageSize.trim());
}
