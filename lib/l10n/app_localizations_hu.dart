// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get commonNext => 'Következő';

  @override
  String get commonGotIt => 'Értem';

  @override
  String get commonSkip => 'Kihagyás';

  @override
  String get catNameQuestion => 'Mi a macskád neve?';

  @override
  String get catNameLabel => 'Add meg a macskád nevét';

  @override
  String get catNameHint => 'Karamell';

  @override
  String get catNameValidationEmpty => 'Kérjük, add meg a macskád nevét';

  @override
  String get genderQuestion => 'Mi a macskád neme?';

  @override
  String get genderFemale => 'Nőstény';

  @override
  String get genderMale => 'Hím';

  @override
  String get photoQuestion => 'Adj hozzá egy fotót a macskádról';

  @override
  String get photoSheetTitle => 'Fotó hozzáadása';

  @override
  String get photoSheetTakePhoto => 'Fénykép készítése';

  @override
  String get photoSheetUploadLibrary => 'Feltöltés a galériából';

  @override
  String get photoCameraError =>
      'Nem sikerült hozzáférni a kamerához. Ellenőrizd az engedélyeket a Beállításokban.';

  @override
  String get photoLibraryError =>
      'Nem sikerült megnyitni a fotóidat. Ellenőrizd az engedélyeket a Beállításokban.';

  @override
  String get ageQuestion => 'Hány éves a macskád?';

  @override
  String get ageColumnYears => 'Év';

  @override
  String get ageColumnMonths => 'Hónap';

  @override
  String get ageUnitYear => 'év';

  @override
  String get ageUnitMonth => 'hó';

  @override
  String ageStageKitten(String years) {
    return 'Körülbelül $years éves — kölyök.';
  }

  @override
  String ageStageAdult(String years) {
    return 'Körülbelül $years éves — felnőtt.';
  }

  @override
  String ageStageSenior(String years) {
    return 'Körülbelül $years éves — idős.';
  }

  @override
  String get bodyConditionQuestion => 'Milyen a macskád testalkata?';

  @override
  String get bodyUnderweightLabel => 'Sovány';

  @override
  String get bodyUnderweightDesc =>
      'Bordák és gerinc látszódnak, nagyon kevés zsír';

  @override
  String get bodyNormalLabel => 'Ideális';

  @override
  String get bodyNormalDesc => 'Bordák könnyen tapinthatók, derékvonal látható';

  @override
  String get bodyOverweightLabel => 'Túlsúlyos';

  @override
  String get bodyOverweightDesc => 'Bordák nehezen tapinthatók, kerekded has';

  @override
  String get bodyObeseLabel => 'Elhízott';

  @override
  String get bodyObeseDesc => 'Vastag zsírréteg, nincs derékvonal';

  @override
  String get activityQuestion => 'Mennyire aktív a macskád?';

  @override
  String get activityLowLabel => 'Alacsony';

  @override
  String get activityLowDesc => 'Főleg alszik, ritkán szaladgál';

  @override
  String get activityMediumLabel => 'Közepes';

  @override
  String get activityMediumDesc => 'Naponta néhányszor játszik';

  @override
  String get activityHighLabel => 'Magas';

  @override
  String get activityHighDesc => 'Mászik, fut, játékokra vadászik';

  @override
  String get waterFactHeadline =>
      'A megfelelő folyadékbevitel védi a macskád veséit és húgyúti egészségét';

  @override
  String get waterFactHighlight => 'veséit és húgyúti egészségét';

  @override
  String get waterFactBody =>
      'A nedvességdús táplálék csökkenti a húgyúti és vesebetegségek kockázatát — minden értékelésnél figyelembe vesszük a hidratációt.';

  @override
  String get neuteredQuestion => 'Ivartalanított-e a macskád?';

  @override
  String get neuteredIntact => 'Ivartalanítás nélküli';

  @override
  String get neuteredNeutered => 'Ivartalanított';

  @override
  String get neuteredPregnant => 'Vemhes';

  @override
  String get neuteredLactating => 'Szoptat';

  @override
  String get coatQuestion => 'Milyen a szőrzete?';

  @override
  String get coatShortHair => 'Rövid szőrű';

  @override
  String get coatLongHair => 'Hosszú szőrű';

  @override
  String get coatHairless => 'Szőrtelen';

  @override
  String get coatFactHeadline => 'A hosszú szőrű macskáknak\ntöbb omega-3 kell';

  @override
  String get coatFactHighlight => 'több omega-3';

  @override
  String get coatFactBody =>
      'Az omega-3 fényes szőrt és egészséges bőrt biztosít.';

  @override
  String get healthQuestion => 'Vannak egészségügyi szempontok?';

  @override
  String get healthNone => 'Nincs';

  @override
  String get healthUrinaryIssues => 'Húgyúti problémák';

  @override
  String get healthKidneyDisease => 'Vesebetegség';

  @override
  String get healthSensitiveStomach => 'Érzékeny gyomor';

  @override
  String get healthSkinAllergies => 'Bőrallergia';

  @override
  String get healthFoodAllergies => 'Ételérzékenység';

  @override
  String get healthDiabetes => 'Cukorbetegség';

  @override
  String get healthDentalProblems => 'Fogproblémák';

  @override
  String get healthHairballIssues => 'Szőrgolyó-problémák';

  @override
  String get healthHeartCondition => 'Szívbetegség';

  @override
  String get healthJointIssues => 'Ízületi vagy mozgásszervi problémák';

  @override
  String get breedQuestion => 'Milyen fajtájú a macskád?';

  @override
  String get breedUnknownPrefix => 'Nem tudod a fajtát? ';

  @override
  String get breedMixedUnknown => 'Keverék / ismeretlen';

  @override
  String get disclaimerTitle => 'Útmutató, nem előírás';

  @override
  String get disclaimerBody1 =>
      'A YuCat a macskád profilja és az egyes termékek összetevői alapján javasol táplálékot. Nem helyettesíti az állatorvosi tanácsadást.';

  @override
  String get disclaimerBody2 =>
      'Diagnosztizált betegségek, illetve a testsúly, étvágy vagy viselkedés hirtelen változása esetén kérjük, fordulj engedéllyel rendelkező állatorvoshoz.';

  @override
  String get catCreateCtaCreateProfile => 'Profil létrehozása';

  @override
  String get catCreateCtaSaveChanges => 'Módosítások mentése';

  @override
  String get catCreateCtaNoneOfThese => 'Ezek egyike sem';

  @override
  String get catCreateErrorCreate =>
      'Nem sikerült létrehozni a profilt. Kérjük, próbáld újra.';

  @override
  String get catCreateErrorSave =>
      'Nem sikerült menteni a módosításokat. Kérjük, próbáld újra.';

  @override
  String get onboardingWelcomeHeadline => 'Dekódold\nminden\nmacska-\neledelt';

  @override
  String get onboardingGetStarted => 'Kezdjük el';

  @override
  String get onboardingLegalPrefix => 'A folytatással elfogadod a\n';

  @override
  String get onboardingTermsOfUse => 'Felhasználási feltételeket';

  @override
  String get onboardingLegalAnd => ' és az ';

  @override
  String get onboardingPrivacyNotice => 'Adatvédelmi tájékoztatót';

  @override
  String get onboardingWhyYucatTitle =>
      'Miért működik\na YuCat\negyedi megközelítése';

  @override
  String get onboardingLetsGo => 'Gyerünk';

  @override
  String get onboardingHealthIntroTitle =>
      'Most mesélj\na macskád\negészségéről';

  @override
  String get onboardingCouldNotOpenLink =>
      'Nem sikerült megnyitni ezt a hivatkozást.';

  @override
  String get onboardingNutritionFactHeadlinePart1 => 'Egy kölyökmacskának\n';

  @override
  String get onboardingNutritionFactHighlight => '2,5× több fehérje';

  @override
  String get onboardingNutritionFactHeadlinePart2 =>
      '\nkell, mint egy idős macskának';

  @override
  String get onboardingNutritionFactBody =>
      'Az életkor, a testsúly, az aktivitás és az egészségi állapot mind befolyásolja, mi kerüljön a macskád tálba.';

  @override
  String get onboardingMerckManualName => 'Merck állatorvosi kézikönyv ';

  @override
  String get onboardingMerckManualQuote =>
      'szerint a macskák fehérje- és aminosavszükséglete az életkorral változik — a kölyökmacskáknak több fehérjére van szükségük, mint a felnőtteknek, és érzékenyebbek az aminosav-egyensúlyra.';

  @override
  String get onboardingSourceLink => 'Ajánlások forrása';

  @override
  String get onboardingScanDemoTitle => 'Tudd meg\nmi van benne';

  @override
  String get onboardingScanDemoSubtitle =>
      'Irányítsd a kamerádat bármely\nmacskaeledel csomagolására és kapj értékelést';

  @override
  String get onboardingProfileIntroTitle => 'Hozzuk létre\na macskád profilját';

  @override
  String get onboardingProfileIntroTime => '2 perc';

  @override
  String get onboardingProfileIntroQuote =>
      'Egy gyors profil egyénre szabott értékeléseket ad minden csomagoláshoz';

  @override
  String get onboardingProfileNameLabel => 'Add meg a macskád nevét';

  @override
  String get onboardingProfileNameHint => 'Mochi';

  @override
  String get onboardingProofChartTitle =>
      'A YuCat\nhosszú távú eredményeket nyújt';

  @override
  String get onboardingProofChartCalloutBold => 'Jobban illeszkedő táplálék ';

  @override
  String get onboardingProofChartCalloutRest =>
      'a macskád igényeihez igazítva, mindössze néhány szkenneléssel';

  @override
  String get onboardingRatingEyebrow => 'Segíts minket fejlődni';

  @override
  String get onboardingRatingTitle => 'Értékelj minket';

  @override
  String get onboardingRatingStatValue => 'Imádott';

  @override
  String get onboardingRatingStatLabel => 'macskaszülők által';

  @override
  String get onboardingRatingPeopleLabel => 'Macskaszülők, mint te';

  @override
  String get onboardingReview1Headline => 'Pontosan erre volt szükségem!';

  @override
  String get onboardingReview1Body =>
      'Beszkenneltem a macskám száraztápját, és végre megértettem, mi van benne. Ugyanabban a héten márkát váltottam, és soha nem néztem vissza.';

  @override
  String get onboardingReview2Headline => 'Imádom ezt az appot!!!';

  @override
  String get onboardingReview2Body =>
      'Fantasztikus app, nagyon könnyű kezelni. Csak feltöltöm a táplálék fotóját, és mindent megmond — nagyszerű!';

  @override
  String get onboardingReview3Headline => 'Életmentő idős macskásoknak';

  @override
  String get onboardingReview3Body =>
      'A YuCat egyetlen délután leszűkítette azokat az idős macskaeledel-opciókat, amelyek kímélők Lulu gyomrával.';

  @override
  String get onboardingReview4Headline => 'Végre magabiztos vagyok';

  @override
  String get onboardingReview4Body =>
      'Régen csak azt vettem, ami éppen akción volt. Most tényleg tudom, melyik eledel illik a kölyköm igényeihez. Teljes megnyugvás.';

  @override
  String get onboardingReview5Headline => 'Annyira egyszerű használni';

  @override
  String get onboardingReview5Body =>
      'Készíts egy fotót, és másodpercek alatt kapsz egy áttekinthető elemzést. Az állatiorvosom is le volt nyűgözve, amikor megmutattam neki.';

  @override
  String get onboardingReview6Headline => 'Két macska, kétféle diéta';

  @override
  String get onboardingReview6Body =>
      'Egy túlsúlyos tarka és egy válogatós Sziámi macska ételének kezelése rémálom volt. A YuCat mindkét esetben könnyűvé tette.';

  @override
  String get onboardingAttributionTitle => 'Hogyan hallottál\nrólunk?';

  @override
  String get onboardingAttributionInstagram => 'Instagram';

  @override
  String get onboardingAttributionTikTok => 'TikTok';

  @override
  String get onboardingAttributionYouTube => 'YouTube';

  @override
  String get onboardingAttributionAppStore => 'App Store keresés';

  @override
  String get onboardingAttributionFriends => 'Barátok/család';

  @override
  String get onboardingNotifPrimerTitle =>
      'Szemmel tartjuk\na macskád eledelét';

  @override
  String get onboardingSetUpReminders => 'Emlékeztetők beállítása';

  @override
  String get onboardingNotifMatchDropped => 'Egyezés csökkent';

  @override
  String get onboardingNotifMockBody =>
      'Luna eledelének megváltozott a receptúrája — nézd meg az új értékelést 🔍';

  @override
  String get onboardingRemindersTitle => 'Miről értesítsünk\ntéged?';

  @override
  String get commonDone => 'Kész';

  @override
  String get onboardingSetUpLater => 'Beállítás később';

  @override
  String get onboardingRemindersOptionFoodChange =>
      'Ha egy mentett eledel megváltozik';

  @override
  String get onboardingRemindersOptionBetterFit => 'Ha jobb egyezést találunk';

  @override
  String get onboardingRemindersOptionMonthly => 'Havi áttekintés';

  @override
  String get onboardingRemindersCalloutPart1 =>
      'Az emlékeztetők egészséges étkezési szokásokat alakítanak ki ';

  @override
  String get onboardingRemindersCalloutBold => '2× gyorsabban';

  @override
  String onboardingSuccessWithName(String name) {
    return '$name\nmár kész!';
  }

  @override
  String get onboardingSuccessNoName => 'Mindennel\nkész vagy!';

  @override
  String get onboardingStartScanning => 'Szkennelés megkezdése';

  @override
  String get onboardingSuccessNotSet => 'Nincs beállítva';

  @override
  String get onboardingSuccessNone => 'Nincs';

  @override
  String get onboardingSuccessRowAge => 'Kor';

  @override
  String get onboardingSuccessRowActivity => 'Aktivitás';

  @override
  String get onboardingSuccessRowBodyCondition => 'Testalkat';

  @override
  String get onboardingSuccessRowCoat => 'Szőrzet';

  @override
  String get onboardingSuccessRowNeuterStatus => 'Ivartalanítás állapota';

  @override
  String get onboardingSuccessRowBreed => 'Fajta';

  @override
  String get onboardingSuccessRowHealthConditions => 'Egészségi állapot';

  @override
  String get onboardingSuccessProfileReadyTitle => 'Profil kész';

  @override
  String get onboardingSuccessProfileReadyBody =>
      'Ezeket az adatokat bármikor szerkesztheted a macskád profiljában.';

  @override
  String get paywallHeroHeadline => 'Tudd pontosan\nmi kerül a tálba';

  @override
  String get paywallHeroHighlight => 'pontosan';

  @override
  String get paywallPlusBadge => 'Plus';

  @override
  String get paywallBadgeBestValue => 'LEGJOBB AJÁNLAT';

  @override
  String get paywallLimitedTimeOffer => 'Korlátozott idejű ajánlat';

  @override
  String paywallLimitedTimeOfferWithSavings(String savings) {
    return 'Korlátozott idejű ajánlat · $savings';
  }

  @override
  String get paywallEverythingYouGet => 'Mindent megkapsz';

  @override
  String get paywallFeatureIngredientScannerTitle => 'Összetevő-szkenner';

  @override
  String get paywallFeatureIngredientScannerBenefit =>
      'Szkennelj bármilyen címkét másodpercek alatt';

  @override
  String get paywallFeaturePersonalizedVerdictsTitle =>
      'Személyre szabott értékelések';

  @override
  String get paywallFeaturePersonalizedVerdictsBenefit =>
      'Igazítva a macskád korához, fajtájához és egészségéhez';

  @override
  String get paywallFeatureUnlimitedScansTitle => 'Korlátlan szkennelés';

  @override
  String get paywallFeatureUnlimitedScansBenefit => 'Soha nincs napi korlát';

  @override
  String get paywallFeatureReformulationAlertsTitle =>
      'Receptúraváltozás-értesítők';

  @override
  String get paywallFeatureReformulationAlertsBenefit =>
      'Azonnal tudj róla, ha megváltozik egy receptúra';

  @override
  String get paywallFeatureSavedFoodsTitle => 'Mentett ételek és előzmények';

  @override
  String get paywallFeatureSavedFoodsBenefit =>
      'Minden átvizsgált étel egy helyen';

  @override
  String get paywallFeatureMultiCatTitle => 'Több macska profilja';

  @override
  String get paywallFeatureMultiCatBenefit =>
      'Személyre szabott profil minden macskádnak';

  @override
  String get paywallSuccessStoriesHeading => 'Sikertörténetek\nmacskaszülőktől';

  @override
  String get paywallTestimonial1Quote =>
      'Évekig csak találgattam. A YuCat egyetlen délután leszűkítette azokat az idős macskaeledel-opciókat, amelyek kímélők Lulu gyomrával.';

  @override
  String get paywallTestimonial1Name => 'Sophie';

  @override
  String get paywallTestimonial1Detail => 'Idős macska · érzékeny gyomor';

  @override
  String get paywallTestimonial2Quote =>
      'Beszkenneltem a kölyökmacskám tápját, és végre megértettem, mi van benne. Ugyanabban a héten márkát váltottam.';

  @override
  String get paywallTestimonial2Name => 'Marco';

  @override
  String get paywallTestimonial2Detail => 'Kölyökmacska · válogatós evő';

  @override
  String get paywallTestimonial3Quote =>
      'Két macska, két teljesen különböző igény. Most már tudom, melyik eledel illik igazán mindkettőjükhöz.';

  @override
  String get paywallTestimonial3Name => 'Priya';

  @override
  String get paywallTestimonial3Detail => 'Több macskás háztartás';

  @override
  String get paywallStatRatingLabel => 'átlagos\nértékelés';

  @override
  String get paywallStatCatParentsLabel => 'macskaszülő\nszerte a világon';

  @override
  String get paywallCancelAnytime => 'Bármikor lemondható.';

  @override
  String get paywallAutoRenewDisclosure =>
      'Az előfizetés automatikusan megújul, hacsak a jelenlegi időszak lejárta előtt legalább 24 órával nem mondod le. Bármikor lemondhatsz az App Store-ban, extra költség nélkül.';

  @override
  String get paywallRestorePurchases => 'Vásárlások visszaállítása';

  @override
  String get commonTerms => 'Feltételek';

  @override
  String get commonPrivacy => 'Adatvédelem';

  @override
  String get commonClose => 'Bezárás';

  @override
  String get paywallPeriodAnnual => 'Éves';

  @override
  String get paywallPeriod6Months => '6 hónap';

  @override
  String get paywallPeriod3Months => '3 hónap';

  @override
  String get paywallPeriod2Months => '2 hónap';

  @override
  String get paywallPeriodMonthly => 'Havi';

  @override
  String get paywallPeriodWeekly => 'Heti';

  @override
  String get paywallPeriodLifetime => 'Élethosszig';

  @override
  String get paywallCtaUnlockPlus => 'Yucat Plus megnyitása';

  @override
  String get paywallSkipDebug => 'Fizetési kapu kihagyása (debug)';

  @override
  String get paywallErroriOSOnly => 'Az előfizetések csak iOS-en érhetők el.';

  @override
  String get paywallErrorCouldNotLoadPlans =>
      'Nem sikerült betölteni az előfizetési csomagokat.';

  @override
  String get paywallErrorNoPlansAvailable =>
      'Jelenleg nincs elérhető előfizetési csomag.';

  @override
  String get paywallErrorPurchaseNotComplete =>
      'A vásárlás nem fejeződött be. Kérjük, próbáld újra.';

  @override
  String get paywallErrorPurchaseFailed =>
      'A vásárlás sikertelen volt. Kérjük, próbáld újra.';

  @override
  String get paywallErrorSomethingWentWrong =>
      'Valami hiba történt. Kérjük, próbáld újra.';

  @override
  String get paywallErrorNoActiveSubscription =>
      'Nem található aktív előfizetés.';

  @override
  String get paywallErrorRestoreFailed =>
      'Nem sikerült visszaállítani a vásárlásokat. Kérjük, próbáld újra.';

  @override
  String get commonGoBack => 'Vissza';

  @override
  String get productDetailLoadError => 'Nem sikerült betölteni ezt a terméket.';

  @override
  String get productDetailOverallAnalysis => 'ÁLTALÁNOS ELEMZÉS';

  @override
  String get productDetailAiIdentifiedPill => '* AI AZONOSÍTOTT';

  @override
  String get productDetailMyCatScore => 'A macskám pontszáma';

  @override
  String get productDetailNoCatPrompt =>
      'Hozz létre macska-profilt, hogy személyre szabott pontszámot láss a macskádnak.';

  @override
  String get productDetailAddACat => 'Macska hozzáadása';

  @override
  String get productDetailForYourCats => 'A macskáidnak';

  @override
  String productDetailCatsCount(int count) {
    return '$count MACSKA';
  }

  @override
  String get productDetailPickACat =>
      'Válassz macskát, hogy lásd, hogyan illik ez a termék a profiljához.';

  @override
  String get productDetailPersonalizedScore =>
      'Személyre szabott pontszám a macskád profilja alapján.';

  @override
  String get productDetailDimHealth => 'EGÉSZSÉG';

  @override
  String get productDetailDimWeight => 'TESTSÚLY';

  @override
  String get productDetailDimAge => 'KOR';

  @override
  String get productDetailDimActivity => 'AKTIVITÁS';

  @override
  String get productDetailDimNeuteredStatus => 'IVARTALANÍTÁS';

  @override
  String get productDetailDimBreed => 'FAJTA';

  @override
  String get productDetailNeutralFit =>
      'Nincs erős egyezés ennél a macskánál — semleges illeszkedés.';

  @override
  String get productDetailAgeGroupKitten => 'Kölyök';

  @override
  String get productDetailAgeGroupAdult => 'Felnőtt';

  @override
  String get productDetailAgeGroupSenior => 'Idős';

  @override
  String get productDetailNutrientProtein => 'Fehérje';

  @override
  String get productDetailNutrientFat => 'Zsír';

  @override
  String get productDetailNutrientMoisture => 'Nedvesség';

  @override
  String get productDetailNutrientFiber => 'Rost';

  @override
  String get productDetailNutrientCarbs => 'Szénhidrát';

  @override
  String get productDetailVerdictExcellent => 'Kiváló mindennapi választás';

  @override
  String get productDetailVerdictGood => 'Megbízható mindennapi választás';

  @override
  String get productDetailVerdictAverage => 'Elfogadható választás';

  @override
  String get productDetailVerdictPoor => 'Érdemes kihagyni';

  @override
  String get productDetailNoDataHeadline => 'Még nem találtuk meg az adatokat';

  @override
  String get productDetailNoDataBody =>
      'Nem találtuk meg a termék garantált beltartalmi adatait. Próbáld meg beolvasni a tápértékcímkét, vagy nézz vissza később – tovább keressük.';

  @override
  String get productDetailNoDataCatsNote =>
      'Amint meglesznek a tápértékadatok, megmutatjuk, mennyire illik a macskáidhoz.';

  @override
  String get productDetailImagePlaceholder => 'TERMÉK';

  @override
  String productDetailScoreSemantics(int score, int maxScore) {
    return '$score pont $maxScore-ból';
  }

  @override
  String get assessmentKittenHighProtein =>
      'Magas fehérjetartalom (>35%), ami kedvező a kölyökmacskák számára';

  @override
  String get assessmentKittenHighFat =>
      'Magas zsírtartalom (>18%), ami támogatja a kölyökmacskák növekedését';

  @override
  String get assessmentKittenSeniorFormula =>
      'Az idős macskáknak szánt receptúra nem ideális kölyökmacskák számára';

  @override
  String get assessmentKittenLowProtein =>
      'Az alacsony fehérjetartalom (<28%) nem feltétlenül felel meg a kölyökmacskák szükségleteinek';

  @override
  String get assessmentSeniorModerateProtein =>
      'Mérsékelt fehérjetartalom (30–35%) megfelelő az idős macskák számára';

  @override
  String get assessmentSeniorHighFat =>
      'Nagyon magas zsírtartalom (>20%) nem biztos, hogy megfelelő idős macskák számára';

  @override
  String get assessmentSeniorJointSupport =>
      'Ízülettámogató összetevőket tartalmaz (pl. glükozamin, kondroitin)';

  @override
  String get assessmentSeniorKidneyFriendly =>
      'Vesekímélő receptúra (pl. alacsonyabb foszfortartalom)';

  @override
  String get assessmentUnderweightHighCalories =>
      'Magas kalóriatartalom (>380 kcal/100g) segíthet a sovány macskának súlyt gyarapítani';

  @override
  String get assessmentUnderweightHighFat =>
      'Magas zsírtartalom (>18%) támogatja a súlygyarapodást sovány macskáknál';

  @override
  String get assessmentOverweightHighCalories =>
      'Magas kalóriatartalom (>360 kcal/100g) nem biztos, hogy ideális egy túlsúlyos macskának';

  @override
  String get assessmentOverweightLowCalories =>
      'Alacsonyabb kalóriatartalom (<320 kcal/100g) segít a testsúly kezelésében túlsúlyos macskáknál';

  @override
  String get assessmentOverweightHighFiber =>
      'Magasabb rosttartalom (>4%) segíthet a teltségérzet fokozásában túlsúlyos macskáknál';

  @override
  String get assessmentObeseHighFat =>
      'Magas zsírtartalom (>15%) nem megfelelő elhízott macskák számára';

  @override
  String get assessmentObeseHighCalories =>
      'Magas kalóriatartalom (>330 kcal/100g) nem ideális elhízott macskák számára';

  @override
  String get assessmentObeseLeanProtein =>
      'Sovány, magas fehérjetartalmú receptúra (>40% fehérje, <12% zsír) kedvező elhízott macskák számára';

  @override
  String get assessmentLowActivityHighCalories =>
      'Magas kalóriatartalom (>360 kcal/100g) nem biztos, hogy megfelelő egy kevésbé aktív macskának';

  @override
  String get assessmentLowActivityModerateCalories =>
      'Mérsékelt kalóriatartalom (<330 kcal/100g) jobb a kevésbé aktív macskák számára';

  @override
  String get assessmentHighActivityHighCalories =>
      'Magasabb kalóriatartalom (>380 kcal/100g) támogatja a nagyon aktív macskát';

  @override
  String get assessmentHighActivityHighProtein =>
      'Magas fehérjetartalom (>35%) segít fenntartani az izomzatot aktív macskáknál';

  @override
  String get assessmentNeuteredHighCalories =>
      'Nagyon kalóriadús táplálék (>380 kcal/100g) elősegítheti a súlygyarapodást ivartalanított macskáknál';

  @override
  String get assessmentNeuteredUrinarySupport =>
      'Húgyúttámogató összetevőket tartalmaz, kedvező ivartalanított macskák számára';

  @override
  String get assessmentNeuteredHighFat =>
      'Magas zsírtartalom (>16%) nem biztos, hogy ideális ivartalanított macskák számára';

  @override
  String get assessmentPregnantHighProtein =>
      'Nagyon magas fehérjetartalom (>35%) támogatja a vemhes/szoptató macskák megnövekedett szükségleteit';

  @override
  String get assessmentPregnantHighFat =>
      'Magas zsírtartalom (>20%) extra energiát biztosít a vemhes/szoptató macskák számára';

  @override
  String get assessmentPregnantHighCalories =>
      'Nagyon kalóriadús táplálék (>400 kcal/100g) segít kielégíteni az energiaigényt vemhesség/szoptatás alatt';

  @override
  String get assessmentMaineCoonJointSupport =>
      'Ízülettámogató összetevőket tartalmaz, kedvező Maine Coon macskák számára';

  @override
  String get assessmentMaineCoonHighProtein =>
      'Magas fehérjetartalom (>35%) támogatja a nagy testű Maine Coon macskákat';

  @override
  String get assessmentPersianHairball =>
      'Szőrgolyó-ellenes receptúra (4–6% rosttartalom vagy szőrgolyó-kontroll állítás)';

  @override
  String get assessmentPersianOmega3 =>
      'Omega-3 gazdag összetevőket tartalmaz, kedvező a Perzsa macskák szőrzetének/bőrének';

  @override
  String get assessmentPersianHighCarbs =>
      'Magas szénhidráttartalom (>30%) nem biztos, hogy ideális Perzsa macskák számára';

  @override
  String get assessmentSiameseDigestible =>
      'Könnyen emészthető fehérjéket használ, kedvező Sziámi macskák számára';

  @override
  String get assessmentSiameseFillers =>
      'Sok töltőanyagot tartalmaz (kukorica, búza, szója), ami nem biztos, hogy megfelelő Sziámi macskák számára';

  @override
  String get assessmentSphynxHighFat =>
      'Magasabb zsírtartalom (>18%) támogathatja a Sphynx macskák bőregészségét';

  @override
  String get assessmentSphynxLowFat =>
      'Alacsony zsírtartalmú receptúra (<12%) nem biztos, hogy elegendő támogatást nyújt a Sphynx macskák bőrének';

  @override
  String get assessmentBritishHighCalories =>
      'Magas kalóriatartalmú táplálék elősegítheti a súlygyarapodást Brit rövidszőrű macskáknál';

  @override
  String get assessmentBritishWeightManagement =>
      'Testsúlykezelő receptúra megfelelő Brit rövidszőrű macskák számára';

  @override
  String get assessmentBengalHighProtein =>
      'Magas fehérjetartalom (>38%) megfelel a Bengál macskák energiaszükségletének';

  @override
  String get assessmentBengalLowProtein =>
      'Alacsony fehérjetartalom (<30%) nem biztos, hogy elegendő Bengál macskák számára';

  @override
  String get assessmentUrinaryLowAsh =>
      'Alacsony hamutartalommal készült receptúra, kedvező húgyúti problémák esetén';

  @override
  String get assessmentUrinarySupport =>
      'Húgyúttámogató összetevőket tartalmaz, mint az áfonya vagy a DL-metionin';

  @override
  String get assessmentUrinaryHighMinerals =>
      'Magas ásványianyag-tartalom nem biztos, hogy ideális húgyúti problémák esetén';

  @override
  String get assessmentKidneyHighProtein =>
      'Magas fehérjetartalom (>32%) nem biztos, hogy ideális vesebetegség esetén';

  @override
  String get assessmentKidneyPhosphorus =>
      'Foszforrásokat tartalmaz, amelyek problematikusak lehetnek vesebetegség esetén';

  @override
  String get assessmentKidneyRenalSupport => 'Vesekímélő diétaként formulázott';

  @override
  String get assessmentSensitiveStomachLimitedIngredient =>
      'Kevés összetevős receptúra segíthet érzékeny gyomor esetén';

  @override
  String get assessmentSensitiveStomachLongIngredients =>
      'A nagyon hosszú összetevőlista nem biztos, hogy megfelelő érzékeny gyomor esetén';

  @override
  String get assessmentFoodAllergyCommonAllergens =>
      'Általános allergéneket tartalmaz, mint csirke, hal vagy marha';

  @override
  String get assessmentFoodAllergyNovelProteins =>
      'Szokatlan fehérjéket használ (pl. kacsa, szarvas), amelyek segíthetnek allergia esetén';

  @override
  String get assessmentSkinAllergyOmega3 =>
      'Omega-3 gazdag összetétel támogathatja a bőr és szőrzet egészségét';

  @override
  String get assessmentSkinAllergyArtificialColor =>
      'Mesterséges színezékeket tartalmaz, amelyek súlyosbíthatják a bőrallergiát';

  @override
  String get assessmentDiabetesHighCarbs =>
      'Magas szénhidráttartalom (>20%) kevésbé alkalmas cukorbeteg macskák számára';

  @override
  String get assessmentDiabetesHighProtein =>
      'Nagyon magas fehérjetartalom (>40%) támogathatja a vércukorkontrollt cukorbetegség esetén';

  @override
  String get assessmentDentalHighMoisture =>
      'A magas nedvességtartalmú (nedves) táplálék könnyebben fogyasztható fogproblémák esetén';

  @override
  String get assessmentDentalLargeKibble =>
      'A nagyon nagy száraztáp-szemek nehezen rághatók fogproblémák esetén';

  @override
  String get assessmentHairballControl =>
      'Szőrgolyó-kontroll diéta (4–6% rosttartalom vagy szőrgolyó-kontroll állítás)';

  @override
  String get homeScanProduct => 'Termék szkennelése';

  @override
  String get homeScanProductSubtitle => 'Készíts fotót a csomagolásról';

  @override
  String get homeGreetingHey => 'Üdv újra';

  @override
  String get homeGreetingWelcome => 'Üdvözlünk';

  @override
  String homeReadyForCat(String name) {
    return 'Keressünk eledelt $name számára?';
  }

  @override
  String get homeReadyToScan => 'Kész vagy beszkennelni egy terméket?';

  @override
  String get homeAddCatTitle => 'Add hozzá a macskádat';

  @override
  String get homeAddCatBody =>
      'Hozz létre profilt személyre szabott élelmiszer-pontszámokhoz.';

  @override
  String get homeAddCatButton => 'Macska hozzáadása';

  @override
  String get homeSavedProductsTitle => 'Mentett termékek';

  @override
  String get homeSeeAll => 'Összes megtekintése';

  @override
  String get homeNoSavedProductsTitle => 'Még nincs mentett termék';

  @override
  String get homeNoSavedProductsBody =>
      'Koppints a könyvjelzőre egy terméken, hogy ide mentsd.';

  @override
  String get homeLoadingEyebrow => 'Egy pillanat';

  @override
  String get homeLoadingMsgReading => 'Címke beolvasása…';

  @override
  String get homeLoadingMsgSniffing => 'Összetevők szimatolása…';

  @override
  String get homeLoadingMsgMatching => 'Egyeztetés az adatbázisunkkal…';

  @override
  String get homeLoadingMsgCrunching => 'Számok elemzése…';

  @override
  String get homeLoadingMsgAlmost => 'Mindjárt kész…';

  @override
  String get homeCameraUnavailable => 'A kamera nem elérhető';

  @override
  String get homeCameraUnavailableBody =>
      'Engedélyezd a YuCat kameraelérését a Beállításokban, vagy válassz fotót a galériádból.';

  @override
  String get homeChooseFromGallery => 'Választás galériából';

  @override
  String get homeScannerHint => 'Irányítsd a termék címkéjére';

  @override
  String get homeErrorProductNotFound => 'A termék nem található';

  @override
  String get homeErrorTimeout =>
      'A kérés túl sokáig tartott. Kérjük, próbáld újra.';

  @override
  String get homeErrorNoInternet =>
      'Nincs internetkapcsolat. Kérjük, ellenőrizd a hálózatot és próbáld újra.';

  @override
  String get homeErrorGeneric => 'Valami hiba történt. Kérjük, próbáld újra.';

  @override
  String get homeCatKitten => 'Kölyök';

  @override
  String get homeCatAdult => 'Felnőtt';

  @override
  String get homeCatSenior => 'Idős';

  @override
  String get homeCatUnderweight => 'Sovány';

  @override
  String get homeCatHealthyWeight => 'Egészséges testsúly';

  @override
  String get homeCatOverweight => 'Túlsúlyos';

  @override
  String get homeCatObese => 'Elhízott';

  @override
  String homeCatConditionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count egészségügyi szempont',
      one: '1 egészségügyi szempont',
    );
    return '$_temp0';
  }

  @override
  String get scanHistoryTitle => 'Szkennelési előzmények';

  @override
  String scanHistoryScanCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count szkennelés',
      one: '1 szkennelés',
    );
    return '$_temp0';
  }

  @override
  String get scanHistoryEmptyTitle => 'Még nincs szkennelés';

  @override
  String get scanHistoryEmptyBody =>
      'Az általad szkennelt ételek itt jelennek meg.';

  @override
  String get commonTryAgain => 'Próbáld újra';

  @override
  String get searchTabTitle => 'Keresés';

  @override
  String get searchHint => 'Keress macskaeledelre';

  @override
  String get searchRecentLabel => 'Legutóbbi';

  @override
  String get searchClearLabel => 'Törlés';

  @override
  String get searchPopularBrands => 'Népszerű márkák';

  @override
  String get searchNoMatchesHeadline => 'Nincs találat';

  @override
  String get searchNoMatchesBody =>
      'Próbálj más nevet, vagy böngéssz a népszerű márkák között.';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count találat',
      one: '1 találat',
    );
    return '$_temp0';
  }

  @override
  String get searchErrorBody => 'Hiba történt a keresés közben.';

  @override
  String get bottomNavSearch => 'Keresés';

  @override
  String get bottomNavHome => 'Főoldal';

  @override
  String get bottomNavProfile => 'Profil';

  @override
  String get productListingEmpty => 'Nem találhatók termékek ennél a márkánál.';

  @override
  String get commonAgeGroupKitten => 'Kölyök';

  @override
  String get commonAgeGroupAdult => 'Felnőtt';

  @override
  String get commonAgeGroupSenior => 'Idős';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileLinkError => 'Nem sikerült megnyitni ezt a hivatkozást.';

  @override
  String get profileSubscriptionLinkError =>
      'Nem sikerült megnyitni az App Store előfizetéseket.';

  @override
  String profileEmailError(String email) {
    return 'Nem sikerült megnyitni: $email.';
  }

  @override
  String get profilePrivacyError =>
      'Nem sikerült megnyitni az Adatvédelmi szabályzatot.';

  @override
  String get profileTermsError =>
      'Nem sikerült megnyitni a Felhasználási feltételeket.';

  @override
  String get profileSubscriptionActive => 'Aktív előfizetés';

  @override
  String get profileRestorePurchases => 'Vásárlások visszaállítása';

  @override
  String get profileManageSubscription => 'Előfizetés kezelése';

  @override
  String get profileYourCats => 'Macskáid';

  @override
  String get profileManage => 'Kezelés';

  @override
  String get profileAddCat => 'Macska hozzáadása';

  @override
  String get profileSavedProductsLabel => 'Mentett termékek';

  @override
  String get profileSavedProductsEmpty => 'Még nincs mentett termék';

  @override
  String profileSavedProductsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count termék mentve',
      one: '1 termék mentve',
    );
    return '$_temp0';
  }

  @override
  String get profileScanHistoryLabel => 'Szkennelési előzmények';

  @override
  String get profileScanHistoryEmpty => 'Még nincs szkennelés';

  @override
  String profileScanHistoryCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count szkennelés',
      one: '1 szkennelés',
    );
    return '$_temp0';
  }

  @override
  String get profileContactUs => 'Kapcsolat';

  @override
  String get profilePrivacyPolicy => 'Adatvédelmi szabályzat';

  @override
  String get profileTermsAndConditions => 'Általános szerződési feltételek';

  @override
  String get profileResetOnboarding => 'Bemutató visszaállítása';

  @override
  String get profileDebugOnly => 'Csak debug';

  @override
  String get profileRestoreNotAvailable =>
      'A visszaállítás csak iOS-en érhető el.';

  @override
  String get profileRestoreSuccess => 'Az előfizetés sikeresen visszaállítva!';

  @override
  String get profileNoSubscriptionFound => 'Nem található aktív előfizetés.';

  @override
  String get profileRestoreError =>
      'Nem sikerült visszaállítani a vásárlásokat. Kérjük, próbáld újra.';

  @override
  String get savedProductsTitle => 'Mentett termékek';

  @override
  String savedProductsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count termék',
      one: '1 termék',
    );
    return '$_temp0';
  }

  @override
  String get savedProductsEmptyHeadline => 'Még nincs mentett termék';

  @override
  String get savedProductsEmptyBody =>
      'Tedd könyvjelzőbe a termékeket, hogy megtaláld őket itt';

  @override
  String get catDetailDeleteError =>
      'Nem sikerült törölni a macskádat. Kérjük, próbáld újra.';

  @override
  String catDetailDeleteTitle(String name) {
    return 'Törlöd $name profilját?';
  }

  @override
  String get catDetailDeleteBody => 'Ez véglegesen törli a profilt.';

  @override
  String get catDetailDeleteCancel => 'Mégse';

  @override
  String get catDetailDeleteConfirm => 'Törlés';

  @override
  String get catDetailProfileCompletion => 'Profil kitöltöttsége';

  @override
  String get catDetailNotSet => 'Nincs beállítva';

  @override
  String get catDetailBreedLabel => 'Fajta';

  @override
  String get catDetailAgeLabel => 'Kor';

  @override
  String get catDetailAgeYears => 'év';

  @override
  String get catDetailGenderLabel => 'Nem';

  @override
  String get catDetailCoatLabel => 'Szőrzet';

  @override
  String get catDetailActivityLabel => 'Aktivitás';

  @override
  String get catDetailBodyLabel => 'Testalkat';

  @override
  String get catDetailStatusLabel => 'Állapot';

  @override
  String get catDetailStatusNeutered => 'Ivartalanított';

  @override
  String get catDetailStatusSpayed => 'Ivartalanított (nőstény)';

  @override
  String get catDetailDetailsSection => 'Részletek';

  @override
  String get catDetailActivityModerate => 'Közepes';

  @override
  String get catDetailBodyNormal => 'Normál';

  @override
  String get catDetailCoatMedium => 'Közepes szőrzet';

  @override
  String get catDetailHealthConditionsSection => 'Egészségi állapot';

  @override
  String get catDetailDeleteProfile => 'Profil törlése';

  @override
  String get catListingTitle => 'Macskáid';

  @override
  String get catListingErrorGeneric => 'Valami hiba történt';

  @override
  String get catListingEmptyHeadline => 'Még nincs macska';

  @override
  String get catListingEmptyBody =>
      'Add hozzá az első macskádat személyre szabott ajánlásokért';

  @override
  String get catListingEmptyCta => 'Add hozzá a macskádat';

  @override
  String get catListingAddAnotherCat => 'Újabb macska hozzáadása';

  @override
  String get catListingCreateNewProfile => 'Új profil létrehozása';

  @override
  String get catListingCatFallback => 'Macska';

  @override
  String catListingConditionsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count egészségügyi szempont',
      one: '1 egészségügyi szempont',
    );
    return '$_temp0';
  }
}
