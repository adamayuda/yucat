import 'package:yucat/l10n/app_localizations.dart';

/// Localized display labels for the raw cat-profile values stored on
/// [CatEntity] / `CatCreateModel`.
///
/// Profile values are persisted as stable snake_case keys (`short_hair`,
/// `kidney_disease`, …) and must stay that way — the rules engines and Firestore
/// documents depend on them. Everything user-facing goes through here.
///
/// These lived as private `_format*` methods on `CatDetailPage` while
/// `CatSummary` kept a second, **hardcoded-English** copy, so the onboarding
/// recap rendered English regardless of locale. One implementation now.

String catFormatSnakeCase(String text) {
  return text
      .split('_')
      .map(
        (word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase(),
      )
      .join(' ');
}

/// "6 mo", "2 yrs", "2 yrs 6 mo" — from an age in months.
String catFormatAge(int ageInMonths, AppLocalizations l10n) {
  final years = ageInMonths ~/ 12;
  final months = ageInMonths % 12;
  if (years == 0) return '$months ${l10n.ageUnitMonth}';
  final yearStr =
      '$years ${years == 1 ? l10n.ageUnitYear : l10n.catDetailAgeYears}';
  if (months == 0) return yearStr;
  return '$yearStr $months ${l10n.ageUnitMonth}';
}

/// Kitten / Adult / Senior from an age in months. Thresholds mirror
/// `ageGroupFromMonths` in `cat_entity.dart` — keep the two in step.
String catFormatLifeStageFromMonths(int ageInMonths, AppLocalizations l10n) {
  if (ageInMonths < 12) return l10n.commonAgeGroupKitten;
  if (ageInMonths < 120) return l10n.commonAgeGroupAdult;
  return l10n.commonAgeGroupSenior;
}

String catFormatGender(String gender, AppLocalizations l10n) {
  return switch (gender.toLowerCase()) {
    'male' => l10n.genderMale,
    'female' => l10n.genderFemale,
    _ => catFormatSnakeCase(gender),
  };
}

String catFormatActivityLevel(String level, AppLocalizations l10n) {
  return switch (level.toLowerCase()) {
    'low' => l10n.activityLowLabel,
    'moderate' => l10n.catDetailActivityModerate,
    'medium' => l10n.activityMediumLabel,
    'high' => l10n.activityHighLabel,
    _ => catFormatSnakeCase(level),
  };
}

String catFormatBodyCondition(String category, AppLocalizations l10n) {
  return switch (category.toLowerCase()) {
    'underweight' => l10n.bodyUnderweightLabel,
    'normal' => l10n.catDetailBodyNormal,
    'overweight' => l10n.bodyOverweightLabel,
    'obese' => l10n.bodyObeseLabel,
    _ => catFormatSnakeCase(category),
  };
}

String catFormatNeuteredStatus(String status, AppLocalizations l10n) {
  return switch (status.toLowerCase()) {
    'neutered' => l10n.catDetailStatusNeutered,
    'spayed' => l10n.catDetailStatusSpayed,
    'intact' => l10n.neuteredIntact,
    'pregnant' => l10n.neuteredPregnant,
    'lactating' => l10n.neuteredLactating,
    _ => catFormatSnakeCase(status),
  };
}

String catFormatCoatType(String coatType, AppLocalizations l10n) {
  return switch (coatType.toLowerCase()) {
    'short' => l10n.coatShortHair,
    'short_hair' => l10n.coatShortHair,
    'medium' => l10n.catDetailCoatMedium,
    'long' => l10n.coatLongHair,
    'long_hair' => l10n.coatLongHair,
    'hairless' => l10n.coatHairless,
    _ => catFormatSnakeCase(coatType),
  };
}

String catFormatHealthCondition(String condition, AppLocalizations l10n) {
  return switch (condition.toLowerCase()) {
    'urinary_issues' => l10n.healthUrinaryIssues,
    'kidney_disease' => l10n.healthKidneyDisease,
    'sensitive_stomach' => l10n.healthSensitiveStomach,
    'skin_allergies' => l10n.healthSkinAllergies,
    'food_allergies' => l10n.healthFoodAllergies,
    'diabetes' => l10n.healthDiabetes,
    'dental_problems' => l10n.healthDentalProblems,
    'hairball_issues' => l10n.healthHairballIssues,
    'heart_condition' => l10n.healthHeartCondition,
    'joint_issues' => l10n.healthJointIssues,
    _ => catFormatSnakeCase(condition),
  };
}
