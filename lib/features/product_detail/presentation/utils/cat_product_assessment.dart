import 'package:yucat/features/cat/domain/entities/cat_allergen.dart';
import 'package:yucat/features/cat/presentation/utils/cat_labels.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/presentation/utils/assessment_weights.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Thresholds
// All numeric cutoffs live here so the rule set is editable in one place.
//
// IMPORTANT: macro thresholds (protein/fat/carbs/fiber) are compared on a
// DRY-MATTER basis — the product's as-fed percentages are normalized by
// moisture first (see `_Nm`), so a wet food (~80% water) and a dry food are
// judged on the same scale. Calories are on the same DRY-MATTER basis
// (kcal per 100 g of dry matter, ≈ 350–500 for complete foods). They used to
// be as-fed, which compared a wet pâté's ~90 kcal/100 g against cutoffs
// written for kibble (280–400): no wet food could ever trigger a calorie
// finding, up or down, and nearly every dry food tripped them all — four of
// the six dimensions were a wet-vs-dry detector. The one thing as-fed density
// genuinely captures — water adds volume without calories — is now its own
// explicit rule (`_satietyMoistureMin`) instead of a side effect.
// ---------------------------------------------------------------------------

// Age — AAFCO growth life-stage minimums (kitten); senior values are heuristic.
const _kittenProteinMin = 28.0;
const _kittenProteinHigh = 35.0;
const _kittenFatHigh = 18.0;
const _seniorProteinLow = 30.0;
const _seniorProteinHigh = 35.0;
const _seniorFatMax = 20.0;

// Weight category — heuristic. Calorie cutoffs are kcal per 100 g DRY MATTER
// (modified Atwater, see `ProductDisplayModel.calories`): a lean pâté sits
// ≈ 380–420, a typical kibble ≈ 390, a fat-rich food ≈ 450+.
const _underweightCaloriesHigh = 430.0;
const _underweightFatHigh = 18.0;
const _overweightCaloriesHigh = 420.0;
const _overweightCaloriesLow = 380.0;
const _overweightFiberHigh = 4.0;
// Water bulks a meal without calories — the as-fed advantage of wet food for
// a cat that needs to eat less, stated as a rule rather than left to fall out
// of an as-fed calorie figure.
const _satietyMoistureMin = 70.0;
const _obeseFatMax = 15.0;
const _obeseCaloriesMax = 400.0;
const _obeseLeanProteinMin = 40.0;
const _obeseLeanFatMax = 12.0;

// Activity — heuristic (kcal/100 g DM).
const _lowActivityCaloriesHigh = 420.0;
const _lowActivityCaloriesLow = 380.0;
const _highActivityCaloriesHigh = 430.0;
const _highActivityProteinHigh = 35.0;

// Neutered status — heuristic (kcal/100 g DM).
const _neuteredCaloriesHigh = 430.0;
const _neuteredFatHigh = 16.0;
const _pregnantProteinHigh = 35.0;
const _pregnantFatHigh = 20.0;
const _pregnantCaloriesHigh = 440.0;

// Breed — heuristic.
const _maineCoonProteinHigh = 35.0;
const _persianFiberLow = 4.0;
const _persianFiberHigh = 6.0;
const _persianCarbsHigh = 30.0;
const _sphynxFatHigh = 18.0;
const _sphynxFatLow = 12.0;
const _britishCaloriesHigh = 420.0;
const _bengalProteinHigh = 38.0;
const _bengalProteinLow = 30.0;
// Shared archetype threshold for large / muscular breeds.
const _breedProteinHigh = 35.0;

// Health conditions — heuristic.
const _kidneyProteinMax = 32.0;
const _diabetesCarbsMax = 20.0;
const _diabetesProteinHigh = 40.0;
const _dentalMoistureMin = 70.0;
const _hairballFiberLow = 4.0;
const _hairballFiberHigh = 6.0;
const _sensitiveStomachIngredientMax = 12;

// Dimension weights, ×10 (we divide by 10 at the end so we stay in ints).
// Shared with the diet-tips engine through `assessment_weights.dart`.
const _wHealth = AssessmentWeights.health;
const _wWeight = AssessmentWeights.weight;
const _wAge = AssessmentWeights.age;
const _wActivity = AssessmentWeights.activity;
const _wNeutered = AssessmentWeights.neutered;
const _wBreed = AssessmentWeights.breed;

// ---------------------------------------------------------------------------
// Keyword sets — text scans against the LLM's pros/cons summary + name/brand.
// Hyphens are normalized to spaces before matching, so use space form here
// (`'omega 3'`, not `'omega-3'`).
// ---------------------------------------------------------------------------

