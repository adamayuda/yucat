import 'package:yucat/features/food_guide/domain/entities/food_guide_entity.dart';

abstract class FoodGuideRepository {
  /// [language] is the app's resolved language code; an unsupported or null
  /// value yields the canonical English copy.
  Future<List<FoodGuideEntity>> getFoodGuide({String? language});
}
