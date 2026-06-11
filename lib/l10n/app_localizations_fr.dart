// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get commonNext => 'Suivant';

  @override
  String get commonGotIt => 'Compris';

  @override
  String get commonSkip => 'Passer';

  @override
  String get catNameQuestion => 'Comment s\'appelle ton chat ?';

  @override
  String get catNameLabel => 'Nomme ton chat';

  @override
  String get catNameHint => 'Caramel';

  @override
  String get catNameValidationEmpty => 'Saisis un nom pour ton chat';

  @override
  String get genderQuestion => 'Quel est le sexe de ton chat ?';

  @override
  String get genderFemale => 'Femelle';

  @override
  String get genderMale => 'Mâle';

  @override
  String get photoQuestion => 'Ajoute une photo de ton chat';

  @override
  String get photoSheetTitle => 'Ajouter une photo';

  @override
  String get photoSheetTakePhoto => 'Prendre une photo';

  @override
  String get photoSheetUploadLibrary => 'Importer depuis la galerie';

  @override
  String get photoCameraError =>
      'Impossible d\'accéder à l\'appareil photo. Vérifie les autorisations dans Réglages.';

  @override
  String get photoLibraryError =>
      'Impossible d\'ouvrir tes photos. Vérifie les autorisations dans Réglages.';

  @override
  String get ageQuestion => 'Quel âge a ton chat ?';

  @override
  String get ageColumnYears => 'Ans';

  @override
  String get ageColumnMonths => 'Mois';

  @override
  String get ageUnitYear => 'an';

  @override
  String get ageUnitMonth => 'mo';

  @override
  String ageStageKitten(String years) {
    return 'Environ $years ans — un chaton.';
  }

  @override
  String ageStageAdult(String years) {
    return 'Environ $years ans — un adulte.';
  }

  @override
  String ageStageSenior(String years) {
    return 'Environ $years ans — un senior.';
  }

  @override
  String get bodyConditionQuestion => 'Quelle est la corpulence de ton chat ?';

  @override
  String get bodyUnderweightLabel => 'Sous-poids';

  @override
  String get bodyUnderweightDesc =>
      'Côtes et colonne saillantes, très peu de graisse';

  @override
  String get bodyNormalLabel => 'Parfait';

  @override
  String get bodyNormalDesc => 'Côtes facilement palpables, taille visible';

  @override
  String get bodyOverweightLabel => 'Surpoids';

  @override
  String get bodyOverweightDesc => 'Côtes difficiles à sentir, ventre arrondi';

  @override
  String get bodyObeseLabel => 'Obèse';

  @override
  String get bodyObeseDesc => 'Couverture graisseuse importante, pas de taille';

  @override
  String get activityQuestion => 'Ton chat est-il actif ?';

  @override
  String get activityLowLabel => 'Faible';

  @override
  String get activityLowDesc => 'Dort surtout, chasse rarement';

  @override
  String get activityMediumLabel => 'Moyen';

  @override
  String get activityMediumDesc => 'Joue quelques fois par jour';

  @override
  String get activityHighLabel => 'Élevé';

  @override
  String get activityHighDesc => 'Grimpe, court et chasse les jouets';

  @override
  String get waterFactHeadline =>
      'L\'hydratation protège les reins et la santé urinaire de ton chat';

  @override
  String get waterFactHighlight => 'les reins et la santé urinaire';

  @override
  String get waterFactBody =>
      'Les aliments riches en eau réduisent les risques de problèmes urinaires et rénaux — nous prenons en compte l\'hydratation dans chaque évaluation.';

  @override
  String get neuteredQuestion => 'Ton chat est-il castré ou stérilisé ?';

  @override
  String get neuteredIntact => 'Entier';

  @override
  String get neuteredNeutered => 'Castré / Stérilisé';

  @override
  String get neuteredPregnant => 'Gestante';

  @override
  String get neuteredLactating => 'Allaitante';

  @override
  String get coatQuestion => 'Quel type de pelage ?';

  @override
  String get coatShortHair => 'Poil court';

  @override
  String get coatLongHair => 'Poil long';

  @override
  String get coatHairless => 'Sans poil';

  @override
  String get coatFactHeadline =>
      'Les chats à poil long ont besoin\nde plus d\'oméga-3';

  @override
  String get coatFactHighlight => 'plus d\'oméga-3';

  @override
  String get coatFactBody =>
      'L\'oméga-3 garde leur pelage brillant et leur peau en bonne santé.';

  @override
  String get healthQuestion => 'Des problèmes de santé particuliers ?';

  @override
  String get healthNone => 'Aucun';

  @override
  String get healthUrinaryIssues => 'Problèmes urinaires';

  @override
  String get healthKidneyDisease => 'Maladie rénale';

  @override
  String get healthSensitiveStomach => 'Estomac sensible';

  @override
  String get healthSkinAllergies => 'Allergies cutanées';

  @override
  String get healthFoodAllergies => 'Allergies alimentaires';

  @override
  String get healthDiabetes => 'Diabète';

  @override
  String get healthDentalProblems => 'Problèmes dentaires';

  @override
  String get healthHairballIssues => 'Boules de poil';

  @override
  String get healthHeartCondition => 'Problème cardiaque';

  @override
  String get healthJointIssues => 'Problèmes articulaires ou de mobilité';

  @override
  String get breedQuestion => 'Quelle race est ton chat ?';

  @override
  String get breedUnknownPrefix => 'Tu ne connais pas la race ? ';

  @override
  String get breedMixedUnknown => 'Croisé / inconnu';

  @override
  String get disclaimerTitle => 'On guide, on ne prescrit pas';

  @override
  String get disclaimerBody1 =>
      'YuCat suggère des aliments selon le profil de ton chat et les ingrédients que nous lisons sur chaque produit. Ce n\'est pas un substitut à l\'avis d\'un vétérinaire.';

  @override
  String get disclaimerBody2 =>
      'En cas de pathologie diagnostiquée ou de changement soudain de poids, d\'appétit ou de comportement, consulte un vétérinaire.';

  @override
  String get catCreateCtaCreateProfile => 'Créer le profil';

  @override
  String get catCreateCtaSaveChanges => 'Enregistrer les modifications';

  @override
  String get catCreateCtaNoneOfThese => 'Aucune de ces options';

  @override
  String get catCreateErrorCreate => 'Impossible de créer le profil. Réessaie.';

  @override
  String get catCreateErrorSave =>
      'Impossible d\'enregistrer les modifications. Réessaie.';

  @override
  String get onboardingWelcomeHeadline => 'Décode\nchaque\naliment\npour chat';

  @override
  String get onboardingGetStarted => 'Commencer';

  @override
  String get onboardingLegalPrefix => 'En continuant, tu acceptes nos\n';

  @override
  String get onboardingTermsOfUse => 'Conditions d\'utilisation';

  @override
  String get onboardingLegalAnd => ' et ';

  @override
  String get onboardingPrivacyNotice => 'Politique de confidentialité';

  @override
  String get onboardingWhyYucatTitle =>
      'Pourquoi l\'approche\nunique de YuCat\nfonctionne';

  @override
  String get onboardingLetsGo => 'C\'est parti !';

  @override
  String get onboardingHealthIntroTitle =>
      'Maintenant, parle-nous\nde la santé\nde ton chat';

  @override
  String get onboardingCouldNotOpenLink => 'Impossible d\'ouvrir ce lien.';

  @override
  String get onboardingNutritionFactHeadlinePart1 => 'Un chaton a besoin\n';

  @override
  String get onboardingNutritionFactHighlight => '2,5× plus de protéines';

  @override
  String get onboardingNutritionFactHeadlinePart2 => '\nqu\'un chat senior';

  @override
  String get onboardingNutritionFactBody =>
      'L\'étape de vie, le poids, l\'activité et l\'état de santé influencent ce que doit contenir la gamelle de ton chat.';

  @override
  String get onboardingMerckManualName => 'Manuel vétérinaire Merck ';

  @override
  String get onboardingMerckManualQuote =>
      'note que les besoins en protéines et en acides aminés d\'un chat évoluent selon son stade de vie — les chatons ont besoin de plus de protéines que les adultes et sont plus sensibles à l\'équilibre en acides aminés.';

  @override
  String get onboardingSourceLink => 'Source des recommandations';

  @override
  String get onboardingScanDemoTitle => 'Suis\nce qu\'il y a dedans';

  @override
  String get onboardingScanDemoSubtitle =>
      'Pointe ta caméra sur n\'importe quel\naliment pour chat et obtiens un verdict';

  @override
  String get onboardingProfileIntroTitle =>
      'Configurons\nle profil de ton chat';

  @override
  String get onboardingProfileIntroTime => '2 min';

  @override
  String get onboardingProfileIntroQuote =>
      'Un profil rapide débloque des verdicts personnalisés sur chaque paquet';

  @override
  String get onboardingProfileNameLabel => 'Nomme ton chat';

  @override
  String get onboardingProfileNameHint => 'Mochi';

  @override
  String get onboardingProofChartTitle => 'YuCat offre\ndes résultats durables';

  @override
  String get onboardingProofChartCalloutBold => 'Un aliment mieux adapté ';

  @override
  String get onboardingProofChartCalloutRest =>
      'aux besoins de ton chat, en quelques scans';

  @override
  String get onboardingRatingEyebrow => 'Aide-nous à grandir';

  @override
  String get onboardingRatingTitle => 'Note-nous';

  @override
  String get onboardingRatingStatValue => 'Adoré';

  @override
  String get onboardingRatingStatLabel => 'par les propriétaires de chats';

  @override
  String get onboardingRatingPeopleLabel =>
      'Des propriétaires de chats comme toi';

  @override
  String get onboardingReview1Headline => 'Exactement ce qu\'il me fallait !';

  @override
  String get onboardingReview1Body =>
      'J\'ai scanné les croquettes de mon chat et j\'ai enfin compris ce qu\'elles contenaient. J\'ai changé de marque la même semaine et je ne l\'ai jamais regretté.';

  @override
  String get onboardingReview2Headline => 'J\'adore cette appli !!!';

  @override
  String get onboardingReview2Body =>
      'Une appli incroyable, tellement facile à utiliser. Je télécharge juste des photos de la nourriture et ça m\'explique tout !';

  @override
  String get onboardingReview3Headline => 'Un sauveur pour les chats âgés';

  @override
  String get onboardingReview3Body =>
      'YuCat a trouvé une nourriture senior douce pour l\'estomac de Lulu en une après-midi.';

  @override
  String get onboardingReview4Headline => 'Enfin sereine';

  @override
  String get onboardingReview4Body =>
      'Avant, j\'achetais ce qui était en promo. Maintenant je sais quels aliments correspondent aux besoins de mon chaton. Une vraie tranquillité d\'esprit.';

  @override
  String get onboardingReview5Headline => 'Si simple à utiliser';

  @override
  String get onboardingReview5Body =>
      'Tu prends une photo et tu obtiens une analyse claire en quelques secondes. Ma véto était même impressionnée quand je lui ai montré.';

  @override
  String get onboardingReview6Headline => 'Deux chats, deux régimes';

  @override
  String get onboardingReview6Body =>
      'Gérer l\'alimentation d\'un chat tigré en surpoids et d\'un Siamois difficile était un cauchemar. YuCat a tout simplifié pour les deux.';

  @override
  String get onboardingAttributionTitle =>
      'Comment as-tu entendu\nparler de nous ?';

  @override
  String get onboardingAttributionInstagram => 'Instagram';

  @override
  String get onboardingAttributionTikTok => 'TikTok';

  @override
  String get onboardingAttributionYouTube => 'YouTube';

  @override
  String get onboardingAttributionAppStore => 'Recherche sur l\'App Store';

  @override
  String get onboardingAttributionFriends => 'Amis/famille';

  @override
  String get onboardingNotifPrimerTitle =>
      'On surveille\nla nourriture de ton chat';

  @override
  String get onboardingSetUpReminders => 'Configurer les rappels';

  @override
  String get onboardingNotifMatchDropped => 'Compatibilité réduite';

  @override
  String get onboardingNotifMockBody =>
      'La nourriture de Luna a changé de recette — voir le nouveau verdict 🔍';

  @override
  String get onboardingRemindersTitle => 'Sur quoi doit-on\nte notifier ?';

  @override
  String get commonDone => 'Terminé';

  @override
  String get onboardingSetUpLater => 'Configurer plus tard';

  @override
  String get onboardingRemindersOptionFoodChange =>
      'Quand un aliment enregistré change';

  @override
  String get onboardingRemindersOptionBetterFit =>
      'Quand un meilleur aliment est trouvé';

  @override
  String get onboardingRemindersOptionMonthly => 'Bilan mensuel';

  @override
  String get onboardingRemindersCalloutPart1 =>
      'Les rappels créent de bonnes habitudes alimentaires ';

  @override
  String get onboardingRemindersCalloutBold => '2× plus vite';

  @override
  String onboardingSuccessWithName(String name) {
    return '$name est\nprêt !';
  }

  @override
  String get onboardingSuccessNoName => 'Tout est\nprêt !';

  @override
  String get onboardingStartScanning => 'Commencer à scanner';

  @override
  String get onboardingSuccessNotSet => 'Non renseigné';

  @override
  String get onboardingSuccessNone => 'Aucun';

  @override
  String get onboardingSuccessRowAge => 'Âge';

  @override
  String get onboardingSuccessRowActivity => 'Activité';

  @override
  String get onboardingSuccessRowBodyCondition => 'Condition corporelle';

  @override
  String get onboardingSuccessRowCoat => 'Pelage';

  @override
  String get onboardingSuccessRowNeuterStatus => 'Statut de castration';

  @override
  String get onboardingSuccessRowBreed => 'Race';

  @override
  String get onboardingSuccessRowHealthConditions => 'Conditions de santé';

  @override
  String get onboardingSuccessProfileReadyTitle => 'Profil prêt';

  @override
  String get onboardingSuccessProfileReadyBody =>
      'Tu peux modifier ces informations à tout moment dans le profil de ton chat.';

  @override
  String get paywallHeroHeadline =>
      'Sache exactement\nce qu\'il y a dans son bol';

  @override
  String get paywallHeroHighlight => 'exactement';

  @override
  String get paywallPlusBadge => 'Plus';

  @override
  String get paywallBadgeBestValue => 'MEILLEURE OFFRE';

  @override
  String get paywallLimitedTimeOffer => 'Offre limitée';

  @override
  String paywallLimitedTimeOfferWithSavings(String savings) {
    return 'Offre limitée · $savings';
  }

  @override
  String get paywallEverythingYouGet => 'Tout ce que tu obtiens';

  @override
  String get paywallFeatureIngredientScannerTitle => 'Scanner d\'ingrédients';

  @override
  String get paywallFeatureIngredientScannerBenefit =>
      'Scanne n\'importe quelle étiquette en quelques secondes';

  @override
  String get paywallFeaturePersonalizedVerdictsTitle =>
      'Verdicts personnalisés';

  @override
  String get paywallFeaturePersonalizedVerdictsBenefit =>
      'Adaptés à l\'âge, la race et la santé de ton chat';

  @override
  String get paywallFeatureUnlimitedScansTitle => 'Scans illimités';

  @override
  String get paywallFeatureUnlimitedScansBenefit =>
      'Aucune limite quotidienne, jamais';

  @override
  String get paywallFeatureReformulationAlertsTitle =>
      'Alertes de reformulation';

  @override
  String get paywallFeatureReformulationAlertsBenefit =>
      'Sois averti dès qu\'une recette change';

  @override
  String get paywallFeatureSavedFoodsTitle =>
      'Aliments enregistrés & historique';

  @override
  String get paywallFeatureSavedFoodsBenefit =>
      'Chaque aliment que tu as vérifié, en un seul endroit';

  @override
  String get paywallFeatureMultiCatTitle => 'Profils multi-chats';

  @override
  String get paywallFeatureMultiCatBenefit =>
      'Un profil personnalisé pour chacun de tes chats';

  @override
  String get paywallSuccessStoriesHeading =>
      'Témoignages\nde propriétaires de chats';

  @override
  String get paywallTestimonial1Quote =>
      'J\'avais deviné pendant des années. YuCat a trouvé une nourriture senior douce pour l\'estomac de Lulu en une après-midi.';

  @override
  String get paywallTestimonial1Name => 'Sophie';

  @override
  String get paywallTestimonial1Detail => 'Chat senior · estomac sensible';

  @override
  String get paywallTestimonial2Quote =>
      'J\'ai scanné les croquettes de notre chaton et j\'ai enfin compris ce qu\'elles contenaient. J\'ai changé de marque la même semaine.';

  @override
  String get paywallTestimonial2Name => 'Marco';

  @override
  String get paywallTestimonial2Detail => 'Chaton · difficile à nourrir';

  @override
  String get paywallTestimonial3Quote =>
      'Deux chats, deux besoins très différents. Maintenant je sais quel aliment convient vraiment à chacun.';

  @override
  String get paywallTestimonial3Name => 'Priya';

  @override
  String get paywallTestimonial3Detail => 'Foyer avec plusieurs chats';

  @override
  String get paywallStatRatingLabel => 'note\nmoyenne';

  @override
  String get paywallStatCatParentsLabel =>
      'propriétaires de chats\ndans le monde';

  @override
  String get paywallCancelAnytime => 'Annule à tout moment.';

  @override
  String get paywallAutoRenewDisclosure =>
      'Ton abonnement se renouvelle automatiquement sauf annulation au moins 24 heures avant la fin de la période en cours. Annule à tout moment sur l\'App Store sans frais supplémentaires.';

  @override
  String get paywallRestorePurchases => 'Restaurer les achats';

  @override
  String get commonTerms => 'Conditions';

  @override
  String get commonPrivacy => 'Confidentialité';

  @override
  String get commonClose => 'Fermer';

  @override
  String get paywallPeriodAnnual => 'Annuel';

  @override
  String get paywallPeriod6Months => '6 mois';

  @override
  String get paywallPeriod3Months => '3 mois';

  @override
  String get paywallPeriod2Months => '2 mois';

  @override
  String get paywallPeriodMonthly => 'Mensuel';

  @override
  String get paywallPeriodWeekly => 'Hebdomadaire';

  @override
  String get paywallPeriodLifetime => 'À vie';

  @override
  String get paywallCtaUnlockPlus => 'Débloquer Yucat Plus';

  @override
  String get paywallSkipDebug => 'Passer le paywall (debug)';

  @override
  String get paywallErroriOSOnly =>
      'Les abonnements sont disponibles uniquement sur iOS.';

  @override
  String get paywallErrorCouldNotLoadPlans =>
      'Impossible de charger les offres.';

  @override
  String get paywallErrorNoPlansAvailable =>
      'Aucun plan d\'abonnement disponible pour l\'instant.';

  @override
  String get paywallErrorPurchaseNotComplete =>
      'L\'achat n\'a pas abouti. Réessaie.';

  @override
  String get paywallErrorPurchaseFailed => 'L\'achat a échoué. Réessaie.';

  @override
  String get paywallErrorSomethingWentWrong =>
      'Une erreur est survenue. Réessaie.';

  @override
  String get paywallErrorNoActiveSubscription =>
      'Aucun abonnement actif trouvé.';

  @override
  String get paywallErrorRestoreFailed =>
      'Impossible de restaurer les achats. Réessaie.';

  @override
  String get commonGoBack => 'Retour';

  @override
  String get productDetailLoadError => 'Impossible de charger ce produit.';

  @override
  String get productDetailOverallAnalysis => 'ANALYSE GÉNÉRALE';

  @override
  String get productDetailAiIdentifiedPill => '* IDENTIFIÉ PAR IA';

  @override
  String get productDetailMyCatScore => 'Score de mon chat';

  @override
  String get productDetailNoCatPrompt =>
      'Crée un profil pour ton chat pour voir un score personnalisé.';

  @override
  String get productDetailAddACat => 'Ajouter un chat';

  @override
  String get productDetailForYourCats => 'Pour tes chats';

  @override
  String productDetailCatsCount(int count) {
    return '$count CHATS';
  }

  @override
  String get productDetailPickACat =>
      'Choisis un chat pour voir comment ce produit correspond à son profil.';

  @override
  String get productDetailPersonalizedScore =>
      'Score personnalisé basé sur le profil de ton chat.';

  @override
  String get productDetailDimHealth => 'SANTÉ';

  @override
  String get productDetailDimWeight => 'POIDS';

  @override
  String get productDetailDimAge => 'ÂGE';

  @override
  String get productDetailDimActivity => 'ACTIVITÉ';

  @override
  String get productDetailDimNeuteredStatus => 'STATUT DE CASTRATION';

  @override
  String get productDetailDimBreed => 'RACE';

  @override
  String get productDetailNeutralFit =>
      'Aucune correspondance forte pour ce chat — résultat neutre.';

  @override
  String get productDetailAgeGroupKitten => 'Chaton';

  @override
  String get productDetailAgeGroupAdult => 'Adulte';

  @override
  String get productDetailAgeGroupSenior => 'Senior';

  @override
  String get productDetailNutrientProtein => 'Protéines';

  @override
  String get productDetailNutrientFat => 'Lipides';

  @override
  String get productDetailNutrientMoisture => 'Humidité';

  @override
  String get productDetailNutrientFiber => 'Fibres';

  @override
  String get productDetailNutrientCarbs => 'Glucides';

  @override
  String get productDetailVerdictExcellent => 'Un excellent choix au quotidien';

  @override
  String get productDetailVerdictGood => 'Un bon choix au quotidien';

  @override
  String get productDetailVerdictAverage => 'Un choix acceptable';

  @override
  String get productDetailVerdictPoor => 'Mieux vaut éviter celui-ci';

  @override
  String get productDetailImagePlaceholder => 'PRODUIT';

  @override
  String productDetailScoreSemantics(int score, int maxScore) {
    return 'Score $score sur $maxScore';
  }

  @override
  String get assessmentKittenHighProtein =>
      'Riche en protéines (>35 %), bénéfique pour les chatons';

  @override
  String get assessmentKittenHighFat =>
      'Riche en graisses (>18 %), favorise la croissance du chaton';

  @override
  String get assessmentKittenSeniorFormula =>
      'La formule pour senior n\'est pas idéale pour les chatons';

  @override
  String get assessmentKittenLowProtein =>
      'Faible en protéines (<28 %), peut ne pas répondre aux besoins du chaton';

  @override
  String get assessmentSeniorModerateProtein =>
      'Protéines modérées (30–35 %), appropriées pour les seniors';

  @override
  String get assessmentSeniorHighFat =>
      'Très riche en graisses (>20 %), peut être peu adapté aux seniors';

  @override
  String get assessmentSeniorJointSupport =>
      'Contient des ingrédients pour le soutien articulaire (ex. glucosamine, chondroïtine)';

  @override
  String get assessmentSeniorKidneyFriendly =>
      'Formulation douce pour les reins (ex. faible en phosphore)';

  @override
  String get assessmentUnderweightHighCalories =>
      'Riche en calories (>380 kcal/100g), peut aider un chat sous-poids à prendre du poids';

  @override
  String get assessmentUnderweightHighFat =>
      'Riche en graisses (>18 %), favorise la prise de poids chez les chats sous-poids';

  @override
  String get assessmentOverweightHighCalories =>
      'Riche en calories (>360 kcal/100g), peut ne pas convenir à un chat en surpoids';

  @override
  String get assessmentOverweightLowCalories =>
      'Moins de calories (<320 kcal/100g), aide à gérer le poids des chats en surpoids';

  @override
  String get assessmentOverweightHighFiber =>
      'Plus de fibres (>4 %), peut aider à la satiété pour les chats en surpoids';

  @override
  String get assessmentObeseHighFat =>
      'Riche en graisses (>15 %), ne convient pas aux chats obèses';

  @override
  String get assessmentObeseHighCalories =>
      'Riche en calories (>330 kcal/100g), peu adapté aux chats obèses';

  @override
  String get assessmentObeseLeanProtein =>
      'Formule légère et riche en protéines (>40 % protéines, <12 % graisses), bon pour les chats obèses';

  @override
  String get assessmentLowActivityHighCalories =>
      'Riche en calories (>360 kcal/100g), peut ne pas convenir à un chat peu actif';

  @override
  String get assessmentLowActivityModerateCalories =>
      'Calories modérées (<330 kcal/100g), mieux pour les chats peu actifs';

  @override
  String get assessmentHighActivityHighCalories =>
      'Plus de calories (>380 kcal/100g), soutient un chat très actif';

  @override
  String get assessmentHighActivityHighProtein =>
      'Riche en protéines (>35 %), aide à maintenir la masse musculaire des chats actifs';

  @override
  String get assessmentNeuteredHighCalories =>
      'Aliment très calorique (>380 kcal/100g), peut favoriser la prise de poids chez les chats castrés';

  @override
  String get assessmentNeuteredUrinarySupport =>
      'Contient des ingrédients pour le soutien urinaire, bon pour les chats castrés';

  @override
  String get assessmentNeuteredHighFat =>
      'Riche en graisses (>16 %), peut ne pas être idéal pour les chats castrés';

  @override
  String get assessmentPregnantHighProtein =>
      'Très riche en protéines (>35 %), couvre les besoins accrus des chattes gestantes/allaitantes';

  @override
  String get assessmentPregnantHighFat =>
      'Riche en graisses (>20 %), apporte de l\'énergie supplémentaire aux chattes gestantes/allaitantes';

  @override
  String get assessmentPregnantHighCalories =>
      'Aliment très calorique (>400 kcal/100g), aide à répondre aux besoins énergétiques durant la gestation/l\'allaitement';

  @override
  String get assessmentMaineCoonJointSupport =>
      'Contient des ingrédients pour le soutien articulaire, utile pour les Maine Coon';

  @override
  String get assessmentMaineCoonHighProtein =>
      'Riche en protéines (>35 %), soutient les Maine Coon de grande taille';

  @override
  String get assessmentPersianHairball =>
      'Formule type contrôle des boules de poil (fibres 4–6 % ou allégations anti-boules de poil)';

  @override
  String get assessmentPersianOmega3 =>
      'Contient des ingrédients riches en oméga-3, bon pour le pelage et la peau du Persan';

  @override
  String get assessmentPersianHighCarbs =>
      'Riche en glucides (>30 %), peut ne pas être idéal pour les Persans';

  @override
  String get assessmentSiameseDigestible =>
      'Utilise des protéines facilement digestibles, bonnes pour les chats Siamois';

  @override
  String get assessmentSiameseFillers =>
      'Contient de nombreuses charges (maïs, blé, soja) qui peuvent ne pas convenir aux chats Siamois';

  @override
  String get assessmentSphynxHighFat =>
      'Plus de graisses (>18 %), peut favoriser la santé cutanée du Sphynx';

  @override
  String get assessmentSphynxLowFat =>
      'Formule pauvre en graisses (<12 %), peut ne pas offrir suffisamment de soutien à la peau du Sphynx';

  @override
  String get assessmentBritishHighCalories =>
      'Un aliment riche en calories peut favoriser la prise de poids chez les British Shorthair';

  @override
  String get assessmentBritishWeightManagement =>
      'Une formule type gestion du poids convient aux British Shorthair';

  @override
  String get assessmentBengalHighProtein =>
      'Riche en protéines (>38 %), correspond aux besoins énergétiques du Bengal';

  @override
  String get assessmentBengalLowProtein =>
      'Faible en protéines (<30 %), peut être insuffisant pour les Bengals';

  @override
  String get assessmentUrinaryLowAsh =>
      'Formulé avec une faible teneur en cendres, favorable aux problèmes urinaires';

  @override
  String get assessmentUrinarySupport =>
      'Contient des ingrédients de soutien urinaire comme la canneberge ou la DL-méthionine';

  @override
  String get assessmentUrinaryHighMinerals =>
      'Une teneur élevée en minéraux peut ne pas être idéale en cas de problèmes urinaires';

  @override
  String get assessmentKidneyHighProtein =>
      'Riche en protéines (>32 %), peut ne pas être idéal en cas de maladie rénale';

  @override
  String get assessmentKidneyPhosphorus =>
      'Contient des sources de phosphore pouvant être problématiques en cas de maladie rénale';

  @override
  String get assessmentKidneyRenalSupport =>
      'Formulé comme régime de soutien rénal';

  @override
  String get assessmentSensitiveStomachLimitedIngredient =>
      'Une recette à ingrédients limités peut aider les estomacs sensibles';

  @override
  String get assessmentSensitiveStomachLongIngredients =>
      'Une liste d\'ingrédients très longue peut ne pas convenir aux estomacs sensibles';

  @override
  String get assessmentFoodAllergyCommonAllergens =>
      'Contient des allergènes courants comme le poulet, le poisson ou le bœuf';

  @override
  String get assessmentFoodAllergyNovelProteins =>
      'Utilise des protéines originales (ex. canard, chevreuil) pouvant aider en cas d\'allergies';

  @override
  String get assessmentSkinAllergyOmega3 =>
      'Une formulation riche en oméga-3 peut soutenir la santé de la peau et du pelage';

  @override
  String get assessmentSkinAllergyArtificialColor =>
      'Contient des colorants artificiels pouvant aggraver les allergies cutanées';

  @override
  String get assessmentDiabetesHighCarbs =>
      'Riche en glucides (>20 %), moins adapté aux chats diabétiques';

  @override
  String get assessmentDiabetesHighProtein =>
      'Très riche en protéines (>40 %), peut aider au contrôle de la glycémie en cas de diabète';

  @override
  String get assessmentDentalHighMoisture =>
      'Un aliment riche en eau (type humide) est plus facile à manger en cas de problèmes dentaires';

  @override
  String get assessmentDentalLargeKibble =>
      'Des croquettes très grandes peuvent être difficiles à mâcher en cas de problèmes dentaires';

  @override
  String get assessmentHairballControl =>
      'Régime type contrôle des boules de poil (fibres 4–6 % ou allégations anti-boules de poil)';

  @override
  String get homeScanProduct => 'Scanner un produit';

  @override
  String get homeScanProductSubtitle => 'Photographier l\'emballage';

  @override
  String get homeGreetingHey => 'Salut 👋';

  @override
  String get homeGreetingWelcome => 'Bienvenue';

  @override
  String homeReadyForCat(String name) {
    return 'Prêt à trouver de la nourriture pour $name ?';
  }

  @override
  String get homeReadyToScan => 'Prêt à scanner un produit ?';

  @override
  String get homeAddCatTitle => 'Ajoute ton chat';

  @override
  String get homeAddCatBody =>
      'Crée un profil pour obtenir des scores personnalisés.';

  @override
  String get homeAddCatButton => 'Ajouter un chat';

  @override
  String get homeSavedProductsTitle => 'Produits enregistrés';

  @override
  String get homeSeeAll => 'Voir tout';

  @override
  String get homeNoSavedProductsTitle => 'Aucun produit enregistré';

  @override
  String get homeNoSavedProductsBody =>
      'Appuie sur le signet d\'un produit pour l\'enregistrer ici.';

  @override
  String get homeLoadingStepScanning => 'Scan en cours';

  @override
  String get homeLoadingStepScanningDesc => 'Identification du produit...';

  @override
  String get homeLoadingStepFetching => 'Récupération des données';

  @override
  String get homeLoadingStepFetchingDesc => 'Chargement des informations...';

  @override
  String get homeLoadingStepAnalyzing => 'Analyse des ingrédients';

  @override
  String get homeLoadingStepAnalyzingDesc =>
      'Traitement des données nutritionnelles...';

  @override
  String get homeLoadingStepPreparing => 'Préparation des résultats';

  @override
  String get homeLoadingStepPreparingDesc => 'Presque prêt...';

  @override
  String get homeLoadingStepDone => 'Terminé';

  @override
  String get homeCameraUnavailable => 'Appareil photo indisponible';

  @override
  String get homeCameraUnavailableBody =>
      'Active l\'accès à l\'appareil photo pour YuCat dans Réglages, ou choisis une photo depuis ta galerie.';

  @override
  String get homeChooseFromGallery => 'Choisir depuis la galerie';

  @override
  String get homeErrorProductNotFound => 'Produit introuvable';

  @override
  String get homeErrorTimeout => 'La requête a pris trop de temps. Réessaie.';

  @override
  String get homeErrorNoInternet =>
      'Pas de connexion Internet. Vérifie ta connexion et réessaie.';

  @override
  String get homeErrorGeneric => 'Une erreur est survenue. Réessaie.';

  @override
  String get homeCatKitten => 'Chaton';

  @override
  String get homeCatAdult => 'Adulte';

  @override
  String get homeCatSenior => 'Senior';

  @override
  String get homeCatUnderweight => 'Sous-poids';

  @override
  String get homeCatHealthyWeight => 'Poids sain';

  @override
  String get homeCatOverweight => 'Surpoids';

  @override
  String get homeCatObese => 'Obèse';

  @override
  String homeCatConditionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count affections',
      one: '1 affection',
    );
    return '$_temp0';
  }

  @override
  String get scanHistoryTitle => 'Historique des scans';

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
  String get scanHistoryEmptyTitle => 'Aucun scan pour l\'instant';

  @override
  String get scanHistoryEmptyBody =>
      'Les aliments que tu scanneras apparaîtront ici.';

  @override
  String get commonTryAgain => 'Réessayer';

  @override
  String get searchTabTitle => 'Recherche';

  @override
  String get searchHint => 'Rechercher un aliment pour chat';

  @override
  String get searchRecentLabel => 'Récents';

  @override
  String get searchClearLabel => 'Effacer';

  @override
  String get searchPopularBrands => 'Marques populaires';

  @override
  String get searchNoMatchesHeadline => 'Aucun résultat';

  @override
  String get searchNoMatchesBody =>
      'Essaie un autre nom, ou explore les marques populaires.';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
    );
    return '$_temp0';
  }

  @override
  String get searchErrorBody => 'Une erreur est survenue lors de la recherche.';

  @override
  String get bottomNavSearch => 'Recherche';

  @override
  String get bottomNavHome => 'Accueil';

  @override
  String get bottomNavProfile => 'Profil';

  @override
  String get productListingEmpty => 'Aucun produit trouvé pour cette marque.';

  @override
  String get commonAgeGroupKitten => 'Chaton';

  @override
  String get commonAgeGroupAdult => 'Adulte';

  @override
  String get commonAgeGroupSenior => 'Senior';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileLinkError => 'Impossible d\'ouvrir ce lien.';

  @override
  String get profileSubscriptionLinkError =>
      'Impossible d\'ouvrir les abonnements App Store.';

  @override
  String profileEmailError(String email) {
    return 'Impossible d\'ouvrir $email.';
  }

  @override
  String get profilePrivacyError =>
      'Impossible d\'ouvrir la politique de confidentialité.';

  @override
  String get profileTermsError =>
      'Impossible d\'ouvrir les conditions générales.';

  @override
  String get profileSubscriptionActive => 'Abonnement actif';

  @override
  String get profileRestorePurchases => 'Restaurer les achats';

  @override
  String get profileManageSubscription => 'Gérer l\'abonnement';

  @override
  String get profileYourCats => 'Tes chats';

  @override
  String get profileManage => 'Gérer';

  @override
  String get profileAddCat => 'Ajouter un chat';

  @override
  String get profileSavedProductsLabel => 'Produits enregistrés';

  @override
  String get profileSavedProductsEmpty => 'Aucun produit enregistré';

  @override
  String profileSavedProductsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produits enregistrés',
      one: '1 produit enregistré',
    );
    return '$_temp0';
  }

  @override
  String get profileScanHistoryLabel => 'Historique des scans';

  @override
  String get profileScanHistoryEmpty => 'Aucun scan pour l\'instant';

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
  String get profileContactUs => 'Nous contacter';

  @override
  String get profilePrivacyPolicy => 'Politique de confidentialité';

  @override
  String get profileTermsAndConditions => 'Conditions générales';

  @override
  String get profileResetOnboarding => 'Réinitialiser l\'introduction';

  @override
  String get profileDebugOnly => 'Débogage uniquement';

  @override
  String get profileRestoreNotAvailable =>
      'La restauration est disponible uniquement sur iOS.';

  @override
  String get profileRestoreSuccess => 'Abonnement restauré avec succès !';

  @override
  String get profileNoSubscriptionFound => 'Aucun abonnement actif trouvé.';

  @override
  String get profileRestoreError =>
      'Impossible de restaurer tes achats. Réessaie.';

  @override
  String get savedProductsTitle => 'Produits enregistrés';

  @override
  String savedProductsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produits',
      one: '1 produit',
    );
    return '$_temp0';
  }

  @override
  String get savedProductsEmptyHeadline => 'Aucun produit enregistré';

  @override
  String get savedProductsEmptyBody =>
      'Mets des produits en favori pour les retrouver ici';

  @override
  String get catDetailDeleteError =>
      'Impossible de supprimer ton chat. Réessaie.';

  @override
  String catDetailDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get catDetailDeleteBody =>
      'Cela supprimera définitivement son profil.';

  @override
  String get catDetailDeleteCancel => 'Annuler';

  @override
  String get catDetailDeleteConfirm => 'Supprimer';

  @override
  String get catDetailProfileCompletion => 'Complétion du profil';

  @override
  String get catDetailNotSet => 'Non renseigné';

  @override
  String get catDetailBreedLabel => 'Race';

  @override
  String get catDetailAgeLabel => 'Âge';

  @override
  String get catDetailAgeYears => 'ans';

  @override
  String get catDetailGenderLabel => 'Sexe';

  @override
  String get catDetailCoatLabel => 'Pelage';

  @override
  String get catDetailActivityLabel => 'Activité';

  @override
  String get catDetailBodyLabel => 'Condition corporelle';

  @override
  String get catDetailStatusLabel => 'Statut';

  @override
  String get catDetailStatusNeutered => 'Castré / Stérilisé';

  @override
  String get catDetailStatusSpayed => 'Stérilisée';

  @override
  String get catDetailDetailsSection => 'Détails';

  @override
  String get catDetailActivityModerate => 'Modérée';

  @override
  String get catDetailBodyNormal => 'Normal';

  @override
  String get catDetailCoatMedium => 'Poil mi-long';

  @override
  String get catDetailHealthConditionsSection => 'Problèmes de santé';

  @override
  String get catDetailDeleteProfile => 'Supprimer le profil';

  @override
  String get catListingTitle => 'Tes chats';

  @override
  String get catListingErrorGeneric => 'Une erreur est survenue';

  @override
  String get catListingEmptyHeadline => 'Aucun chat pour l\'instant';

  @override
  String get catListingEmptyBody =>
      'Ajoute ton premier chat pour obtenir des recommandations personnalisées';

  @override
  String get catListingEmptyCta => 'Ajoute ton chat';

  @override
  String get catListingAddAnotherCat => 'Ajouter un autre chat';

  @override
  String get catListingCreateNewProfile => 'Créer un nouveau profil';

  @override
  String get catListingCatFallback => 'Chat';

  @override
  String catListingConditionsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count affections',
      one: '1 affection',
    );
    return '$_temp0';
  }
}
