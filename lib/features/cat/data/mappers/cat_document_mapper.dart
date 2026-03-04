import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';

abstract class CatDocumentMapper {
  CatEntity call(QueryDocumentSnapshot<Map<String, dynamic>> doc);
  Map<String, dynamic> toDocument(CatEntity entity);
}

class CatDocumentMapperImpl implements CatDocumentMapper {
  @override
  CatEntity call(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return CatEntity(
      id: doc.id,
      name: data['name'] as String,
      age: data['age'] as int?,
      weight: data['weight'] as double?,
      neutered: data['neutered'] as bool? ?? false,
      profileImageUrl: data['profileImageUrl'] as String?,
      ageGroup: data['age_group'] as String?,
      neuteredStatus: data['neutered_status'] as String?,
      breed: data['breed'] as String?,
      weightCategory: data['weight_category'] as String?,
      activityLevel: data['activity_level'] as String?,
      coatType: data['coat_type'] as String?,
      healthConditions: (data['health_conditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toDocument(CatEntity entity) {
    return {
      'name': entity.name,
      'age': entity.age,
      'weight': entity.weight,
      'neutered': entity.neutered,
      if (entity.profileImageUrl != null)
        'profileImageUrl': entity.profileImageUrl,
      'age_group': entity.ageGroup,
      'neutered_status': entity.neuteredStatus,
      'breed': entity.breed,
      'weight_category': entity.weightCategory,
      'activity_level': entity.activityLevel,
      'coat_type': entity.coatType,
      if (entity.healthConditions != null && entity.healthConditions!.isNotEmpty)
        'health_conditions': entity.healthConditions,
    };
  }
}
