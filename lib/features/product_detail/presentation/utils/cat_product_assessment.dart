import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_model.dart';

class CatProductAssessment {
  final List<String> pros;
  final List<String> cons;

  const CatProductAssessment({required this.pros, required this.cons});
}

CatProductAssessment evaluateAgeProsCons(CatEntity cat, ProductModel product) {
  final pros = <String>[];
  final cons = <String>[];

  switch (cat.ageGroup) {
    case 'kitten':
      // pro: high protein (>35%)
      if (product.protein > 35) {
        pros.add('High protein (>35%) which is beneficial for kittens');
      }

      // pro: high fat (>18%)
      if (product.fat > 18) {
        pros.add('High fat (>18%) which supports kitten growth');
      }

      // con: senior-targeted formula
      if (_isSeniorFormula(product)) {
        cons.add('Senior-targeted formula is not ideal for kittens');
      }

      // con: low protein (<28%)
      if (product.protein < 28) {
        cons.add('Low protein (<28%) may not meet kitten needs');
      }
      break;

    case 'adult':
      // Neutral baseline for now – no strong age rules
      break;

    case 'senior':
      // pro: moderate protein (30–35%)
      if (product.protein >= 30 && product.protein <= 35) {
        pros.add('Moderate protein (30–35%) is appropriate for seniors');
      }

      // con: very high fat (>20%)
      if (product.fat > 20) {
        cons.add('Very high fat (>20%) may be unsuitable for seniors');
      }

      // pro: joint support ingredient (glucosamine, chondroitin)
      if (_hasJointSupport(product)) {
        pros.add(
          'Contains joint support ingredients (e.g. glucosamine, chondroitin)',
        );
      }

      // pro: kidney-friendly (lower phosphorus)
      if (_isKidneyFriendly(product)) {
        pros.add('Kidney-friendly formulation (e.g. lower phosphorus)');
      }
      break;
  }

  return CatProductAssessment(pros: pros, cons: cons);
}

/// Combines all current rule sets (age, weight, etc.) into a single assessment.
CatProductAssessment evaluateCatProduct(CatEntity cat, ProductModel product) {
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
  );
}

CatProductAssessment evaluateActivityProsCons(
  CatEntity cat,
  ProductModel product,
) {
  final pros = <String>[];
  final cons = <String>[];

  final activityLevel = cat.activityLevel;
  if (activityLevel == null) {
    return CatProductAssessment(pros: pros, cons: cons);
  }

  switch (activityLevel) {
    case 'low':
      // con: high calories (>360 kcal)
      if (product.caloriesPer100g > 360) {
        cons.add(
          'High calories (>360 kcal/100g) may not suit a low-activity cat',
        );
      }

      // pro: moderate calorie (<330 kcal)
      if (product.caloriesPer100g > 0 && product.caloriesPer100g < 330) {
        pros.add(
          'Moderate calories (<330 kcal/100g) are better for low-activity cats',
        );
      }
      break;

    case 'high':
      // pro: high calorie (>380 kcal)
      if (product.caloriesPer100g > 380) {
        pros.add(
          'Higher calories (>380 kcal/100g) support a highly active cat',
        );
      }

      // pro: high protein (>35%)
      if (product.protein > 35) {
        pros.add('High protein (>35%) helps maintain muscle in active cats');
      }
      break;
  }

  return CatProductAssessment(pros: pros, cons: cons);
}

