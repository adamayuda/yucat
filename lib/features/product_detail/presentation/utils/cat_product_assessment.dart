import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';

// ---------------------------------------------------------------------------
// Thresholds
// All numeric cutoffs live here so the rule set is editable in one place.
// AAFCO-anchored values are noted in comments; everything else is heuristic.
// ---------------------------------------------------------------------------

// Age — AAFCO growth life-stage minimums (kitten); senior values are heuristic.
const _kittenProteinMin = 28.0;
const _kittenProteinHigh = 35.0;
const _kittenFatHigh = 18.0;
const _seniorProteinLow = 30.0;
const _seniorProteinHigh = 35.0;
const _seniorFatMax = 20.0;

// Weight category — heuristic.
const _underweightCaloriesHigh = 380.0;
const _underweightFatHigh = 18.0;
const _overweightCaloriesHigh = 360.0;
const _overweightCaloriesLowMin = 280.0;
const _overweightCaloriesLowMax = 320.0;
const _overweightFiberHigh = 4.0;
const _obeseFatMax = 15.0;
const _obeseCaloriesMax = 330.0;
const _obeseLeanProteinMin = 40.0;
const _obeseLeanFatMax = 12.0;

// Activity — heuristic.
const _lowActivityCaloriesHigh = 360.0;
const _lowActivityCaloriesLow = 330.0;
const _highActivityCaloriesHigh = 380.0;
const _highActivityProteinHigh = 35.0;

// Neutered status — heuristic.
const _neuteredCaloriesHigh = 380.0;
const _neuteredFatHigh = 16.0;
const _pregnantProteinHigh = 35.0;
const _pregnantFatHigh = 20.0;
const _pregnantCaloriesHigh = 400.0;

// Breed — heuristic. Bengal thresholds softened from prior 40/32 → 38/30 to
// reduce the chance one breed rule dominates the overall delta.
const _maineCoonProteinHigh = 35.0;
const _persianFiberLow = 4.0;
const _persianFiberHigh = 6.0;
const _persianCarbsHigh = 30.0;
const _sphynxFatHigh = 18.0;
const _sphynxFatLow = 12.0;
const _britishCaloriesHigh = 360.0;
const _bengalProteinHigh = 38.0;
const _bengalProteinLow = 30.0;

// Health conditions — heuristic.
const _kidneyProteinMax = 32.0;
const _diabetesCarbsMax = 20.0;
const _diabetesProteinHigh = 40.0;
const _dentalMoistureMin = 70.0;
const _hairballFiberLow = 4.0;
const _hairballFiberHigh = 6.0;
const _sensitiveStomachIngredientMax = 12;

// Dimension weights, ×10 (we divide by 10 at the end so we stay in ints).
// Health and weight dominate; breed is a tiebreaker.
const _wHealth = 15;
const _wWeight = 12;
const _wAge = 10;
const _wActivity = 8;
const _wNeutered = 6;
const _wBreed = 5;

// ---------------------------------------------------------------------------
// Keyword sets — text scans against the LLM's pros/cons summary.
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
const _kLowPhosphorus = 'low phosphorus';
const _kRenalSupport = ['renal support', 'kidney support', 'renal care'];
const _kLimitedIngredient = [
  'limited ingredient',
  'single protein',
  'single source protein',
];
const _kCommonAllergens = ['chicken', 'fish', 'beef'];
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

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum CatAssessmentDimension { health, weight, age, activity, neutered, breed }

class CatProductFinding {
  final String text;
  final CatAssessmentDimension dimension;
  const CatProductFinding({required this.text, required this.dimension});
}

