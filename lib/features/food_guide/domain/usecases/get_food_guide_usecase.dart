import 'package:yucat/features/food_guide/domain/entities/food_guide_entity.dart';
import 'package:yucat/features/food_guide/domain/repositories/food_guide_repository.dart';

class GetFoodGuideUsecase {
  final FoodGuideRepository _repository;

  GetFoodGuideUsecase({required FoodGuideRepository repository})
      : _repository = repository;

  Future<List<FoodGuideEntity>> call({String? language}) =>
      _repository.getFoodGuide(language: language);
}
