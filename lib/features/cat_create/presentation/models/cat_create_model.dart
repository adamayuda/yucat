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
}