/// Per-cat fit assessment for a product.
///
/// `score` is a 0-100 fit score derived from the same rules that produce
/// `pros` and `cons`. 70 is the neutral baseline; each finding shifts the
/// score by a small delta proportional to its severity, weighted by
/// dimension priority (health/weight outweigh breed/neutered).
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
) {
  final text = _normalizeText(product);

  final age = _evaluateAge(cat, product, text);
  final weight = _evaluateWeight(cat, product);
  final activity = _evaluateActivity(cat, product);
  final neutered = _evaluateNeutered(cat, product, text);
  final breed = _evaluateBreed(cat, product, text);
  final health = _evaluateHealth(cat, product, text);

  // Weight category overrides neutered status when they pull in opposite
  // directions. An underweight neutered cat needs calories — drop the
  // neutered penalty + matching pro/con line rather than letting them cancel.
  final neuteredResolved = _resolveWeightVsNeutered(weight, neutered);

  final weighted =
      (health.delta * _wHealth +
              weight.delta * _wWeight +
              age.delta * _wAge +
              activity.delta * _wActivity +
              neuteredResolved.delta * _wNeutered +
              breed.delta * _wBreed) ~/
          10;

  // Concatenate in priority order so the most important findings appear first.
  return CatProductAssessment(
    pros: [
      ...health.pros,
      ...weight.pros,
      ...age.pros,
      ...activity.pros,
      ...neuteredResolved.pros,
      ...breed.pros,
    ],
    cons: [
      ...health.cons,
      ...weight.cons,
      ...age.cons,
      ...activity.cons,
      ...neuteredResolved.cons,
      ...breed.cons,
    ],
    delta: weighted,
  );
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
  ProductDisplayModel product,
  String text,
) {
  final pros = <CatProductFinding>[];
  final cons = <CatProductFinding>[];
  var delta = 0;

  switch (cat.ageGroup) {
    case 'kitten':
      if (product.protein > _kittenProteinHigh) {
        pros.add(_p('High protein (>35%) which is beneficial for kittens',
            CatAssessmentDimension.age));
        delta += 8;
      }
      if (product.fat > _kittenFatHigh) {
        pros.add(_p('High fat (>18%) which supports kitten growth',
            CatAssessmentDimension.age));
        delta += 6;
      }
      if (_containsAny(text, _kSenior)) {
        cons.add(_p('Senior-targeted formula is not ideal for kittens',
            CatAssessmentDimension.age));
        delta -= 10;
      }
      if (product.protein < _kittenProteinMin) {
        cons.add(_p('Low protein (<28%) may not meet kitten needs',
            CatAssessmentDimension.age));
        delta -= 10;
      }
      break;
    case 'adult':
      // Neutral baseline — no strong age rules.
      break;
    case 'senior':
      if (product.protein >= _seniorProteinLow &&
          product.protein <= _seniorProteinHigh) {
        pros.add(_p('Moderate protein (30–35%) is appropriate for seniors',
            CatAssessmentDimension.age));
        delta += 6;
      }
      if (product.fat > _seniorFatMax) {
        cons.add(_p('Very high fat (>20%) may be unsuitable for seniors',
            CatAssessmentDimension.age));
        delta -= 8;
      }
      if (_containsAny(text, _kJointSupport)) {
        pros.add(_p(
            'Contains joint support ingredients (e.g. glucosamine, chondroitin)',
            CatAssessmentDimension.age));
        delta += 8;
      }
      if (_containsAny(text, _kKidneyFriendly)) {
        pros.add(_p('Kidney-friendly formulation (e.g. lower phosphorus)',
            CatAssessmentDimension.age));
        delta += 10;
      }
      break;
  }

  return _DimensionResult(pros: pros, cons: cons, delta: delta);
}

_DimensionResult _evaluateWeight(CatEntity cat, ProductDisplayModel product) {
  final pros = <CatProductFinding>[];
  final cons = <CatProductFinding>[];
  var delta = 0;

  switch (cat.weightCategory) {
    case 'underweight':
      if (product.calories > _underweightCaloriesHigh) {
        pros.add(_p(
            'High calories (>380 kcal/100g) can help an underweight cat gain weight',
            CatAssessmentDimension.weight));
        delta += 8;
      }
      if (product.fat > _underweightFatHigh) {
        pros.add(_p('High fat (>18%) supports weight gain for underweight cats',
            CatAssessmentDimension.weight));
        delta += 6;
      }
      break;
    case 'normal':
      break;
    case 'overweight':
      if (product.calories > _overweightCaloriesHigh) {
        cons.add(_p(
            'High calories (>360 kcal/100g) may not be ideal for an overweight cat',
            CatAssessmentDimension.weight));
        delta -= 10;
      }
      if (product.calories >= _overweightCaloriesLowMin &&
          product.calories < _overweightCaloriesLowMax) {
        pros.add(_p(
            'Lower calories (<320 kcal/100g) help manage weight in overweight cats',
            CatAssessmentDimension.weight));
        delta += 8;
      }
      if (product.fiber > _overweightFiberHigh) {
        pros.add(_p(
            'Higher fiber (>4%) can help with satiety for overweight cats',
            CatAssessmentDimension.weight));
        delta += 6;
      }
      break;
    case 'obese':
      if (product.fat > _obeseFatMax) {
        cons.add(_p('High fat (>15%) is not suitable for obese cats',
            CatAssessmentDimension.weight));
        delta -= 10;
      }
      if (product.calories > _obeseCaloriesMax) {
        cons.add(_p('High calories (>330 kcal/100g) are not ideal for obese cats',
            CatAssessmentDimension.weight));
        delta -= 10;
      }
      if (product.protein > _obeseLeanProteinMin &&
          product.fat < _obeseLeanFatMax) {
        pros.add(_p(
            'Lean, high-protein formula (>40% protein, <12% fat) is good for obese cats',
            CatAssessmentDimension.weight));
        delta += 10;
      }
      break;
  }

  return _DimensionResult(pros: pros, cons: cons, delta: delta);
}

