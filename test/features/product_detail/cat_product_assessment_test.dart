import 'package:flutter_test/flutter_test.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/utils/cat_product_assessment.dart';
import 'package:yucat/features/product_detail/presentation/utils/fit_verdict.dart';
import 'package:yucat/features/product_detail/presentation/utils/score_bands.dart';
import 'package:yucat/l10n/app_localizations_en.dart';

// The generated English bundle can be built without a widget tree, so the
// rules engine — which takes `AppLocalizations` to return translated findings
// — is testable as a pure function.
final l10n = AppLocalizationsEn();

ProductDisplayModel food({
  String name = 'Test food',
  String brand = 'Test brand',
  int score = 80,
  required double protein,
  required double fat,
  required double carbs,
  double fiber = 1,
  required double moisture,
  List<String> pros = const [],
  List<String> cons = const [],
}) =>
    ProductDisplayModel(
      name: name,
      brand: brand,
      score: score,
      maxScore: 100,
      ratingText: ScoreBand.of(score, 100).key,
      ratingColor: ScoreBand.of(score, 100).color,
      protein: protein,
      fat: fat,
      carbs: carbs,
      fiber: fiber,
      moisture: moisture,
      pros: pros,
      cons: cons,
    );

/// A lean pâté: ≈ 68 kcal/100 g as fed, ≈ 338 kcal/100 g dry matter.
final leanPate = food(protein: 10, fat: 3, carbs: 2, moisture: 80);

/// A fat-rich pâté: ≈ 110 kcal/100 g as fed, ≈ 500 kcal/100 g dry matter.
final richPate = food(protein: 11, fat: 8, carbs: 1, moisture: 78);

/// A typical kibble: ≈ 357 kcal/100 g as fed, ≈ 388 kcal/100 g dry matter.
final kibble = food(protein: 32, fat: 14, carbs: 36, fiber: 3, moisture: 8);

/// A light kibble: ≈ 329 kcal/100 g as fed, ≈ 357 kcal/100 g dry matter.
final lightKibble = food(protein: 34, fat: 9, carbs: 38, fiber: 5, moisture: 8);

const blankCat = CatEntity(name: 'Blank');
// ---------------------------------------------------------------------------
// Phase 3 — ingredients and food type
// ---------------------------------------------------------------------------

final chickenPate = ProductDisplayModel(
  name: 'Ocean feast',
  brand: 'Test brand',
  score: 80,
  maxScore: 100,
  ratingText: 'Excellent',
  ratingColor: ProductRatingColor.green,
  protein: 10,
  fat: 5,
  carbs: 2,
  moisture: 80,
  pros: const ['Named fish as the main protein'],
  ingredients: const ['Tuna (40%)', 'Chicken (20%)', 'Rice', 'Minerals'],
);


