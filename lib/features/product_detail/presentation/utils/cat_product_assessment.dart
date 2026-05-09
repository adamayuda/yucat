import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';

/// Per-cat fit assessment for a product.
///
/// `score` is a 0-100 fit score computed from the same rules that produce
/// `pros` and `cons`. Higher is better. 70 is the neutral baseline (no
/// signal, neither good nor bad). Each pro/con shifts the score by a small
/// delta proportional to its severity.
class CatProductAssessment {
  final List<String> pros;
  final List<String> cons;

  /// Signed delta from the neutral baseline (70). Use `score` for the
  /// clamped 0-100 value.
  final int delta;

  const CatProductAssessment({
    required this.pros,
    required this.cons,
    this.delta = 0,
  });

  /// 0-100 fit score for the cat. Clamped.
  int get score => (70 + delta).clamp(0, 100);
}

/// Combines all current rule sets into a single assessment with score.
CatProductAssessment evaluateCatProduct(
  CatEntity cat,
  ProductDisplayModel product,
) {
  final ageAssessment = evaluateAgeProsCons(cat, product);
  final weightAssessment = evaluateWeightProsCons(cat, product);
  final activityAssessment = evaluateActivityProsCons(cat, product);
  final neuteredAssessment = evaluateNeuteredProsCons(cat, product);
  final breedAssessment = evaluateBreedProsCons(cat, product);
  final healthAssessment = evaluateHealthConditionProsCons(cat, product);

  return CatProductAssessment(
    pros: [
      ...ageAssessment.pros,
      ...weightAssessment.pros,
      ...activityAssessment.pros,
      ...neuteredAssessment.pros,
      ...breedAssessment.pros,
      ...healthAssessment.pros,
    ],
    cons: [
      ...ageAssessment.cons,
      ...weightAssessment.cons,
      ...activityAssessment.cons,
      ...neuteredAssessment.cons,
      ...breedAssessment.cons,
      ...healthAssessment.cons,
    ],
    delta: ageAssessment.delta +
        weightAssessment.delta +
        activityAssessment.delta +
        neuteredAssessment.delta +
        breedAssessment.delta +
        healthAssessment.delta,
  );
}

CatProductAssessment evaluateAgeProsCons(
  CatEntity cat,
  ProductDisplayModel product,
) {
  final pros = <String>[];
  final cons = <String>[];
  var delta = 0;

  switch (cat.ageGroup) {
    case 'kitten':
      if (product.protein > 35) {
        pros.add('High protein (>35%) which is beneficial for kittens');
        delta += 8;
      }
      if (product.fat > 18) {
        pros.add('High fat (>18%) which supports kitten growth');
        delta += 6;
      }
      if (_isSeniorFormula(product)) {
        cons.add('Senior-targeted formula is not ideal for kittens');
        delta -= 10;
      }
      if (product.protein < 28) {
        cons.add('Low protein (<28%) may not meet kitten needs');
        delta -= 10;
      }
      break;

    case 'adult':
      // Neutral baseline for now – no strong age rules
      break;

    case 'senior':
      if (product.protein >= 30 && product.protein <= 35) {
        pros.add('Moderate protein (30–35%) is appropriate for seniors');
        delta += 6;
      }
      if (product.fat > 20) {
        cons.add('Very high fat (>20%) may be unsuitable for seniors');
        delta -= 8;
      }
      if (_hasJointSupport(product)) {
        pros.add(
          'Contains joint support ingredients (e.g. glucosamine, chondroitin)',
        );
        delta += 8;
      }
      if (_isKidneyFriendly(product)) {
        pros.add('Kidney-friendly formulation (e.g. lower phosphorus)');
        delta += 10;
      }
      break;
  }

  return CatProductAssessment(pros: pros, cons: cons, delta: delta);
}

CatProductAssessment evaluateActivityProsCons(
  CatEntity cat,
  ProductDisplayModel product,
) {
  final pros = <String>[];
  final cons = <String>[];
  var delta = 0;

  final activityLevel = cat.activityLevel;
  if (activityLevel == null) {
    return CatProductAssessment(pros: pros, cons: cons);
  }

  switch (activityLevel) {
    case 'low':
      if (product.calories > 360) {
        cons.add(
          'High calories (>360 kcal/100g) may not suit a low-activity cat',
        );
        delta -= 8;
      }
      if (product.calories > 0 && product.calories < 330) {
        pros.add(
          'Moderate calories (<330 kcal/100g) are better for low-activity cats',
        );
        delta += 6;
      }
      break;

    case 'high':
      if (product.calories > 380) {
        pros.add(
          'Higher calories (>380 kcal/100g) support a highly active cat',
        );
        delta += 6;
      }
      if (product.protein > 35) {
        pros.add('High protein (>35%) helps maintain muscle in active cats');
        delta += 6;
      }
      break;
  }

  return CatProductAssessment(pros: pros, cons: cons, delta: delta);
}

