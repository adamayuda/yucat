import 'package:yucat/features/cat/data/datasources/cat_narrative_datasource.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/entities/cat_narrative.dart';
import 'package:yucat/features/cat/domain/repositories/cat_narrative_repository.dart';

class CatNarrativeRepositoryImpl implements CatNarrativeRepository {
  final CatNarrativeDataSource _dataSource;

  CatNarrativeRepositoryImpl({required CatNarrativeDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<CatNarrative?> generateNarrative({
    required CatEntity cat,
    required List<DietTip> tips,
    required String locale,
  }) {
    final lifeStage = cat.ageGroup ?? ageGroupFromMonths(cat.age);
    final neuteredStatus =
        cat.neuteredStatus ?? (cat.neutered ? 'neutered' : null);
    final conditions = (cat.healthConditions ?? const [])
        .where((c) => c.toLowerCase() != 'none')
        .toList();

    final payload = <String, dynamic>{
      'name': cat.name,
      if (lifeStage != null) 'lifeStage': lifeStage,
      if (cat.breed != null && cat.breed!.isNotEmpty) 'breed': cat.breed,
      if (cat.gender != null) 'gender': cat.gender,
      if (cat.weightCategory != null) 'bodyCondition': cat.weightCategory,
      if (cat.activityLevel != null) 'activityLevel': cat.activityLevel,
      if (neuteredStatus != null) 'neuteredStatus': neuteredStatus,
      if (cat.coatType != null) 'coatType': cat.coatType,
      'healthConditions': conditions,
      'tips': [
        for (final t in tips)
          {'nutrient': t.nutrient, 'direction': t.direction},
      ],
      'locale': locale,
    };

    return _dataSource.generateNarrative(payload);
  }
}
