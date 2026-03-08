import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_create_model.dart';

class CatModelToEntityMapper {
  CatEntity call(CatCreateModel model) => CatEntity(
    id: model.id,
    name: model.name,
    age: model.age,
    weight: model.weight,
    neutered: model.neutered,
    profileImageUrl:
        null, // Image URL is not available in the model, only the file
    ageGroup: model.ageGroup,
    neuteredStatus: model.neuteredStatus,
    breed: model.breed,
    weightCategory: model.weightCategory,
    activityLevel: model.activityLevel,
    coatType: model.coatType,
    gender: model.gender,
    healthConditions: model.healthConditions,
  );
}
