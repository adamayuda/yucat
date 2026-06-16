import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/product_detail/presentation/utils/cat_product_assessment.dart'
    show CatAssessmentDimension;
import 'package:yucat/l10n/app_localizations.dart';

/// Cat-only dietary guidance derived purely from the wizard profile — the
/// owner-facing sibling of `evaluateCatProduct` (which scores a *product* for a
/// cat). No product, network, or LLM involved: rules map profile attributes to
/// "eat more / less of X" tips, with a short rationale.
///
/// Rules mirror the thresholds and priorities in `cat_product_assessment.dart`.
/// Each rule emits a [DietRecommendation]; the aggregator then keeps one tip per
/// nutrient, resolving conflicts (e.g. kidney "less protein" vs kitten "more
/// protein") in favour of the higher-priority source. See [recommendDiet].

enum DietNutrient {
  protein,
  fat,
  carbs,
  fiber,
  moisture,
  omega3,
  phosphorus,
  calories,
  water,
  taurine,
  sodium,
  novelProtein,
  digestibility,
}

enum DietDirection { more, less }

class DietRecommendation {
  final DietNutrient nutrient;
  final DietDirection direction;

  /// Localized short label, e.g. "More omega-3".
  final String title;

  /// Localized one-line rationale tailored to the cat.
  final String why;

  /// The profile dimension this tip came from.
  final CatAssessmentDimension source;

  /// Higher wins when two rules touch the same nutrient; also the sort key.
  final int priority;

  const DietRecommendation({
    required this.nutrient,
    required this.direction,
    required this.title,
    required this.why,
    required this.source,
    required this.priority,
  });
}

// Dimension priorities — same ordering as the product assessment (health and
// weight dominate; breed/coat are tiebreakers). General hydration sits low.
const _wHealth = 15;
const _wWeight = 12;
const _wAge = 10;
const _wActivity = 8;
const _wNeutered = 6;
const _wBreed = 5;
const _wCoat = 4;
const _wHydration = 3;

