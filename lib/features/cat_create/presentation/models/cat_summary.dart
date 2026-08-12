import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_create_model.dart';

/// Presentation-ready recap of a freshly created cat, surfaced on the
/// onboarding success screen. Built from a [CatCreateModel] so the screen can
/// render labelled attribute rows without re-deriving anything.
class CatSummary {
  final String name;

  /// Raw age in months (as collected by the wizard). Null if unknown.
  final int? ageMonths;

  /// Raw profile values, exactly as the wizard stores them (`short_hair`,
  /// `kidney_disease`, …). These are deliberately **not** display strings: the
  /// summary is built in `CatCreateBloc`, which has no `BuildContext` and so no
  /// `AppLocalizations`. Render them through `cat_labels.dart` at the widget
  /// layer instead — they used to be pre-baked English here, which is why the
  /// onboarding recap showed English in every locale.
  final String? gender;
  final String? activityLevel;
  final String? coatType;
  final String? neuteredStatus;
  final String? weightCategory;

  /// Breed name, or null when unset / "Other" (mixed / unknown).
  final String? breed;

  /// Raw health-condition keys (excludes "none"). Empty when healthy.
  final List<String> healthConditions;

  /// The canonical cat profile, used to drive the personalized narrative and
  /// dietary tips on the success screen (carries the raw values the rule engine
  /// needs, unlike the display labels above).
  final CatEntity entity;

  const CatSummary({
    required this.name,
    required this.entity,
    this.ageMonths,
    this.gender,
    this.activityLevel,
    this.coatType,
    this.neuteredStatus,
    this.weightCategory,
    this.breed,
    this.healthConditions = const [],
  });

  factory CatSummary.fromModel(CatCreateModel cat) {
    final age = cat.age;

    return CatSummary(
      name: cat.name,
      entity: CatEntity(
        id: cat.id,
        name: cat.name,
        age: cat.age,
        weight: cat.weight,
        neutered: cat.neutered,
        profileImageUrl: cat.profileImageUrl,
        ageGroup: cat.ageGroup ?? ageGroupFromMonths(cat.age),
        neuteredStatus: cat.neuteredStatus,
        breed: cat.breed,
        weightCategory: cat.weightCategory,
        activityLevel: cat.activityLevel,
        coatType: cat.coatType,
        gender: cat.gender,
        healthConditions: cat.healthConditions,
      ),
      ageMonths: age,
      gender: cat.gender,
      activityLevel: cat.activityLevel,
      coatType: cat.coatType,
      neuteredStatus: cat.neuteredStatus,
      weightCategory: cat.weightCategory,
      breed: (cat.breed != null && cat.breed != 'Other') ? cat.breed : null,
      healthConditions: [
        for (final c in cat.healthConditions)
          if (c != 'none') c,
      ],
    );
  }
}
