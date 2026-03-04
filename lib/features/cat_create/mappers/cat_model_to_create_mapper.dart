import 'package:yucat/features/cat_create/presentation/models/cat_create_model.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';

abstract class CatModelToCreateMapper {
  CatCreateModel call(CatModel model);
}

class CatModelToCreateMapperImpl extends CatModelToCreateMapper {
  @override
  CatCreateModel call(CatModel model) {
    return CatCreateModel(
      id: model.id,
      name: model.name,
      age: model.age,
      ageGroup: model.ageGroup,
      weight: model.weight,
      neutered: model.neutered,
      profileImageUrl: model.profileImageUrl,
      neuteredStatus: model.neuteredStatus,
      breed: model.breed,
      weightCategory: model.weightCategory,
      activityLevel: model.activityLevel,
      coatType: model.coatType,
      healthConditions: model.healthConditions ?? [],
    );
  }
}
