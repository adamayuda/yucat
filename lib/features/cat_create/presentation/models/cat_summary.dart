import 'package:yucat/features/cat_create/presentation/models/cat_create_model.dart';

/// Presentation-ready recap of a freshly created cat, surfaced on the
/// onboarding success screen. Built from a [CatCreateModel] so the screen can
/// render labelled attribute rows without re-deriving anything.
class CatSummary {
  final String name;

  /// Raw age in months (as collected by the wizard). Null if unknown.
  final int? ageMonths;

  /// Kitten / Adult / Senior, derived from age (months). Null if age unknown.
  final String? lifeStage;
  final String? gender;
  final String? activityLabel;
  final String? coatLabel;
  final String? neuterLabel;
  final String? bodyConditionLabel;

  /// Breed name, or null when unset / "Other" (mixed / unknown).
  final String? breed;

  /// Friendly health-condition labels (excludes "None"). Empty when healthy.
  final List<String> healthLabels;

  const CatSummary({
    required this.name,
    this.ageMonths,
    this.lifeStage,
    this.gender,
    this.activityLabel,
    this.coatLabel,
    this.neuterLabel,
    this.bodyConditionLabel,
    this.breed,
    this.healthLabels = const [],
  });

  /// Age formatted as "2 yr 6 mo", with the life stage appended
  /// ("2 yr 6 mo · Adult"). Null when the age is unknown.
  String? get ageLabel {
    final m = ageMonths;
    if (m == null) return null;
    final years = m ~/ 12;
    final months = m % 12;
    final String age;
    if (years == 0) {
      age = '$months mo';
    } else if (months == 0) {
      age = '$years ${years == 1 ? 'yr' : 'yrs'}';
    } else {
      age = '$years ${years == 1 ? 'yr' : 'yrs'} $months mo';
    }
    return lifeStage != null ? '$age · $lifeStage' : age;
  }

  factory CatSummary.fromModel(CatCreateModel cat) {
    String cap(String v) =>
        v.isEmpty ? v : '${v[0].toUpperCase()}${v.substring(1)}';

    String? lifeStage;
    final age = cat.age;
    if (age != null) {
      lifeStage = age < 12 ? 'Kitten' : (age < 120 ? 'Adult' : 'Senior');
    }

    return CatSummary(
      name: cat.name,
      ageMonths: age,
      lifeStage: lifeStage,
      gender: cat.gender != null ? cap(cat.gender!) : null,
      activityLabel: cat.activityLevel != null
          ? '${cap(cat.activityLevel!)} activity'
          : null,
      coatLabel: _coatLabels[cat.coatType],
      neuterLabel: _neuterLabels[cat.neuteredStatus],
      bodyConditionLabel: _bodyConditionLabels[cat.weightCategory],
      breed: (cat.breed != null && cat.breed != 'Other') ? cat.breed : null,
      healthLabels: [
        for (final c in cat.healthConditions)
          if (c != 'none' && _healthLabels[c] != null) _healthLabels[c]!,
      ],
    );
  }

  static const _coatLabels = {
    'short_hair': 'Short hair',
    'long_hair': 'Long hair',
    'hairless': 'Hairless',
  };

  static const _neuterLabels = {
    'neutered': 'Neutered',
    'intact': 'Not neutered',
    'pregnant': 'Pregnant',
    'lactating': 'Lactating',
  };

  static const _bodyConditionLabels = {
    'underweight': 'Underweight',
    'normal': 'Ideal weight',
    'overweight': 'Overweight',
    'obese': 'Obese',
  };

  static const _healthLabels = {
    'urinary_issues': 'Urinary issues',
    'kidney_disease': 'Kidney disease',
    'sensitive_stomach': 'Sensitive stomach',
    'skin_allergies': 'Skin allergies',
    'food_allergies': 'Food allergies',
    'diabetes': 'Diabetes',
    'dental_problems': 'Dental problems',
    'hairball_issues': 'Hairball issues',
    'heart_condition': 'Heart condition',
    'joint_issues': 'Joint or mobility issues',
  };
}
