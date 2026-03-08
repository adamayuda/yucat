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
