import 'dart:io';

class CatCreateModel {
  final String name;
  final int? age;
  final String? ageGroup;
  final double? weight;
  final bool neutered;
  final File? profileImageFile;
  final String? neuteredStatus;
  final String? breed;
  final String? gender;
  final String? weightCategory;
  final String? activityLevel;
  final String? coatType;
  final List<String> healthConditions;

  const CatCreateModel({
    required this.name,
    this.age,
    this.ageGroup,
    this.weight,
    this.neutered = false,
    this.profileImageFile,
    this.neuteredStatus,
    this.breed,
    this.gender,
    this.weightCategory,
    this.activityLevel,
    this.coatType,
    this.healthConditions = const [],
  });

  CatCreateModel copyWith({
    String? name,
    int? age,
    String? ageGroup,
    double? weight,
    bool? neutered,
    File? profileImageFile,
    String? neuteredStatus,
    String? breed,
    String? gender,
    String? weightCategory,
    String? activityLevel,
    String? coatType,
    List<String>? healthConditions,
  }) {
    return CatCreateModel(
      name: name ?? this.name,
      age: age ?? this.age,
      ageGroup: ageGroup ?? this.ageGroup,
      weight: weight ?? this.weight,
      neutered: neutered ?? this.neutered,
      profileImageFile: profileImageFile ?? this.profileImageFile,
      neuteredStatus: neuteredStatus ?? this.neuteredStatus,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      weightCategory: weightCategory ?? this.weightCategory,
      activityLevel: activityLevel ?? this.activityLevel,
      coatType: coatType ?? this.coatType,
      healthConditions: healthConditions ?? this.healthConditions,
    );
  }
}