CatProductAssessment evaluateBreedProsCons(
  CatEntity cat,
  ProductModel product,
) {
  final pros = <String>[];
  final cons = <String>[];

  final breedRaw = cat.breed;
  if (breedRaw == null) {
    return CatProductAssessment(pros: pros, cons: cons);
  }

  final breed = breedRaw.toLowerCase();
  final text = (product.pros + product.cons).join(' ').toLowerCase();

  switch (breed) {
    case 'maine coon':
      // pro: joint ingredients
      if (_hasJointSupport(product)) {
        pros.add('Contains joint support ingredients, helpful for Maine Coons');
      }
      // pro: high protein (>35%) for large breed
      if (product.protein > 35) {
        pros.add('High protein (>35%) supports large-breed Maine Coons');
      }
      break;

    case 'persian':
      // pro: hairball control (fiber 4–6%)
      if (product.fiber >= 4 && product.fiber <= 6 ||
          text.contains('hairball')) {
        pros.add(
          'Hairball-control style formula (fiber 4–6% or hairball claims)',
        );
      }
      // pro: omega-3 rich ingredients
      if (_hasOmega3(product)) {
        pros.add(
          'Includes omega-3 rich ingredients, good for Persian coat/skin',
        );
      }
      // con: high carb (>30%)
      if (product.carbs > 30) {
        cons.add('High carbohydrate (>30%) may not be ideal for Persians');
      }
      break;

    case 'siamese':
      // pro: easily digestible proteins
      if (text.contains('digestible') || text.contains('highly digestible')) {
        pros.add('Uses easily digestible proteins, good for Siamese cats');
      }
      // con: many fillers (corn, wheat, soy)
      if (_hasManyFillers(product)) {
        cons.add(
          'Contains many fillers (corn, wheat, soy) which may not suit Siamese cats',
        );
      }
      break;

    case 'sphynx':
      // pro: high fat (>18%) for skin health
      if (product.fat > 18) {
        pros.add('Higher fat (>18%) can support Sphynx skin health');
      }
      // con: low-fat diets (<12%)
      if (product.fat < 12) {
        cons.add(
          'Low-fat formula (<12%) may not provide enough support for Sphynx skin',
        );
      }
      break;

    case 'british shorthair':
      // con: high-calorie foods
      if (product.caloriesPer100g > 360) {
        cons.add(
          'High-calorie food may promote weight gain in British Shorthairs',
        );
      }
      // pro: weight-management formulas
      if (text.contains('weight management') ||
          text.contains('light') ||
          text.contains('indoor')) {
        pros.add(
          'Weight-management style formula is suitable for British Shorthairs',
        );
      }
      break;

    case 'bengal':
      // pro: high protein (>40%)
      if (product.protein > 40) {
        pros.add('Very high protein (>40%) matches Bengal energy needs');
      }
      // con: low-protein foods (<32%)
      if (product.protein < 32) {
        cons.add('Low protein (<32%) may be insufficient for Bengals');
      }
      break;
  }

  return CatProductAssessment(pros: pros, cons: cons);
}

CatProductAssessment evaluateNeuteredProsCons(
  CatEntity cat,
  ProductModel product,
) {
  final pros = <String>[];
  final cons = <String>[];

  final status = cat.neuteredStatus;
  if (status == null) {
    return CatProductAssessment(pros: pros, cons: cons);
  }

  final text = (product.pros + product.cons).join(' ').toLowerCase();

  switch (status) {
    case 'neutered':
      // con: calorie dense foods (we'll interpret as very high calories)
      if (product.caloriesPer100g > 380) {
        cons.add(
          'Very calorie-dense food (>380 kcal/100g) can promote weight gain in neutered cats',
        );
      }

      // pro: urinary support ingredients
      if (text.contains('urinary') ||
          text.contains('struvite') ||
          text.contains('urinary tract')) {
        pros.add(
          'Contains urinary support ingredients, good for neutered cats',
        );
      }

      // con: high fat (>16%)
      if (product.fat > 16) {
        cons.add('High fat (>16%) may not be ideal for neutered cats');
      }
      break;

    case 'pregnant':
    case 'lactating':
      // pro: very high protein (>35%)
      if (product.protein > 35) {
        pros.add(
          'Very high protein (>35%) supports the increased needs of pregnant/lactating cats',
        );
      }

      // pro: high fat (>20%)
      if (product.fat > 20) {
        pros.add(
          'High fat (>20%) provides extra energy for pregnant/lactating cats',
        );
      }

      // pro: calorie dense (>400kcal)
      if (product.caloriesPer100g > 400) {
        pros.add(
          'Very calorie-dense food (>400 kcal/100g) helps meet energy demands in pregnancy/lactation',
        );
      }
      break;
  }

  return CatProductAssessment(pros: pros, cons: cons);
}

