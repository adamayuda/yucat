import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat_listing/presentation/models/cat_model.dart';

abstract class CatEntityToModelMapper {
  CatModel call(CatEntity entity);
}

class CatEntityToModelMapperImpl extends CatEntityToModelMapper {
  @override
  CatModel call(CatEntity entity) {
    return CatModel(
      name: entity.name,
      age: entity.age,
      weight: entity.weight,
      neutered: entity.neutered,
      profileImageUrl: entity.profileImageUrl,
      ageGroup: entity.ageGroup,
      neuteredStatus: entity.neuteredStatus,
      breed: entity.breed,
      weightCategory: entity.weightCategory,
      activityLevel: entity.activityLevel,
      coatType: entity.coatType,
      healthConditions: entity.healthConditions,
    );
  }
}