const _kSenior = ['senior'];
const _kJointSupport = ['glucosamine', 'chondroitin'];
const _kKidneyFriendly = [
  'kidney',
  'renal',
  'low phosphorus',
  'reduced phosphorus',
];
const _kOmega3 = ['omega 3', 'fish oil', 'salmon oil'];
const _kFillers = ['corn', 'wheat', 'soy'];
const _kHairball = ['hairball'];
const _kUrinaryClaim = ['urinary', 'struvite', 'urinary tract'];
const _kLowAsh = ['low ash', 'reduced ash'];
const _kUrinarySupport = [
  'cranberry',
  'd mannose',
  'dl methionine',
  'methionine',
];
const _kHighMinerals = ['high minerals', 'mineral rich', 'added minerals'];
const _kPhosphorus = 'phosphorus';
const _kReducedPhosphorus = [
  'low phosphorus',
  'reduced phosphorus',
  'controlled phosphorus',
  'restricted phosphorus',
];
const _kRenalSupport = ['renal support', 'kidney support', 'renal care'];
const _kLimitedIngredient = [
  'limited ingredient',
  'single protein',
  'single source protein',
];
// Common feline allergens. Includes name-level proteins (salmon/tuna/lamb) since
// the scanned text now includes the product name.
//
// This is the generic list used when the profile only says `food_allergies`
// without naming anything. When the owner has declared specific allergens in the
// health carnet, `_evaluateDeclaredAllergens` matches those instead, using the
// richer needle sets on `CatAllergen`.
const _kCommonAllergens = [
  'chicken',
  'fish',
  'beef',
  'salmon',
  'tuna',
  'lamb',
  'dairy',
  'egg',
];
const _kNovelProteins = ['duck', 'venison', 'kangaroo', 'rabbit'];
const _kArtificialColor = [
  'artificial color',
  'artificial colour',
  'red 40',
  'yellow 5',
];
const _kLargeKibble = ['large kibble', 'large sized kibble'];
const _kDigestible = ['digestible', 'highly digestible'];
const _kWeightManagement = ['weight management', 'light', 'indoor'];

// Heart condition.
const _kTaurine = ['taurine'];
const _kLowSodium = ['low sodium', 'reduced sodium', 'low salt'];
const _kHighSodium = ['high sodium', 'added salt', 'high salt'];
const _kHeartOmega = ['omega 3', 'epa', 'dha', 'fish oil', 'salmon oil'];

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum CatAssessmentDimension { health, weight, age, activity, neutered, breed, coat }

class CatProductFinding {
  final String text;
  final CatAssessmentDimension dimension;

  /// A contraindication, not a trade-off: a declared allergen present in the
  /// food, kidney disease with high protein, diabetes with high carbs. One hard
  /// finding makes the verdict "not recommended" regardless of the arithmetic
  /// (`fit_verdict.dart`), because no number of pros offsets it.
  final bool hard;

  const CatProductFinding({
    required this.text,
    required this.dimension,
    this.hard = false,
  });
}

/// Per-cat fit assessment for a product.
///
/// `score` is a 0-100 fit score derived from the same rules that produce
/// `pros` and `cons`. 70 is the neutral baseline; each finding shifts the
/// score by a small delta proportional to its severity, weighted by
/// dimension priority (health/weight outweigh breed/neutered).
///
/// ⚠️ The score is an internal ranking key (the "Better for {cat}" list), not
/// display copy. The UI shows `FitVerdict.of(this)` — a banded verdict on
/// `delta` plus `hasHardFlag` — beside the product's own quality score, which
/// is the only number on the screen.
class CatProductAssessment {
  final List<CatProductFinding> pros;
  final List<CatProductFinding> cons;

  /// Signed delta from the neutral baseline (70). Already weighted across
  /// dimensions. Use `score` for the clamped 0-100 value.
  final int delta;

  const CatProductAssessment({
    required this.pros,
    required this.cons,
    this.delta = 0,
  });

  int get score => (70 + delta).clamp(0, 100);

  /// True when any con is a contraindication (see [CatProductFinding.hard]).
  bool get hasHardFlag => cons.any((c) => c.hard);
}

/// Nutrient view used by the rule dimensions. Macros AND calories are on a
/// DRY-MATTER basis (normalized by moisture) so wet and dry foods meet the
/// same cutoffs; moisture is the raw as-fed percentage.
class _Nm {
  final double protein;
  final double fat;
  final double carbs;
  final double fiber;
  final double calories;
  final double moisture;

  const _Nm({
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.fiber,
    required this.calories,
    required this.moisture,
  });

  factory _Nm.from(ProductDisplayModel p) {
    // Dry-matter factor: divide out the water. Clamp moisture so the factor
    // stays sane for malformed/extreme values.
    final moisture = p.moisture.clamp(0.0, 95.0);
    final f = 100.0 / (100.0 - moisture);
    return _Nm(
      protein: p.protein * f,
      fat: p.fat * f,
      carbs: p.carbs * f,
      fiber: p.fiber * f,
      calories: p.calories * f, // kcal per 100 g dry matter
      moisture: p.moisture,
    );
  }
}