CatProductAssessment evaluateWeightProsCons(
  CatEntity cat,
  ProductModel product,
) {
  final pros = <String>[];
  final cons = <String>[];

  final bodyCondition = cat.weightCategory;
  if (bodyCondition == null) {
    return CatProductAssessment(pros: pros, cons: cons);
  }

  switch (bodyCondition) {
    case 'underweight':
      // pro: high calories (>380 kcal/100g)
      if (product.caloriesPer100g > 380) {
        pros.add(
          'High calories (>380 kcal/100g) can help an underweight cat gain weight',
        );
      }

      // pro: high fat (>18%)
      if (product.fat > 18) {
        pros.add('High fat (>18%) supports weight gain for underweight cats');
      }
      break;

    case 'normal':
      // no special rule
      break;

    case 'overweight':
      // con: high calories (>360 kcal/100g)
      if (product.caloriesPer100g > 360) {
        cons.add(
          'High calories (>360 kcal/100g) may not be ideal for an overweight cat',
        );
      }

      // pro: low calories (<320 kcal/100g)
      if (product.caloriesPer100g > 0 && product.caloriesPer100g < 320) {
        pros.add(
          'Lower calories (<320 kcal/100g) help manage weight in overweight cats',
        );
      }

      // pro: high fiber for satiety (>4%)
      if (product.fiber > 4) {
        pros.add(
          'Higher fiber (>4%) can help with satiety for overweight cats',
        );
      }
      break;

    case 'obese':
      // con: fat > 15%
      if (product.fat > 15) {
        cons.add('High fat (>15%) is not suitable for obese cats');
      }

      // con: calories > 330 kcal
      if (product.caloriesPer100g > 330) {
        cons.add('High calories (>330 kcal/100g) are not ideal for obese cats');
      }

      // pro: lean-protein (>40% protein, <12% fat)
      if (product.protein > 40 && product.fat < 12) {
        pros.add(
          'Lean, high-protein formula (>40% protein, <12% fat) is good for obese cats',
        );
      }
      break;
  }

  return CatProductAssessment(pros: pros, cons: cons);
}

bool _isSeniorFormula(ProductModel product) {
  final text = (product.pros + product.cons).join(' ').toLowerCase();
  return text.contains('senior');
}

bool _hasJointSupport(ProductModel product) {
  final text = (product.pros + product.cons).join(' ').toLowerCase();
  return text.contains('glucosamine') || text.contains('chondroitin');
}

bool _isKidneyFriendly(ProductModel product) {
  final text = (product.pros + product.cons).join(' ').toLowerCase();
  return text.contains('kidney') ||
      text.contains('renal') ||
      text.contains('low phosphorus') ||
      text.contains('reduced phosphorus');
}

bool _hasOmega3(ProductModel product) {
  final text = (product.pros + product.cons).join(' ').toLowerCase();
  return text.contains('omega-3') ||
      text.contains('omega 3') ||
      text.contains('fish oil') ||
      text.contains('salmon oil');
}

bool _hasManyFillers(ProductModel product) {
  final text = (product.pros + product.cons).join(' ').toLowerCase();
  final hasCorn = text.contains('corn');
  final hasWheat = text.contains('wheat');
  final hasSoy = text.contains('soy');
  final fillersCount = [hasCorn, hasWheat, hasSoy].where((e) => e).length;
  return fillersCount >= 2;
}

