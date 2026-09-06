/// Maps an age in months to the assessment's age group:
/// `<12` → kitten, `12–119` → adult, `>=120` → senior. Mirrors the life-stage
/// labels shown in the onboarding Age step. Returns null when [months] is null.
String? ageGroupFromMonths(int? months) {
  if (months == null) return null;
  if (months < 12) return 'kitten';
  if (months < 120) return 'adult';
  return 'senior';
}

class CatEntity {
  final String? id;
  final String name;
  final int? age;
  final double? weight;
  final bool neutered;
  final String? profileImageUrl;
  final String? ageGroup;
  final String? neuteredStatus;
  final String? breed;
  final String? weightCategory;
  final String? activityLevel;
  final String? coatType;
  final String? gender;
  final List<String>? healthConditions;

  /// Declared allergies and sensitivities, as `CatAllergen` keys.
  ///
  /// Edited from the health carnet, not the create wizard — which is why
  /// `CatDocumentMapper.toDocument` writes the field only when it is non-empty.
  /// A wizard save builds a `CatEntity` with no allergies, and omitting the key
  /// from the update map leaves the stored value untouched instead of wiping it.
  /// Clearing all allergies goes through `CatRepository.updateCatAllergies`,
  /// which writes the empty list explicitly.
  final List<String>? allergies;

  const CatEntity({
    this.id,
    required this.name,
    this.age,
    this.weight,
    this.neutered = false,
    this.profileImageUrl,
    this.ageGroup,
    this.neuteredStatus,
    this.breed,
    this.weightCategory,
    this.activityLevel,
    this.coatType,
    this.gender,
    this.healthConditions,
    this.allergies,
  });

  CatEntity copyWith({String? profileImageUrl}) => CatEntity(
        id: id,
        name: name,
        age: age,
        weight: weight,
        neutered: neutered,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        ageGroup: ageGroup,
        neuteredStatus: neuteredStatus,
        breed: breed,
        weightCategory: weightCategory,
        activityLevel: activityLevel,
        coatType: coatType,
        gender: gender,
        healthConditions: healthConditions,
        allergies: allergies,
      );
}
