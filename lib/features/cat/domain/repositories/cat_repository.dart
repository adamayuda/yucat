import 'dart:io';

import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/entities/cat_vet_contact.dart';

abstract class CatRepository {
  Future<List<CatEntity>> getCats({required String userId});
  Future<String?> uploadCatProfileImage({
    required File imageFile,
    required String catId,
  });
  Future<void> updateCatProfileImageUrl({
    required String catId,
    required String profileImageUrl,
  });

  /// Best-effort delete of a replaced profile photo by URL. Never throws.
  Future<void> deleteCatProfileImage({required String imageUrl});
  Future<({CatEntity entity, String catId})> createCat({
    required String userId,
    required String name,
    int? age,
    DateTime? birthDate,
    String? ageGroup,
    double? weight,
    bool neutered = false,
    String? profileImageUrl,
    String? neuteredStatus,
    String? breed,
    String? weightCategory,
    String? activityLevel,
    String? coatType,
    String? gender,
    List<String>? healthConditions,
  });
  Future<void> deleteCat({required String catId});
  Future<void> updateCat({required CatEntity cat});

  /// Replaces the cat's allergy list, empty included. Separate from [updateCat]
  /// because the document mapper cannot express "clear this field".
  Future<void> updateCatAllergies({
    required String catId,
    required List<String> allergies,
  });

  /// Replaces the cat's vet contact; null removes it. Separate from
  /// [updateCat] for the same reason as [updateCatAllergies].
  Future<void> updateCatVet({
    required String catId,
    required CatVetContact? vet,
  });

  /// `CatLifestyle.indoor` / `.outdoor`; null clears it.
  Future<void> updateCatLifestyle({
    required String catId,
    required String? lifestyle,
  });

  /// The measured weight, in kg — from a carnet weigh-in.
  Future<void> updateCatWeight({
    required String catId,
    required double weight,
  });
}