/// Produces the personalized dietary tips for [cat], ordered most-important
/// first. Returns an empty list only for a profile with no usable attributes.
List<DietRecommendation> recommendDiet(CatEntity cat, AppLocalizations l10n) {
  final raws = <DietRecommendation>[];

  void add(
    DietNutrient nutrient,
    DietDirection direction,
    String why,
    CatAssessmentDimension source,
    int priority,
  ) {
    raws.add(
      DietRecommendation(
        nutrient: nutrient,
        direction: direction,
        title: _title(l10n, nutrient, direction),
        why: why,
        source: source,
        priority: priority,
      ),
    );
  }

  // --- Age ---------------------------------------------------------------
  switch (_ageGroup(cat)) {
    case 'kitten':
      add(DietNutrient.protein, DietDirection.more, l10n.dietWhyKittenProtein,
          CatAssessmentDimension.age, _wAge);
      add(DietNutrient.fat, DietDirection.more, l10n.dietWhyKittenFat,
          CatAssessmentDimension.age, _wAge);
      break;
    case 'senior':
      add(DietNutrient.omega3, DietDirection.more, l10n.dietWhySeniorOmega3,
          CatAssessmentDimension.age, _wAge);
      add(DietNutrient.phosphorus, DietDirection.less,
          l10n.dietWhySeniorPhosphorus, CatAssessmentDimension.age, _wAge);
      break;
  }

  // --- Weight category ---------------------------------------------------
  switch (_norm(cat.weightCategory)) {
    case 'underweight':
      add(DietNutrient.calories, DietDirection.more,
          l10n.dietWhyUnderweightCalories, CatAssessmentDimension.weight,
          _wWeight);
      add(DietNutrient.fat, DietDirection.more, l10n.dietWhyUnderweightFat,
          CatAssessmentDimension.weight, _wWeight);
      break;
    case 'overweight':
    case 'obese':
      add(DietNutrient.calories, DietDirection.less,
          l10n.dietWhyOverweightCalories, CatAssessmentDimension.weight,
          _wWeight);
      add(DietNutrient.fat, DietDirection.less, l10n.dietWhyOverweightFat,
          CatAssessmentDimension.weight, _wWeight);
      add(DietNutrient.fiber, DietDirection.more, l10n.dietWhyOverweightFiber,
          CatAssessmentDimension.weight, _wWeight);
      add(DietNutrient.protein, DietDirection.more,
          l10n.dietWhyOverweightProtein, CatAssessmentDimension.weight,
          _wWeight);
      break;
  }

  // --- Activity ----------------------------------------------------------
  switch (_norm(cat.activityLevel)) {
    case 'low':
      add(DietNutrient.calories, DietDirection.less,
          l10n.dietWhyLowActivityCalories, CatAssessmentDimension.activity,
          _wActivity);
      break;
    case 'high':
      add(DietNutrient.protein, DietDirection.more,
          l10n.dietWhyHighActivityProtein, CatAssessmentDimension.activity,
          _wActivity);
      add(DietNutrient.calories, DietDirection.more,
          l10n.dietWhyHighActivityCalories, CatAssessmentDimension.activity,
          _wActivity);
      break;
  }

  // --- Neutered status ---------------------------------------------------
  final neuteredStatus = _norm(cat.neuteredStatus) ??
      (cat.neutered ? 'neutered' : null);
  switch (neuteredStatus) {
    case 'neutered':
      add(DietNutrient.calories, DietDirection.less,
          l10n.dietWhyNeuteredCalories, CatAssessmentDimension.neutered,
          _wNeutered);
      add(DietNutrient.fat, DietDirection.less, l10n.dietWhyNeuteredFat,
          CatAssessmentDimension.neutered, _wNeutered);
      break;
    case 'pregnant':
    case 'lactating':
      add(DietNutrient.protein, DietDirection.more,
          l10n.dietWhyPregnantProtein, CatAssessmentDimension.neutered,
          _wNeutered);
      add(DietNutrient.fat, DietDirection.more, l10n.dietWhyPregnantFat,
          CatAssessmentDimension.neutered, _wNeutered);
      add(DietNutrient.calories, DietDirection.more,
          l10n.dietWhyPregnantCalories, CatAssessmentDimension.neutered,
          _wNeutered);
      break;
  }

  // --- Breed -------------------------------------------------------------
  switch (_norm(cat.breed)) {
    case 'maine coon':
      add(DietNutrient.protein, DietDirection.more,
          l10n.dietWhyMaineCoonProtein, CatAssessmentDimension.breed, _wBreed);
      add(DietNutrient.omega3, DietDirection.more, l10n.dietWhyMaineCoonOmega3,
          CatAssessmentDimension.breed, _wBreed);
      break;
    case 'persian':
      add(DietNutrient.omega3, DietDirection.more, l10n.dietWhyPersianOmega3,
          CatAssessmentDimension.breed, _wBreed);
      add(DietNutrient.fiber, DietDirection.more, l10n.dietWhyPersianFiber,
          CatAssessmentDimension.breed, _wBreed);
      add(DietNutrient.carbs, DietDirection.less, l10n.dietWhyPersianCarbs,
          CatAssessmentDimension.breed, _wBreed);
      break;
    case 'sphynx':
      add(DietNutrient.fat, DietDirection.more, l10n.dietWhySphynxFat,
          CatAssessmentDimension.breed, _wBreed);
      break;
    case 'bengal':
      add(DietNutrient.protein, DietDirection.more, l10n.dietWhyBengalProtein,
          CatAssessmentDimension.breed, _wBreed);
      break;
    case 'british shorthair':
      add(DietNutrient.calories, DietDirection.less,
          l10n.dietWhyBritishCalories, CatAssessmentDimension.breed, _wBreed);
      break;
  }

  // --- Coat --------------------------------------------------------------
  switch (_norm(cat.coatType)) {
    case 'long_hair':
    case 'long':
      add(DietNutrient.omega3, DietDirection.more, l10n.dietWhyLongCoatOmega3,
          CatAssessmentDimension.coat, _wCoat);
      add(DietNutrient.fiber, DietDirection.more, l10n.dietWhyLongCoatFiber,
          CatAssessmentDimension.coat, _wCoat);
      break;
    case 'hairless':
      add(DietNutrient.fat, DietDirection.more, l10n.dietWhyHairlessFat,
          CatAssessmentDimension.coat, _wCoat);
      break;
  }

  // --- Health conditions -------------------------------------------------
  final conditions = cat.healthConditions ?? const [];
  for (final c in conditions) {
    switch (c.trim().toLowerCase()) {
      case 'urinary_issues':
        add(DietNutrient.water, DietDirection.more, l10n.dietWhyUrinaryWater,
            CatAssessmentDimension.health, _wHealth);
        break;
      case 'kidney_disease':
        add(DietNutrient.phosphorus, DietDirection.less,
            l10n.dietWhyKidneyPhosphorus, CatAssessmentDimension.health,
            _wHealth);
        add(DietNutrient.protein, DietDirection.less,
            l10n.dietWhyKidneyProtein, CatAssessmentDimension.health, _wHealth);
        add(DietNutrient.omega3, DietDirection.more, l10n.dietWhyKidneyOmega3,
            CatAssessmentDimension.health, _wHealth);
        break;
      case 'diabetes':
        add(DietNutrient.carbs, DietDirection.less, l10n.dietWhyDiabetesCarbs,
            CatAssessmentDimension.health, _wHealth);
        add(DietNutrient.protein, DietDirection.more,
            l10n.dietWhyDiabetesProtein, CatAssessmentDimension.health,
            _wHealth);
        break;
      case 'skin_allergies':
        add(DietNutrient.omega3, DietDirection.more, l10n.dietWhySkinOmega3,
            CatAssessmentDimension.health, _wHealth);
        break;
      case 'hairball_issues':
        add(DietNutrient.fiber, DietDirection.more, l10n.dietWhyHairballFiber,
            CatAssessmentDimension.health, _wHealth);
        add(DietNutrient.omega3, DietDirection.more,
            l10n.dietWhyHairballOmega3, CatAssessmentDimension.health,
            _wHealth);
        break;
      case 'joint_issues':
        add(DietNutrient.omega3, DietDirection.more, l10n.dietWhyJointOmega3,
            CatAssessmentDimension.health, _wHealth);
        break;
      case 'dental_problems':
        add(DietNutrient.moisture, DietDirection.more,
            l10n.dietWhyDentalMoisture, CatAssessmentDimension.health,
            _wHealth);
        break;
      case 'heart_condition':
        add(DietNutrient.omega3, DietDirection.more, l10n.dietWhyHeartOmega3,
            CatAssessmentDimension.health, _wHealth);
        add(DietNutrient.taurine, DietDirection.more, l10n.dietWhyHeartTaurine,
            CatAssessmentDimension.health, _wHealth);
        add(DietNutrient.sodium, DietDirection.less, l10n.dietWhyHeartSodium,
            CatAssessmentDimension.health, _wHealth);
        break;
      case 'food_allergies':
        add(DietNutrient.novelProtein, DietDirection.more,
            l10n.dietWhyAllergyNovelProtein, CatAssessmentDimension.health,
            _wHealth);
        break;
      case 'sensitive_stomach':
        add(DietNutrient.digestibility, DietDirection.more,
            l10n.dietWhySensitiveDigestible, CatAssessmentDimension.health,
            _wHealth);
        break;
    }
  }

  // --- Hydration (always) ------------------------------------------------
  // Every cat benefits from more water; a stronger, condition-specific water
  // tip (e.g. urinary) will outrank this in the dedup below.
  add(DietNutrient.water, DietDirection.more, l10n.dietWhyWaterGeneral,
      CatAssessmentDimension.health, _wHydration);

  return _dedupe(raws);
}

