import 'dart:io';

import 'package:yucat/features/cat/domain/entities/cat_entity.dart';

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
  Future<({CatEntity entity, String catId})> createCat({
    required String userId,
    required String name,
    int? age,
    String? ageGroup,
    double? weight,
    bool neutered = false,
    String? profileImageUrl,
    String? neuteredStatus,
    String? breed,
    String? weightCategory,
    String? activityLevel,
    String? coatType,
    List<String>? healthConditions,
  });
  Future<void> deleteCat({required String catId});
  Future<void> updateCat({required CatEntity cat});
}
