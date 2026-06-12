// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonNext => 'Next';

  @override
  String get commonGotIt => 'Got it';

  @override
  String get commonSkip => 'Skip';

  @override
  String get catNameQuestion => 'What\'s your cat\'s name?';

  @override
  String get catNameLabel => 'Name your cat';

  @override
  String get catNameHint => 'Caramel';

  @override
  String get catNameValidationEmpty => 'Please enter a cat name';

  @override
  String get genderQuestion => 'What\'s your cat\'s gender?';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderMale => 'Male';

  @override
  String get photoQuestion => 'Add a photo of your cat';

  @override
  String get photoSheetTitle => 'Add a photo';

  @override
  String get photoSheetTakePhoto => 'Take a photo';

  @override
  String get photoSheetUploadLibrary => 'Upload from library';

  @override
  String get photoCameraError =>
      'Couldn\'t access the camera. Check permissions in Settings.';

  @override
  String get photoLibraryError =>
      'Couldn\'t open your photos. Check permissions in Settings.';

  @override
  String get ageQuestion => 'How old is your cat?';

  @override
  String get ageColumnYears => 'Years';

  @override
  String get ageColumnMonths => 'Months';

  @override
  String get ageUnitYear => 'yr';

  @override
  String get ageUnitMonth => 'mo';

  @override
  String ageStageKitten(String years) {
    return 'About $years years old — a kitten.';
  }

  @override
  String ageStageAdult(String years) {
    return 'About $years years old — an adult.';
  }

  @override
  String ageStageSenior(String years) {
    return 'About $years years old — a senior.';
  }

  @override
  String get bodyConditionQuestion => 'What\'s your cat\'s body shape?';

  @override
  String get bodyUnderweightLabel => 'Underweight';

  @override
  String get bodyUnderweightDesc => 'Ribs and spine show, very little fat';

  @override
  String get bodyNormalLabel => 'Just right';

  @override
  String get bodyNormalDesc => 'Ribs felt easily, visible waist';

  @override
  String get bodyOverweightLabel => 'Overweight';

  @override
  String get bodyOverweightDesc => 'Ribs hard to feel, rounded belly';

  @override
  String get bodyObeseLabel => 'Obese';

  @override
  String get bodyObeseDesc => 'Heavy fat cover, no waist';

  @override
  String get activityQuestion => 'How active is your cat?';

  @override
  String get activityLowLabel => 'Low';

  @override
  String get activityLowDesc => 'Mostly naps, rarely chases';

  @override
  String get activityMediumLabel => 'Medium';

  @override
  String get activityMediumDesc => 'Plays a few times a day';

  @override
  String get activityHighLabel => 'High';

  @override
  String get activityHighDesc => 'Climbs, sprints, hunts toys';

  @override
  String get waterFactHeadline =>
      'Hydration protects your cat\'s kidneys and urinary health';

  @override
  String get waterFactHighlight => 'kidneys and urinary health';

  @override
  String get waterFactBody =>
      'Moisture-rich food lowers the risk of urinary and kidney issues — we weigh hydration into every assessment.';

  @override
  String get neuteredQuestion => 'Is your cat neutered or spayed?';

  @override
  String get neuteredIntact => 'Intact';

  @override
  String get neuteredNeutered => 'Neutered / Spayed';

  @override
  String get neuteredPregnant => 'Pregnant';

  @override
  String get neuteredLactating => 'Lactating';

  @override
  String get coatQuestion => 'What type of coat?';

  @override
  String get coatShortHair => 'Short hair';

  @override
  String get coatLongHair => 'Long hair';

  @override
  String get coatHairless => 'Hairless';

  @override
  String get coatFactHeadline => 'Long-haired cats need\nmore omega-3';

  @override
  String get coatFactHighlight => 'more omega-3';

  @override
  String get coatFactBody =>
      'Omega-3 keeps their coat glossy and skin healthy.';

  @override
  String get healthQuestion => 'Any health considerations?';

  @override
  String get healthNone => 'None';

  @override
  String get healthUrinaryIssues => 'Urinary issues';

  @override
  String get healthKidneyDisease => 'Kidney disease';

  @override
  String get healthSensitiveStomach => 'Sensitive stomach';

  @override
  String get healthSkinAllergies => 'Skin allergies';

  @override
  String get healthFoodAllergies => 'Food allergies';

  @override
  String get healthDiabetes => 'Diabetes';

  @override
  String get healthDentalProblems => 'Dental problems';

  @override
  String get healthHairballIssues => 'Hairball issues';

  @override
  String get healthHeartCondition => 'Heart condition';

  @override
  String get healthJointIssues => 'Joint or mobility issues';

  @override
  String get breedQuestion => 'What breed is your cat?';

  @override
  String get breedUnknownPrefix => 'Don\'t know the breed? ';

  @override
  String get breedMixedUnknown => 'Mixed / unknown';

  @override
  String get disclaimerTitle => 'Guiding, not prescribing';

  @override
  String get disclaimerBody1 =>
      'YuCat suggests foods based on your cat\'s profile and the ingredients we read off each product. It is not a substitute for veterinary advice.';

  @override
  String get disclaimerBody2 =>
      'For diagnosed conditions or sudden changes in weight, appetite, or behavior, please consult a licensed veterinarian.';

  @override
  String get catCreateCtaCreateProfile => 'Create profile';

  @override
  String get catCreateCtaSaveChanges => 'Save changes';

  @override
  String get catCreateCtaNoneOfThese => 'None of these';

  @override
  String get catCreateErrorCreate =>
      'Couldn\'t create the profile. Please try again.';

  @override
  String get catCreateErrorSave =>
      'Couldn\'t save your changes. Please try again.';

  @override
  String get onboardingWelcomeHeadline => 'Decode\nevery\ncat\nfood';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingLegalPrefix => 'By continuing you\'re accepting our\n';

  @override
  String get onboardingTermsOfUse => 'Terms of Use';

  @override
  String get onboardingLegalAnd => ' and ';

  @override
  String get onboardingPrivacyNotice => 'Privacy Notice';

  @override
  String get onboardingWhyYucatTitle => 'Why YuCat\'s\nunique approach\nworks';

  @override
  String get onboardingLetsGo => 'Let\'s go';

  @override
  String get onboardingHealthIntroTitle =>
      'Now tell us\nabout your cat\'s\nhealth';

  @override
  String get onboardingCouldNotOpenLink => 'Could not open this link.';

  @override
  String get onboardingNutritionFactHeadlinePart1 => 'A kitten needs\n';

  @override
  String get onboardingNutritionFactHighlight => '2.5× more protein';

  @override
  String get onboardingNutritionFactHeadlinePart2 => '\nthan a senior cat';

  @override
  String get onboardingNutritionFactBody =>
      'Life stage, weight, activity and health conditions all change what belongs in your cat\'s bowl.';

  @override
  String get onboardingMerckManualName => 'Merck Veterinary Manual ';

  @override
  String get onboardingMerckManualQuote =>
      'notes a cat\'s protein and amino-acid needs change with life stage — kittens require more protein than adults and are more sensitive to amino-acid balance.';

  @override
  String get onboardingSourceLink => 'Source of recommendations';

  @override
  String get onboardingScanDemoTitle => 'Track\nwhat\'s inside';

  @override
  String get onboardingScanDemoSubtitle =>
      'Point your camera at any\ncat food and get a verdict';

  @override
  String get onboardingProfileIntroTitle =>
      'Let\'s set up\nyour cat\'s profile';

  @override
  String get onboardingProfileIntroTime => '2 min';

  @override
  String get onboardingProfileIntroQuote =>
      'A quick profile unlocks tailored verdicts on every bag';

  @override
  String get onboardingProfileNameLabel => 'Name your cat';

  @override
  String get onboardingProfileNameHint => 'Mochi';

  @override
  String get onboardingProofChartTitle => 'YuCat provides\nlong-term results';

  @override
  String get onboardingProofChartCalloutBold => 'A better-fit food ';

  @override
  String get onboardingProofChartCalloutRest =>
      'tailored to your cat\'s needs, in just a few scans';

  @override
  String get onboardingRatingEyebrow => 'Help us grow';

  @override
  String get onboardingRatingTitle => 'Give us rating';

  @override
  String get onboardingRatingStatValue => 'Loved';

  @override
  String get onboardingRatingStatLabel => 'by cat parents';

  @override
  String get onboardingRatingPeopleLabel => 'Cat parents like you';

  @override
  String get onboardingReview1Headline => 'Exactly what I needed!';

  @override
  String get onboardingReview1Body =>
      'I scanned my cat\'s kibble and finally understood what was in it. Switched brands the same week and never looked back.';

  @override
  String get onboardingReview2Headline => 'Loving this app!!!';

  @override
  String get onboardingReview2Body =>
      'Amazing app, so easy to use. I just upload pictures of the food and it tells me everything great!';

  @override
  String get onboardingReview3Headline => 'A senior-cat lifesaver';

  @override
  String get onboardingReview3Body =>
      'YuCat narrowed down a senior food that\'s gentle on Lulu\'s stomach in one afternoon.';

  @override
  String get onboardingReview4Headline => 'Finally feel confident';

  @override
  String get onboardingReview4Body =>
      'I used to just grab whatever was on sale. Now I actually know which foods match my kitten\'s needs. Total peace of mind.';

  @override
  String get onboardingReview5Headline => 'So simple to use';

  @override
  String get onboardingReview5Body =>
      'Snap a photo and you get a clear breakdown in seconds. My vet was even impressed when I showed her.';

  @override
  String get onboardingReview6Headline => 'Two cats, two diets';

  @override
  String get onboardingReview6Body =>
      'Managing food for an overweight tabby and a picky Siamese was a nightmare. YuCat made it effortless for both.';

  @override
  String get onboardingAttributionTitle => 'How did you hear\nabout us?';

  @override
  String get onboardingAttributionInstagram => 'Instagram';

  @override
  String get onboardingAttributionTikTok => 'TikTok';

  @override
  String get onboardingAttributionYouTube => 'YouTube';

  @override
  String get onboardingAttributionAppStore => 'App Store search';

  @override
  String get onboardingAttributionFriends => 'Friends/family';

  @override
  String get onboardingNotifPrimerTitle =>
      'We\'ll keep an eye on\nyour cat\'s food';

  @override
  String get onboardingSetUpReminders => 'Set up reminders';

  @override
  String get onboardingNotifMatchDropped => 'Match dropped';

  @override
  String get onboardingNotifMockBody =>
      'Luna\'s food changed recipe — see the new verdict 🔍';

  @override
  String get onboardingRemindersTitle => 'What should we\nping you about?';

  @override
  String get commonDone => 'Done';

  @override
  String get onboardingSetUpLater => 'Set up later';

  @override
  String get onboardingRemindersOptionFoodChange => 'When a saved food changes';

  @override
  String get onboardingRemindersOptionBetterFit => 'When a better fit is found';

  @override
  String get onboardingRemindersOptionMonthly => 'Monthly check-in';

  @override
  String get onboardingRemindersCalloutPart1 =>
      'Reminders build healthy eating habits ';

  @override
  String get onboardingRemindersCalloutBold => '2x faster';

  @override
  String onboardingSuccessWithName(String name) {
    return '$name is\nall set!';
  }

  @override
  String get onboardingSuccessNoName => 'You\'re all\nset!';

  @override
  String get onboardingStartScanning => 'Start scanning';

  @override
  String get onboardingSuccessNotSet => 'Not set';

  @override
  String get onboardingSuccessNone => 'None';

  @override
  String get onboardingSuccessRowAge => 'Age';

  @override
  String get onboardingSuccessRowActivity => 'Activity';

  @override
  String get onboardingSuccessRowBodyCondition => 'Body condition';

  @override
  String get onboardingSuccessRowCoat => 'Coat';

  @override
  String get onboardingSuccessRowNeuterStatus => 'Neuter status';

  @override
  String get onboardingSuccessRowBreed => 'Breed';

  @override
  String get onboardingSuccessRowHealthConditions => 'Health conditions';

  @override
  String get onboardingSuccessProfileReadyTitle => 'Profile ready';

  @override
  String get onboardingSuccessProfileReadyBody =>
      'You can edit these details anytime in your cat\'s profile.';

  @override
  String get paywallHeroHeadline => 'Know exactly\nwhat\'s in the bowl';

  @override
  String get paywallHeroHighlight => 'exactly';

  @override
  String get paywallPlusBadge => 'Plus';

  @override
  String get paywallBadgeBestValue => 'BEST VALUE';

  @override
  String get paywallLimitedTimeOffer => 'Limited-time offer';

  @override
  String paywallLimitedTimeOfferWithSavings(String savings) {
    return 'Limited-time offer · $savings';
  }

  @override
  String get paywallEverythingYouGet => 'Everything you get';

  @override
  String get paywallFeatureIngredientScannerTitle => 'Ingredient scanner';

  @override
  String get paywallFeatureIngredientScannerBenefit =>
      'Scan any label in seconds';

  @override
  String get paywallFeaturePersonalizedVerdictsTitle => 'Personalized verdicts';

  @override
  String get paywallFeaturePersonalizedVerdictsBenefit =>
      'Matched to your cat\'s age, breed & health';

  @override
  String get paywallFeatureUnlimitedScansTitle => 'Unlimited scans';

  @override
  String get paywallFeatureUnlimitedScansBenefit => 'No daily caps, ever';

  @override
  String get paywallFeatureReformulationAlertsTitle => 'Reformulation alerts';

  @override
  String get paywallFeatureReformulationAlertsBenefit =>
      'Know the moment a recipe changes';

  @override
  String get paywallFeatureSavedFoodsTitle => 'Saved foods & history';

  @override
  String get paywallFeatureSavedFoodsBenefit =>
      'Every food you\'ve checked, in one place';

  @override
  String get paywallFeatureMultiCatTitle => 'Multi-cat profiles';

  @override
  String get paywallFeatureMultiCatBenefit =>
      'A tailored profile for each of your cats';

  @override
  String get paywallSuccessStoriesHeading =>
      'Success stories\nfrom cat parents';

  @override
  String get paywallTestimonial1Quote =>
      'I\'d been guessing for years. YuCat narrowed down a senior food that\'s gentle on Lulu\'s stomach in one afternoon.';

  @override
  String get paywallTestimonial1Name => 'Sophie';

  @override
  String get paywallTestimonial1Detail => 'Senior cat · sensitive stomach';

  @override
  String get paywallTestimonial2Quote =>
      'Scanned our kitten\'s kibble and finally understood what was in it. Switched brands the same week.';

  @override
  String get paywallTestimonial2Name => 'Marco';

  @override
  String get paywallTestimonial2Detail => 'Kitten · picky eater';

  @override
  String get paywallTestimonial3Quote =>
      'Two cats, two very different needs. Now I know which food actually fits each of them.';

  @override
  String get paywallTestimonial3Name => 'Priya';

  @override
  String get paywallTestimonial3Detail => 'Multi-cat household';

  @override
  String get paywallStatRatingLabel => 'average\nrating';

  @override
  String get paywallStatCatParentsLabel => 'cat parents\nworldwide';

  @override
  String get paywallCancelAnytime => 'Cancel anytime.';

  @override
  String get paywallAutoRenewDisclosure =>
      'Your subscription auto-renews unless cancelled at least 24 hours before the end of the current term. Cancel anytime in the App Store at no extra cost.';

  @override
  String get paywallRestorePurchases => 'Restore purchases';

  @override
  String get commonTerms => 'Terms';

  @override
  String get commonPrivacy => 'Privacy';

  @override
  String get commonClose => 'Close';

  @override
  String get paywallPeriodAnnual => 'Annual';

  @override
  String get paywallPeriod6Months => '6 months';

  @override
  String get paywallPeriod3Months => '3 months';

  @override
  String get paywallPeriod2Months => '2 months';

  @override
  String get paywallPeriodMonthly => 'Monthly';

  @override
  String get paywallPeriodWeekly => 'Weekly';

  @override
  String get paywallPeriodLifetime => 'Lifetime';

  @override
  String get paywallCtaUnlockPlus => 'Unlock Yucat Plus';

  @override
  String get paywallSkipDebug => 'Skip paywall (debug)';

  @override
  String get paywallErroriOSOnly => 'Subscriptions are only available on iOS.';

  @override
  String get paywallErrorCouldNotLoadPlans => 'Could not load plans.';

  @override
  String get paywallErrorNoPlansAvailable =>
      'No subscription plans are available right now.';

  @override
  String get paywallErrorPurchaseNotComplete =>
      'Purchase did not complete. Please try again.';

  @override
  String get paywallErrorPurchaseFailed => 'Purchase failed. Please try again.';

  @override
  String get paywallErrorSomethingWentWrong =>
      'Something went wrong. Please try again.';

  @override
  String get paywallErrorNoActiveSubscription =>
      'No active subscription found.';

  @override
  String get paywallErrorRestoreFailed =>
      'Could not restore purchases. Please try again.';

  @override
  String get commonGoBack => 'Go back';

  @override
  String get productDetailLoadError => 'Could not load this product.';

  @override
  String get productDetailOverallAnalysis => 'OVERALL ANALYSIS';

  @override
  String get productDetailAiIdentifiedPill => '* AI IDENTIFIED';

  @override
  String get productDetailMyCatScore => 'My cat\'s score';

  @override
  String get productDetailNoCatPrompt =>
      'Create a cat profile to see a personalized score for your cat.';

  @override
  String get productDetailAddACat => 'Add a cat';

  @override
  String get productDetailForYourCats => 'For your cats';

  @override
  String productDetailCatsCount(int count) {
    return '$count CATS';
  }

  @override
  String get productDetailPickACat =>
      'Pick a cat to see how this product fits its profile.';

  @override
  String get productDetailPersonalizedScore =>
      'Personalized score based on your cat\'s profile.';

  @override
  String get productDetailDimHealth => 'HEALTH';

  @override
  String get productDetailDimWeight => 'WEIGHT';

  @override
  String get productDetailDimAge => 'AGE';

  @override
  String get productDetailDimActivity => 'ACTIVITY';

  @override
  String get productDetailDimNeuteredStatus => 'NEUTERED STATUS';

  @override
  String get productDetailDimBreed => 'BREED';

  @override
  String get productDetailNeutralFit =>
      'No strong matches for this cat — neutral fit.';

  @override
  String get productDetailAgeGroupKitten => 'Kitten';

  @override
  String get productDetailAgeGroupAdult => 'Adult';

  @override
  String get productDetailAgeGroupSenior => 'Senior';

  @override
  String get productDetailNutrientProtein => 'Protein';

  @override
  String get productDetailNutrientFat => 'Fat';

  @override
  String get productDetailNutrientMoisture => 'Moisture';

  @override
  String get productDetailNutrientFiber => 'Fiber';

  @override
  String get productDetailNutrientCarbs => 'Carbs';

  @override
  String get productDetailVerdictExcellent => 'A great everyday pick';

  @override
  String get productDetailVerdictGood => 'A solid everyday pick';

  @override
  String get productDetailVerdictAverage => 'A reasonable choice';

  @override
  String get productDetailVerdictPoor => 'Best to skip this one';

  @override
  String get productDetailNoDataHeadline => 'We couldn\'t find the details yet';

  @override
  String get productDetailNoDataBody =>
      'We couldn\'t find the guaranteed analysis for this product. Try scanning the nutrition label, or check back later — we keep looking.';

  @override
  String get productDetailNoDataCatsNote =>
      'We\'ll show how this fits your cats once we have the nutrition details.';

  @override
  String get productDetailImagePlaceholder => 'PRODUCT';

  @override
  String productDetailScoreSemantics(int score, int maxScore) {
    return 'Score $score out of $maxScore';
  }

  @override
  String get assessmentKittenHighProtein =>
      'High protein (>35%) which is beneficial for kittens';

  @override
  String get assessmentKittenHighFat =>
      'High fat (>18%) which supports kitten growth';

  @override
  String get assessmentKittenSeniorFormula =>
      'Senior-targeted formula is not ideal for kittens';

  @override
  String get assessmentKittenLowProtein =>
      'Low protein (<28%) may not meet kitten needs';

  @override
  String get assessmentSeniorModerateProtein =>
      'Moderate protein (30–35%) is appropriate for seniors';

  @override
  String get assessmentSeniorHighFat =>
      'Very high fat (>20%) may be unsuitable for seniors';

  @override
  String get assessmentSeniorJointSupport =>
      'Contains joint support ingredients (e.g. glucosamine, chondroitin)';

  @override
  String get assessmentSeniorKidneyFriendly =>
      'Kidney-friendly formulation (e.g. lower phosphorus)';

  @override
  String get assessmentUnderweightHighCalories =>
      'High calories (>380 kcal/100g) can help an underweight cat gain weight';

  @override
  String get assessmentUnderweightHighFat =>
      'High fat (>18%) supports weight gain for underweight cats';

  @override
  String get assessmentOverweightHighCalories =>
      'High calories (>360 kcal/100g) may not be ideal for an overweight cat';

  @override
  String get assessmentOverweightLowCalories =>
      'Lower calories (<320 kcal/100g) help manage weight in overweight cats';

  @override
  String get assessmentOverweightHighFiber =>
      'Higher fiber (>4%) can help with satiety for overweight cats';

  @override
  String get assessmentObeseHighFat =>
      'High fat (>15%) is not suitable for obese cats';

  @override
  String get assessmentObeseHighCalories =>
      'High calories (>330 kcal/100g) are not ideal for obese cats';

  @override
  String get assessmentObeseLeanProtein =>
      'Lean, high-protein formula (>40% protein, <12% fat) is good for obese cats';

  @override
  String get assessmentLowActivityHighCalories =>
      'High calories (>360 kcal/100g) may not suit a low-activity cat';

  @override
  String get assessmentLowActivityModerateCalories =>
      'Moderate calories (<330 kcal/100g) are better for low-activity cats';

  @override
  String get assessmentHighActivityHighCalories =>
      'Higher calories (>380 kcal/100g) support a highly active cat';

  @override
  String get assessmentHighActivityHighProtein =>
      'High protein (>35%) helps maintain muscle in active cats';

  @override
  String get assessmentNeuteredHighCalories =>
      'Very calorie-dense food (>380 kcal/100g) can promote weight gain in neutered cats';

  @override
  String get assessmentNeuteredUrinarySupport =>
      'Contains urinary support ingredients, good for neutered cats';

  @override
  String get assessmentNeuteredHighFat =>
      'High fat (>16%) may not be ideal for neutered cats';

  @override
  String get assessmentPregnantHighProtein =>
      'Very high protein (>35%) supports the increased needs of pregnant/lactating cats';

  @override
  String get assessmentPregnantHighFat =>
      'High fat (>20%) provides extra energy for pregnant/lactating cats';

  @override
  String get assessmentPregnantHighCalories =>
      'Very calorie-dense food (>400 kcal/100g) helps meet energy demands in pregnancy/lactation';

  @override
  String get assessmentMaineCoonJointSupport =>
      'Contains joint support ingredients, helpful for Maine Coons';

  @override
  String get assessmentMaineCoonHighProtein =>
      'High protein (>35%) supports large-breed Maine Coons';

  @override
  String get assessmentPersianHairball =>
      'Hairball-control style formula (fiber 4–6% or hairball claims)';

  @override
  String get assessmentPersianOmega3 =>
      'Includes omega-3 rich ingredients, good for Persian coat/skin';

  @override
  String get assessmentPersianHighCarbs =>
      'High carbohydrate (>30%) may not be ideal for Persians';

  @override
  String get assessmentSiameseDigestible =>
      'Uses easily digestible proteins, good for Siamese cats';

  @override
  String get assessmentSiameseFillers =>
      'Contains many fillers (corn, wheat, soy) which may not suit Siamese cats';

  @override
  String get assessmentSphynxHighFat =>
      'Higher fat (>18%) can support Sphynx skin health';

  @override
  String get assessmentSphynxLowFat =>
      'Low-fat formula (<12%) may not provide enough support for Sphynx skin';

  @override
  String get assessmentBritishHighCalories =>
      'High-calorie food may promote weight gain in British Shorthairs';

  @override
  String get assessmentBritishWeightManagement =>
      'Weight-management style formula is suitable for British Shorthairs';

  @override
  String get assessmentBengalHighProtein =>
      'High protein (>38%) matches Bengal energy needs';

  @override
  String get assessmentBengalLowProtein =>
      'Low protein (<30%) may be insufficient for Bengals';

  @override
  String get assessmentUrinaryLowAsh =>
      'Formulated with low ash content, supportive for urinary issues';

  @override
  String get assessmentUrinarySupport =>
      'Includes urinary-support ingredients like cranberry or DL-methionine';

  @override
  String get assessmentUrinaryHighMinerals =>
      'High mineral content may not be ideal for urinary issues';

  @override
  String get assessmentKidneyHighProtein =>
      'High protein (>32%) may not be ideal for kidney disease';

  @override
  String get assessmentKidneyPhosphorus =>
      'Contains phosphorus sources that may be problematic in kidney disease';

  @override
  String get assessmentKidneyRenalSupport =>
      'Formulated as a renal-support diet';

  @override
  String get assessmentSensitiveStomachLimitedIngredient =>
      'Limited-ingredient style recipe can help sensitive stomachs';

  @override
  String get assessmentSensitiveStomachLongIngredients =>
      'Very long ingredient list may not suit sensitive stomachs';

  @override
  String get assessmentFoodAllergyCommonAllergens =>
      'Contains common allergens like chicken, fish, or beef';

  @override
  String get assessmentFoodAllergyNovelProteins =>
      'Uses novel proteins (e.g. duck, venison) which may help with allergies';

  @override
  String get assessmentSkinAllergyOmega3 =>
      'Omega-3 rich formulation can support skin and coat health';

  @override
  String get assessmentSkinAllergyArtificialColor =>
      'Contains artificial colors which may aggravate skin allergies';

  @override
  String get assessmentDiabetesHighCarbs =>
      'High carbohydrates (>20%) are less suitable for diabetic cats';

  @override
  String get assessmentDiabetesHighProtein =>
      'Very high protein (>40%) can support blood sugar control in diabetes';

  @override
  String get assessmentDentalHighMoisture =>
      'High-moisture (wet-style) food is easier to eat with dental problems';

  @override
  String get assessmentDentalLargeKibble =>
      'Very large kibble pieces may be hard to chew with dental issues';

  @override
  String get assessmentHairballControl =>
      'Hairball control style diet (fiber 4–6% or hairball claims)';

  @override
  String get homeScanProduct => 'Scan a product';

  @override
  String get homeScanProductSubtitle => 'Take a photo of the package';

  @override
  String get homeGreetingHey => 'Welcome back';

  @override
  String get homeGreetingWelcome => 'Welcome';

  @override
  String homeReadyForCat(String name) {
    return 'Ready to find food for $name?';
  }

  @override
  String get homeReadyToScan => 'Ready to scan a product?';

  @override
  String get homeAddCatTitle => 'Add your cat';

  @override
  String get homeAddCatBody =>
      'Create a profile to get personalized food scores.';

  @override
  String get homeAddCatButton => 'Add a cat';

  @override
  String get homeSavedProductsTitle => 'Saved products';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeNoSavedProductsTitle => 'No saved products yet';

  @override
  String get homeNoSavedProductsBody =>
      'Tap the bookmark on a product to save it here.';

  @override
  String get homeLoadingEyebrow => 'Hang tight';

  @override
  String get homeLoadingMsgReading => 'Reading the label…';

  @override
  String get homeLoadingMsgSniffing => 'Sniffing the ingredients…';

  @override
  String get homeLoadingMsgMatching => 'Matching our database…';

  @override
  String get homeLoadingMsgCrunching => 'Crunching the numbers…';

  @override
  String get homeLoadingMsgAlmost => 'Almost there…';

  @override
  String get homeCameraUnavailable => 'Camera unavailable';

  @override
  String get homeCameraUnavailableBody =>
      'Enable camera access for YuCat in Settings, or pick a photo from your gallery instead.';

  @override
  String get homeChooseFromGallery => 'Choose from gallery';

  @override
  String get homeScannerHint => 'Point at the product label';

  @override
  String get homeErrorProductNotFound => 'Product not found';

  @override
  String get homeErrorTimeout => 'The request took too long. Please try again.';

  @override
  String get homeErrorNoInternet =>
      'No internet connection. Please check your network and try again.';

  @override
  String get homeErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get homeCatKitten => 'Kitten';

  @override
  String get homeCatAdult => 'Adult';

  @override
  String get homeCatSenior => 'Senior';

  @override
  String get homeCatUnderweight => 'Underweight';

  @override
  String get homeCatHealthyWeight => 'Healthy weight';

  @override
  String get homeCatOverweight => 'Overweight';

  @override
  String get homeCatObese => 'Obese';

  @override
  String homeCatConditionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conditions',
      one: '1 condition',
    );
    return '$_temp0';
  }

  @override
  String get scanHistoryTitle => 'Scan history';

  @override
  String scanHistoryScanCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scans',
      one: '1 scan',
    );
    return '$_temp0';
  }

  @override
  String get scanHistoryEmptyTitle => 'No scans yet';

  @override
  String get scanHistoryEmptyBody => 'Foods you scan will show up here.';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get searchTabTitle => 'Search';

  @override
  String get searchHint => 'Search for a cat food';

  @override
  String get searchRecentLabel => 'Recent';

  @override
  String get searchClearLabel => 'Clear';

  @override
  String get searchPopularBrands => 'Popular brands';

  @override
  String get searchNoMatchesHeadline => 'No matches';

  @override
  String get searchNoMatchesBody =>
      'Try a different name, or browse popular brands.';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get searchErrorBody => 'Something went wrong while searching.';

  @override
  String get bottomNavSearch => 'Search';

  @override
  String get bottomNavHome => 'Home';

  @override
  String get bottomNavProfile => 'Profile';

  @override
  String get productListingEmpty => 'No products found for this brand.';

  @override
  String get commonAgeGroupKitten => 'Kitten';

  @override
  String get commonAgeGroupAdult => 'Adult';

  @override
  String get commonAgeGroupSenior => 'Senior';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileLinkError => 'Couldn\'t open that link.';

  @override
  String get profileSubscriptionLinkError =>
      'Couldn\'t open App Store subscriptions.';

  @override
  String profileEmailError(String email) {
    return 'Couldn\'t open $email.';
  }

  @override
  String get profilePrivacyError => 'Couldn\'t open Privacy Policy.';

  @override
  String get profileTermsError => 'Couldn\'t open Terms and Conditions.';

  @override
  String get profileSubscriptionActive => 'Active subscription';

  @override
  String get profileRestorePurchases => 'Restore purchases';

  @override
  String get profileManageSubscription => 'Manage subscription';

  @override
  String get profileYourCats => 'Your cats';

  @override
  String get profileManage => 'Manage';

  @override
  String get profileAddCat => 'Add cat';

  @override
  String get profileSavedProductsLabel => 'Saved products';

  @override
  String get profileSavedProductsEmpty => 'No saved products yet';

  @override
  String profileSavedProductsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products saved',
      one: '1 product saved',
    );
    return '$_temp0';
  }

  @override
  String get profileScanHistoryLabel => 'Scan history';

  @override
  String get profileScanHistoryEmpty => 'No scans yet';

  @override
  String profileScanHistoryCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scans',
      one: '1 scan',
    );
    return '$_temp0';
  }

  @override
  String get profileContactUs => 'Contact us';

  @override
  String get profilePrivacyPolicy => 'Privacy Policy';

  @override
  String get profileTermsAndConditions => 'Terms & Conditions';

  @override
  String get profileResetOnboarding => 'Reset onboarding';

  @override
  String get profileDebugOnly => 'Debug only';

  @override
  String get profileRestoreNotAvailable => 'Restore is only available on iOS.';

  @override
  String get profileRestoreSuccess => 'Subscription restored successfully!';

  @override
  String get profileNoSubscriptionFound => 'No active subscription found.';

  @override
  String get profileRestoreError =>
      'Couldn\'t restore your purchases. Please try again.';

  @override
  String get savedProductsTitle => 'Saved products';

  @override
  String savedProductsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
    );
    return '$_temp0';
  }

  @override
  String get savedProductsEmptyHeadline => 'No saved products yet';

  @override
  String get savedProductsEmptyBody => 'Bookmark products to find them here';

  @override
  String get catDetailDeleteError =>
      'Couldn\'t delete your cat. Please try again.';

  @override
  String catDetailDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get catDetailDeleteBody =>
      'This will permanently delete their profile.';

  @override
  String get catDetailDeleteCancel => 'Cancel';

  @override
  String get catDetailDeleteConfirm => 'Delete';

  @override
  String get catDetailProfileCompletion => 'Profile completion';

  @override
  String get catDetailNotSet => 'Not set';

  @override
  String get catDetailBreedLabel => 'Breed';

  @override
  String get catDetailAgeLabel => 'Age';

  @override
  String get catDetailAgeYears => 'yrs';

  @override
  String get catDetailGenderLabel => 'Gender';

  @override
  String get catDetailCoatLabel => 'Coat';

  @override
  String get catDetailActivityLabel => 'Activity';

  @override
  String get catDetailBodyLabel => 'Body condition';

  @override
  String get catDetailStatusLabel => 'Status';

  @override
  String get catDetailStatusNeutered => 'Neutered / Spayed';

  @override
  String get catDetailStatusSpayed => 'Spayed';

  @override
  String get catDetailDetailsSection => 'Details';

  @override
  String get catDetailActivityModerate => 'Moderate';

  @override
  String get catDetailBodyNormal => 'Normal';

  @override
  String get catDetailCoatMedium => 'Medium hair';

  @override
  String get catDetailHealthConditionsSection => 'Health conditions';

  @override
  String get catDetailDeleteProfile => 'Delete profile';

  @override
  String get catListingTitle => 'Your cats';

  @override
  String get catListingErrorGeneric => 'Something went wrong';

  @override
  String get catListingEmptyHeadline => 'No cats yet';

  @override
  String get catListingEmptyBody =>
      'Add your first cat to get personalized recommendations';

  @override
  String get catListingEmptyCta => 'Add your cat';

  @override
  String get catListingAddAnotherCat => 'Add another cat';

  @override
  String get catListingCreateNewProfile => 'Create a new profile';

  @override
  String get catListingCatFallback => 'Cat';

  @override
  String catListingConditionsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conditions',
      one: '1 condition',
    );
    return '$_temp0';
  }
}
