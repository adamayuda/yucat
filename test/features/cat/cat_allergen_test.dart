import 'package:flutter_test/flutter_test.dart';
import 'package:yucat/features/cat/domain/entities/cat_allergen.dart';

void main() {
  group('detectFoodAllergenKeys', () {
    test('finds declared proteins in canonical English text', () {
      final found = detectFoodAllergenKeys(
        'chicken and rice pâté with salmon oil',
      );
      expect(found, containsAll(['chicken', 'salmon']));
      expect(found, isNot(contains('beef')));
    });

    test('matches every needle of a group to one key', () {
      expect(detectFoodAllergenKeys('made with maize'), contains('grain'));
      expect(detectFoodAllergenKeys('with prawn'), contains('shellfish'));
    });

    test('never matches environmental allergens', () {
      final found = detectFoodAllergenKeys('dust pollen grass mould');
      expect(found, isEmpty);
    });

    test('over-reports by plain substring, on purpose', () {
      // Documented false positives inherited from `_kCommonAllergens`: no word
      // boundary and no "-free" exclusion. If either of these starts failing,
      // the matcher and the generic assessment branch have drifted apart.
      expect(detectFoodAllergenKeys('rich in fish oil'), contains('fish'));
      expect(detectFoodAllergenKeys('contains no chicken'), contains('chicken'));
    });
  });

  group('CatAllergen.resolveAll', () {
    test('drops keys the catalogue no longer knows rather than throwing', () {
      final resolved = CatAllergen.resolveAll(['chicken', 'retired_key', 'dust']);
      expect(resolved.map((a) => a.key), ['chicken', 'dust']);
    });

    test('treats a missing list as no allergies', () {
      expect(CatAllergen.resolveAll(null), isEmpty);
    });
  });

  test('every food allergen has needles and every environmental one has none', () {
    for (final a in CatAllergen.food) {
      expect(a.needles, isNotEmpty, reason: a.key);
    }
    for (final a in CatAllergen.environmental) {
      expect(a.needles, isEmpty, reason: a.key);
    }
  });
}
