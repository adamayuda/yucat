import 'package:flutter_test/flutter_test.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/utils/daily_portion.dart';

ProductDisplayModel food({
  required double protein,
  required double fat,
  required double carbs,
  required double moisture,
  String packageSize = '',
  String? foodType,
}) =>
    ProductDisplayModel(
      name: 'x',
      brand: 'y',
      score: 80,
      maxScore: 100,
      ratingText: 'Excellent',
      ratingColor: ProductRatingColor.green,
      protein: protein,
      fat: fat,
      carbs: carbs,
      moisture: moisture,
      packageSize: packageSize,
      foodType: foodType,
    );

void main() {
  group('maintenanceFactor', () {
    test('life stage wins, then reproduction, then weight goal', () {
      expect(maintenanceFactor(const CatEntity(name: 'k', ageGroup: 'kitten')),
          2.5);
      expect(
          maintenanceFactor(
              const CatEntity(name: 'p', neuteredStatus: 'pregnant')),
          1.8);
      expect(
          maintenanceFactor(const CatEntity(
            name: 'o',
            weightCategory: 'obese',
            neuteredStatus: 'neutered',
          )),
          0.8);
    });

    test('neutered adults sit at 1.2, intact at 1.4, activity nudges', () {
      expect(maintenanceFactor(const CatEntity(name: 'n', neutered: true)), 1.2);
      expect(maintenanceFactor(const CatEntity(name: 'i')), 1.4);
      expect(
          maintenanceFactor(const CatEntity(
            name: 'a',
            neutered: true,
            activityLevel: 'high',
          )),
          closeTo(1.4, 1e-9));
    });
  });

  group('computeDailyPortion', () {
    // 4 kg neutered adult: RER = 70 × 4^0.75 ≈ 198 → × 1.2 ≈ 238 kcal.
    const cat = CatEntity(name: 'Mochi', weight: 4, neutered: true);

    test('a pouch food yields kcal, grams and pouches per day', () {
      // 10/5/2 → 35 + 42.5 + 7 = 84.5 kcal/100 g
      final p = computeDailyPortion(
        cat,
        food(protein: 10, fat: 5, carbs: 2, moisture: 80, packageSize: '85g pouch'),
      )!;
      expect(p.kcalPerDay, 238);
      expect(p.gramsPerDay, closeTo(238 / 84.5 * 100, 1));
      expect(p.unitLabel, '85g pouch');
      expect(p.unitsPerDay, closeTo(p.gramsPerDay / 85, 0.02));
      expect(p.isTreatBudget, isFalse);
    });

    test('a bag gives no unit count', () {
      final p = computeDailyPortion(
        cat,
        food(protein: 32, fat: 14, carbs: 36, moisture: 8, packageSize: '2 kg bag'),
      )!;
      expect(p.unitsPerDay, isNull);
      expect(p.gramsPerDay, closeTo(238 / 357 * 100, 1));
    });

    test('a treat reports the 10 % budget in grams of the treat', () {
      final p = computeDailyPortion(
        cat,
        food(protein: 40, fat: 20, carbs: 10, moisture: 10, foodType: 'treat'),
      )!;
      expect(p.isTreatBudget, isTrue);
      // 40×3.5 + 20×8.5 + 10×3.5 = 345 kcal/100 g; budget 23.8 kcal → ≈ 7 g
      expect(p.gramsPerDay, 7);
    });

    test('no weight → null', () {
      expect(
        computeDailyPortion(const CatEntity(name: 'x'),
            food(protein: 10, fat: 5, carbs: 2, moisture: 80)),
        isNull,
      );
    });
  });

  group('parsePackUnit', () {
    test('single-serve containers parse, bags do not', () {
      expect(parsePackUnit('85g pouch')!.grams, 85);
      expect(parsePackUnit('12 x 85g pouches')!.grams, 85);
      expect(parsePackUnit('5.5 oz can')!.grams, closeTo(155.9, 0.1));
      expect(parsePackUnit('400g can')!.grams, 400);
      expect(parsePackUnit('3 kg bag'), isNull);
      expect(parsePackUnit('1.5kg'), isNull);
      expect(parsePackUnit(''), isNull);
    });
  });
}
