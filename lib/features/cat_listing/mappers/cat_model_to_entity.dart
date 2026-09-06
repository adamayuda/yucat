import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';

/// Presentation [CatModel] → domain [CatEntity]. The two are field-identical.
///
/// Exists because the shared rules engines (`recommendDiet`,
/// `recommendProductsForCat`, `computeDueItems`) all take a [CatEntity], while
/// every screen that hosts them is handed a [CatModel] by its route. This used
/// to be a private `_entityFromModel` inside `cat_detail_page.dart`; the health
/// carnet needed the same conversion, so it lives here rather than being copied.
///
/// Note this is the *reverse* of `CatEntityToModelMapper` and unrelated to
/// `CatModelToEntityMapper`, which maps the wizard's `CatCreateModel`.
CatEntity catEntityFromModel(CatModel m) => CatEntity(
      id: m.id,
      name: m.name,
      age: m.age,
      weight: m.weight,
      neutered: m.neutered,
      profileImageUrl: m.profileImageUrl,
      ageGroup: m.ageGroup,
      neuteredStatus: m.neuteredStatus,
      breed: m.breed,
      weightCategory: m.weightCategory,
      activityLevel: m.activityLevel,
      coatType: m.coatType,
      gender: m.gender,
      healthConditions: m.healthConditions,
      allergies: m.allergies,
    );
