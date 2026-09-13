import 'package:flutter_test/flutter_test.dart';
import 'package:yucat/features/cat/domain/entities/cat_vet_contact.dart';

/// The edit sheet turns "every field blank" into a removal and refuses a
/// phone number with nobody attached to it — both hang off these two getters.
void main() {
  test('blank everywhere is empty, whitespace included', () {
    expect(const CatVetContact(name: '').isEmpty, isTrue);
    expect(
      const CatVetContact(name: '  ', clinic: ' ', phone: '', address: null)
          .isEmpty,
      isTrue,
    );
  });

  test('any single field makes it non-empty', () {
    expect(const CatVetContact(name: '', phone: '+34 600').isEmpty, isFalse);
    expect(const CatVetContact(name: 'Dr Ruiz').isEmpty, isFalse);
  });

  test('displayName prefers the name, falls back to the clinic', () {
    expect(
      const CatVetContact(name: ' Dr Ruiz ', clinic: 'VetSur').displayName,
      'Dr Ruiz',
    );
    expect(const CatVetContact(name: '', clinic: 'VetSur').displayName, 'VetSur');
    expect(const CatVetContact(name: '', phone: '600').displayName, '');
  });
}