class _DimensionResult {
  final List<CatProductFinding> pros;
  final List<CatProductFinding> cons;
  final int delta;
  const _DimensionResult({
    this.pros = const [],
    this.cons = const [],
    this.delta = 0,
  });
}

// ---------------------------------------------------------------------------
// Aggregator
// ---------------------------------------------------------------------------

CatProductAssessment evaluateCatProduct(
  CatEntity cat,
  ProductDisplayModel product,
  AppLocalizations l10n,
) {
  final text = _normalizeText(product);
  final n = _Nm.from(product);

  final age = _evaluateAge(cat, n, text, l10n);
  final weight = _evaluateWeight(cat, n, l10n);
  final activity = _evaluateActivity(cat, n, l10n);
  final neutered = _evaluateNeutered(cat, n, text, l10n);
  final breed = _evaluateBreed(cat, n, text, l10n);
  final declared = _evaluateDeclaredAllergens(cat, text, l10n);
  // Once a declared allergen has been named, the generic "contains common
  // allergens" line is the same finding said twice — and a second −12 on top.
  final health = _evaluateHealth(
    cat,
    product,
    n,
    text,
    l10n,
    skipGenericAllergenCon: declared.cons.isNotEmpty,
  );

  // Weight category overrides neutered status when they pull in opposite
  // directions. An underweight neutered cat needs calories — drop the
  // neutered penalty + matching pro/con line rather than letting them cancel.
  final neuteredResolved = _resolveWeightVsNeutered(weight, neutered);

  // Declared allergens ride on the health dimension's weight — they are a health
  // fact about this specific cat, and the strongest one the profile carries.
  final healthCombined = _DimensionResult(
    pros: health.pros,
    cons: [...declared.cons, ...health.cons],
    delta: health.delta + declared.delta,
  );

  final weighted =
      (healthCombined.delta * _wHealth +
              weight.delta * _wWeight +
              age.delta * _wAge +
              activity.delta * _wActivity +
              neuteredResolved.delta * _wNeutered +
              breed.delta * _wBreed) ~/
          10;

  // Concatenate in priority order so the most important findings appear first.
  return CatProductAssessment(
    pros: [
      ...healthCombined.pros,
      ...weight.pros,
      ...age.pros,
      ...activity.pros,
      ...neuteredResolved.pros,
      ...breed.pros,
    ],
    cons: [
      ...healthCombined.cons,
      ...weight.cons,
      ...age.cons,
      ...activity.cons,
      ...neuteredResolved.cons,
      ...breed.cons,
    ],
    delta: weighted,
  );
}

/// Allergens the owner declared on the cat's profile, matched against the
/// product's canonical-English text.
///
/// Distinct from the `food_allergies` branch in [_evaluateHealth], which is a
/// generic "this cat reacts to something" heuristic. This one names the culprit,
/// so it earns a heavier penalty and a specific line.
///
/// ⚠️ Matching is plain substring, with no word boundary and no "-free"
/// exclusion — so `"contains no chicken"` triggers and `fish` matches inside
/// `fish oil`. That is inherited on purpose from `_kCommonAllergens`, which has
/// always behaved this way: fixing it here alone would make the two branches
/// disagree about the same product. On an allergy warning, over-reporting is the
/// safer direction.
_DimensionResult _evaluateDeclaredAllergens(
  CatEntity cat,
  String text,
  AppLocalizations l10n,
) {
  final declared = CatAllergen.resolveAll(cat.allergies)
      .where((a) => a.kind == CatAllergenKind.food);
  if (declared.isEmpty) return const _DimensionResult();

  final present = detectFoodAllergenKeys(text);
  final cons = <CatProductFinding>[];
  var delta = 0;

  for (final allergen in declared) {
    if (!present.contains(allergen.key)) continue;
    cons.add(_p(
      l10n.assessmentDeclaredAllergen(catFormatAllergen(allergen.key, l10n)),
      CatAssessmentDimension.health,
      hard: true,
    ));
    delta -= 14;
  }

  // One allergen already sinks the verdict; several should not drive the score
  // to a floor that no product could recover from, because the message is the
  // same either way — do not feed this to your cat.
  return _DimensionResult(cons: cons, delta: delta.clamp(-24, 0));
}

_DimensionResult _resolveWeightVsNeutered(
  _DimensionResult weight,
  _DimensionResult neutered,
) {
  if (weight.delta == 0 || neutered.delta == 0) return neutered;
  final sameDirection = (weight.delta > 0) == (neutered.delta > 0);
  if (sameDirection) return neutered;
  return const _DimensionResult();
}

