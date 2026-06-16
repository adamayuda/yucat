import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/entities/cat_narrative.dart';
import 'package:yucat/features/cat/domain/repositories/cat_narrative_repository.dart';

/// Generates the onboarding "personalized narrative" for a freshly created cat.
/// Non-critical: returns null on failure so the UI can fall back to a local
/// template.
class GenerateCatNarrativeUsecase {
  final CatNarrativeRepository _repository;

  GenerateCatNarrativeUsecase({required CatNarrativeRepository repository})
      : _repository = repository;

  Future<CatNarrative?> call({
    required CatEntity cat,
    required List<DietTip> tips,
    required String locale,
  }) {
    return _repository.generateNarrative(cat: cat, tips: tips, locale: locale);
  }
}
