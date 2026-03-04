import 'dart:io';

import 'package:yucat/features/cat/data/datasources/cat_datasource.dart';
import 'package:yucat/features/cat/data/mappers/cat_document_mapper.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/repositories/cat_repository.dart';

class CatRepositoryImpl implements CatRepository {
  final CatDataSource _dataSource;
  final CatDocumentMapper _mapper;

  CatRepositoryImpl({
    required CatDataSource dataSource,
    required CatDocumentMapper mapper,
  }) : _dataSource = dataSource,
       _mapper = mapper;

  @override
  Future<List<CatEntity>> getCats({required String userId}) async {
    final querySnapshot = await _dataSource.getCats(userId: userId);
    return querySnapshot?.docs.map((doc) => _mapper(doc)).toList() ?? [];
  }

  @override
  Future<String?> uploadCatProfileImage({
    required File imageFile,
    required String catId,
  }) async {
    return await _dataSource.uploadCatProfileImage(
      imageFile: imageFile,
      catId: catId,
    );
  }

  @override
  Future<void> updateCatProfileImageUrl({
    required String catId,
    required String profileImageUrl,
  }) async {
    await _dataSource.updateCatProfileImageUrl(
      catId: catId,
      profileImageUrl: profileImageUrl,
    );
  }

  @override
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
  }) async {
    final docRef = await _dataSource.createCat(
      userId: userId,
      name: name,
      age: age,
      ageGroup: ageGroup,
      weight: weight,
      neutered: neutered,
      profileImageUrl: profileImageUrl,
      neuteredStatus: neuteredStatus,
      breed: breed,
      weightCategory: weightCategory,
      activityLevel: activityLevel,
      coatType: coatType,
      healthConditions: healthConditions,
    );

    if (docRef == null) {
      throw Exception('Failed to create cat');
    }

    final catId = docRef.id;

    // Since we already know the values we sent, we can construct the entity
    // directly rather than reading it back from Firestore.
    final entity = CatEntity(
      name: name,
      age: age,
      weight: weight,
      neutered: neutered,
      profileImageUrl: profileImageUrl,
      ageGroup: ageGroup,
      neuteredStatus: neuteredStatus,
      breed: breed,
      weightCategory: weightCategory,
      activityLevel: activityLevel,
      coatType: coatType,
      healthConditions: healthConditions,
    );

    return (entity: entity, catId: catId);
  }

  @override
  Future<void> deleteCat({required String catId}) async {
    return _dataSource.deleteCat(catId: catId);
  }

  @override
  Future<void> updateCat({required CatEntity cat}) async {
    if (cat.id == null) {
      throw Exception('Cannot update cat without ID');
    }

    final catData = _mapper.toDocument(cat);
    return _dataSource.updateCat(catId: cat.id!, catData: catData);
  }
}
