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
  });
}