// ---------------------------------------------------------------------------
// Dimensions
// ---------------------------------------------------------------------------

_DimensionResult _evaluateAge(
  CatEntity cat,
  _Nm n,
  String text,
  AppLocalizations l10n,
) {
  final pros = <CatProductFinding>[];
  final cons = <CatProductFinding>[];
  var delta = 0;

  // Same fallback the diet-tips engine uses: a cat saved with only a birth
  // date / age in months must not lose its whole age dimension.
  switch (_norm(cat.ageGroup) ?? ageGroupFromMonths(cat.age)) {
    case 'kitten':
      if (n.protein > _kittenProteinHigh) {
        pros.add(_p(l10n.assessmentKittenHighProtein,
            CatAssessmentDimension.age));
        delta += 8;
      }
      if (n.fat > _kittenFatHigh) {
        pros.add(_p(l10n.assessmentKittenHighFat,
            CatAssessmentDimension.age));
        delta += 6;
      }
      if (_containsAny(text, _kSenior)) {
        cons.add(_p(l10n.assessmentKittenSeniorFormula,
            CatAssessmentDimension.age));
        delta -= 10;
      }
      if (n.protein < _kittenProteinMin) {
        cons.add(_p(l10n.assessmentKittenLowProtein,
            CatAssessmentDimension.age));
        delta -= 10;
      }
      break;
    case 'adult':
      // Neutral baseline — no strong age rules.
      break;
    case 'senior':
      if (n.protein >= _seniorProteinLow &&
          n.protein <= _seniorProteinHigh) {
        pros.add(_p(l10n.assessmentSeniorModerateProtein,
            CatAssessmentDimension.age));
        delta += 6;
      }
      if (n.fat > _seniorFatMax) {
        cons.add(_p(l10n.assessmentSeniorHighFat,
            CatAssessmentDimension.age));
        delta -= 8;
      }
      if (_containsAny(text, _kJointSupport)) {
        pros.add(_p(
            l10n.assessmentSeniorJointSupport,
            CatAssessmentDimension.age));
        delta += 8;
      }
      if (_containsAny(text, _kKidneyFriendly)) {
        pros.add(_p(l10n.assessmentSeniorKidneyFriendly,
            CatAssessmentDimension.age));
        delta += 10;
      }
      break;
  }

  return _DimensionResult(pros: pros, cons: cons, delta: delta);
}

_DimensionResult _evaluateWeight(
  CatEntity cat,
  _Nm n,
  AppLocalizations l10n,
) {
  final pros = <CatProductFinding>[];
  final cons = <CatProductFinding>[];
  var delta = 0;

  switch (_norm(cat.weightCategory)) {
    case 'underweight':
      if (n.calories > _underweightCaloriesHigh) {
        pros.add(_p(
            l10n.assessmentUnderweightHighCalories,
            CatAssessmentDimension.weight));
        delta += 8;
      }
      if (n.fat > _underweightFatHigh) {
        pros.add(_p(l10n.assessmentUnderweightHighFat,
            CatAssessmentDimension.weight));
        delta += 6;
      }
      break;
    case 'normal':
      break;
    case 'overweight':
      if (n.calories > _overweightCaloriesHigh) {
        cons.add(_p(
            l10n.assessmentOverweightHighCalories,
            CatAssessmentDimension.weight));
        delta -= 10;
      }
      if (n.calories < _overweightCaloriesLow) {
        pros.add(_p(
            l10n.assessmentOverweightLowCalories,
            CatAssessmentDimension.weight));
        delta += 8;
      }
      if (n.fiber > _overweightFiberHigh) {
        pros.add(_p(
            l10n.assessmentOverweightHighFiber,
            CatAssessmentDimension.weight));
        delta += 6;
      }
      if (n.moisture > _satietyMoistureMin) {
        pros.add(_p(
            l10n.assessmentOverweightHighMoisture,
            CatAssessmentDimension.weight));
        delta += 6;
      }
      break;
    case 'obese':
      if (n.fat > _obeseFatMax) {
        cons.add(_p(l10n.assessmentObeseHighFat,
            CatAssessmentDimension.weight));
        delta -= 10;
      }
      if (n.calories > _obeseCaloriesMax) {
        cons.add(_p(l10n.assessmentObeseHighCalories,
            CatAssessmentDimension.weight));
        delta -= 10;
      }
      if (n.protein > _obeseLeanProteinMin &&
          n.fat < _obeseLeanFatMax) {
        pros.add(_p(
            l10n.assessmentObeseLeanProtein,
            CatAssessmentDimension.weight));
        delta += 10;
      }
      if (n.moisture > _satietyMoistureMin) {
        pros.add(_p(
            l10n.assessmentOverweightHighMoisture,
            CatAssessmentDimension.weight));
        delta += 6;
      }
      break;
  }

  return _DimensionResult(pros: pros, cons: cons, delta: delta);
}

