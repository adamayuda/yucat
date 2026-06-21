// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get commonNext => 'Weiter';

  @override
  String get commonGotIt => 'Verstanden';

  @override
  String get commonSkip => 'Überspringen';

  @override
  String get catNameQuestion => 'Wie heißt deine Katze?';

  @override
  String get catNameLabel => 'Benenne deine Katze';

  @override
  String get catNameHint => 'Karamell';

  @override
  String get catNameValidationEmpty =>
      'Bitte gib einen Namen für die Katze ein';

  @override
  String get genderQuestion => 'Welches Geschlecht hat deine Katze?';

  @override
  String get genderFemale => 'Weiblich';

  @override
  String get genderMale => 'Männlich';

  @override
  String get photoTapHint => 'Hier tippen';

  @override
  String get photoQuestion => 'Füge ein Foto deiner Katze hinzu';

  @override
  String get photoSheetTitle => 'Foto hinzufügen';

  @override
  String get photoSheetTakePhoto => 'Foto aufnehmen';

  @override
  String get photoSheetUploadLibrary => 'Aus der Mediathek hochladen';

  @override
  String get photoCameraError =>
      'Auf die Kamera konnte nicht zugegriffen werden. Prüfe die Berechtigungen in den Einstellungen.';

  @override
  String get photoLibraryError =>
      'Deine Fotos konnten nicht geöffnet werden. Prüfe die Berechtigungen in den Einstellungen.';

  @override
  String get ageQuestion => 'Wie alt ist deine Katze?';

  @override
  String get ageColumnYears => 'Jahre';

  @override
  String get ageColumnMonths => 'Monate';

  @override
  String get ageUnitYear => 'J';

  @override
  String get ageUnitMonth => 'M';

  @override
  String ageStageKitten(String years) {
    return 'Etwa $years Jahre alt — ein Kätzchen.';
  }

  @override
  String ageStageAdult(String years) {
    return 'Etwa $years Jahre alt — erwachsen.';
  }

  @override
  String ageStageSenior(String years) {
    return 'Etwa $years Jahre alt — eine Seniorin.';
  }

  @override
  String get bodyConditionQuestion => 'Welche Figur hat deine Katze?';

  @override
  String get bodyUnderweightLabel => 'Untergewichtig';

  @override
  String get bodyUnderweightDesc =>
      'Rippen und Wirbelsäule sichtbar, sehr wenig Fett';

  @override
  String get bodyNormalLabel => 'Genau richtig';

  @override
  String get bodyNormalDesc => 'Rippen leicht tastbar, sichtbare Taille';

  @override
  String get bodyOverweightLabel => 'Übergewichtig';

  @override
  String get bodyOverweightDesc => 'Rippen schwer tastbar, runder Bauch';

  @override
  String get bodyObeseLabel => 'Fettleibig';

  @override
  String get bodyObeseDesc => 'Dicke Fettschicht, keine Taille';

  @override
  String get activityQuestion => 'Wie aktiv ist deine Katze?';

  @override
  String get activityLowLabel => 'Niedrig';

  @override
  String get activityLowDesc => 'Schläft meistens, jagt selten';

  @override
  String get activityMediumLabel => 'Mittel';

  @override
  String get activityMediumDesc => 'Spielt mehrmals am Tag';

  @override
  String get activityHighLabel => 'Hoch';

  @override
  String get activityHighDesc => 'Klettert, sprintet, jagt Spielzeug';

  @override
  String get waterFactHeadline =>
      'Eine gute Hydration schützt die Nieren und die Harngesundheit deiner Katze';

  @override
  String get waterFactHighlight => 'die Nieren und die Harngesundheit';

  @override
  String get waterFactBody =>
      'Feuchtigkeitsreiches Futter senkt das Risiko von Harnwegs- und Nierenproblemen — wir berücksichtigen die Hydration in jeder Bewertung.';

  @override
  String get neuteredQuestion => 'Ist deine Katze kastriert oder sterilisiert?';

  @override
  String get neuteredIntact => 'Unkastriert';

  @override
  String get neuteredNeutered => 'Kastriert / Sterilisiert';

  @override
  String get neuteredPregnant => 'Trächtig';

  @override
  String get neuteredLactating => 'Säugend';

  @override
  String get coatQuestion => 'Welcher Felltyp?';

  @override
  String get coatShortHair => 'Kurzhaar';

  @override
  String get coatLongHair => 'Langhaar';

  @override
  String get coatHairless => 'Haarlos';

  @override
  String get coatFactHeadline => 'Langhaarkatzen brauchen\nmehr Omega-3';

  @override
  String get coatFactHighlight => 'mehr Omega-3';

  @override
  String get coatFactBody =>
      'Omega-3 hält ihr Fell glänzend und die Haut gesund.';

  @override
  String get coatFactHeadlineShort =>
      'Kurzhaarkatzen profitieren von\nmehr Ballaststoffen';

  @override
  String get coatFactHighlightShort => 'mehr Ballaststoffen';

  @override
  String get coatFactBodyShort =>
      'Ballaststoffe reduzieren Haarballen durch die Fellpflege.';

  @override
  String get coatFactHeadlineHairless => 'Nacktkatzen verbrennen\nmehr Energie';

  @override
  String get coatFactHighlightHairless => 'mehr Energie';

  @override
  String get coatFactBodyHairless =>
      'Ohne Fell brauchen sie mehr Kalorien, um warm zu bleiben.';

  @override
  String get healthQuestion => 'Gibt es gesundheitliche Aspekte?';

  @override
  String get healthNone => 'Keine';

  @override
  String get healthUrinaryIssues => 'Harnwegsprobleme';

  @override
  String get healthKidneyDisease => 'Nierenerkrankung';

  @override
  String get healthSensitiveStomach => 'Empfindlicher Magen';

  @override
  String get healthSkinAllergies => 'Hautallergien';

  @override
  String get healthFoodAllergies => 'Futtermittelallergien';

  @override
  String get healthDiabetes => 'Diabetes';

  @override
  String get healthDentalProblems => 'Zahnprobleme';

  @override
  String get healthHairballIssues => 'Haarballen';

  @override
  String get healthHeartCondition => 'Herzproblem';

  @override
  String get healthJointIssues => 'Gelenk- oder Bewegungsprobleme';

  @override
  String get breedQuestion => 'Welche Rasse hat deine Katze?';

  @override
  String get breedUnknownPrefix => 'Rasse unbekannt? ';

  @override
  String get breedMixedUnknown => 'Mischling / unbekannt';

  @override
  String get disclaimerTitle => 'Wir orientieren, wir verschreiben nicht';

  @override
  String get disclaimerBody1 =>
      'YuCat schlägt Futter auf Basis des Profils deiner Katze und der Zutaten vor, die wir von jedem Produkt ablesen. Es ersetzt keine tierärztliche Beratung.';

  @override
  String get disclaimerBody2 =>
      'Bei diagnostizierten Erkrankungen oder plötzlichen Veränderungen von Gewicht, Appetit oder Verhalten wende dich bitte an eine zugelassene Tierärztin oder einen Tierarzt.';

  @override
  String get catCreateCtaCreateProfile => 'Profil erstellen';

  @override
  String get catCreateCtaSaveChanges => 'Änderungen speichern';

  @override
  String get catCreateCtaNoneOfThese => 'Nichts davon';

  @override
  String get catCreateErrorCreate =>
      'Das Profil konnte nicht erstellt werden. Bitte versuche es erneut.';

  @override
  String get catCreateErrorSave =>
      'Die Änderungen konnten nicht gespeichert werden. Bitte versuche es erneut.';

  @override
  String get onboardingWelcomeHeadline =>
      'Entschlüssle\njedes\nKatzen-\nfutter';

  @override
  String get onboardingGetStarted => 'Loslegen';

  @override
  String get onboardingLegalPrefix =>
      'Indem du fortfährst, akzeptierst du unsere\n';

  @override
  String get onboardingTermsOfUse => 'Nutzungsbedingungen';

  @override
  String get onboardingLegalAnd => ' und ';

  @override
  String get onboardingPrivacyNotice => 'Datenschutzhinweis';

  @override
  String get onboardingWhyYucatTitle =>
      'Warum YuCats\neinzigartiger Ansatz\nfunktioniert';

  @override
  String get onboardingLetsGo => 'Los geht\'s';

  @override
  String get onboardingHealthIntroTitle =>
      'Erzähl uns jetzt\nüber die Gesundheit\ndeiner Katze';

  @override
  String get onboardingCouldNotOpenLink =>
      'Dieser Link konnte nicht geöffnet werden.';

  @override
  String get onboardingNutritionFactHeadlinePart1 => 'Ein Kätzchen braucht\n';

  @override
  String get onboardingNutritionFactHighlight => '2,5× mehr Protein';

  @override
  String get onboardingNutritionFactHeadlinePart2 => '\nals eine Seniorenkatze';

  @override
  String get onboardingNutritionFactBody =>
      'Lebensphase, Gewicht, Aktivität und Gesundheitszustand verändern, was in den Napf deiner Katze gehört.';

  @override
  String get onboardingMerckManualName => 'Merck Veterinärhandbuch ';

  @override
  String get onboardingMerckManualQuote =>
      'weist darauf hin, dass sich der Protein- und Aminosäurebedarf einer Katze mit der Lebensphase ändert — Kätzchen brauchen mehr Protein als ausgewachsene Katzen und reagieren empfindlicher auf das Aminosäuregleichgewicht.';

  @override
  String get onboardingSourceLink => 'Quelle der Empfehlungen';

  @override
  String get onboardingScanDemoTitle => 'Verfolge,\nwas drin ist';

  @override
  String get onboardingScanDemoSubtitle =>
      'Richte deine Kamera auf ein beliebiges\nKatzenfutter und erhalte ein Urteil';

  @override
  String get onboardingProfileIntroTitle =>
      'Lass uns das Profil\ndeiner Katze einrichten';

  @override
  String get onboardingProfileIntroTime => '2 Min.';

  @override
  String get onboardingProfileIntroQuote =>
      'Ein schnelles Profil schaltet maßgeschneiderte Urteile für jede Tüte frei';

  @override
  String get onboardingProfileNameLabel => 'Benenne deine Katze';

  @override
  String get onboardingProfileNameHint => 'Mochi';

  @override
  String get onboardingProofChartTitle =>
      'YuCat liefert\nlangfristige Ergebnisse';

  @override
  String get onboardingProofChartCalloutBold => 'Ein besser passendes Futter ';

  @override
  String get onboardingProofChartCalloutRest =>
      'abgestimmt auf die Bedürfnisse deiner Katze, in nur wenigen Scans';

  @override
  String get onboardingRatingEyebrow => 'Hilf uns zu wachsen';

  @override
  String get onboardingRatingTitle => 'Gib uns eine Bewertung';

  @override
  String get onboardingRatingStatValue => 'Geliebt';

  @override
  String get onboardingRatingStatLabel => 'von Katzeneltern';

  @override
  String get onboardingRatingPeopleLabel => 'Katzeneltern wie du';

  @override
  String get onboardingReview1Headline => 'Genau das, was ich brauchte!';

  @override
  String get onboardingReview1Body =>
      'Ich habe das Trockenfutter meiner Katze gescannt und endlich verstanden, was drin ist. Noch in derselben Woche habe ich die Marke gewechselt und es nie bereut.';

  @override
  String get onboardingReview2Headline => 'Ich liebe diese App!!!';

  @override
  String get onboardingReview2Body =>
      'Eine fantastische App, super einfach zu bedienen. Ich lade einfach Fotos vom Futter hoch und sie erklärt mir alles. Großartig!';

  @override
  String get onboardingReview3Headline => 'Ein Lebensretter für Seniorenkatzen';

  @override
  String get onboardingReview3Body =>
      'YuCat hat an einem Nachmittag ein Seniorenfutter gefunden, das Lulus Magen schont.';

  @override
  String get onboardingReview4Headline => 'Endlich fühle ich mich sicher';

  @override
  String get onboardingReview4Body =>
      'Früher habe ich einfach genommen, was im Angebot war. Jetzt weiß ich genau, welches Futter zu den Bedürfnissen meines Kätzchens passt. Absolute Sicherheit.';

  @override
  String get onboardingReview5Headline => 'So einfach zu bedienen';

  @override
  String get onboardingReview5Body =>
      'Foto machen und in Sekunden eine klare Auswertung erhalten. Sogar meine Tierärztin war beeindruckt, als ich es ihr gezeigt habe.';

  @override
  String get onboardingReview6Headline => 'Zwei Katzen, zwei Diäten';

  @override
  String get onboardingReview6Body =>
      'Das Futter für eine übergewichtige Tigerkatze und eine wählerische Siamkatze zu managen, war ein Albtraum. YuCat hat es für beide mühelos gemacht.';

  @override
  String get onboardingAttributionTitle => 'Wie hast du von uns\nerfahren?';

  @override
  String get onboardingAttributionInstagram => 'Instagram';

  @override
  String get onboardingAttributionTikTok => 'TikTok';

  @override
  String get onboardingAttributionYouTube => 'YouTube';

  @override
  String get onboardingAttributionAppStore => 'App-Store-Suche';

  @override
  String get onboardingAttributionFriends => 'Freunde/Familie';

  @override
  String get onboardingNotifPrimerTitle =>
      'Wir behalten das Futter\ndeiner Katze im Auge';

  @override
  String get onboardingSetUpReminders => 'Erinnerungen einrichten';

  @override
  String get onboardingNotifMatchDropped => 'Passung gesunken';

  @override
  String get onboardingNotifMockBody =>
      'Lunas Futter hat die Rezeptur geändert — sieh dir das neue Urteil an 🔍';

  @override
  String get onboardingRemindersTitle =>
      'Worüber sollen wir\ndich benachrichtigen?';

  @override
  String get commonDone => 'Fertig';

  @override
  String get onboardingSetUpLater => 'Später einrichten';

  @override
  String get onboardingRemindersOptionFoodChange =>
      'Wenn sich ein gespeichertes Futter ändert';

  @override
  String get onboardingRemindersOptionBetterFit =>
      'Wenn eine bessere Option gefunden wird';

  @override
  String get onboardingRemindersOptionMonthly => 'Monatlicher Check-in';

  @override
  String get onboardingRemindersCalloutPart1 =>
      'Erinnerungen schaffen gesunde Ernährungsgewohnheiten ';

  @override
  String get onboardingRemindersCalloutBold => '2x schneller';

  @override
  String onboardingSuccessWithName(String name) {
    return '$name ist\nstartklar!';
  }

  @override
  String get onboardingSuccessNoName => 'Alles\nbereit!';

  @override
  String get onboardingStartScanning => 'Mit dem Scannen beginnen';

  @override
  String get onboardingSuccessNotSet => 'Nicht festgelegt';

  @override
  String get onboardingSuccessNone => 'Keine';

  @override
  String get onboardingSuccessRowAge => 'Alter';

  @override
  String get onboardingSuccessRowActivity => 'Aktivität';

  @override
  String get onboardingSuccessRowBodyCondition => 'Körperzustand';

  @override
  String get onboardingSuccessRowCoat => 'Fell';

  @override
  String get onboardingSuccessRowNeuterStatus => 'Kastrationsstatus';

  @override
  String get onboardingSuccessRowBreed => 'Rasse';

  @override
  String get onboardingSuccessRowHealthConditions => 'Gesundheitszustand';

  @override
  String get onboardingSuccessProfileReadyTitle => 'Profil bereit';

  @override
  String get onboardingSuccessProfileReadyBody =>
      'Du kannst diese Angaben jederzeit im Profil deiner Katze bearbeiten.';

  @override
  String get paywallHeroHeadline => 'Wisse genau,\nwas im Napf ist';

  @override
  String get paywallHeroHighlight => 'genau';

  @override
  String get paywallPlusBadge => 'Plus';

  @override
  String get paywallBadgeBestValue => 'BESTER WERT';

  @override
  String get paywallLimitedTimeOffer => 'Zeitlich begrenztes Angebot';

  @override
  String paywallLimitedTimeOfferWithSavings(String savings) {
    return 'Zeitlich begrenztes Angebot · $savings';
  }

  @override
  String get paywallEverythingYouGet => 'Alles, was du bekommst';

  @override
  String get paywallFeatureIngredientScannerTitle => 'Zutaten-Scanner';

  @override
  String get paywallFeatureIngredientScannerBenefit =>
      'Scanne jedes Etikett in Sekunden';

  @override
  String get paywallFeaturePersonalizedVerdictsTitle =>
      'Personalisierte Urteile';

  @override
  String get paywallFeaturePersonalizedVerdictsBenefit =>
      'Abgestimmt auf Alter, Rasse und Gesundheit deiner Katze';

  @override
  String get paywallFeatureUnlimitedScansTitle => 'Unbegrenzte Scans';

  @override
  String get paywallFeatureUnlimitedScansBenefit =>
      'Keine täglichen Limits, niemals';

  @override
  String get paywallFeatureReformulationAlertsTitle =>
      'Rezeptur-Benachrichtigungen';

  @override
  String get paywallFeatureReformulationAlertsBenefit =>
      'Erfahre sofort, wenn sich ein Rezept ändert';

  @override
  String get paywallFeatureSavedFoodsTitle => 'Gespeicherte Futter & Verlauf';

  @override
  String get paywallFeatureSavedFoodsBenefit =>
      'Jedes geprüfte Futter an einem Ort';

  @override
  String get paywallFeatureMultiCatTitle => 'Profile für mehrere Katzen';

  @override
  String get paywallFeatureMultiCatBenefit =>
      'Ein maßgeschneidertes Profil für jede deiner Katzen';

  @override
  String get paywallSuccessStoriesHeading =>
      'Erfolgsgeschichten\nvon Katzeneltern';

  @override
  String get paywallTestimonial1Quote =>
      'Ich habe jahrelang geraten. YuCat hat an einem Nachmittag ein Seniorenfutter gefunden, das Lulus Magen schont.';

  @override
  String get paywallTestimonial1Name => 'Sophie';

  @override
  String get paywallTestimonial1Detail => 'Seniorenkatze · empfindlicher Magen';

  @override
  String get paywallTestimonial2Quote =>
      'Ich habe das Trockenfutter unseres Kätzchens gescannt und endlich verstanden, was drin ist. Noch in derselben Woche die Marke gewechselt.';

  @override
  String get paywallTestimonial2Name => 'Marco';

  @override
  String get paywallTestimonial2Detail => 'Kätzchen · wählerischer Esser';

  @override
  String get paywallTestimonial3Quote =>
      'Zwei Katzen, zwei sehr unterschiedliche Bedürfnisse. Jetzt weiß ich, welches Futter wirklich zu jeder passt.';

  @override
  String get paywallTestimonial3Name => 'Priya';

  @override
  String get paywallTestimonial3Detail => 'Haushalt mit mehreren Katzen';

  @override
  String get paywallStatRatingLabel => 'Durchschnittliche\nBewertung';

  @override
  String get paywallStatCatParentsLabel => 'Katzeneltern\nweltweit';

  @override
  String get paywallCancelAnytime => 'Jederzeit kündbar.';

  @override
  String get paywallAutoRenewDisclosure =>
      'Dein Abo verlängert sich automatisch, sofern es nicht mindestens 24 Stunden vor Ablauf des aktuellen Zeitraums gekündigt wird. Kündige jederzeit kostenlos im App Store.';

  @override
  String get paywallRestorePurchases => 'Käufe wiederherstellen';

  @override
  String get commonTerms => 'Bedingungen';

  @override
  String get commonPrivacy => 'Datenschutz';

  @override
  String get commonClose => 'Schließen';

  @override
  String get paywallPeriodAnnual => 'Jährlich';

  @override
  String get paywallPeriod6Months => '6 Monate';

  @override
  String get paywallPeriod3Months => '3 Monate';

  @override
  String get paywallPeriod2Months => '2 Monate';

  @override
  String get paywallPeriodMonthly => 'Monatlich';

  @override
  String get paywallPeriodWeekly => 'Wöchentlich';

  @override
  String get paywallPeriodLifetime => 'Lebenslang';

  @override
  String get paywallCtaUnlockPlus => 'Los geht\'s';

  @override
  String get paywallSkipDebug => 'Paywall überspringen (Debug)';

  @override
  String get paywallErroriOSOnly => 'Abos sind nur auf iOS verfügbar.';

  @override
  String get paywallErrorCouldNotLoadPlans =>
      'Die Tarife konnten nicht geladen werden.';

  @override
  String get paywallErrorNoPlansAvailable =>
      'Derzeit sind keine Abo-Tarife verfügbar.';

  @override
  String get paywallErrorPurchaseNotComplete =>
      'Der Kauf wurde nicht abgeschlossen. Bitte versuche es erneut.';

  @override
  String get paywallErrorPurchaseFailed =>
      'Der Kauf ist fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get paywallErrorSomethingWentWrong =>
      'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get paywallErrorNoActiveSubscription => 'Kein aktives Abo gefunden.';

  @override
  String get paywallErrorRestoreFailed =>
      'Die Käufe konnten nicht wiederhergestellt werden. Bitte versuche es erneut.';

  @override
  String get commonGoBack => 'Zurück';

  @override
  String get productDetailLoadError =>
      'Dieses Produkt konnte nicht geladen werden.';

  @override
  String get productDetailOverallAnalysis => 'GESAMTANALYSE';

  @override
  String get productDetailAiIdentifiedPill => '* VON KI ERKANNT';

  @override
  String get productDetailMyCatScore => 'Punktzahl meiner Katze';

  @override
  String get productDetailNoCatPrompt =>
      'Erstelle ein Profil für deine Katze, um eine personalisierte Punktzahl zu sehen.';

  @override
  String get productDetailAddACat => 'Katze hinzufügen';

  @override
  String get productDetailForYourCats => 'Für deine Katzen';

  @override
  String productDetailCatsCount(int count) {
    return '$count KATZEN';
  }

  @override
  String get productDetailPickACat =>
      'Wähle eine Katze, um zu sehen, wie dieses Produkt zu ihrem Profil passt.';

  @override
  String get productDetailPersonalizedScore =>
      'Personalisierte Punktzahl basierend auf dem Profil deiner Katze.';

  @override
  String get productDetailDimHealth => 'GESUNDHEIT';

  @override
  String get productDetailDimWeight => 'GEWICHT';

  @override
  String get productDetailDimAge => 'ALTER';

  @override
  String get productDetailDimActivity => 'AKTIVITÄT';

  @override
  String get productDetailDimNeuteredStatus => 'KASTRATIONSSTATUS';

  @override
  String get productDetailDimBreed => 'RASSE';

  @override
  String get productDetailNeutralFit =>
      'Keine starken Übereinstimmungen für diese Katze — neutrale Passung.';

  @override
  String get productDetailAgeGroupKitten => 'Kätzchen';

  @override
  String get productDetailAgeGroupAdult => 'Erwachsen';

  @override
  String get productDetailAgeGroupSenior => 'Senior';

  @override
  String get productDetailNutrientProtein => 'Protein';

  @override
  String get productDetailNutrientFat => 'Fett';

  @override
  String get productDetailNutrientMoisture => 'Feuchtigkeit';

  @override
  String get productDetailNutrientFiber => 'Faser';

  @override
  String get productDetailNutrientCarbs => 'Kohlenhydrate';

  @override
  String get productDetailVerdictExcellent =>
      'Eine hervorragende Wahl für jeden Tag';

  @override
  String get productDetailVerdictGood => 'Eine solide Wahl für jeden Tag';

  @override
  String get productDetailVerdictAverage => 'Eine vertretbare Wahl';

  @override
  String get productDetailVerdictPoor => 'Dieses besser überspringen';

  @override
  String get productDetailNoDataHeadline =>
      'Wir haben die Details noch nicht gefunden';

  @override
  String get productDetailNoDataBody =>
      'Wir konnten die garantierte Analyse für dieses Produkt nicht finden. Versuche, das Nährwertetikett zu scannen, oder schau später wieder vorbei — wir suchen weiter.';

  @override
  String get productDetailNoDataCatsNote =>
      'Wir zeigen dir, wie es zu deinen Katzen passt, sobald wir die Nährwertdaten haben.';

  @override
  String get productDetailImagePlaceholder => 'PRODUKT';

  @override
  String productDetailScoreSemantics(int score, int maxScore) {
    return 'Punktzahl $score von $maxScore';
  }

  @override
  String get assessmentKittenHighProtein =>
      'Hoher Proteingehalt (>35%), vorteilhaft für Kätzchen';

  @override
  String get assessmentKittenHighFat =>
      'Hoher Fettgehalt (>18%), der das Wachstum von Kätzchen unterstützt';

  @override
  String get assessmentKittenSeniorFormula =>
      'Eine auf Senioren ausgerichtete Rezeptur ist für Kätzchen nicht ideal';

  @override
  String get assessmentKittenLowProtein =>
      'Niedriger Proteingehalt (<28%) deckt den Bedarf eines Kätzchens möglicherweise nicht';

  @override
  String get assessmentSeniorModerateProtein =>
      'Moderater Proteingehalt (30–35%), passend für Seniorenkatzen';

  @override
  String get assessmentSeniorHighFat =>
      'Sehr hoher Fettgehalt (>20%) ist für Seniorenkatzen möglicherweise ungeeignet';

  @override
  String get assessmentSeniorJointSupport =>
      'Enthält gelenkunterstützende Zutaten (z. B. Glucosamin, Chondroitin)';

  @override
  String get assessmentSeniorKidneyFriendly =>
      'Nierenfreundliche Rezeptur (z. B. weniger Phosphor)';

  @override
  String get assessmentUnderweightHighCalories =>
      'Hoher Kaloriengehalt (>380 kcal/100g) kann einer untergewichtigen Katze beim Zunehmen helfen';

  @override
  String get assessmentUnderweightHighFat =>
      'Hoher Fettgehalt (>18%) fördert die Gewichtszunahme bei untergewichtigen Katzen';

  @override
  String get assessmentOverweightHighCalories =>
      'Hoher Kaloriengehalt (>360 kcal/100g) ist für eine übergewichtige Katze möglicherweise nicht ideal';

  @override
  String get assessmentOverweightLowCalories =>
      'Weniger Kalorien (<320 kcal/100g) helfen, das Gewicht bei übergewichtigen Katzen zu kontrollieren';

  @override
  String get assessmentOverweightHighFiber =>
      'Mehr Faser (>4%) kann bei der Sättigung von übergewichtigen Katzen helfen';

  @override
  String get assessmentObeseHighFat =>
      'Hoher Fettgehalt (>15%) ist für fettleibige Katzen ungeeignet';

  @override
  String get assessmentObeseHighCalories =>
      'Hoher Kaloriengehalt (>330 kcal/100g) ist für fettleibige Katzen nicht ideal';

  @override
  String get assessmentObeseLeanProtein =>
      'Magere, proteinreiche Rezeptur (>40% Protein, <12% Fett) ist gut für fettleibige Katzen';

  @override
  String get assessmentLowActivityHighCalories =>
      'Hoher Kaloriengehalt (>360 kcal/100g) passt möglicherweise nicht zu einer wenig aktiven Katze';

  @override
  String get assessmentLowActivityModerateCalories =>
      'Moderate Kalorien (<330 kcal/100g) sind besser für wenig aktive Katzen';

  @override
  String get assessmentHighActivityHighCalories =>
      'Mehr Kalorien (>380 kcal/100g) unterstützen eine sehr aktive Katze';

  @override
  String get assessmentHighActivityHighProtein =>
      'Hoher Proteingehalt (>35%) hilft, die Muskeln aktiver Katzen zu erhalten';

  @override
  String get assessmentNeuteredHighCalories =>
      'Sehr kalorienreiches Futter (>380 kcal/100g) kann bei kastrierten Katzen die Gewichtszunahme fördern';

  @override
  String get assessmentNeuteredUrinarySupport =>
      'Enthält harnwegsunterstützende Zutaten, gut für kastrierte Katzen';

  @override
  String get assessmentNeuteredHighFat =>
      'Hoher Fettgehalt (>16%) ist für kastrierte Katzen möglicherweise nicht ideal';

  @override
  String get assessmentPregnantHighProtein =>
      'Sehr hoher Proteingehalt (>35%) deckt den erhöhten Bedarf trächtiger/säugender Katzen';

  @override
  String get assessmentPregnantHighFat =>
      'Hoher Fettgehalt (>20%) liefert zusätzliche Energie für trächtige/säugende Katzen';

  @override
  String get assessmentPregnantHighCalories =>
      'Sehr kalorienreiches Futter (>400 kcal/100g) hilft, den Energiebedarf in Trächtigkeit/Laktation zu decken';

  @override
  String get assessmentMaineCoonJointSupport =>
      'Enthält gelenkunterstützende Zutaten, hilfreich für Maine Coons';

  @override
  String get assessmentMaineCoonHighProtein =>
      'Hoher Proteingehalt (>35%) unterstützt großwüchsige Maine Coons';

  @override
  String get assessmentPersianHairball =>
      'Rezeptur zur Haarballenkontrolle (Faser 4–6% oder Haarballen-Angaben)';

  @override
  String get assessmentPersianOmega3 =>
      'Enthält omega-3-reiche Zutaten, gut für Fell/Haut der Perserkatze';

  @override
  String get assessmentPersianHighCarbs =>
      'Hoher Kohlenhydratgehalt (>30%) ist für Perserkatzen möglicherweise nicht ideal';

  @override
  String get assessmentSiameseDigestible =>
      'Verwendet leicht verdauliche Proteine, gut für Siamkatzen';

  @override
  String get assessmentSiameseFillers =>
      'Enthält viele Füllstoffe (Mais, Weizen, Soja), die für Siamkatzen möglicherweise ungeeignet sind';

  @override
  String get assessmentSphynxHighFat =>
      'Mehr Fett (>18%) kann die Hautgesundheit der Sphynx unterstützen';

  @override
  String get assessmentSphynxLowFat =>
      'Fettarme Rezeptur (<12%) bietet der Haut der Sphynx möglicherweise nicht genug Unterstützung';

  @override
  String get assessmentBritishHighCalories =>
      'Kalorienreiches Futter kann bei British Shorthairs die Gewichtszunahme fördern';

  @override
  String get assessmentBritishWeightManagement =>
      'Eine Rezeptur zum Gewichtsmanagement ist für British Shorthairs geeignet';

  @override
  String get assessmentBengalHighProtein =>
      'Hoher Proteingehalt (>38%) passt zum Energiebedarf der Bengalkatze';

  @override
  String get assessmentBengalLowProtein =>
      'Niedriger Proteingehalt (<30%) kann für Bengalkatzen unzureichend sein';

  @override
  String get assessmentBreedHighProtein =>
      'Hoher Proteingehalt (>35%) unterstützt große, muskulöse Rassen';

  @override
  String get assessmentBreedHighFat =>
      'Höherer Fettgehalt (>18%) eignet sich für feinhaarige Rassen mit hohem Stoffwechsel';

  @override
  String get assessmentBreedLowFat =>
      'Niedriger Fettgehalt (<12%) kann für feinhaarige Rassen unzureichend sein';

  @override
  String get assessmentBreedHairball =>
      'Haarballen-Formel (Faser 4–6% oder Haarballen-Angaben) eignet sich für langhaarige Rassen';

  @override
  String get assessmentBreedOmega3 =>
      'Enthält Omega-3-reiche Zutaten, gut für Fell und Haut';

  @override
  String get assessmentBreedHighCarbs =>
      'Hoher Kohlenhydratgehalt (>30%) ist für diese Rasse nicht ideal';

  @override
  String get assessmentBreedDigestible =>
      'Verwendet leicht verdauliche Proteine, gut für schlanke, aktive Rassen';

  @override
  String get assessmentBreedFillers =>
      'Enthält viele Füllstoffe (Mais, Weizen, Soja), die für diese Rasse ungeeignet sein können';

  @override
  String get assessmentBreedJointSupport =>
      'Enthält gelenkunterstützende Zutaten, hilfreich für diese Rasse';

  @override
  String get assessmentBreedLowPhosphorus =>
      'Nierenfreundliche, phosphorarme Formel eignet sich für Rassen mit Nierenrisiko';

  @override
  String get assessmentBreedHighMinerals =>
      'Hoher Mineralstoffgehalt kann für Rassen mit Nierenrisiko ungeeignet sein';

  @override
  String get assessmentBreedHighCalories =>
      'Kalorienreiches Futter kann bei dieser Rasse zu Gewichtszunahme führen';

  @override
  String get assessmentBreedWeightManagement =>
      'Gewichtsmanagement-Formel eignet sich für Rassen mit Neigung zur Gewichtszunahme';

  @override
  String get assessmentBreedHighCarbsDiabetes =>
      'Hoher Kohlenhydratgehalt (>20%) kann für Rassen mit Diabetes-Neigung ungeeignet sein';

  @override
  String get assessmentUrinaryLowAsh =>
      'Mit niedrigem Aschegehalt formuliert, unterstützend bei Harnwegsproblemen';

  @override
  String get assessmentUrinarySupport =>
      'Enthält harnwegsunterstützende Zutaten wie Cranberry oder DL-Methionin';

  @override
  String get assessmentUrinaryHighMinerals =>
      'Hoher Mineralstoffgehalt ist bei Harnwegsproblemen möglicherweise nicht ideal';

  @override
  String get assessmentKidneyHighProtein =>
      'Hoher Proteingehalt (>32%) ist bei einer Nierenerkrankung möglicherweise nicht ideal';

  @override
  String get assessmentKidneyPhosphorus =>
      'Enthält Phosphorquellen, die bei einer Nierenerkrankung problematisch sein können';

  @override
  String get assessmentKidneyRenalSupport =>
      'Als nierenunterstützende Diät formuliert';

  @override
  String get assessmentSensitiveStomachLimitedIngredient =>
      'Eine Rezeptur mit begrenzten Zutaten kann empfindlichen Mägen helfen';

  @override
  String get assessmentSensitiveStomachLongIngredients =>
      'Eine sehr lange Zutatenliste ist für empfindliche Mägen möglicherweise ungeeignet';

  @override
  String get assessmentFoodAllergyCommonAllergens =>
      'Enthält häufige Allergene wie Huhn, Fisch oder Rind';

  @override
  String get assessmentFoodAllergyNovelProteins =>
      'Verwendet neuartige Proteine (z. B. Ente, Wild), die bei Allergien helfen können';

  @override
  String get assessmentSkinAllergyOmega3 =>
      'Eine omega-3-reiche Rezeptur kann die Haut- und Fellgesundheit unterstützen';

  @override
  String get assessmentSkinAllergyArtificialColor =>
      'Enthält künstliche Farbstoffe, die Hautallergien verschlimmern können';

  @override
  String get assessmentDiabetesHighCarbs =>
      'Hoher Kohlenhydratgehalt (>20%) ist für diabetische Katzen weniger geeignet';

  @override
  String get assessmentDiabetesHighProtein =>
      'Sehr hoher Proteingehalt (>40%) kann die Blutzuckerkontrolle bei Diabetes unterstützen';

  @override
  String get assessmentDentalHighMoisture =>
      'Feuchtigkeitsreiches (nasses) Futter ist bei Zahnproblemen leichter zu fressen';

  @override
  String get assessmentDentalLargeKibble =>
      'Sehr große Kroketten können bei Zahnproblemen schwer zu kauen sein';

  @override
  String get assessmentHairballControl =>
      'Diät zur Haarballenkontrolle (Faser 4–6% oder Haarballen-Angaben)';

  @override
  String get homeScanProduct => 'Produkt scannen';

  @override
  String get homeScanProductSubtitle => 'Fotografiere die Verpackung';

  @override
  String get homeGreetingHey => 'Willkommen zurück';

  @override
  String get homeGreetingWelcome => 'Willkommen';

  @override
  String homeReadyForCat(String name) {
    return 'Bereit, Futter für $name zu finden?';
  }

  @override
  String get homeReadyToScan => 'Bereit, ein Produkt zu scannen?';

  @override
  String get homeAddCatTitle => 'Füge deine Katze hinzu';

  @override
  String get homeAddCatBody =>
      'Erstelle ein Profil, um personalisierte Futter-Punktzahlen zu erhalten.';

  @override
  String get homeAddCatButton => 'Katze hinzufügen';

  @override
  String homeProfileCompletionTitle(String name) {
    return 'Profil von $name vervollständigen';
  }

  @override
  String get homeProfileCompletionBody =>
      'Ein paar Details für bessere Empfehlungen.';

  @override
  String homeProfileCompletionProgress(int filled, int total) {
    return '$filled/$total';
  }

  @override
  String get homeProfileCompletionButton => 'Profil vervollständigen';

  @override
  String get homeMyCatsTitle => 'Meine Katzen';

  @override
  String get homeSavedProductsTitle => 'Gespeicherte Produkte';

  @override
  String get homeSeeAll => 'Alle ansehen';

  @override
  String get homeNoSavedProductsTitle => 'Noch keine gespeicherten Produkte';

  @override
  String get homeNoSavedProductsBody =>
      'Tippe auf das Lesezeichen eines Produkts, um es hier zu speichern.';

  @override
  String get homeLoadingEyebrow => 'Einen Moment';

  @override
  String get homeLoadingMsgReading => 'Etikett wird gelesen…';

  @override
  String get homeLoadingMsgSniffing => 'Zutaten werden beschnuppert…';

  @override
  String get homeLoadingMsgMatching => 'Abgleich mit unserer Datenbank…';

  @override
  String get homeLoadingMsgCrunching => 'Zahlen werden ausgewertet…';

  @override
  String get homeLoadingMsgAlmost => 'Fast geschafft…';

  @override
  String get homeCameraUnavailable => 'Kamera nicht verfügbar';

  @override
  String get homeCameraUnavailableBody =>
      'Aktiviere den Kamerazugriff für YuCat in den Einstellungen oder wähle stattdessen ein Foto aus deiner Galerie.';

  @override
  String get homeChooseFromGallery => 'Aus Galerie wählen';

  @override
  String get homeScannerHint => 'Richte sie auf das Produktetikett';

  @override
  String get homeErrorProductNotFound => 'Produkt nicht gefunden';

  @override
  String get homeErrorTimeout =>
      'Die Anfrage hat zu lange gedauert. Bitte versuche es erneut.';

  @override
  String get homeErrorNoInternet =>
      'Keine Internetverbindung. Bitte prüfe dein Netzwerk und versuche es erneut.';

  @override
  String get homeErrorGeneric =>
      'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get homeCatKitten => 'Kätzchen';

  @override
  String get homeCatAdult => 'Erwachsen';

  @override
  String get homeCatSenior => 'Senior';

  @override
  String get homeCatUnderweight => 'Untergewichtig';

  @override
  String get homeCatHealthyWeight => 'Gesundes Gewicht';

  @override
  String get homeCatOverweight => 'Übergewichtig';

  @override
  String get homeCatObese => 'Fettleibig';

  @override
  String homeCatConditionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Beschwerden',
      one: '1 Beschwerde',
    );
    return '$_temp0';
  }

  @override
  String get scanHistoryTitle => 'Scan-Verlauf';

  @override
  String scanHistoryScanCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Scans',
      one: '1 Scan',
    );
    return '$_temp0';
  }

  @override
  String get scanHistoryEmptyTitle => 'Noch keine Scans';

  @override
  String get scanHistoryEmptyBody => 'Gescannte Futter erscheinen hier.';

  @override
  String get commonTryAgain => 'Erneut versuchen';

  @override
  String get searchTabTitle => 'Suchen';

  @override
  String get searchHint => 'Suche nach einem Katzenfutter';

  @override
  String get searchRecentLabel => 'Zuletzt';

  @override
  String get searchClearLabel => 'Löschen';

  @override
  String get searchPopularBrands => 'Beliebte Marken';

  @override
  String get searchNoMatchesHeadline => 'Keine Treffer';

  @override
  String get searchNoMatchesBody =>
      'Versuche einen anderen Namen oder durchstöbere beliebte Marken.';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ergebnisse',
      one: '1 Ergebnis',
    );
    return '$_temp0';
  }

  @override
  String get searchErrorBody => 'Bei der Suche ist etwas schiefgelaufen.';

  @override
  String get bottomNavSearch => 'Suchen';

  @override
  String get bottomNavHome => 'Start';

  @override
  String get bottomNavProfile => 'Profil';

  @override
  String get productListingEmpty =>
      'Für diese Marke wurden keine Produkte gefunden.';

  @override
  String get commonAgeGroupKitten => 'Kätzchen';

  @override
  String get commonAgeGroupAdult => 'Erwachsen';

  @override
  String get commonAgeGroupSenior => 'Senior';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileLinkError => 'Der Link konnte nicht geöffnet werden.';

  @override
  String get profileSubscriptionLinkError =>
      'Die App-Store-Abos konnten nicht geöffnet werden.';

  @override
  String profileEmailError(String email) {
    return '$email konnte nicht geöffnet werden.';
  }

  @override
  String get profilePrivacyError =>
      'Die Datenschutzrichtlinie konnte nicht geöffnet werden.';

  @override
  String get profileTermsError =>
      'Die Allgemeinen Geschäftsbedingungen konnten nicht geöffnet werden.';

  @override
  String get profileSubscriptionActive => 'Aktives Abo';

  @override
  String get profileRestorePurchases => 'Käufe wiederherstellen';

  @override
  String get profileManageSubscription => 'Abo verwalten';

  @override
  String get profileYourCats => 'Deine Katzen';

  @override
  String get profileManage => 'Verwalten';

  @override
  String get profileAddCat => 'Katze hinzufügen';

  @override
  String get profileSavedProductsLabel => 'Gespeicherte Produkte';

  @override
  String get profileSavedProductsEmpty => 'Noch keine gespeicherten Produkte';

  @override
  String profileSavedProductsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Produkte gespeichert',
      one: '1 Produkt gespeichert',
    );
    return '$_temp0';
  }

  @override
  String get profileScanHistoryLabel => 'Scan-Verlauf';

  @override
  String get profileScanHistoryEmpty => 'Noch keine Scans';

  @override
  String profileScanHistoryCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Scans',
      one: '1 Scan',
    );
    return '$_temp0';
  }

  @override
  String get profileContactUs => 'Kontaktiere uns';

  @override
  String get profilePrivacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get profileTermsAndConditions => 'Allgemeine Geschäftsbedingungen';

  @override
  String get profileResetOnboarding => 'Einführung zurücksetzen';

  @override
  String get profileDebugOnly => 'Nur Debug';

  @override
  String get profileRestoreNotAvailable =>
      'Die Wiederherstellung ist nur auf iOS verfügbar.';

  @override
  String get profileRestoreSuccess => 'Abo erfolgreich wiederhergestellt!';

  @override
  String get profileNoSubscriptionFound => 'Kein aktives Abo gefunden.';

  @override
  String get profileRestoreError =>
      'Deine Käufe konnten nicht wiederhergestellt werden. Bitte versuche es erneut.';

  @override
  String get savedProductsTitle => 'Gespeicherte Produkte';

  @override
  String savedProductsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Produkte',
      one: '1 Produkt',
    );
    return '$_temp0';
  }

  @override
  String get savedProductsEmptyHeadline => 'Noch keine gespeicherten Produkte';

  @override
  String get savedProductsEmptyBody =>
      'Markiere Produkte, um sie hier zu finden';

  @override
  String get catDetailDeleteError =>
      'Deine Katze konnte nicht gelöscht werden. Bitte versuche es erneut.';

  @override
  String catDetailDeleteTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get catDetailDeleteBody =>
      'Dadurch wird das Profil dauerhaft gelöscht.';

  @override
  String get catDetailDeleteCancel => 'Abbrechen';

  @override
  String get catDetailDeleteConfirm => 'Löschen';

  @override
  String get catDetailProfileCompletion => 'Profil-Vollständigkeit';

  @override
  String get catDetailNotSet => 'Nicht festgelegt';

  @override
  String get catDetailBreedLabel => 'Rasse';

  @override
  String get catDetailAgeLabel => 'Alter';

  @override
  String get catDetailAgeYears => 'Jahre';

  @override
  String get catDetailGenderLabel => 'Geschlecht';

  @override
  String get catDetailCoatLabel => 'Fell';

  @override
  String get catDetailActivityLabel => 'Aktivität';

  @override
  String get catDetailBodyLabel => 'Körperzustand';

  @override
  String get catDetailStatusLabel => 'Status';

  @override
  String get catDetailStatusNeutered => 'Kastriert / Sterilisiert';

  @override
  String get catDetailStatusSpayed => 'Sterilisiert';

  @override
  String get catDetailDetailsSection => 'Details';

  @override
  String get catDetailActivityModerate => 'Moderat';

  @override
  String get catDetailBodyNormal => 'Normal';

  @override
  String get catDetailCoatMedium => 'Halblanges Haar';

  @override
  String get catDetailHealthConditionsSection => 'Gesundheitszustand';

  @override
  String get catDetailDeleteProfile => 'Profil löschen';

  @override
  String get catListingTitle => 'Deine Katzen';

  @override
  String get catListingErrorGeneric => 'Etwas ist schiefgelaufen';

  @override
  String get catListingEmptyHeadline => 'Noch keine Katzen';

  @override
  String get catListingEmptyBody =>
      'Füge deine erste Katze hinzu, um personalisierte Empfehlungen zu erhalten';

  @override
  String get catListingEmptyCta => 'Füge deine Katze hinzu';

  @override
  String get catListingAddAnotherCat => 'Weitere Katze hinzufügen';

  @override
  String get catListingCreateNewProfile => 'Neues Profil erstellen';

  @override
  String get catListingCatFallback => 'Katze';

  @override
  String catListingConditionsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Beschwerden',
      one: '1 Beschwerde',
    );
    return '$_temp0';
  }

  @override
  String get catDetailDietaryTipsSection => 'Ernährungstipps';

  @override
  String get dietTipsDisclaimer =>
      'Allgemeine Orientierung — konsultiere bei medizinischen Fragen immer deinen Tierarzt.';

  @override
  String homeCatTipsTitle(String name) {
    return 'Tipps für $name';
  }

  @override
  String get dietTitleMoreProtein => 'Mehr Protein';

  @override
  String get dietTitleLessProtein => 'Weniger Protein';

  @override
  String get dietTitleMoreFat => 'Mehr gesundes Fett';

  @override
  String get dietTitleLessFat => 'Weniger Fett';

  @override
  String get dietTitleLessCarbs => 'Weniger Kohlenhydrate';

  @override
  String get dietTitleMoreFiber => 'Mehr Faser';

  @override
  String get dietTitleMoreMoisture => 'Mehr Feuchtigkeit';

  @override
  String get dietTitleMoreOmega3 => 'Mehr Omega-3';

  @override
  String get dietTitleLessPhosphorus => 'Weniger Phosphor';

  @override
  String get dietTitleMoreCalories => 'Mehr Kalorien';

  @override
  String get dietTitleLessCalories => 'Weniger Kalorien';

  @override
  String get dietTitleMoreWater => 'Mehr Wasser';

  @override
  String get dietWhyKittenProtein =>
      'Wachsende Kätzchen brauchen mehr Protein, um Muskeln aufzubauen.';

  @override
  String get dietWhyKittenFat =>
      'Gesunde Fette versorgen das schnelle Wachstum und die Energie eines Kätzchens.';

  @override
  String get dietWhySeniorOmega3 =>
      'Omega-3 unterstützt alternde Gelenke, Nieren und das Fell.';

  @override
  String get dietWhySeniorPhosphorus =>
      'Weniger Phosphor entlastet alternde Nieren.';

  @override
  String get dietWhyUnderweightCalories =>
      'Kalorienreiches Futter hilft deiner Katze, ein gesundes Gewicht zu erreichen.';

  @override
  String get dietWhyUnderweightFat =>
      'Mehr gesundes Fett liefert die zum Zunehmen nötigen Kalorien.';

  @override
  String get dietWhyOverweightCalories =>
      'Weniger Kalorien fördern eine schrittweise, gesunde Gewichtsabnahme.';

  @override
  String get dietWhyOverweightFat =>
      'Weniger Fett senkt die Kalorienaufnahme zur Gewichtskontrolle.';

  @override
  String get dietWhyOverweightFiber =>
      'Faser hält deine Katze satt, während sie weniger frisst.';

  @override
  String get dietWhyOverweightProtein =>
      'Mageres Protein erhält die Muskeln während der Gewichtsabnahme.';

  @override
  String get dietWhyLowActivityCalories =>
      'Eine ruhigere Katze braucht weniger Kalorien, um nicht zuzunehmen.';

  @override
  String get dietWhyHighActivityProtein =>
      'Aktive Katzen brauchen mehr Protein, um die Muskeln zu erhalten.';

  @override
  String get dietWhyHighActivityCalories =>
      'Eine energiegeladene Katze verbraucht mehr und braucht mehr Kalorien.';

  @override
  String get dietWhyNeuteredCalories =>
      'Kastrierte Katzen verbrauchen weniger Energie und nehmen leicht zu.';

  @override
  String get dietWhyNeuteredFat =>
      'Weniger Fett hilft einer kastrierten Katze, schlank zu bleiben.';

  @override
  String get dietWhyPregnantProtein =>
      'Trächtigkeit und Säugen erfordern mehr Protein.';

  @override
  String get dietWhyPregnantFat =>
      'Mehr Fett deckt den hohen Energiebedarf beim Säugen.';

  @override
  String get dietWhyPregnantCalories =>
      'Mehr Kalorien unterstützen Trächtigkeit und Milchproduktion.';

  @override
  String get dietWhyMaineCoonProtein =>
      'Große, muskulöse Rassen gedeihen mit viel Protein.';

  @override
  String get dietWhyMaineCoonOmega3 =>
      'Omega-3 unterstützt die Gelenke großwüchsiger Rassen.';

  @override
  String get dietWhyPersianOmega3 =>
      'Omega-3 hält das lange Fell der Perserkatze gesund.';

  @override
  String get dietWhyPersianFiber =>
      'Faser hilft, Haarballen durch den Darm zu befördern.';

  @override
  String get dietWhyPersianCarbs =>
      'Perserkatzen vertragen kohlenhydratarme Diäten meist besser.';

  @override
  String get dietWhySphynxFat =>
      'Haarlose Katzen verbrauchen schnell Energie und brauchen mehr Fett.';

  @override
  String get dietWhyBengalProtein =>
      'Energiegeladene Bengalkatzen brauchen viel Protein.';

  @override
  String get dietWhyBritishCalories =>
      'Diese gemütliche Rasse nimmt leicht zu.';

  @override
  String get dietWhyBreedProtein =>
      'Große, muskulöse Rassen gedeihen mit viel Protein.';

  @override
  String get dietWhyBreedOmega3 =>
      'Omega-3 hält Fell und Gelenke dieser Rasse gesund.';

  @override
  String get dietWhyBreedFat =>
      'Feinhaarige Rassen verbrennen schnell Energie und brauchen mehr Fett.';

  @override
  String get dietWhyBreedFiber =>
      'Ballaststoffe helfen, Haarballen durch den Darm zu befördern.';

  @override
  String get dietWhyBreedCarbs =>
      'Diese Rasse fährt besser mit kohlenhydratärmerem Futter.';

  @override
  String get dietWhyBreedDigestibility =>
      'Schlanke, aktive Rassen fühlen sich mit leicht verdaulichem Futter am wohlsten.';

  @override
  String get dietWhyBreedPhosphorus =>
      'Weniger Phosphor entlastet Rassen mit Nierenrisiko.';

  @override
  String get dietWhyBreedCalories =>
      'Diese Rasse nimmt leicht zu und braucht weniger Kalorien.';

  @override
  String get dietWhyLongCoatOmega3 => 'Omega-3 nährt ein langes, dichtes Fell.';

  @override
  String get dietWhyLongCoatFiber =>
      'Faser hilft, Haarballen bei Langhaarkatzen vorzubeugen.';

  @override
  String get dietWhyHairlessFat =>
      'Haarlose Katzen brauchen mehr Fett, um warm und energiegeladen zu bleiben.';

  @override
  String get dietWhyUrinaryWater =>
      'Mehr Wasser verdünnt den Urin und schützt die Harnwege.';

  @override
  String get dietWhyKidneyPhosphorus =>
      'Wenig Phosphor hilft, eine Nierenerkrankung zu verlangsamen.';

  @override
  String get dietWhyKidneyProtein => 'Protein zu mäßigen entlastet die Nieren.';

  @override
  String get dietWhyKidneyOmega3 =>
      'Omega-3 hilft, geschädigte Nieren zu unterstützen.';

  @override
  String get dietWhyDiabetesCarbs =>
      'Wenige Kohlenhydrate halten den Blutzucker stabil.';

  @override
  String get dietWhyDiabetesProtein =>
      'Protein unterstützt die Glukosekontrolle und die Muskeln.';

  @override
  String get dietWhySkinOmega3 =>
      'Omega-3 beruhigt Hautentzündungen und Reizungen.';

  @override
  String get dietWhyHairballFiber =>
      'Faser hilft deiner Katze, Haarballen auf natürliche Weise loszuwerden.';

  @override
  String get dietWhyHairballOmega3 =>
      'Omega-3 verbessert die Fellgesundheit und reduziert den Haarausfall.';

  @override
  String get dietWhyJointOmega3 =>
      'Omega-3 verringert Gelenkentzündungen und Steifheit.';

  @override
  String get dietWhyDentalMoisture =>
      'Feuchtes Futter ist schonender für schmerzende Zähne und Zahnfleisch.';

  @override
  String get dietWhyWaterGeneral =>
      'Katzen neigen zur Dehydrierung — Nassfutter und frisches Wasser helfen.';

  @override
  String get assessmentHeartTaurine =>
      'Enthält Taurin, essenziell für die Herzgesundheit';

  @override
  String get assessmentHeartLowSodium =>
      'Niedriger Natriumgehalt, was das Herz entlastet';

  @override
  String get assessmentHeartOmega3 => 'Omega-3 unterstützt Herz und Kreislauf';

  @override
  String get assessmentHeartHighSodium =>
      'Hoher Natriumgehalt, was das Herz belastet';

  @override
  String get onboardingNarrativeTitle => 'Personalisiert für deine Katze';

  @override
  String onboardingNarrativeFallback(String name) {
    return 'Hier ist der Anfang von ${name}s Ernährungsplan — ein paar Dinge, auf die wir uns konzentrieren würden, damit es ihr rundum gut geht.';
  }

  @override
  String get dietTitleMoreTaurine => 'Mehr Taurin';

  @override
  String get dietTitleLessSodium => 'Weniger Natrium';

  @override
  String get dietTitleNovelProtein => 'Neuartige Proteine';

  @override
  String get dietTitleDigestible => 'Leicht verdauliches Futter';

  @override
  String get dietWhyHeartOmega3 =>
      'Omega-3 (EPA & DHA) unterstützt Herzmuskel und Kreislauf.';

  @override
  String get dietWhyHeartTaurine =>
      'Taurin ist essenziell für ein gesundes Katzenherz.';

  @override
  String get dietWhyHeartSodium => 'Weniger Natrium entlastet das Herz.';

  @override
  String get dietWhyAllergyNovelProtein =>
      'Neuartige oder begrenzte Proteine helfen, häufige Allergieauslöser zu vermeiden.';

  @override
  String get dietWhySensitiveDigestible =>
      'Schonende, gut verdauliche Rezepturen sind magenfreundlicher.';

  @override
  String get onboardingNarrativeOutlookTitle => 'In etwa 2 Wochen';

  @override
  String onboardingNarrativeOutlookFallback(String name) {
    return 'Mit dem richtigen Futter könntest du innerhalb von ein paar Wochen bemerken, dass $name mehr Energie und ein gesünderes, glänzenderes Fell hat.';
  }

  @override
  String onboardingNarrativeFocusTitle(String name) {
    return 'Worauf man bei $name achten sollte';
  }

  @override
  String get onboardingAnalyzeEyebrow => 'Wird personalisiert';

  @override
  String onboardingAnalyzeStep1(String name) {
    return '${name}s Profil wird geprüft';
  }

  @override
  String get onboardingAnalyzeStep2 =>
      'Gesundheitliche Bedürfnisse werden geprüft';

  @override
  String get onboardingAnalyzeStep3 =>
      'Passende Ernährungsempfehlungen werden gesucht';

  @override
  String get onboardingAnalyzeStep4 => 'Empfehlungen werden personalisiert';

  @override
  String onboardingResultTitle(String name) {
    return '${name}s Plan ist fertig';
  }

  @override
  String productPicksTitle(String name) {
    return 'Top-Empfehlungen für $name';
  }

  @override
  String get onboardingResultContinue => 'Weiter';

  @override
  String onboardingBrandTitle(String name) {
    return 'Was fütterst du $name?';
  }

  @override
  String get onboardingBrandSubtitle =>
      'Wir prüfen, wie es wirklich für deine Katze abschneidet.';

  @override
  String get onboardingBrandHint =>
      'Suche eine Marke (z. B. Whiskas, Royal Canin)';

  @override
  String get onboardingBrandAnalyzeCta => 'Dieses Futter prüfen';

  @override
  String get onboardingBrandSkip => 'Ich bin nicht sicher';

  @override
  String onboardingBrandAnalyzing(String brand) {
    return '$brand wird analysiert…';
  }

  @override
  String onboardingBrandUnavailable(String brand) {
    return 'Wir konnten $brand gerade nicht analysieren — aber hier ist, was wir stattdessen empfehlen würden.';
  }

  @override
  String onboardingBrandUnlockCta(String name) {
    return '${name}s Top-Empfehlungen entdecken';
  }

  @override
  String brandTeaserFound(num count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bessere Futter',
      one: '1 besseres Futter',
    );
    return 'Wir haben $_temp0 für $name gefunden';
  }

  @override
  String get brandTeaserLockedHint =>
      'Abonniere, um sie zu sehen — abgestimmt auf die Bedürfnisse deiner Katze.';

  @override
  String get brandTeaserRowLocked => 'Zum Ansehen freischalten';

  @override
  String get onboardingScanTitle => 'Scannen wir die\nerste Packung';

  @override
  String get onboardingScanSubtitle =>
      'Scanne die Verpackung und wir bewerten sie für deine Katze.';

  @override
  String get onboardingScanCta => 'Los scannen';

  @override
  String get onboardingScanSkip => 'Vorerst überspringen';

  @override
  String get onboardingScanVerdictIntro => 'So schneidet dieses Futter ab:';

  @override
  String get onboardingScanFailed =>
      'Wir konnten dieses Etikett nicht lesen. Versuche es erneut mit der Vorderseite der Verpackung im Bild.';

  @override
  String get onboardingScanRetry => 'Erneut scannen';

  @override
  String onboardingScanPersonalCon(String name, String con) {
    return 'Für $name: $con';
  }

  @override
  String onboardingResultWhyTitle(String name) {
    return 'Warum das für $name nicht ideal ist';
  }

  @override
  String onboardingResultProfileTitle(String name) {
    return '${name}s Profil';
  }
}