/// Keeps one tip per nutrient: the highest-priority rule wins, which also
/// resolves opposite-direction conflicts (health beats age, etc.). Mirrors the
/// spirit of `_resolveWeightVsNeutered` in the product assessment. Final list
/// is sorted by priority descending.
List<DietRecommendation> _dedupe(List<DietRecommendation> raws) {
  final winners = <DietNutrient, DietRecommendation>{};
  for (final r in raws) {
    final current = winners[r.nutrient];
    if (current == null || r.priority > current.priority) {
      winners[r.nutrient] = r;
    }
  }
  final result = winners.values.toList()
    ..sort((a, b) => b.priority.compareTo(a.priority));
  return result;
}

String _title(AppLocalizations l10n, DietNutrient nutrient,
    DietDirection direction) {
  final more = direction == DietDirection.more;
  switch (nutrient) {
    case DietNutrient.protein:
      return more ? l10n.dietTitleMoreProtein : l10n.dietTitleLessProtein;
    case DietNutrient.fat:
      return more ? l10n.dietTitleMoreFat : l10n.dietTitleLessFat;
    case DietNutrient.carbs:
      return l10n.dietTitleLessCarbs;
    case DietNutrient.fiber:
      return l10n.dietTitleMoreFiber;
    case DietNutrient.moisture:
      return l10n.dietTitleMoreMoisture;
    case DietNutrient.omega3:
      return l10n.dietTitleMoreOmega3;
    case DietNutrient.phosphorus:
      return l10n.dietTitleLessPhosphorus;
    case DietNutrient.calories:
      return more ? l10n.dietTitleMoreCalories : l10n.dietTitleLessCalories;
    case DietNutrient.water:
      return l10n.dietTitleMoreWater;
    case DietNutrient.taurine:
      return l10n.dietTitleMoreTaurine;
    case DietNutrient.sodium:
      return l10n.dietTitleLessSodium;
    case DietNutrient.novelProtein:
      return l10n.dietTitleNovelProtein;
    case DietNutrient.digestibility:
      return l10n.dietTitleDigestible;
  }
}

/// Cat's life stage, falling back to deriving it from age in months when the
/// stored `ageGroup` is missing.
String? _ageGroup(CatEntity cat) =>
    _norm(cat.ageGroup) ?? ageGroupFromMonths(cat.age);

/// Trim + lowercase a loosely-stored profile field; null/empty → null so the
/// rule switches fall through to no recommendation.
String? _norm(String? value) {
  if (value == null) return null;
  final trimmed = value.trim().toLowerCase();
  return trimmed.isEmpty ? null : trimmed;
}
