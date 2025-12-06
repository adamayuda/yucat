import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';

abstract class CatDocumentMapper {
  CatEntity call(QueryDocumentSnapshot<Map<String, dynamic>> doc);
}

class CatDocumentMapperImpl implements CatDocumentMapper {
  @override
  CatEntity call(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return CatEntity(
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
}