_DimensionResult _evaluateActivity(
  CatEntity cat,
  _Nm n,
  AppLocalizations l10n,
) {
  final pros = <CatProductFinding>[];
  final cons = <CatProductFinding>[];
  var delta = 0;

  switch (_norm(cat.activityLevel)) {
    case 'low':
      if (n.calories > _lowActivityCaloriesHigh) {
        cons.add(_p(
            l10n.assessmentLowActivityHighCalories,
            CatAssessmentDimension.activity));
        delta -= 8;
      }
      if (n.calories < _lowActivityCaloriesLow) {
        pros.add(_p(
            l10n.assessmentLowActivityModerateCalories,
            CatAssessmentDimension.activity));
        delta += 6;
      }
      break;
    case 'high':
      if (n.calories > _highActivityCaloriesHigh) {
        pros.add(_p(
            l10n.assessmentHighActivityHighCalories,
            CatAssessmentDimension.activity));
        delta += 6;
      }
      if (n.protein > _highActivityProteinHigh) {
        pros.add(_p(l10n.assessmentHighActivityHighProtein,
            CatAssessmentDimension.activity));
        delta += 6;
      }
      break;
  }

  return _DimensionResult(pros: pros, cons: cons, delta: delta);
}

_DimensionResult _evaluateNeutered(
  CatEntity cat,
  _Nm n,
  String text,
  AppLocalizations l10n,
) {
  final pros = <CatProductFinding>[];
  final cons = <CatProductFinding>[];
  var delta = 0;

  // `neuteredStatus` is the richer field (neutered / pregnant / lactating);
  // the plain bool is what older profiles carry. Read both, like diet tips do.
  switch (_norm(cat.neuteredStatus) ?? (cat.neutered ? 'neutered' : null)) {
    case 'neutered':
      if (n.calories > _neuteredCaloriesHigh) {
        cons.add(_p(
            l10n.assessmentNeuteredHighCalories,
            CatAssessmentDimension.neutered));
        delta -= 8;
      }
      if (_containsAny(text, _kUrinaryClaim)) {
        pros.add(_p(
            l10n.assessmentNeuteredUrinarySupport,
            CatAssessmentDimension.neutered));
        delta += 8;
      }
      if (n.fat > _neuteredFatHigh) {
        cons.add(_p(l10n.assessmentNeuteredHighFat,
            CatAssessmentDimension.neutered));
        delta -= 6;
      }
      break;
    case 'pregnant':
    case 'lactating':
      if (n.protein > _pregnantProteinHigh) {
        pros.add(_p(
            l10n.assessmentPregnantHighProtein,
            CatAssessmentDimension.neutered));
        delta += 8;
      }
      if (n.fat > _pregnantFatHigh) {
        pros.add(_p(
            l10n.assessmentPregnantHighFat,
            CatAssessmentDimension.neutered));
        delta += 8;
      }
      if (n.calories > _pregnantCaloriesHigh) {
        pros.add(_p(
            l10n.assessmentPregnantHighCalories,
            CatAssessmentDimension.neutered));
        delta += 6;
      }
      break;
  }

  return _DimensionResult(pros: pros, cons: cons, delta: delta);
}

