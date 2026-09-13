import 'dart:io';

import 'package:equatable/equatable.dart';

class CatCreateModel extends Equatable {
  final String? id;
  final String name;
  final int? age;

  /// Set only when the owner picked a birthday on the Age step; [age] is then
  /// derived from it. Moving the wheels clears it (`clearBirthDate`).
  final DateTime? birthDate;
  final String? ageGroup;
  final double? weight;
  final bool neutered;
  final File? profileImageFile;
  final String? profileImageUrl;
  final String? neuteredStatus;
  final String? breed;
  final String? gender;
  final String? weightCategory;
  final String? activityLevel;
  final String? coatType;
  /// What the health step holds. May contain [noHealthCondition], the
  /// "None" chip's value — a wizard answer, not a condition, and never to be
  /// persisted (see [persistedHealthConditions]).
  final List<String> healthConditions;

  /// The "None" chip's value. The step needs *some* selection to let the user
  /// proceed, so "no conditions" has to be representable — but YUC-9 was this
  /// sentinel reaching Firestore: the cat list counted it as "1 condition"
  /// while the profile rendered it as "None".
  static const String noHealthCondition = 'none';

  /// [healthConditions] with the sentinel stripped — the only list that may
  /// reach a use case, a document or an analytics property.
  List<String> get persistedHealthConditions => [
        for (final c in healthConditions)
          if (c != noHealthCondition) c,
      ];

  const CatCreateModel({
    this.id,
    required this.name,
    this.age,
    this.birthDate,
    this.ageGroup,
    this.weight,
    this.neutered = false,
    this.profileImageFile,
    this.profileImageUrl,
    this.neuteredStatus,
    this.breed,
    this.gender,
    this.weightCategory,
    this.activityLevel,
    this.coatType,
    this.healthConditions = const [],
  });

  /// `??` semantics throughout, so a null argument keeps the value. The one
  /// field that must be clearable — the birthday, when the wheels move — has
  /// an explicit [clearBirthDate] flag instead.
  CatCreateModel copyWith({
    String? id,
    String? name,
    int? age,
    DateTime? birthDate,
    bool clearBirthDate = false,
    String? ageGroup,
    double? weight,
    bool? neutered,
    File? profileImageFile,
    String? profileImageUrl,
    String? neuteredStatus,
    String? breed,
    String? gender,
    String? weightCategory,
    String? activityLevel,
    String? coatType,
    List<String>? healthConditions,
  }) {
    return CatCreateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      birthDate: clearBirthDate ? null : birthDate ?? this.birthDate,
      ageGroup: ageGroup ?? this.ageGroup,
      weight: weight ?? this.weight,
      neutered: neutered ?? this.neutered,
      profileImageFile: profileImageFile ?? this.profileImageFile,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      neuteredStatus: neuteredStatus ?? this.neuteredStatus,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      weightCategory: weightCategory ?? this.weightCategory,
      activityLevel: activityLevel ?? this.activityLevel,
      coatType: coatType ?? this.coatType,
      healthConditions: healthConditions ?? this.healthConditions,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        age,
        birthDate,
        ageGroup,
        weight,
        neutered,
        profileImageFile,
        profileImageUrl,
        neuteredStatus,
        breed,
        gender,
        weightCategory,
        activityLevel,
        coatType,
        healthConditions,
      ];
}
