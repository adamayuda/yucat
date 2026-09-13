import 'dart:io';

import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/repositories/cat_repository.dart';

class CreateCatUsecase {
  final CatRepository _repository;

  CreateCatUsecase({required CatRepository repository})
    : _repository = repository;

  Future<CatEntity> call({
    required String userId,
    required String name,
    int? age,
    DateTime? birthDate,
    String? ageGroup,
    double? weight,
    bool neutered = false,
    File? profileImageFile,
    String? neuteredStatus,
    String? breed,
    String? weightCategory,
    String? activityLevel,
    String? coatType,
    String? gender,
    List<String>? healthConditions,
  }) async {
    if (name.trim().isEmpty) {
      throw Exception('Cat name cannot be empty');
    }

    // Create cat first to get the catId
    final result = await _repository.createCat(
      userId: userId,
      name: name.trim(),
      age: age,
      birthDate: birthDate,
      ageGroup: ageGroup,
      weight: weight,
      neutered: neutered,
      neuteredStatus: neuteredStatus,
      breed: breed,
      weightCategory: weightCategory,
      activityLevel: activityLevel,
      coatType: coatType,
      gender: gender,
      healthConditions: healthConditions,
    );

    // Upload image if provided and update cat document
    if (profileImageFile != null) {
      final profileImageUrl = await _repository.uploadCatProfileImage(
        imageFile: profileImageFile,
        catId: result.catId,
      );

      if (profileImageUrl == null) {
        throw Exception('Failed to upload profile image');
      }

      // Update the cat document with the image URL
      await _repository.updateCatProfileImageUrl(
        catId: result.catId,
        profileImageUrl: profileImageUrl,
      );

      // Return entity with the image URL
      return result.entity.copyWith(profileImageUrl: profileImageUrl);
    }

    return result.entity;
  }
}