void main() {
  group('neutral baseline', () {
    test('a blank profile produces no findings, delta 0, good fit', () {
      final a = evaluateCatProduct(blankCat, kibble, l10n);
      expect(a.pros, isEmpty);
      expect(a.cons, isEmpty);
      expect(a.delta, 0);
      expect(a.score, 70);
      expect(FitVerdict.of(a), FitVerdict.goodFit);
    });
  });

  group('calories are judged on a dry-matter basis', () {
    const overweight = CatEntity(name: 'Round', weightCategory: 'overweight');
    const lowActivity = CatEntity(name: 'Couch', activityLevel: 'low');

    test('a fat-rich wet food can now trigger the energy-dense con', () {
      final a = evaluateCatProduct(overweight, richPate, l10n);
      expect(
        a.cons.map((c) => c.text),
        contains(l10n.assessmentOverweightHighCalories),
      );
    });

    test('a lean wet food earns the lower-energy pro and the satiety pro', () {
      final a = evaluateCatProduct(overweight, leanPate, l10n);
      final pros = a.pros.map((p) => p.text).toList();
      expect(pros, contains(l10n.assessmentOverweightLowCalories));
      expect(pros, contains(l10n.assessmentOverweightHighMoisture));
      expect(a.cons, isEmpty);
    });

    test('a typical kibble is neither penalised nor rewarded on energy', () {
      final a = evaluateCatProduct(overweight, kibble, l10n);
      final texts = [...a.pros, ...a.cons].map((f) => f.text);
      expect(texts, isNot(contains(l10n.assessmentOverweightHighCalories)));
      expect(texts, isNot(contains(l10n.assessmentOverweightLowCalories)));
    });

    test('a light kibble reads as moderate for a low-activity cat', () {
      final a = evaluateCatProduct(lowActivity, lightKibble, l10n);
      expect(
        a.pros.map((p) => p.text),
        contains(l10n.assessmentLowActivityModerateCalories),
      );
    });

    test('the model reports modified-Atwater as-fed kcal', () {
      // 32×3.5 + 14×8.5 + 36×3.5 = 112 + 119 + 126
      expect(kibble.calories, closeTo(357, 0.01));
    });
  });

  group('hard flags', () {
    test('kidney disease + high protein is not recommended despite pros', () {
      const cat = CatEntity(
        name: 'Renal',
        healthConditions: ['kidney_disease'],
        ageGroup: 'senior',
      );
      final a = evaluateCatProduct(
        cat,
        food(
          protein: 45,
          fat: 18,
          carbs: 15,
          moisture: 8,
          pros: ['Contains glucosamine and chondroitin for joints'],
        ),
        l10n,
      );
      expect(a.pros, isNotEmpty);
      expect(a.hasHardFlag, isTrue);
      expect(FitVerdict.of(a), FitVerdict.notRecommended);
    });

    test('a declared allergen in the food is a hard flag', () {
      const cat = CatEntity(name: 'Itchy', allergies: ['chicken']);
      final a = evaluateCatProduct(
        cat,
        food(
          protein: 10,
          fat: 5,
          carbs: 2,
          moisture: 80,
          pros: ['Real chicken as the first ingredient'],
        ),
        l10n,
      );
      expect(a.hasHardFlag, isTrue);
      expect(FitVerdict.of(a), FitVerdict.notRecommended);
    });

    test('several declared allergens are clamped to one strong penalty', () {
      const cat = CatEntity(
        name: 'Itchy',
        allergies: ['chicken', 'fish', 'beef'],
      );
      final a = evaluateCatProduct(
        cat,
        food(
          protein: 10,
          fat: 5,
          carbs: 2,
          moisture: 80,
          pros: ['Chicken, fish and beef in gravy'],
        ),
        l10n,
      );
      expect(a.cons.where((c) => c.hard).length, 3);
      // −24 on the health dimension (×15 ÷ 10) = −36, not 3 × −14 × 1.5.
      expect(a.delta, -36);
    });
  });

  group('weight overrides neutered', () {
    test('an underweight neutered cat keeps the weight pro, drops the neutered con',
        () {
      const cat = CatEntity(
        name: 'Skinny',
        weightCategory: 'underweight',
        neuteredStatus: 'neutered',
      );
      final a = evaluateCatProduct(cat, richPate, l10n);
      final texts = [...a.pros, ...a.cons].map((f) => f.text).toList();
      expect(texts, contains(l10n.assessmentUnderweightHighCalories));
      expect(texts, isNot(contains(l10n.assessmentNeuteredHighCalories)));
      expect(
        a.cons.where((c) => c.dimension == CatAssessmentDimension.neutered),
        isEmpty,
      );
    });
  });

  group('profile fallbacks', () {
    test('the neutered bool counts when neuteredStatus is null', () {
      const cat = CatEntity(name: 'Snip', neutered: true);
      final a = evaluateCatProduct(cat, richPate, l10n);
      expect(
        a.cons.map((c) => c.text),
        contains(l10n.assessmentNeuteredHighCalories),
      );
    });

    test('age in months derives the age group when ageGroup is null', () {
      const cat = CatEntity(name: 'Kit', age: 4);
      final a = evaluateCatProduct(cat, leanPate, l10n);
      // 10 % protein at 80 % moisture is 50 % on a dry-matter basis.
      expect(
        a.pros.map((p) => p.text),
        contains(l10n.assessmentKittenHighProtein),
      );
    });
  });

  group('FitVerdict bands', () {
    CatProductAssessment withDelta(int d) =>
        CatProductAssessment(pros: const [], cons: const [], delta: d);

    test('bands on delta with neutral at zero', () {
      expect(FitVerdict.of(withDelta(8)), FitVerdict.greatFit);
      expect(FitVerdict.of(withDelta(7)), FitVerdict.goodFit);
      expect(FitVerdict.of(withDelta(0)), FitVerdict.goodFit);
      expect(FitVerdict.of(withDelta(-1)), FitVerdict.someCautions);
      expect(FitVerdict.of(withDelta(-9)), FitVerdict.someCautions);
      expect(FitVerdict.of(withDelta(-10)), FitVerdict.notRecommended);
    });
  });

  group('ScoreBand', () {
    test('label and colour agree in the 60–69 range', () {
      final band = ScoreBand.of(65, 100);
      expect(band, ScoreBand.good);
      expect(band.key, 'Good');
      expect(band.color, ProductRatingColor.green);
    });

    test('edges', () {
      expect(ScoreBand.of(80, 100), ScoreBand.excellent);
      expect(ScoreBand.of(79, 100), ScoreBand.good);
      expect(ScoreBand.of(40, 100), ScoreBand.average);
      expect(ScoreBand.of(39, 100), ScoreBand.poor);
      expect(ScoreBand.of(0, 0), ScoreBand.poor);
    });
  });

  group('ingredients feed the engine', () {
    test('an allergen present only in the ingredients list is found', () {
      const cat = CatEntity(name: 'Itchy', allergies: ['chicken']);
      final a = evaluateCatProduct(cat, chickenPate, l10n);
      expect(a.hasHardFlag, isTrue);
      expect(FitVerdict.of(a), FitVerdict.notRecommended);
    });

    test('the real list length drives the sensitive-stomach count', () {
      const cat = CatEntity(
        name: 'Queasy',
        healthConditions: ['sensitive_stomach'],
      );
      final long = food(
        protein: 32,
        fat: 14,
        carbs: 36,
        moisture: 8,
      );
      final longList = ProductDisplayModel(
        name: long.name,
        brand: long.brand,
        score: long.score,
        maxScore: 100,
        ratingText: long.ratingText,
        ratingColor: long.ratingColor,
        protein: long.protein,
        fat: long.fat,
        carbs: long.carbs,
        moisture: long.moisture,
        ingredients: List.generate(13, (i) => 'Ingredient $i'),
      );
      final a = evaluateCatProduct(cat, longList, l10n);
      expect(
        a.cons.map((c) => c.text),
        contains(l10n.assessmentSensitiveStomachLongIngredients),
      );
      expect(evaluateCatProduct(cat, long, l10n).cons, isEmpty);
    });
  });

  group('food type', () {
    ProductDisplayModel typed(String? t) => ProductDisplayModel(
          name: 'x',
          brand: 'y',
          score: 90,
          maxScore: 100,
          ratingText: 'Excellent',
          ratingColor: ProductRatingColor.green,
          foodType: t,
        );

    test('treats, toppers and supplements are complementary', () {
      expect(typed('treat').isComplementary, isTrue);
      expect(typed('topper').isComplementary, isTrue);
      expect(typed('supplement').isComplementary, isTrue);
    });

    test('wet, dry and unknown count as complete foods', () {
      expect(typed('wet').isComplementary, isFalse);
      expect(typed('dry').isComplementary, isFalse);
      expect(typed(null).isComplementary, isFalse);
    });
  });
}
