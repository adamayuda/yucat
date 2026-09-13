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
    // The second `Timestamp` field in the app, after `health_events`. Kept as a
    // `DateTime` from here on — nothing downstream sees a `Timestamp`.
    final birthDate = (data['birth_date'] as Timestamp?)?.toDate();
    // With a real birth date the months are derived on every read, so the
    // profile ages itself; the stored `age` is then only a snapshot for
    // clients that predate the field.
    final age =
        birthDate != null ? monthsSince(birthDate) : data['age'] as int?;
    return CatEntity(
      id: doc.id,
      name: data['name'] as String,
      age: age,
      birthDate: birthDate,
      weight: data['weight'] as double?,
      neutered: data['neutered'] as bool? ?? false,
      profileImageUrl: data['profileImageUrl'] as String?,
      // Older cats were saved without an age group; derive it from age so the
      // per-cat assessment's age rules work without a data migration. With a
      // birth date the derived group wins over the stored one, which would
      // otherwise stay "kitten" for ever.
      ageGroup: birthDate != null
          ? ageGroupFromMonths(age)
          : (data['age_group'] as String?) ?? ageGroupFromMonths(age),
      neuteredStatus: data['neutered_status'] as String?,
      breed: data['breed'] as String?,
      weightCategory: data['weight_category'] as String?,
      activityLevel: data['activity_level'] as String?,
      coatType: data['coat_type'] as String?,
      gender: data['gender'] as String?,
      healthConditions: (data['health_conditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      allergies: (data['allergies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toDocument(CatEntity entity) {
    return {
      'name': entity.name,
      'age': entity.age,
      // Written even when null: the wizard owns this field, and moving the
      // age wheels clears the birthday — omitting the key would leave the old
      // date in place to override the new months on the next read.
      'birth_date': entity.birthDate == null
          ? null
          : Timestamp.fromDate(entity.birthDate!),
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
      'gender': entity.gender,
      if (entity.healthConditions != null && entity.healthConditions!.isNotEmpty)
        'health_conditions': entity.healthConditions,
      // Written only when non-empty, so a cat-wizard save — which never carries
      // allergies — leaves the stored list alone rather than wiping it.
      // Clearing goes through `updateCatAllergies`, which writes `[]` outright.
      if (entity.allergies != null && entity.allergies!.isNotEmpty)
        'allergies': entity.allergies,
    };
  }
}