CatProductAssessment evaluateBreedProsCons(
  CatEntity cat,
  ProductDisplayModel product,
) {
  final pros = <String>[];
  final cons = <String>[];
  var delta = 0;

  final breedRaw = cat.breed;
  if (breedRaw == null) {
    return CatProductAssessment(pros: pros, cons: cons);
  }

  final breed = breedRaw.toLowerCase();
  final text = (product.pros + product.cons).join(' ').toLowerCase();

  switch (breed) {
    case 'maine coon':
      if (_hasJointSupport(product)) {
        pros.add('Contains joint support ingredients, helpful for Maine Coons');
        delta += 6;
      }
      if (product.protein > 35) {
        pros.add('High protein (>35%) supports large-breed Maine Coons');
        delta += 6;
      }
      break;

    case 'persian':
      if (product.fiber >= 4 && product.fiber <= 6 ||
          text.contains('hairball')) {
        pros.add(
          'Hairball-control style formula (fiber 4–6% or hairball claims)',
        );
        delta += 6;
      }
      if (_hasOmega3(product)) {
        pros.add(
          'Includes omega-3 rich ingredients, good for Persian coat/skin',
        );
        delta += 6;
      }
      if (product.carbs > 30) {
        cons.add('High carbohydrate (>30%) may not be ideal for Persians');
        delta -= 6;
      }
      break;

    case 'siamese':
      if (text.contains('digestible') || text.contains('highly digestible')) {
        pros.add('Uses easily digestible proteins, good for Siamese cats');
        delta += 6;
      }
      if (_hasManyFillers(product)) {
        cons.add(
          'Contains many fillers (corn, wheat, soy) which may not suit Siamese cats',
        );
        delta -= 8;
      }
      break;

    case 'sphynx':
      if (product.fat > 18) {
        pros.add('Higher fat (>18%) can support Sphynx skin health');
        delta += 6;
      }
      if (product.fat < 12) {
        cons.add(
          'Low-fat formula (<12%) may not provide enough support for Sphynx skin',
        );
        delta -= 8;
      }
      break;

    case 'british shorthair':
      if (product.calories > 360) {
        cons.add(
          'High-calorie food may promote weight gain in British Shorthairs',
        );
        delta -= 8;
      }
      if (text.contains('weight management') ||
          text.contains('light') ||
          text.contains('indoor')) {
        pros.add(
          'Weight-management style formula is suitable for British Shorthairs',
        );
        delta += 8;
      }
      break;

    case 'bengal':
      if (product.protein > 40) {
        pros.add('Very high protein (>40%) matches Bengal energy needs');
        delta += 8;
      }
      if (product.protein < 32) {
        cons.add('Low protein (<32%) may be insufficient for Bengals');
        delta -= 10;
      }
      break;
  }

  return CatProductAssessment(pros: pros, cons: cons, delta: delta);
}

CatProductAssessment evaluateNeuteredProsCons(
  CatEntity cat,
  ProductDisplayModel product,
) {
  final pros = <String>[];
  final cons = <String>[];
  var delta = 0;

  final status = cat.neuteredStatus;
  if (status == null) {
    return CatProductAssessment(pros: pros, cons: cons);
  }

  final text = (product.pros + product.cons).join(' ').toLowerCase();

  switch (status) {
    case 'neutered':
      if (product.calories > 380) {
        cons.add(
          'Very calorie-dense food (>380 kcal/100g) can promote weight gain in neutered cats',
        );
        delta -= 8;
      }
      if (text.contains('urinary') ||
          text.contains('struvite') ||
          text.contains('urinary tract')) {
        pros.add(
          'Contains urinary support ingredients, good for neutered cats',
        );
        delta += 8;
      }
      if (product.fat > 16) {
        cons.add('High fat (>16%) may not be ideal for neutered cats');
        delta -= 6;
      }
      break;

    case 'pregnant':
    case 'lactating':
      if (product.protein > 35) {
        pros.add(
          'Very high protein (>35%) supports the increased needs of pregnant/lactating cats',
        );
        delta += 8;
      }
      if (product.fat > 20) {
        pros.add(
          'High fat (>20%) provides extra energy for pregnant/lactating cats',
        );
        delta += 8;
      }
      if (product.calories > 400) {
        pros.add(
          'Very calorie-dense food (>400 kcal/100g) helps meet energy demands in pregnancy/lactation',
        );
        delta += 6;
      }
      break;
  }

  return CatProductAssessment(pros: pros, cons: cons, delta: delta);
}

