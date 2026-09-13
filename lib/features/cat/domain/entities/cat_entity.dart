/// Maps an age in months to the assessment's age group:
/// `<12` → kitten, `12–119` → adult, `>=120` → senior. Mirrors the life-stage
/// labels shown in the onboarding Age step. Returns null when [months] is null.
String? ageGroupFromMonths(int? months) {
  if (months == null) return null;
  if (months < 12) return 'kitten';
  if (months < 120) return 'adult';
  return 'senior';
}

/// Whole months between [birth] and [now] (calendar months, not 30-day
/// blocks): a cat born on the 20th is one month old on the 20th of the next
/// month. Never negative. The single conversion behind every derived `age`.
int monthsSince(DateTime birth, [DateTime? now]) {
  final today = now ?? DateTime.now();
  var months = (today.year - birth.year) * 12 + (today.month - birth.month);
  if (today.day < birth.day) months -= 1;
  return months < 0 ? 0 : months;
}

class CatEntity {
  final String? id;
  final String name;

  /// Age in months. ⚠️ A **snapshot** when [birthDate] is null — captured once
  /// in the wizard and never aged. When [birthDate] is set the document mapper
  /// derives this on every read, so the profile ages itself.
  final int? age;

  /// The real birthday, when the owner knows it. Optional: the wizard's Age
  /// step takes either the wheels (→ [age] only) or a date (→ both). The
  /// health carnet's kitten series is the one place the difference matters —
  /// a 3-weekly schedule cannot be run off a months snapshot that drifts.
  final DateTime? birthDate;
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
    this.birthDate,
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

  /// `??` semantics: a null argument keeps the current value. There is no way
  /// to *clear* a field through this; the two call sites that need to (the
  /// wizard dropping a birth date, the carnet clearing allergies) go through
  /// their own explicit paths.
  CatEntity copyWith({
    String? id,
    String? name,
    int? age,
    DateTime? birthDate,
    double? weight,
    bool? neutered,
    String? profileImageUrl,
    String? ageGroup,
    String? neuteredStatus,
    String? breed,
    String? weightCategory,
    String? activityLevel,
    String? coatType,
    String? gender,
    List<String>? healthConditions,
    List<String>? allergies,
  }) =>
      CatEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        age: age ?? this.age,
        birthDate: birthDate ?? this.birthDate,
        weight: weight ?? this.weight,
        neutered: neutered ?? this.neutered,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        ageGroup: ageGroup ?? this.ageGroup,
        neuteredStatus: neuteredStatus ?? this.neuteredStatus,
        breed: breed ?? this.breed,
        weightCategory: weightCategory ?? this.weightCategory,
        activityLevel: activityLevel ?? this.activityLevel,
        coatType: coatType ?? this.coatType,
        gender: gender ?? this.gender,
        healthConditions: healthConditions ?? this.healthConditions,
        allergies: allergies ?? this.allergies,
      );
}
