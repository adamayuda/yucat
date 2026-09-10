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

/// Localized breed display name.
///
/// ⚠️ The argument stays the **canonical English** value persisted on the cat.
/// `cat_product_assessment.dart` and `cat_diet_recommendations.dart` each switch
/// on `breed.toLowerCase()` against English literals, Firestore stores that
/// string, and Mixpanel carries it as `cat_breed` / `primary_cat_breed`. Only
/// the rendering is localized — never write a localized label back to the model.
///
/// Unknown values fall through to the raw string rather than showing a key.
/// That is what keeps older profiles holding the coat patterns `'Tabby'` and
/// `'Tuxedo'` rendering after those left the picker. The fallback is the raw
/// string and **not** [catFormatSnakeCase]: breeds are Title Case English, not
/// snake_case keys like the other profile fields.
String catFormatBreed(String breed, AppLocalizations l10n) {
  return switch (breed.toLowerCase()) {
    // Reuses the picker's existing "Mixed / unknown" copy rather than minting a
    // second key, so a bare "Other" never reaches a screen.
    'other' => l10n.breedMixedUnknown,
    'abyssinian' => l10n.breedNameAbyssinian,
    'american bobtail' => l10n.breedNameAmericanBobtail,
    'american curl' => l10n.breedNameAmericanCurl,
    'american shorthair' => l10n.breedNameAmericanShorthair,
    'balinese' => l10n.breedNameBalinese,
    'bengal' => l10n.breedNameBengal,
    'birman' => l10n.breedNameBirman,
    'bombay' => l10n.breedNameBombay,
    'british shorthair' => l10n.breedNameBritishShorthair,
    'burmese' => l10n.breedNameBurmese,
    'burmilla' => l10n.breedNameBurmilla,
    'chartreux' => l10n.breedNameChartreux,
    'cornish rex' => l10n.breedNameCornishRex,
    'cymric' => l10n.breedNameCymric,
    'devon rex' => l10n.breedNameDevonRex,
    'domestic longhair' => l10n.breedNameDomesticLonghair,
    'domestic shorthair' => l10n.breedNameDomesticShorthair,
    'donskoy' => l10n.breedNameDonskoy,
    'egyptian mau' => l10n.breedNameEgyptianMau,
    'european shorthair' => l10n.breedNameEuropeanShorthair,
    'exotic shorthair' => l10n.breedNameExoticShorthair,
    'havana brown' => l10n.breedNameHavanaBrown,
    'himalayan' => l10n.breedNameHimalayan,
    'japanese bobtail' => l10n.breedNameJapaneseBobtail,
    'korat' => l10n.breedNameKorat,
    'laperm' => l10n.breedNameLaPerm,
    'maine coon' => l10n.breedNameMaineCoon,
    'manx' => l10n.breedNameManx,
    'munchkin' => l10n.breedNameMunchkin,
    'nebelung' => l10n.breedNameNebelung,
    'norwegian forest cat' => l10n.breedNameNorwegianForestCat,
    'ocicat' => l10n.breedNameOcicat,
    'oriental shorthair' => l10n.breedNameOrientalShorthair,
    'persian' => l10n.breedNamePersian,
    'peterbald' => l10n.breedNamePeterbald,
    'ragamuffin' => l10n.breedNameRagamuffin,
    'ragdoll' => l10n.breedNameRagdoll,
    'russian blue' => l10n.breedNameRussianBlue,
    'savannah' => l10n.breedNameSavannah,
    'scottish fold' => l10n.breedNameScottishFold,
    'scottish straight' => l10n.breedNameScottishStraight,
    'selkirk rex' => l10n.breedNameSelkirkRex,
    'siamese' => l10n.breedNameSiamese,
    'siberian' => l10n.breedNameSiberian,
    'singapura' => l10n.breedNameSingapura,
    'snowshoe' => l10n.breedNameSnowshoe,
    'somali' => l10n.breedNameSomali,
    'sphynx' => l10n.breedNameSphynx,
    'tonkinese' => l10n.breedNameTonkinese,
    'toyger' => l10n.breedNameToyger,
    'turkish angora' => l10n.breedNameTurkishAngora,
    'turkish van' => l10n.breedNameTurkishVan,
    _ => breed,
  };
}