CatProductAssessment evaluateWeightProsCons(
  CatEntity cat,
  ProductDisplayModel product,
) {
  final pros = <String>[];
  final cons = <String>[];
  var delta = 0;

  final bodyCondition = cat.weightCategory;
  if (bodyCondition == null) {
    return CatProductAssessment(pros: pros, cons: cons);
  }

  switch (bodyCondition) {
    case 'underweight':
      if (product.calories > 380) {
        pros.add(
          'High calories (>380 kcal/100g) can help an underweight cat gain weight',
        );
        delta += 8;
      }
      if (product.fat > 18) {
        pros.add('High fat (>18%) supports weight gain for underweight cats');
        delta += 6;
      }
      break;

    case 'normal':
      // no special rule
      break;

    case 'overweight':
      if (product.calories > 360) {
        cons.add(
          'High calories (>360 kcal/100g) may not be ideal for an overweight cat',
        );
        delta -= 10;
      }
      if (product.calories > 0 && product.calories < 320) {
        pros.add(
          'Lower calories (<320 kcal/100g) help manage weight in overweight cats',
        );
        delta += 8;
      }
      if (product.fiber > 4) {
        pros.add(
          'Higher fiber (>4%) can help with satiety for overweight cats',
        );
        delta += 6;
      }
      break;

    case 'obese':
      if (product.fat > 15) {
        cons.add('High fat (>15%) is not suitable for obese cats');
        delta -= 10;
      }
      if (product.calories > 330) {
        cons.add('High calories (>330 kcal/100g) are not ideal for obese cats');
        delta -= 10;
      }
      if (product.protein > 40 && product.fat < 12) {
        pros.add(
          'Lean, high-protein formula (>40% protein, <12% fat) is good for obese cats',
        );
        delta += 10;
      }
      break;
  }

  return CatProductAssessment(pros: pros, cons: cons, delta: delta);
}

