import 'package:yucat/features/cat/domain/entities/cat_vet_contact.dart';

class CatModel {
  final String? id;
  final String name;
  final int? age;
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
  final List<String>? allergies;
  final CatVetContact? vet;
  final String? lifestyle;

  const CatModel({
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
    this.vet,
    this.lifestyle,
  });

  /// Only the fields an in-place edit can change today. Widen as needed.
  CatModel copyWith({String? profileImageUrl}) {
    return CatModel(
      id: id,
      name: name,
      age: age,
      birthDate: birthDate,
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
      vet: vet,
      lifestyle: lifestyle,
    );
  }
}