_DimensionResult _evaluateActivity(CatEntity cat, ProductDisplayModel product) {
  final pros = <CatProductFinding>[];
  final cons = <CatProductFinding>[];
  var delta = 0;

  switch (cat.activityLevel) {
    case 'low':
      if (product.calories > _lowActivityCaloriesHigh) {
        cons.add(_p(
            'High calories (>360 kcal/100g) may not suit a low-activity cat',
            CatAssessmentDimension.activity));
        delta -= 8;
      }
      if (product.calories < _lowActivityCaloriesLow) {
        pros.add(_p(
            'Moderate calories (<330 kcal/100g) are better for low-activity cats',
            CatAssessmentDimension.activity));
        delta += 6;
      }
      break;
    case 'high':
      if (product.calories > _highActivityCaloriesHigh) {
        pros.add(_p(
            'Higher calories (>380 kcal/100g) support a highly active cat',
            CatAssessmentDimension.activity));
        delta += 6;
      }
      if (product.protein > _highActivityProteinHigh) {
        pros.add(_p('High protein (>35%) helps maintain muscle in active cats',
            CatAssessmentDimension.activity));
        delta += 6;
      }
      break;
  }

  return _DimensionResult(pros: pros, cons: cons, delta: delta);
}

_DimensionResult _evaluateNeutered(
  CatEntity cat,
  ProductDisplayModel product,
  String text,
) {
  final pros = <CatProductFinding>[];
  final cons = <CatProductFinding>[];
  var delta = 0;

  switch (cat.neuteredStatus) {
    case 'neutered':
      if (product.calories > _neuteredCaloriesHigh) {
        cons.add(_p(
            'Very calorie-dense food (>380 kcal/100g) can promote weight gain in neutered cats',
            CatAssessmentDimension.neutered));
        delta -= 8;
      }
      if (_containsAny(text, _kUrinaryClaim)) {
        pros.add(_p(
            'Contains urinary support ingredients, good for neutered cats',
            CatAssessmentDimension.neutered));
        delta += 8;
      }
      if (product.fat > _neuteredFatHigh) {
        cons.add(_p('High fat (>16%) may not be ideal for neutered cats',
            CatAssessmentDimension.neutered));
        delta -= 6;
      }
      break;
    case 'pregnant':
    case 'lactating':
      if (product.protein > _pregnantProteinHigh) {
        pros.add(_p(
            'Very high protein (>35%) supports the increased needs of pregnant/lactating cats',
            CatAssessmentDimension.neutered));
        delta += 8;
      }
      if (product.fat > _pregnantFatHigh) {
        pros.add(_p(
            'High fat (>20%) provides extra energy for pregnant/lactating cats',
            CatAssessmentDimension.neutered));
        delta += 8;
      }
      if (product.calories > _pregnantCaloriesHigh) {
        pros.add(_p(
            'Very calorie-dense food (>400 kcal/100g) helps meet energy demands in pregnancy/lactation',
            CatAssessmentDimension.neutered));
        delta += 6;
      }
      break;
  }

  return _DimensionResult(pros: pros, cons: cons, delta: delta);
}