CatProductAssessment evaluateHealthConditionProsCons(
  CatEntity cat,
  ProductModel product,
) {
  final pros = <String>[];
  final cons = <String>[];

  final conditions = cat.healthConditions ?? [];
  if (conditions.isEmpty || conditions.contains('none')) {
    return CatProductAssessment(pros: pros, cons: cons);
  }

  final text = (product.pros + product.cons).join(' ').toLowerCase();
  final ingredientCount = _estimateIngredientCount(text);

  if (conditions.contains('urinary_issues')) {
    // pro: low ash (<7%) – approximate via "low ash" or similar claims
    if (text.contains('low ash') || text.contains('reduced ash')) {
      pros.add(
        'Formulated with low ash content, supportive for urinary issues',
      );
    }

    // pro: cranberry or DL-Methionine
    if (text.contains('cranberry') ||
        text.contains('d-mannose') ||
        text.contains('dl-methionine') ||
        text.contains('methionine')) {
      pros.add(
        'Includes urinary-support ingredients like cranberry or DL-methionine',
      );
    }

    // con: high mineral content
    if (text.contains('high minerals') ||
        text.contains('mineral-rich') ||
        text.contains('added minerals')) {
      cons.add('High mineral content may not be ideal for urinary issues');
    }
  }

  if (conditions.contains('kidney_disease')) {
    // con: high protein (>32%)
    if (product.protein > 32) {
      cons.add('High protein (>32%) may not be ideal for kidney disease');
    }

    // con: high phosphorus ingredients
    if (text.contains('phosphorus') && !text.contains('low phosphorus')) {
      cons.add(
        'Contains phosphorus sources that may be problematic in kidney disease',
      );
    }

    // pro: renal support proteins
    if (text.contains('renal support') ||
        text.contains('kidney support') ||
        text.contains('renal care')) {
      pros.add('Formulated as a renal-support diet');
    }
  }

  if (conditions.contains('sensitive_stomach')) {
    // pro: limited ingredient foods
    if (_isLimitedIngredient(text)) {
      pros.add('Limited-ingredient style recipe can help sensitive stomachs');
    }

    // con: long ingredient list (>12 items)
    if (ingredientCount > 12) {
      cons.add('Very long ingredient list may not suit sensitive stomachs');
    }
  }

  if (conditions.contains('food_allergies')) {
    // con: contains allergen (chicken/fish/beef)
    if (_containsCommonAllergen(text)) {
      cons.add('Contains common allergens like chicken, fish, or beef');
    }

    // pro: novel protein (duck, venison)
    if (_hasNovelProtein(text)) {
      pros.add(
        'Uses novel proteins (e.g. duck, venison) which may help with allergies',
      );
    }
  }

  if (conditions.contains('skin_allergies')) {
    // pro: omega-3 rich
    if (_hasOmega3(product)) {
      pros.add('Omega-3 rich formulation can support skin and coat health');
    }

    // con: artificial colors
    if (text.contains('artificial color') ||
        text.contains('colour') ||
        text.contains('red 40') ||
        text.contains('yellow 5')) {
      cons.add('Contains artificial colors which may aggravate skin allergies');
    }
  }

  if (conditions.contains('diabetes')) {
    // con: high carbs (>20%)
    if (product.carbs > 20) {
      cons.add('High carbohydrates (>20%) are less suitable for diabetic cats');
    }

    // pro: high protein (>40%)
    if (product.protein > 40) {
      pros.add(
        'Very high protein (>40%) can support blood sugar control in diabetes',
      );
    }
  }

  if (conditions.contains('dental_problems')) {
    // pro: wet food – approximate by high moisture
    if (_isWetFood(product)) {
      pros.add(
        'High-moisture (wet-style) food is easier to eat with dental problems',
      );
    }

    // con: very large kibble – approximate via text
    if (text.contains('large kibble') || text.contains('large-sized kibble')) {
      cons.add(
        'Very large kibble pieces may be hard to chew with dental issues',
      );
    }
  }

  if (conditions.contains('hairball_issues')) {
    // pro: higher fiber (4–6%)
    if (product.fiber >= 4 && product.fiber <= 6 || text.contains('hairball')) {
      pros.add('Hairball control style diet (fiber 4–6% or hairball claims)');
    }
  }

  return CatProductAssessment(pros: pros, cons: cons);
}

int _estimateIngredientCount(String text) {
  // Very rough heuristic: count commas in an "ingredients" style line.
  // This is a fallback since we don't have a structured ingredient list.
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

bool _isWetFood(ProductModel product) {
  // Heuristic: moisture very high suggests wet food.
  return product.moisture > 70;
}
