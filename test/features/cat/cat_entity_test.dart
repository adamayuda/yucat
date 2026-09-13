import 'package:flutter_test/flutter_test.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';

void main() {
  group('monthsSince', () {
    test('counts calendar months, turning over on the birthday day', () {
      final birth = DateTime(2026, 3, 20);
      expect(monthsSince(birth, DateTime(2026, 4, 19)), 0);
      expect(monthsSince(birth, DateTime(2026, 4, 20)), 1);
      expect(monthsSince(birth, DateTime(2027, 3, 19)), 11);
      expect(monthsSince(birth, DateTime(2027, 3, 20)), 12);
    });

    test('never goes negative for a date in the future', () {
      expect(monthsSince(DateTime(2027, 1, 1), DateTime(2026, 9, 13)), 0);
    });
  });

  group('ageGroupFromMonths', () {
    test('matches the wizard tip boundaries', () {
      expect(ageGroupFromMonths(11), 'kitten');
      expect(ageGroupFromMonths(12), 'adult');
      expect(ageGroupFromMonths(119), 'adult');
      expect(ageGroupFromMonths(120), 'senior');
      expect(ageGroupFromMonths(null), isNull);
    });
  });

  test('copyWith keeps every field a null argument does not touch', () {
    final cat = CatEntity(
      id: 'c',
      name: 'Milo',
      age: 30,
      birthDate: DateTime(2024, 3, 1),
      neutered: true,
      allergies: const ['chicken'],
    );
    final copy = cat.copyWith(name: 'Milo II');
    expect(copy.name, 'Milo II');
    expect(copy.age, 30);
    expect(copy.birthDate, cat.birthDate);
    expect(copy.neutered, isTrue);
    expect(copy.allergies, ['chicken']);
  });
}