CatProductAssessment evaluateHealthConditionProsCons(
  CatEntity cat,
  ProductDisplayModel product,
) {
  final pros = <String>[];
  final cons = <String>[];
  var delta = 0;

  final conditions = cat.healthConditions ?? [];
  if (conditions.isEmpty || conditions.contains('none')) {
    return CatProductAssessment(pros: pros, cons: cons);
  }

  final text = (product.pros + product.cons).join(' ').toLowerCase();
  final ingredientCount = _estimateIngredientCount(text);

  if (conditions.contains('urinary_issues')) {
    if (text.contains('low ash') || text.contains('reduced ash')) {
      pros.add(
        'Formulated with low ash content, supportive for urinary issues',
      );
      delta += 8;
    }
    if (text.contains('cranberry') ||
        text.contains('d-mannose') ||
        text.contains('dl-methionine') ||
        text.contains('methionine')) {
      pros.add(
        'Includes urinary-support ingredients like cranberry or DL-methionine',
      );
      delta += 10;
    }
    if (text.contains('high minerals') ||
        text.contains('mineral-rich') ||
        text.contains('added minerals')) {
      cons.add('High mineral content may not be ideal for urinary issues');
      delta -= 8;
    }
  }

  if (conditions.contains('kidney_disease')) {
    if (product.protein > 32) {
      cons.add('High protein (>32%) may not be ideal for kidney disease');
      delta -= 12;
    }
    if (text.contains('phosphorus') && !text.contains('low phosphorus')) {
      cons.add(
        'Contains phosphorus sources that may be problematic in kidney disease',
      );
      delta -= 10;
    }
    if (text.contains('renal support') ||
        text.contains('kidney support') ||
        text.contains('renal care')) {
      pros.add('Formulated as a renal-support diet');
      delta += 12;
    }
  }

  if (conditions.contains('sensitive_stomach')) {
    if (_isLimitedIngredient(text)) {
      pros.add('Limited-ingredient style recipe can help sensitive stomachs');
      delta += 8;
    }
    if (ingredientCount > 12) {
      cons.add('Very long ingredient list may not suit sensitive stomachs');
      delta -= 6;
    }
  }

  if (conditions.contains('food_allergies')) {
    if (_containsCommonAllergen(text)) {
      cons.add('Contains common allergens like chicken, fish, or beef');
      delta -= 12;
    }
    if (_hasNovelProtein(text)) {
      pros.add(
        'Uses novel proteins (e.g. duck, venison) which may help with allergies',
      );
      delta += 10;
    }
  }

  if (conditions.contains('skin_allergies')) {
    if (_hasOmega3(product)) {
      pros.add('Omega-3 rich formulation can support skin and coat health');
      delta += 6;
    }
    if (text.contains('artificial color') ||
        text.contains('colour') ||
        text.contains('red 40') ||
        text.contains('yellow 5')) {
      cons.add('Contains artificial colors which may aggravate skin allergies');
      delta -= 8;
    }
  }

  if (conditions.contains('diabetes')) {
    if (product.carbs > 20) {
      cons.add('High carbohydrates (>20%) are less suitable for diabetic cats');
      delta -= 10;
    }
    if (product.protein > 40) {
      pros.add(
        'Very high protein (>40%) can support blood sugar control in diabetes',
      );
      delta += 8;
    }
  }

  if (conditions.contains('dental_problems')) {
    if (_isWetFood(product)) {
      pros.add(
        'High-moisture (wet-style) food is easier to eat with dental problems',
      );
      delta += 6;
    }
    if (text.contains('large kibble') || text.contains('large-sized kibble')) {
      cons.add(
        'Very large kibble pieces may be hard to chew with dental issues',
      );
      delta -= 6;
    }
  }

  if (conditions.contains('hairball_issues')) {
    if (product.fiber >= 4 && product.fiber <= 6 || text.contains('hairball')) {
      pros.add('Hairball control style diet (fiber 4–6% or hairball claims)');
      delta += 6;
    }
  }

  return CatProductAssessment(pros: pros, cons: cons, delta: delta);
}

bool _isSeniorFormula(ProductDisplayModel product) {
  final text = (product.pros + product.cons).join(' ').toLowerCase();
  return text.contains('senior');
}

bool _hasJointSupport(ProductDisplayModel product) {
  final text = (product.pros + product.cons).join(' ').toLowerCase();
  return text.contains('glucosamine') || text.contains('chondroitin');
}

bool _isKidneyFriendly(ProductDisplayModel product) {
  final text = (product.pros + product.cons).join(' ').toLowerCase();
  return text.contains('kidney') ||
      text.contains('renal') ||
      text.contains('low phosphorus') ||
      text.contains('reduced phosphorus');
}

bool _hasOmega3(ProductDisplayModel product) {
  final text = (product.pros + product.cons).join(' ').toLowerCase();
  return text.contains('omega-3') ||
      text.contains('omega 3') ||
      text.contains('fish oil') ||
      text.contains('salmon oil');
}

bool _hasManyFillers(ProductDisplayModel product) {
  final text = (product.pros + product.cons).join(' ').toLowerCase();
  final hasCorn = text.contains('corn');
  final hasWheat = text.contains('wheat');
  final hasSoy = text.contains('soy');
  final fillersCount = [hasCorn, hasWheat, hasSoy].where((e) => e).length;
  return fillersCount >= 2;
}

int _estimateIngredientCount(String text) {
  final ingredientsIndex = text.indexOf('ingredients');
  if (ingredientsIndex == -1) return 0;
  final snippet = text.substring(ingredientsIndex);
  final commaCount = ','.allMatches(snippet).length;
  return commaCount + 1;
}

bool _isLimitedIngredient(String text) {
  return text.contains('limited ingredient') ||
      text.contains('single protein') ||
      text.contains('single source protein');
}

bool _containsCommonAllergen(String text) {
  return text.contains('chicken') ||
      text.contains('fish') ||
      text.contains('beef');
}

bool _hasNovelProtein(String text) {
  return text.contains('duck') ||
      text.contains('venison') ||
      text.contains('kangaroo') ||
      text.contains('rabbit');
}

bool _isWetFood(ProductDisplayModel product) {
  return product.moisture > 70;
}
