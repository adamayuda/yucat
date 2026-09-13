import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_create_model.dart';

class CatModelToEntityMapper {
  CatEntity call(CatCreateModel model) => CatEntity(
    id: model.id,
    name: model.name,
    age: model.age,
    birthDate: model.birthDate,
    weight: model.weight,
    neutered: model.neutered,
    // The *current* URL. `UpdateCatUsecase` overrides it when a new file was
    // picked and uses this one to delete the replaced Storage object.
    profileImageUrl: model.profileImageUrl,
    ageGroup: model.ageGroup,
    neuteredStatus: model.neuteredStatus,
    breed: model.breed,
    weightCategory: model.weightCategory,
    activityLevel: model.activityLevel,
    coatType: model.coatType,
    gender: model.gender,
    healthConditions: model.persistedHealthConditions,
  );
}