_DimensionResult _evaluateBreed(
  CatEntity cat,
  _Nm n,
  String text,
  AppLocalizations l10n,
) {
  final pros = <CatProductFinding>[];
  final cons = <CatProductFinding>[];
  var delta = 0;

  final breed = _norm(cat.breed);
  if (breed == null) return const _DimensionResult();

  switch (breed) {
    case 'maine coon':
      if (_containsAny(text, _kJointSupport)) {
        pros.add(_p(
            l10n.assessmentMaineCoonJointSupport,
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (n.protein > _maineCoonProteinHigh) {
        pros.add(_p(l10n.assessmentMaineCoonHighProtein,
            CatAssessmentDimension.breed));
        delta += 6;
      }
      break;
    case 'persian':
      if ((n.fiber >= _persianFiberLow &&
              n.fiber <= _persianFiberHigh) ||
          _containsAny(text, _kHairball)) {
        pros.add(_p(
            l10n.assessmentPersianHairball,
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (_containsAny(text, _kOmega3)) {
        pros.add(_p(
            l10n.assessmentPersianOmega3,
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (n.carbs > _persianCarbsHigh) {
        cons.add(_p(l10n.assessmentPersianHighCarbs,
            CatAssessmentDimension.breed));
        delta -= 6;
      }
      break;
    case 'siamese':
      if (_containsAny(text, _kDigestible)) {
        pros.add(_p(l10n.assessmentSiameseDigestible,
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (_hasManyFillersWordBoundary(text)) {
        cons.add(_p(
            l10n.assessmentSiameseFillers,
            CatAssessmentDimension.breed));
        delta -= 8;
      }
      break;
    case 'sphynx':
      if (n.fat > _sphynxFatHigh) {
        pros.add(_p(l10n.assessmentSphynxHighFat,
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (n.fat < _sphynxFatLow) {
        cons.add(_p(
            l10n.assessmentSphynxLowFat,
            CatAssessmentDimension.breed));
        delta -= 8;
      }
      break;
    case 'british shorthair':
      if (n.calories > _britishCaloriesHigh) {
        cons.add(_p(
            l10n.assessmentBritishHighCalories,
            CatAssessmentDimension.breed));
        delta -= 8;
      }
      if (_containsAny(text, _kWeightManagement)) {
        pros.add(_p(
            l10n.assessmentBritishWeightManagement,
            CatAssessmentDimension.breed));
        delta += 8;
      }
      break;
    case 'bengal':
      if (n.protein > _bengalProteinHigh) {
        pros.add(_p(l10n.assessmentBengalHighProtein,
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (n.protein < _bengalProteinLow) {
        cons.add(_p(l10n.assessmentBengalLowProtein,
            CatAssessmentDimension.breed));
        delta -= 6;
      }
      break;
    // --- Large / muscular: high protein + joint support ---
    case 'norwegian forest cat':
    case 'siberian':
    case 'ragdoll':
    case 'savannah':
    case 'ragamuffin':
    case 'american bobtail':
    case 'cymric':
      if (n.protein > _breedProteinHigh) {
        pros.add(_p(l10n.assessmentBreedHighProtein,
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (_containsAny(text, _kJointSupport)) {
        pros.add(_p(l10n.assessmentBreedJointSupport,
            CatAssessmentDimension.breed));
        delta += 6;
      }
      break;
    // --- Hairless / fine-coat: higher fat ---
    case 'devon rex':
    case 'cornish rex':
    case 'peterbald':
    case 'donskoy':
    case 'selkirk rex':
    case 'laperm':
    case 'american curl':
      if (n.fat > _sphynxFatHigh) {
        pros.add(_p(l10n.assessmentBreedHighFat,
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (n.fat < _sphynxFatLow) {
        cons.add(_p(l10n.assessmentBreedLowFat,
            CatAssessmentDimension.breed));
        delta -= 8;
      }
      break;
    // --- Brachycephalic / long-coat: Persian-like ---
    case 'himalayan':
    case 'exotic shorthair':
      if ((n.fiber >= _persianFiberLow && n.fiber <= _persianFiberHigh) ||
          _containsAny(text, _kHairball)) {
        pros.add(_p(l10n.assessmentBreedHairball,
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (_containsAny(text, _kOmega3)) {
        pros.add(_p(l10n.assessmentBreedOmega3,
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (n.carbs > _persianCarbsHigh) {
        cons.add(_p(l10n.assessmentBreedHighCarbs,
            CatAssessmentDimension.breed));
        delta -= 6;
      }
      break;
    // --- Lean / active: digestible proteins, penalise fillers ---
    case 'oriental shorthair':
    case 'tonkinese':
    case 'balinese':
    case 'egyptian mau':
    case 'ocicat':
    case 'singapura':
    case 'korat':
    case 'havana brown':
    case 'toyger':
    case 'japanese bobtail':
    case 'munchkin':
      if (_containsAny(text, _kDigestible)) {
        pros.add(_p(l10n.assessmentBreedDigestible,
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (_hasManyFillersWordBoundary(text)) {
        cons.add(_p(l10n.assessmentBreedFillers,
            CatAssessmentDimension.breed));
        delta -= 8;
      }
      break;
    // --- Kidney-watch active: high protein but reward low phosphorus ---
    case 'abyssinian':
    case 'somali':
    case 'turkish angora':
    case 'turkish van':
      if (n.protein > _breedProteinHigh) {
        pros.add(_p(l10n.assessmentBreedHighProtein,
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (_containsAny(text, _kReducedPhosphorus) ||
          _containsAny(text, _kKidneyFriendly)) {
        pros.add(_p(l10n.assessmentBreedLowPhosphorus,
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (_containsAny(text, _kHighMinerals)) {
        cons.add(_p(l10n.assessmentBreedHighMinerals,
            CatAssessmentDimension.breed));
        delta -= 6;
      }
      break;
    // --- Obesity-prone: penalise high calories, reward weight management ---
    case 'russian blue':
    case 'bombay':
    case 'chartreux':
    case 'american shorthair':
    case 'domestic shorthair':
    case 'domestic longhair':
    case 'european shorthair':
    case 'manx':
    case 'nebelung':
    case 'burmilla':
    case 'snowshoe':
      if (n.calories > _britishCaloriesHigh) {
        cons.add(_p(l10n.assessmentBreedHighCalories,
            CatAssessmentDimension.breed));
        delta -= 8;
      }
      if (_containsAny(text, _kWeightManagement)) {
        pros.add(_p(l10n.assessmentBreedWeightManagement,
            CatAssessmentDimension.breed));
        delta += 8;
      }
      break;
    // --- Diabetes-prone: penalise high carbs ---
    case 'burmese':
      if (n.carbs > _diabetesCarbsMax) {
        cons.add(_p(l10n.assessmentBreedHighCarbsDiabetes,
            CatAssessmentDimension.breed));
        delta -= 8;
      }
      break;
    // --- Joint / cartilage: joint support + omega-3 ---
    case 'scottish fold':
    case 'scottish straight':
      if (_containsAny(text, _kJointSupport)) {
        pros.add(_p(l10n.assessmentBreedJointSupport,
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (_containsAny(text, _kOmega3)) {
        pros.add(_p(l10n.assessmentBreedOmega3,
            CatAssessmentDimension.breed));
        delta += 6;
      }
      break;
    // --- Coat / skin: reward omega-3 ---
    case 'birman':
      if (_containsAny(text, _kOmega3)) {
        pros.add(_p(l10n.assessmentBreedOmega3,
            CatAssessmentDimension.breed));
        delta += 6;
      }
      break;
  }

  return _DimensionResult(pros: pros, cons: cons, delta: delta);
}

_DimensionResult _evaluateHealth(
  CatEntity cat,
  ProductDisplayModel product,
  _Nm n,
  String text,
  AppLocalizations l10n, {
  // True when `_evaluateDeclaredAllergens` already named an allergen in this
  // product: the generic line would then be the same finding, said vaguer, and
  // a second penalty on top of the specific one.
  bool skipGenericAllergenCon = false,
}) {
  final pros = <CatProductFinding>[];
  final cons = <CatProductFinding>[];
  var delta = 0;

  final conditions = cat.healthConditions ?? [];
  if (conditions.isEmpty || conditions.contains('none')) {
    return const _DimensionResult();
  }

  final ingredientCount = _estimateIngredientCount(product, text);

  if (conditions.contains('urinary_issues')) {
    if (_containsAny(text, _kLowAsh)) {
      pros.add(_p(
          l10n.assessmentUrinaryLowAsh,
          CatAssessmentDimension.health));
      delta += 8;
    }
    if (_containsAny(text, _kUrinarySupport)) {
      pros.add(_p(
          l10n.assessmentUrinarySupport,
          CatAssessmentDimension.health));
      delta += 10;
    }
    if (_containsAny(text, _kHighMinerals)) {
      cons.add(_p(l10n.assessmentUrinaryHighMinerals,
          CatAssessmentDimension.health));
      delta -= 8;
    }
  }

  if (conditions.contains('kidney_disease')) {
    if (n.protein > _kidneyProteinMax) {
      cons.add(_p(l10n.assessmentKidneyHighProtein,
          CatAssessmentDimension.health, hard: true));
      delta -= 12;
    }
    // Penalize uncontrolled phosphorus, but not when the product explicitly
    // reduces/controls it (those are kidney-friendly).
    if (text.contains(_kPhosphorus) &&
        !_containsAny(text, _kReducedPhosphorus)) {
      cons.add(_p(
          l10n.assessmentKidneyPhosphorus,
          CatAssessmentDimension.health));
      delta -= 10;
    }
    if (_containsAny(text, _kRenalSupport)) {
      pros.add(_p(l10n.assessmentKidneyRenalSupport,
          CatAssessmentDimension.health));
      delta += 12;
    }
  }

  if (conditions.contains('sensitive_stomach')) {
    if (_containsAny(text, _kLimitedIngredient)) {
      pros.add(_p(
          l10n.assessmentSensitiveStomachLimitedIngredient,
          CatAssessmentDimension.health));
      delta += 8;
    }
    if (ingredientCount > _sensitiveStomachIngredientMax) {
      cons.add(_p(l10n.assessmentSensitiveStomachLongIngredients,
          CatAssessmentDimension.health));
      delta -= 6;
    }
  }

  if (conditions.contains('food_allergies')) {
    if (!skipGenericAllergenCon && _containsAny(text, _kCommonAllergens)) {
      cons.add(_p(l10n.assessmentFoodAllergyCommonAllergens,
          CatAssessmentDimension.health));
      delta -= 12;
    }
    if (_containsAny(text, _kNovelProteins)) {
      pros.add(_p(
          l10n.assessmentFoodAllergyNovelProteins,
          CatAssessmentDimension.health));
      delta += 10;
    }
  }

  if (conditions.contains('skin_allergies')) {
    if (_containsAny(text, _kOmega3)) {
      pros.add(_p(l10n.assessmentSkinAllergyOmega3,
          CatAssessmentDimension.health));
      delta += 6;
    }
    if (_containsAny(text, _kArtificialColor)) {
      cons.add(_p(
          l10n.assessmentSkinAllergyArtificialColor,
          CatAssessmentDimension.health));
      delta -= 8;
    }
  }

  if (conditions.contains('diabetes')) {
    if (n.carbs > _diabetesCarbsMax) {
      cons.add(_p(l10n.assessmentDiabetesHighCarbs,
          CatAssessmentDimension.health, hard: true));
      delta -= 10;
    }
    if (n.protein > _diabetesProteinHigh) {
      pros.add(_p(
          l10n.assessmentDiabetesHighProtein,
          CatAssessmentDimension.health));
      delta += 8;
    }
  }

  if (conditions.contains('dental_problems')) {
    if (n.moisture > _dentalMoistureMin) {
      pros.add(_p(
          l10n.assessmentDentalHighMoisture,
          CatAssessmentDimension.health));
      delta += 6;
    }
    if (_containsAny(text, _kLargeKibble)) {
      cons.add(_p(
          l10n.assessmentDentalLargeKibble,
          CatAssessmentDimension.health));
      delta -= 6;
    }
  }

  if (conditions.contains('hairball_issues')) {
    if ((n.fiber >= _hairballFiberLow &&
            n.fiber <= _hairballFiberHigh) ||
        _containsAny(text, _kHairball)) {
      pros.add(_p(l10n.assessmentHairballControl,
          CatAssessmentDimension.health));
      delta += 6;
    }
  }

  if (conditions.contains('heart_condition')) {
    if (_containsAny(text, _kTaurine)) {
      pros.add(_p(l10n.assessmentHeartTaurine,
          CatAssessmentDimension.health));
      delta += 8;
    }
    if (_containsAny(text, _kLowSodium)) {
      pros.add(_p(l10n.assessmentHeartLowSodium,
          CatAssessmentDimension.health));
      delta += 8;
    }
    if (_containsAny(text, _kHeartOmega)) {
      pros.add(_p(l10n.assessmentHeartOmega3,
          CatAssessmentDimension.health));
      delta += 6;
    }
    if (_containsAny(text, _kHighSodium)) {
      cons.add(_p(l10n.assessmentHeartHighSodium,
          CatAssessmentDimension.health));
      delta -= 8;
    }
  }

  return _DimensionResult(pros: pros, cons: cons, delta: delta);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

CatProductFinding _p(String text, CatAssessmentDimension dim,
        {bool hard = false}) =>
    CatProductFinding(text: text, dimension: dim, hard: hard);

/// Canonicalizes a loosely-stored cat profile field (trims + lowercases) so a
/// value like `'Kitten'` or `'adult '` still matches the rule switches. Returns
/// null for null/empty so callers fall through to the neutral baseline.
String? _norm(String? value) {
  if (value == null) return null;
  final trimmed = value.trim().toLowerCase();
  return trimmed.isEmpty ? null : trimmed;
}

/// Scanned text = pros + cons + product name + brand (so proteins/claims that
/// only appear in the name — e.g. "Lamb", "Renal" — are still detected).
/// The canonical-English text every keyword rule scans. Ingredients are the
/// strongest signal in here — the pros/cons are six short LLM lines, and
/// whether they happen to *mention* chicken or corn decided the allergen and
/// filler findings for as long as the ingredients list stayed unmapped.
String _normalizeText(ProductDisplayModel product) {
  return ([
    ...product.pros,
    ...product.cons,
    product.name,
    product.brand,
    ...product.ingredients,
  ]).join(' ').toLowerCase().replaceAll('-', ' ');
}

bool _containsAny(String text, List<String> needles) =>
    needles.any(text.contains);

bool _hasManyFillersWordBoundary(String text) {
  // Word-boundary match, and ignore "<filler> free" claims. Hyphens are already
  // normalized to spaces upstream, so "corn-free" reads as "corn free"; the
  // negative lookahead keeps that from counting as containing corn.
  final hits = _kFillers.where((needle) {
    final pattern =
        RegExp(r'\b' + RegExp.escape(needle) + r'\b(?!\s+free)');
    return pattern.hasMatch(text);
  }).length;
  return hits >= 2;
}

/// The real list when the product carries one; otherwise the old heuristic —
/// a comma count after the word "ingredients", which only ever fired when the
/// model wrote "Ingredients: …" into a pro or con.
int _estimateIngredientCount(ProductDisplayModel product, String text) {
  if (product.ingredients.isNotEmpty) return product.ingredients.length;
  final i = text.indexOf('ingredients');
  if (i == -1) return 0;
  return ','.allMatches(text.substring(i)).length + 1;
}