_DimensionResult _evaluateBreed(
  CatEntity cat,
  ProductDisplayModel product,
  String text,
) {
  final pros = <CatProductFinding>[];
  final cons = <CatProductFinding>[];
  var delta = 0;

  final breedRaw = cat.breed;
  if (breedRaw == null) return const _DimensionResult();

  switch (breedRaw.toLowerCase()) {
    case 'maine coon':
      if (_containsAny(text, _kJointSupport)) {
        pros.add(_p(
            'Contains joint support ingredients, helpful for Maine Coons',
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (product.protein > _maineCoonProteinHigh) {
        pros.add(_p('High protein (>35%) supports large-breed Maine Coons',
            CatAssessmentDimension.breed));
        delta += 6;
      }
      break;
    case 'persian':
      if ((product.fiber >= _persianFiberLow &&
              product.fiber <= _persianFiberHigh) ||
          _containsAny(text, _kHairball)) {
        pros.add(_p(
            'Hairball-control style formula (fiber 4–6% or hairball claims)',
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (_containsAny(text, _kOmega3)) {
        pros.add(_p(
            'Includes omega-3 rich ingredients, good for Persian coat/skin',
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (product.carbs > _persianCarbsHigh) {
        cons.add(_p('High carbohydrate (>30%) may not be ideal for Persians',
            CatAssessmentDimension.breed));
        delta -= 6;
      }
      break;
    case 'siamese':
      if (_containsAny(text, _kDigestible)) {
        pros.add(_p('Uses easily digestible proteins, good for Siamese cats',
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (_hasManyFillersWordBoundary(text)) {
        cons.add(_p(
            'Contains many fillers (corn, wheat, soy) which may not suit Siamese cats',
            CatAssessmentDimension.breed));
        delta -= 8;
      }
      break;
    case 'sphynx':
      if (product.fat > _sphynxFatHigh) {
        pros.add(_p('Higher fat (>18%) can support Sphynx skin health',
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (product.fat < _sphynxFatLow) {
        cons.add(_p(
            'Low-fat formula (<12%) may not provide enough support for Sphynx skin',
            CatAssessmentDimension.breed));
        delta -= 8;
      }
      break;
    case 'british shorthair':
      if (product.calories > _britishCaloriesHigh) {
        cons.add(_p(
            'High-calorie food may promote weight gain in British Shorthairs',
            CatAssessmentDimension.breed));
        delta -= 8;
      }
      if (_containsAny(text, _kWeightManagement)) {
        pros.add(_p(
            'Weight-management style formula is suitable for British Shorthairs',
            CatAssessmentDimension.breed));
        delta += 8;
      }
      break;
    case 'bengal':
      if (product.protein > _bengalProteinHigh) {
        pros.add(_p('High protein (>38%) matches Bengal energy needs',
            CatAssessmentDimension.breed));
        delta += 6;
      }
      if (product.protein < _bengalProteinLow) {
        cons.add(_p('Low protein (<30%) may be insufficient for Bengals',
            CatAssessmentDimension.breed));
        delta -= 6;
      }
      break;
  }

  return _DimensionResult(pros: pros, cons: cons, delta: delta);
}

_DimensionResult _evaluateHealth(
  CatEntity cat,
  ProductDisplayModel product,
  String text,
) {
  final pros = <CatProductFinding>[];
  final cons = <CatProductFinding>[];
  var delta = 0;

  final conditions = cat.healthConditions ?? [];
  if (conditions.isEmpty || conditions.contains('none')) {
    return const _DimensionResult();
  }

  final ingredientCount = _estimateIngredientCount(text);

  if (conditions.contains('urinary_issues')) {
    if (_containsAny(text, _kLowAsh)) {
      pros.add(_p(
          'Formulated with low ash content, supportive for urinary issues',
          CatAssessmentDimension.health));
      delta += 8;
    }
    if (_containsAny(text, _kUrinarySupport)) {
      pros.add(_p(
          'Includes urinary-support ingredients like cranberry or DL-methionine',
          CatAssessmentDimension.health));
      delta += 10;
    }
    if (_containsAny(text, _kHighMinerals)) {
      cons.add(_p('High mineral content may not be ideal for urinary issues',
          CatAssessmentDimension.health));
      delta -= 8;
    }
  }

  if (conditions.contains('kidney_disease')) {
    if (product.protein > _kidneyProteinMax) {
      cons.add(_p('High protein (>32%) may not be ideal for kidney disease',
          CatAssessmentDimension.health));
      delta -= 12;
    }
    if (text.contains(_kPhosphorus) && !text.contains(_kLowPhosphorus)) {
      cons.add(_p(
          'Contains phosphorus sources that may be problematic in kidney disease',
          CatAssessmentDimension.health));
      delta -= 10;
    }
    if (_containsAny(text, _kRenalSupport)) {
      pros.add(_p('Formulated as a renal-support diet',
          CatAssessmentDimension.health));
      delta += 12;
    }
  }

  if (conditions.contains('sensitive_stomach')) {
    if (_containsAny(text, _kLimitedIngredient)) {
      pros.add(_p(
          'Limited-ingredient style recipe can help sensitive stomachs',
          CatAssessmentDimension.health));
      delta += 8;
    }
    if (ingredientCount > _sensitiveStomachIngredientMax) {
      cons.add(_p('Very long ingredient list may not suit sensitive stomachs',
          CatAssessmentDimension.health));
      delta -= 6;
    }
  }

  if (conditions.contains('food_allergies')) {
    if (_containsAny(text, _kCommonAllergens)) {
      cons.add(_p('Contains common allergens like chicken, fish, or beef',
          CatAssessmentDimension.health));
      delta -= 12;
    }
    if (_containsAny(text, _kNovelProteins)) {
      pros.add(_p(
          'Uses novel proteins (e.g. duck, venison) which may help with allergies',
          CatAssessmentDimension.health));
      delta += 10;
    }
  }

  if (conditions.contains('skin_allergies')) {
    if (_containsAny(text, _kOmega3)) {
      pros.add(_p('Omega-3 rich formulation can support skin and coat health',
          CatAssessmentDimension.health));
      delta += 6;
    }
    if (_containsAny(text, _kArtificialColor)) {
      cons.add(_p(
          'Contains artificial colors which may aggravate skin allergies',
          CatAssessmentDimension.health));
      delta -= 8;
    }
  }

  if (conditions.contains('diabetes')) {
    if (product.carbs > _diabetesCarbsMax) {
      cons.add(_p('High carbohydrates (>20%) are less suitable for diabetic cats',
          CatAssessmentDimension.health));
      delta -= 10;
    }
    if (product.protein > _diabetesProteinHigh) {
      pros.add(_p(
          'Very high protein (>40%) can support blood sugar control in diabetes',
          CatAssessmentDimension.health));
      delta += 8;
    }
  }

  if (conditions.contains('dental_problems')) {
    if (product.moisture > _dentalMoistureMin) {
      pros.add(_p(
          'High-moisture (wet-style) food is easier to eat with dental problems',
          CatAssessmentDimension.health));
      delta += 6;
    }
    if (_containsAny(text, _kLargeKibble)) {
      cons.add(_p(
          'Very large kibble pieces may be hard to chew with dental issues',
          CatAssessmentDimension.health));
      delta -= 6;
    }
  }

  if (conditions.contains('hairball_issues')) {
    if ((product.fiber >= _hairballFiberLow &&
            product.fiber <= _hairballFiberHigh) ||
        _containsAny(text, _kHairball)) {
      pros.add(_p('Hairball control style diet (fiber 4–6% or hairball claims)',
          CatAssessmentDimension.health));
      delta += 6;
    }
  }

  return _DimensionResult(pros: pros, cons: cons, delta: delta);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

CatProductFinding _p(String text, CatAssessmentDimension dim) =>
    CatProductFinding(text: text, dimension: dim);

String _normalizeText(ProductDisplayModel product) {
  return (product.pros + product.cons)
      .join(' ')
      .toLowerCase()
      .replaceAll('-', ' ');
}

bool _containsAny(String text, List<String> needles) =>
    needles.any(text.contains);

bool _hasManyFillersWordBoundary(String text) {
  // Word-boundary match so "corn-free" / "wheat-free" don't false-positive.
  // Note: text has hyphens replaced with spaces, so "corn-free" reads as
  // "corn free" — \b still anchors on the space.
  final hits = _kFillers.where((needle) {
    final pattern = RegExp(r'\b' + RegExp.escape(needle) + r'\b');
    return pattern.hasMatch(text);
  }).length;
  return hits >= 2;
}

int _estimateIngredientCount(String text) {
  final i = text.indexOf('ingredients');
  if (i == -1) return 0;
  return ','.allMatches(text.substring(i)).length + 1;
}
