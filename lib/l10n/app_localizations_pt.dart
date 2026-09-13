// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get commonNext => 'Seguinte';

  @override
  String get commonGotIt => 'Entendi';

  @override
  String get commonSkip => 'Saltar';

  @override
  String get catNameQuestion => 'Como se chama o seu gato?';

  @override
  String get catNameLabel => 'Dê um nome ao seu gato';

  @override
  String get catNameHint => 'Caramelo';

  @override
  String get catNameValidationEmpty => 'Introduza um nome para o gato';

  @override
  String get genderQuestion => 'Qual é o sexo do seu gato?';

  @override
  String get genderFemale => 'Fêmea';

  @override
  String get genderMale => 'Macho';

  @override
  String get photoTapHint => 'Toque aqui';

  @override
  String get photoQuestion => 'Adicione uma foto do seu gato';

  @override
  String get photoSheetTitle => 'Adicionar uma foto';

  @override
  String get photoSheetTakePhoto => 'Tirar uma foto';

  @override
  String get photoSheetUploadLibrary => 'Carregar da galeria';

  @override
  String get photoCameraError =>
      'Não foi possível aceder à câmara. Verifique as permissões nas Definições.';

  @override
  String get photoLibraryError =>
      'Não foi possível abrir as suas fotos. Verifique as permissões nas Definições.';

  @override
  String get ageQuestion => 'Que idade tem o seu gato?';

  @override
  String get ageKnowBirthday => 'Sabe a data de nascimento exata?';

  @override
  String ageBornOn(String date) {
    return 'Nasceu a $date';
  }

  @override
  String get ageChangeBirthday => 'Alterar';

  @override
  String get ageBirthdayPickerHelp => 'Aniversário do seu gato';

  @override
  String get ageColumnYears => 'Anos';

  @override
  String get ageColumnMonths => 'Meses';

  @override
  String get ageUnitYear => 'a';

  @override
  String get ageUnitMonth => 'm';

  @override
  String ageStageKitten(String years) {
    return 'Cerca de $years anos — um gatinho.';
  }

  @override
  String ageStageAdult(String years) {
    return 'Cerca de $years anos — um adulto.';
  }

  @override
  String ageStageSenior(String years) {
    return 'Cerca de $years anos — um gato sénior.';
  }

  @override
  String get bodyConditionQuestion => 'Qual é a forma física do seu gato?';

  @override
  String get bodyUnderweightLabel => 'Abaixo do peso';

  @override
  String get bodyUnderweightDesc =>
      'Costelas e coluna à vista, muito pouca gordura';

  @override
  String get bodyNormalLabel => 'No ponto certo';

  @override
  String get bodyNormalDesc => 'Costelas fáceis de apalpar, cintura visível';

  @override
  String get bodyOverweightLabel => 'Com excesso de peso';

  @override
  String get bodyOverweightDesc =>
      'Costelas difíceis de apalpar, barriga arredondada';

  @override
  String get bodyObeseLabel => 'Obeso';

  @override
  String get bodyObeseDesc => 'Muita gordura, sem cintura';

  @override
  String get activityQuestion => 'Quão ativo é o seu gato?';

  @override
  String get activityLowLabel => 'Baixa';

  @override
  String get activityLowDesc => 'Dorme quase sempre, raramente persegue';

  @override
  String get activityMediumLabel => 'Média';

  @override
  String get activityMediumDesc => 'Brinca várias vezes ao dia';

  @override
  String get activityHighLabel => 'Alta';

  @override
  String get activityHighDesc => 'Trepa, corre e caça brinquedos';

  @override
  String get waterFactHeadline =>
      'A hidratação protege os rins e a saúde urinária do seu gato';

  @override
  String get waterFactHighlight => 'os rins e a saúde urinária';

  @override
  String get waterFactBody =>
      'A comida rica em humidade reduz o risco de problemas urinários e renais — temos a hidratação em conta em cada avaliação.';

  @override
  String get neuteredQuestion => 'O seu gato é castrado ou esterilizado?';

  @override
  String get neuteredIntact => 'Inteiro';

  @override
  String get neuteredNeutered => 'Castrado / Esterilizado';

  @override
  String get neuteredPregnant => 'Gestante';

  @override
  String get neuteredLactating => 'Lactante';

  @override
  String get coatQuestion => 'Que tipo de pelagem?';

  @override
  String get coatShortHair => 'Pelo curto';

  @override
  String get coatLongHair => 'Pelo comprido';

  @override
  String get coatHairless => 'Sem pelo';

  @override
  String get coatFactHeadline =>
      'Os gatos de pelo comprido precisam de\nmais ómega-3';

  @override
  String get coatFactHighlight => 'mais ómega-3';

  @override
  String get coatFactBody =>
      'O ómega-3 mantém a pelagem brilhante e a pele saudável.';

  @override
  String get coatFactHeadlineShort =>
      'Os gatos de pelo curto beneficiam de\nmais fibra';

  @override
  String get coatFactHighlightShort => 'mais fibra';

  @override
  String get coatFactBodyShort =>
      'A fibra ajuda a reduzir as bolas de pelo da higiene.';

  @override
  String get coatFactHeadlineHairless =>
      'Os gatos sem pelo queimam\nmais energia';

  @override
  String get coatFactHighlightHairless => 'mais energia';

  @override
  String get coatFactBodyHairless =>
      'Sem pelagem, precisam de mais calorias para se manterem quentes.';

  @override
  String get healthQuestion => 'Alguma consideração de saúde?';

  @override
  String get healthNone => 'Nenhuma';

  @override
  String get healthUrinaryIssues => 'Problemas urinários';

  @override
  String get healthKidneyDisease => 'Doença renal';

  @override
  String get healthSensitiveStomach => 'Estômago sensível';

  @override
  String get healthSkinAllergies => 'Alergias na pele';

  @override
  String get healthFoodAllergies => 'Alergias alimentares';

  @override
  String get healthDiabetes => 'Diabetes';

  @override
  String get healthDentalProblems => 'Problemas dentários';

  @override
  String get healthHairballIssues => 'Bolas de pelo';

  @override
  String get healthHeartCondition => 'Problema cardíaco';

  @override
  String get healthJointIssues => 'Problemas de articulações ou mobilidade';

  @override
  String get breedQuestion => 'Qual é a raça do seu gato?';

  @override
  String get breedUnknownPrefix => 'Não sabe a raça? ';

  @override
  String get breedMixedUnknown => 'Sem raça / desconhecida';

  @override
  String get breedSearchHint => 'Pesquisar raças';

  @override
  String breedSearchNoResults(String query) {
    return 'Nenhuma raça corresponde a «$query»';
  }

  @override
  String get breedNameAbyssinian => 'Abissínio';

  @override
  String get breedNameAmericanBobtail => 'American Bobtail';

  @override
  String get breedNameAmericanCurl => 'American Curl';

  @override
  String get breedNameAmericanShorthair => 'American Shorthair';

  @override
  String get breedNameBalinese => 'Balinês';

  @override
  String get breedNameBengal => 'Bengal';

  @override
  String get breedNameBirman => 'Sagrado da Birmânia';

  @override
  String get breedNameBombay => 'Bombaim';

  @override
  String get breedNameBritishShorthair => 'British Shorthair';

  @override
  String get breedNameBurmese => 'Burmês';

  @override
  String get breedNameBurmilla => 'Burmilla';

  @override
  String get breedNameChartreux => 'Chartreux';

  @override
  String get breedNameCornishRex => 'Cornish Rex';

  @override
  String get breedNameCymric => 'Cymric';

  @override
  String get breedNameDevonRex => 'Devon Rex';

  @override
  String get breedNameDomesticLonghair => 'Doméstico de pelo comprido';

  @override
  String get breedNameDomesticShorthair => 'Doméstico de pelo curto';

  @override
  String get breedNameDonskoy => 'Donskoy';

  @override
  String get breedNameEgyptianMau => 'Mau egípcio';

  @override
  String get breedNameEuropeanShorthair => 'Europeu de pelo curto';

  @override
  String get breedNameExoticShorthair => 'Exotic Shorthair';

  @override
  String get breedNameHavanaBrown => 'Havana Brown';

  @override
  String get breedNameHimalayan => 'Himalaio';

  @override
  String get breedNameJapaneseBobtail => 'Bobtail japonês';

  @override
  String get breedNameKorat => 'Korat';

  @override
  String get breedNameLaPerm => 'LaPerm';

  @override
  String get breedNameMaineCoon => 'Maine Coon';

  @override
  String get breedNameManx => 'Manx';

  @override
  String get breedNameMunchkin => 'Munchkin';

  @override
  String get breedNameNebelung => 'Nebelung';

  @override
  String get breedNameNorwegianForestCat => 'Floresta da Noruega';

  @override
  String get breedNameOcicat => 'Ocicat';

  @override
  String get breedNameOrientalShorthair => 'Oriental de pelo curto';

  @override
  String get breedNamePersian => 'Persa';

  @override
  String get breedNamePeterbald => 'Peterbald';

  @override
  String get breedNameRagamuffin => 'Ragamuffin';

  @override
  String get breedNameRagdoll => 'Ragdoll';

  @override
  String get breedNameRussianBlue => 'Azul russo';

  @override
  String get breedNameSavannah => 'Savannah';

  @override
  String get breedNameScottishFold => 'Scottish Fold';

  @override
  String get breedNameScottishStraight => 'Scottish Straight';

  @override
  String get breedNameSelkirkRex => 'Selkirk Rex';

  @override
  String get breedNameSiamese => 'Siamês';

  @override
  String get breedNameSiberian => 'Siberiano';

  @override
  String get breedNameSingapura => 'Singapura';

  @override
  String get breedNameSnowshoe => 'Snowshoe';

  @override
  String get breedNameSomali => 'Somali';

  @override
  String get breedNameSphynx => 'Sphynx';

  @override
  String get breedNameTonkinese => 'Tonquinês';

  @override
  String get breedNameToyger => 'Toyger';

  @override
  String get breedNameTurkishAngora => 'Angorá turco';

  @override
  String get breedNameTurkishVan => 'Van turco';

  @override
  String get disclaimerTitle => 'Orientamos, não receitamos';

  @override
  String get disclaimerBody1 =>
      'A YuCat sugere alimentos com base no perfil do seu gato e nos ingredientes que lemos de cada produto. Não substitui o aconselhamento veterinário.';

  @override
  String get disclaimerBody2 =>
      'Perante doenças diagnosticadas ou alterações bruscas de peso, apetite ou comportamento, consulte um médico veterinário.';

  @override
  String get catCreateCtaCreateProfile => 'Criar perfil';

  @override
  String get catCreateCtaSaveChanges => 'Guardar alterações';

  @override
  String get catCreateCtaNoneOfThese => 'Nenhuma destas';

  @override
  String get catCreateErrorCreate =>
      'Não foi possível criar o perfil. Tente novamente.';

  @override
  String get catCreateErrorSave =>
      'Não foi possível guardar as alterações. Tente novamente.';

  @override
  String get onboardingWelcomeHeadline => 'Decifre\ncada\nalimento\npara gatos';

  @override
  String get onboardingGetStarted => 'Começar';

  @override
  String get onboardingLegalPrefix => 'Ao continuar aceita os nossos\n';

  @override
  String get onboardingTermsOfUse => 'Termos de Utilização';

  @override
  String get onboardingLegalAnd => ' e ';

  @override
  String get onboardingPrivacyNotice => 'Aviso de Privacidade';

  @override
  String get onboardingWhyYucatTitle =>
      'Porque é que a\nabordagem única\nda YuCat funciona';

  @override
  String get onboardingLetsGo => 'Vamos!';

  @override
  String get onboardingHealthIntroTitle =>
      'Agora conte-nos\nsobre a saúde\ndo seu gato';

  @override
  String get onboardingCouldNotOpenLink =>
      'Não foi possível abrir esta ligação.';

  @override
  String get onboardingNutritionFactHeadlinePart1 => 'Um gatinho precisa de\n';

  @override
  String get onboardingNutritionFactHighlight => '2,5× mais proteína';

  @override
  String get onboardingNutritionFactHeadlinePart2 => '\ndo que um gato idoso';

  @override
  String get onboardingNutritionFactBody =>
      'A fase de vida, o peso, a atividade e as condições de saúde mudam o que deve estar na tigela do seu gato.';

  @override
  String get onboardingMerckManualName => 'Manual Veterinário Merck ';

  @override
  String get onboardingMerckManualQuote =>
      'indica que as necessidades de proteína e aminoácidos de um gato mudam com a fase de vida — os gatinhos precisam de mais proteína do que os adultos e são mais sensíveis ao equilíbrio de aminoácidos.';

  @override
  String get onboardingSourceLink => 'Fonte das recomendações';

  @override
  String get onboardingScanDemoTitle => 'Saiba\no que há dentro';

  @override
  String get onboardingScanDemoSubtitle =>
      'Aponte a câmara para qualquer\nalimento para gatos e obtenha um veredito';

  @override
  String get onboardingRecipesTitle => 'Receitas e artigos\npara o seu gato';

  @override
  String get onboardingRecipesSubtitle =>
      'Receitas caseiras adaptadas ao perfil dele,\ne artigos para o compreender melhor.';

  @override
  String get onboardingProfileIntroTitle =>
      'Vamos configurar\no perfil do seu gato';

  @override
  String get onboardingProfileIntroTime => '2 min';

  @override
  String get onboardingProfileIntroQuote =>
      'Um perfil rápido desbloqueia vereditos personalizados em cada saco — e um registo de saúde que sabe o que está a vencer';

  @override
  String get onboardingProfileNameLabel => 'Dê um nome ao seu gato';

  @override
  String get onboardingProfileNameHint => 'Mochi';

  @override
  String get onboardingProofChartTitle =>
      'A YuCat traz\nresultados a longo prazo';

  @override
  String get onboardingProofChartCalloutBold => 'Um alimento mais adequado ';

  @override
  String get onboardingProofChartCalloutRest =>
      'à medida das necessidades do seu gato, em apenas algumas leituras';

  @override
  String get onboardingRatingEyebrow => 'Ajude-nos a crescer';

  @override
  String get onboardingRatingTitle => 'Dê-nos uma avaliação';

  @override
  String get onboardingRatingStatValue => 'Adorado';

  @override
  String get onboardingRatingStatLabel => 'por donos de gatos';

  @override
  String get onboardingRatingPeopleLabel => 'Donos de gatos como você';

  @override
  String get onboardingReview1Headline => 'Exatamente o que eu precisava!';

  @override
  String get onboardingReview1Body =>
      'Digitalizei as croquetes do meu gato e finalmente percebi o que continham. Mudei de marca na mesma semana e nunca me arrependi.';

  @override
  String get onboardingReview2Headline => 'Adoro esta app!!!';

  @override
  String get onboardingReview2Body =>
      'Uma app incrível, muito fácil de usar. Só carrego fotos do alimento e diz-me tudo. Excelente!';

  @override
  String get onboardingReview3Headline => 'Uma salvação para gatos idosos';

  @override
  String get onboardingReview3Body =>
      'A YuCat encontrou um alimento para idosos suave para o estômago da Lulu numa só tarde.';

  @override
  String get onboardingReview4Headline => 'Finalmente sinto-me confiante';

  @override
  String get onboardingReview4Body =>
      'Dantes comprava o que estivesse em promoção. Agora sei mesmo que alimentos correspondem às necessidades do meu gatinho. Tranquilidade total.';

  @override
  String get onboardingReview5Headline => 'Tão simples de usar';

  @override
  String get onboardingReview5Body =>
      'Tira uma foto e obtém uma análise clara em segundos. Até a minha veterinária ficou impressionada quando lhe mostrei.';

  @override
  String get onboardingReview6Headline => 'Dois gatos, duas dietas';

  @override
  String get onboardingReview6Body =>
      'Gerir a comida de um malhado com excesso de peso e de um siamês esquisito era um pesadelo. A YuCat tornou tudo fácil para ambos.';

  @override
  String get onboardingAttributionTitle => 'Como soube\nde nós?';

  @override
  String get onboardingAttributionInstagram => 'Instagram';

  @override
  String get onboardingAttributionTikTok => 'TikTok';

  @override
  String get onboardingAttributionYouTube => 'YouTube';

  @override
  String get onboardingAttributionAppStore => 'Pesquisa na App Store';

  @override
  String get onboardingAttributionFriends => 'Amigos/família';

  @override
  String get onboardingNotifPrimerTitle =>
      'Vamos ficar atentos\nà saúde do seu gato';

  @override
  String get onboardingSetUpReminders => 'Configurar lembretes';

  @override
  String get onboardingNotifReminderEyebrow => 'Vacina a vencer';

  @override
  String get onboardingNotifMockBody =>
      'O reforço da raiva da Luna vence na próxima semana — hora de marcar o veterinário 🩺';

  @override
  String get onboardingRemindersTitle => 'Sobre o que devemos\nnotificá-lo?';

  @override
  String get commonDone => 'Concluído';

  @override
  String get onboardingSetUpLater => 'Configurar depois';

  @override
  String get onboardingRemindersOptionFoodChange =>
      'Quando um alimento guardado muda';

  @override
  String get onboardingRemindersOptionBetterFit =>
      'Quando se encontra uma opção melhor';

  @override
  String get onboardingRemindersOptionMonthly =>
      'Lembretes de vacinas e consultas';

  @override
  String get onboardingRemindersCalloutPart1 =>
      'Os lembretes criam hábitos alimentares saudáveis ';

  @override
  String get onboardingRemindersCalloutBold => '2x mais depressa';

  @override
  String onboardingSuccessWithName(String name) {
    return 'O $name está\npronto!';
  }

  @override
  String get onboardingSuccessNoName => 'Está tudo\npronto!';

  @override
  String get onboardingStartScanning => 'Começar a digitalizar';

  @override
  String get onboardingSuccessProfileReadyTitle => 'Perfil pronto';

  @override
  String get onboardingSuccessProfileReadyBody =>
      'Pode editar estes dados a qualquer momento no perfil do seu gato.';

  @override
  String get paywallHeroHeadline => 'Saiba exatamente\no que há na tigela';

  @override
  String get paywallHeroHighlight => 'exatamente';

  @override
  String get paywallPlusBadge => 'Plus';

  @override
  String paywallBadgeFreeTrial(int days) {
    return '$days DIAS GRÁTIS';
  }

  @override
  String get paywallEverythingYouGet => 'Tudo o que recebe';

  @override
  String get paywallFeatureUnlimitedScansTitle => 'Digitalizações ilimitadas';

  @override
  String get paywallFeatureUnlimitedScansBenefit => 'sem limite diário.';

  @override
  String get paywallFeaturePersonalizedVerdictsTitle =>
      'Vereditos personalizados';

  @override
  String get paywallFeaturePersonalizedVerdictsBenefit =>
      'consoante a idade, o peso e a saúde.';

  @override
  String get paywallFeatureRecipesArticlesTitle =>
      'Receitas caseiras e artigos';

  @override
  String get paywallFeatureRecipesArticlesBenefit =>
      'para o alimentar melhor todos os dias.';

  @override
  String get paywallFeatureFoodGuideTitle => 'O guia alimentar completo';

  @override
  String get paywallFeatureFoodGuideBenefit => 'o que pode comer e o que não.';

  @override
  String paywallFeatureLine(String title, String benefit) {
    return '$title: $benefit';
  }

  @override
  String get paywallSuccessStoriesHeading =>
      'Histórias de sucesso\nde donos de gatos';

  @override
  String get paywallTestimonial1Quote =>
      'Andava a adivinhar há anos. A YuCat encontrou um alimento para gatos sénior suave para o estômago da Lulu numa só tarde.';

  @override
  String get paywallTestimonial1Name => 'Sophie';

  @override
  String get paywallTestimonial1Detail => 'Gato sénior · estômago sensível';

  @override
  String get paywallTestimonial2Quote =>
      'Digitalizei a ração do nosso gatinho e finalmente percebi o que continha. Mudei de marca na mesma semana.';

  @override
  String get paywallTestimonial2Name => 'Marco';

  @override
  String get paywallTestimonial2Detail => 'Gatinho · come com caprichos';

  @override
  String get paywallTestimonial3Quote =>
      'Dois gatos, duas necessidades muito diferentes. Agora sei qual o alimento que serve a cada um.';

  @override
  String get paywallTestimonial3Name => 'Priya';

  @override
  String get paywallTestimonial3Detail => 'Lar com vários gatos';

  @override
  String get paywallStatRatingLabel => 'avaliação\nmédia';

  @override
  String get paywallStatCatParentsLabel => 'donos de gatos\nem todo o mundo';

  @override
  String get paywallCancelAnytime => 'Cancele quando quiser.';

  @override
  String get paywallPeriodSuffixWeekly => 'semana';

  @override
  String get paywallPeriodSuffixMonthly => 'mês';

  @override
  String get paywallPeriodSuffixAnnual => 'ano';

  @override
  String paywallPerPeriodPrice(String price, String period) {
    return '$price/$period';
  }

  @override
  String paywallThenPrice(String price, String period) {
    return 'depois $price/$period';
  }

  @override
  String paywallTrialDisclosure(int days, String price, String period) {
    return '$days dias grátis, depois $price/$period. Cancele quando quiser.';
  }

  @override
  String paywallPriceDisclosure(String price, String period) {
    return '$price/$period. Cancele quando quiser.';
  }

  @override
  String paywallAutoRenewDisclosure(String price, String period, String store) {
    return 'O Yucat Plus custa $price/$period e renova-se automaticamente, exceto se o cancelar pelo menos 24 horas antes do final do período em vigor. Faça a gestão ou cancele quando quiser nas definições da sua conta $store.';
  }

  @override
  String paywallAutoRenewDisclosureTrial(
    int days,
    String price,
    String period,
    String store,
  ) {
    return 'A sua avaliação gratuita de $days dias converte-se automaticamente numa subscrição paga do Yucat Plus por $price/$period, exceto se a cancelar pelo menos 24 horas antes de terminar. Depois renova-se automaticamente ao mesmo preço até que a cancele. Faça a gestão ou cancele quando quiser nas definições da sua conta $store.';
  }

  @override
  String get paywallRestorePurchases => 'Restaurar compras';

  @override
  String get commonTerms => 'Termos';

  @override
  String get commonPrivacy => 'Privacidade';

  @override
  String get commonClose => 'Fechar';

  @override
  String get paywallPeriodAnnual => 'Anual';

  @override
  String get paywallPeriod6Months => '6 meses';

  @override
  String get paywallPeriod3Months => '3 meses';

  @override
  String get paywallPeriod2Months => '2 meses';

  @override
  String get paywallPeriodMonthly => 'Mensal';

  @override
  String get paywallPeriodWeekly => 'Semanal';

  @override
  String get paywallPeriodLifetime => 'Vitalício';

  @override
  String get paywallCtaUnlockPlus => 'Vamos começar';

  @override
  String paywallCtaRedeemTrial(int days) {
    return 'Obter $days dias grátis';
  }

  @override
  String get paywallNoPaymentDue => 'Sem pagamento agora';

  @override
  String paywallOfferHeadline(String discount) {
    return 'Oferta por tempo limitado: $discount';
  }

  @override
  String paywallOfferDiscount(int percent) {
    return '-$percent %';
  }

  @override
  String paywallOfferExpiresIn(String time) {
    return 'A oferta termina em: $time';
  }

  @override
  String get paywallOfferFirstYear => 'pelo seu primeiro ano';

  @override
  String get paywallOfferCta => 'Aproveite já';

  @override
  String paywallIntroDisclosure(
    String introPrice,
    String price,
    String period,
  ) {
    return '$introPrice no primeiro ano, depois $price/$period. Cancele quando quiser.';
  }

  @override
  String paywallAutoRenewDisclosureIntro(
    String introPrice,
    String price,
    String period,
    String store,
  ) {
    return 'O seu primeiro ano de Yucat Plus custa $introPrice; depois renova-se automaticamente a $price/$period, salvo cancelamento pelo menos 24 horas antes do fim do período em curso. Gira ou cancele quando quiser nas definições da sua conta $store.';
  }

  @override
  String get paywallRetry => 'Tentar novamente';

  @override
  String get paywallSkipDebug => 'Saltar paywall (debug)';

  @override
  String get paywallErroriOSOnly =>
      'As subscrições só estão disponíveis no iOS.';

  @override
  String get paywallErrorCouldNotLoadPlans =>
      'Não foi possível carregar os planos.';

  @override
  String get paywallErrorNoPlansAvailable =>
      'Não há planos de subscrição disponíveis neste momento.';

  @override
  String get paywallErrorPurchaseNotComplete =>
      'A compra não foi concluída. Tente novamente.';

  @override
  String get paywallErrorPurchaseFailed => 'A compra falhou. Tente novamente.';

  @override
  String get paywallErrorSomethingWentWrong =>
      'Algo correu mal. Tente novamente.';

  @override
  String get paywallErrorNoActiveSubscription =>
      'Não foi encontrada nenhuma subscrição ativa.';

  @override
  String get paywallErrorRestoreFailed =>
      'Não foi possível restaurar as compras. Tente novamente.';

  @override
  String get commonGoBack => 'Voltar';

  @override
  String get productDetailLoadError =>
      'Não foi possível carregar este produto.';

  @override
  String get productDetailOverallAnalysis => 'QUALIDADE DO ALIMENTO';

  @override
  String get productDetailAiIdentifiedPill => '* IDENTIFICADO POR IA';

  @override
  String get productDetailMyCatScore => 'Para o seu gato';

  @override
  String get productDetailNoCatPrompt =>
      'Crie um perfil de gato para ver como este alimento se adequa ao seu gato.';

  @override
  String get productDetailAddACat => 'Adicionar um gato';

  @override
  String get productDetailForYourCats => 'Para os seus gatos';

  @override
  String productDetailCatsCount(int count) {
    return '$count GATOS';
  }

  @override
  String get productDetailPickACat =>
      'Escolha um gato para ver como este produto se adapta ao seu perfil.';

  @override
  String productDetailFitIntro(String name) {
    return 'Como se adequa ao perfil de $name.';
  }

  @override
  String get productDetailFitGreat => 'Muito adequado';

  @override
  String get productDetailFitGood => 'Adequado';

  @override
  String get productDetailFitCautions => 'Com ressalvas';

  @override
  String get productDetailFitNotRecommended => 'Não recomendado';

  @override
  String get productDetailDimHealth => 'SAÚDE';

  @override
  String get productDetailDimWeight => 'PESO';

  @override
  String get productDetailDimAge => 'IDADE';

  @override
  String get productDetailDimActivity => 'ATIVIDADE';

  @override
  String get productDetailDimNeuteredStatus => 'ESTADO DE CASTRAÇÃO';

  @override
  String get productDetailDimBreed => 'RAÇA';

  @override
  String get productDetailNeutralFit =>
      'Nada no perfil deste gato altera o veredito: a qualidade do alimento acima aplica-se tal como está.';

  @override
  String get productDetailAgeGroupKitten => 'Gatinho';

  @override
  String get productDetailAgeGroupAdult => 'Adulto';

  @override
  String get productDetailAgeGroupSenior => 'Sénior';

  @override
  String get productDetailNutrientProtein => 'Proteína';

  @override
  String get productDetailNutrientFat => 'Gordura';

  @override
  String get productDetailNutrientMoisture => 'Humidade';

  @override
  String get productDetailNutrientFiber => 'Fibra';

  @override
  String get productDetailNutrientCarbs => 'Hidratos de carbono';

  @override
  String get productDetailVerdictExcellent =>
      'Uma excelente opção para o dia a dia';

  @override
  String get productDetailVerdictGood => 'Uma boa opção para o dia a dia';

  @override
  String get productDetailVerdictAverage => 'Uma opção razoável';

  @override
  String get productDetailVerdictPoor => 'Melhor evitar este';

  @override
  String get productDetailNoDataHeadline => 'Ainda não encontrámos os detalhes';

  @override
  String get productDetailNoDataBody =>
      'Não conseguimos encontrar a análise garantida deste produto. Experimente digitalizar o rótulo nutricional ou volte mais tarde — continuamos à procura.';

  @override
  String get productDetailNoDataCatsNote =>
      'Mostraremos como serve os seus gatos assim que tivermos os dados nutricionais.';

  @override
  String get productDetailImagePlaceholder => 'PRODUTO';

  @override
  String productDetailScoreSemantics(int score, int maxScore) {
    return 'Pontuação $score de $maxScore';
  }

  @override
  String get assessmentKittenHighProtein =>
      'Rico em proteína (>35%), benéfico para gatinhos';

  @override
  String get assessmentKittenHighFat =>
      'Rico em gordura (>18%), que favorece o crescimento do gatinho';

  @override
  String get assessmentKittenSeniorFormula =>
      'A fórmula para gatos sénior não é ideal para gatinhos';

  @override
  String get assessmentKittenLowProtein =>
      'Pobre em proteína (<28%); pode não cobrir as necessidades do gatinho';

  @override
  String get assessmentSeniorModerateProtein =>
      'Proteína moderada (30–35%), apropriada para gatos sénior';

  @override
  String get assessmentSeniorHighFat =>
      'Muito rico em gordura (>20%); pode não ser adequado para gatos sénior';

  @override
  String get assessmentSeniorJointSupport =>
      'Contém ingredientes de apoio às articulações (p. ex. glucosamina, condroitina)';

  @override
  String get assessmentSeniorKidneyFriendly =>
      'Formulação amiga dos rins (p. ex. menos fósforo)';

  @override
  String get assessmentUnderweightHighCalories =>
      'Alimento denso em energia; pode ajudar um gato abaixo do peso a ganhar peso';

  @override
  String get assessmentUnderweightHighFat =>
      'Rico em gordura (>18%); favorece o aumento de peso em gatos abaixo do peso';

  @override
  String get assessmentOverweightHighCalories =>
      'Alimento denso em energia; pode não ser ideal para um gato com excesso de peso';

  @override
  String get assessmentOverweightLowCalories =>
      'Menor densidade energética; ajuda a controlar o peso em gatos com excesso de peso';

  @override
  String get assessmentOverweightHighFiber =>
      'Mais fibra (>4%); pode ajudar com a saciedade em gatos com excesso de peso';

  @override
  String get assessmentOverweightHighMoisture =>
      'Humidade elevada (>70%); dá volume sem calorias e ajuda a saciar um gato que deve comer menos';

  @override
  String get assessmentObeseHighFat =>
      'Rico em gordura (>15%); não é adequado para gatos obesos';

  @override
  String get assessmentObeseHighCalories =>
      'Alimento denso em energia; não é ideal para gatos obesos';

  @override
  String get assessmentObeseLeanProtein =>
      'Fórmula magra e rica em proteína (>40% proteína, <12% gordura); boa para gatos obesos';

  @override
  String get assessmentLowActivityHighCalories =>
      'Alimento denso em energia; pode não convir a um gato pouco ativo';

  @override
  String get assessmentLowActivityModerateCalories =>
      'Densidade energética moderada; melhor para gatos pouco ativos';

  @override
  String get assessmentHighActivityHighCalories =>
      'Maior densidade energética; apoia um gato muito ativo';

  @override
  String get assessmentHighActivityHighProtein =>
      'Rico em proteína (>35%); ajuda a manter o músculo em gatos ativos';

  @override
  String get assessmentNeuteredHighCalories =>
      'Comida muito densa em energia; pode favorecer o aumento de peso em gatos esterilizados';

  @override
  String get assessmentNeuteredUrinarySupport =>
      'Contém ingredientes de apoio urinário, bons para gatos esterilizados';

  @override
  String get assessmentNeuteredHighFat =>
      'Rico em gordura (>16%); pode não ser ideal para gatos esterilizados';

  @override
  String get assessmentPregnantHighProtein =>
      'Muito rico em proteína (>35%); cobre as maiores necessidades de gatas gestantes/lactantes';

  @override
  String get assessmentPregnantHighFat =>
      'Rico em gordura (>20%); fornece energia extra para gatas gestantes/lactantes';

  @override
  String get assessmentPregnantHighCalories =>
      'Comida muito densa em energia; ajuda a cobrir as exigências energéticas na gestação/lactação';

  @override
  String get assessmentMaineCoonJointSupport =>
      'Contém ingredientes de apoio às articulações, úteis para os Maine Coon';

  @override
  String get assessmentMaineCoonHighProtein =>
      'Rico em proteína (>35%); apoia os Maine Coon de raça grande';

  @override
  String get assessmentPersianHairball =>
      'Fórmula tipo controlo de bolas de pelo (fibra 4–6% ou indicações para bolas de pelo)';

  @override
  String get assessmentPersianOmega3 =>
      'Inclui ingredientes ricos em ómega-3, bons para a pelagem/pele do Persa';

  @override
  String get assessmentPersianHighCarbs =>
      'Rico em hidratos de carbono (>30%); pode não ser ideal para os Persas';

  @override
  String get assessmentSiameseDigestible =>
      'Usa proteínas facilmente digeríveis, boas para os gatos Siameses';

  @override
  String get assessmentSiameseFillers =>
      'Contém muitos enchimentos (milho, trigo, soja) que podem não convir aos gatos Siameses';

  @override
  String get assessmentSphynxHighFat =>
      'Mais gordura (>18%); pode favorecer a saúde da pele do Sphynx';

  @override
  String get assessmentSphynxLowFat =>
      'Fórmula pobre em gordura (<12%); pode não dar apoio suficiente à pele do Sphynx';

  @override
  String get assessmentBritishHighCalories =>
      'A comida rica em calorias pode favorecer o aumento de peso nos British Shorthair';

  @override
  String get assessmentBritishWeightManagement =>
      'A fórmula tipo controlo de peso é adequada para os British Shorthair';

  @override
  String get assessmentBengalHighProtein =>
      'Rico em proteína (>38%); corresponde às necessidades energéticas do Bengal';

  @override
  String get assessmentBengalLowProtein =>
      'Pobre em proteína (<30%); pode ser insuficiente para os Bengal';

  @override
  String get assessmentBreedHighProtein =>
      'Rica em proteína (>35%); apoia raças grandes e musculosas';

  @override
  String get assessmentBreedHighFat =>
      'Maior teor de gordura (>18%); adequado para raças de pelo fino e metabolismo rápido';

  @override
  String get assessmentBreedLowFat =>
      'Baixo teor de gordura (<12%); pode ser insuficiente para raças de pelo fino';

  @override
  String get assessmentBreedHairball =>
      'Fórmula de controlo de bolas de pelo (fibra 4–6% ou indicações de bolas de pelo); adequada a raças de pelo longo';

  @override
  String get assessmentBreedOmega3 =>
      'Inclui ingredientes ricos em ómega-3, bons para o pelo e a pele';

  @override
  String get assessmentBreedHighCarbs =>
      'Rica em hidratos de carbono (>30%); não é ideal para esta raça';

  @override
  String get assessmentBreedDigestible =>
      'Usa proteínas facilmente digeríveis, boas para raças magras e ativas';

  @override
  String get assessmentBreedFillers =>
      'Contém muitos enchimentos (milho, trigo, soja) que podem não convir a esta raça';

  @override
  String get assessmentBreedJointSupport =>
      'Contém ingredientes de apoio articular, úteis para esta raça';

  @override
  String get assessmentBreedLowPhosphorus =>
      'Fórmula renal com baixo teor de fósforo; adequada a raças propensas a problemas renais';

  @override
  String get assessmentBreedHighMinerals =>
      'Alto teor de minerais; pode não convir a raças propensas a problemas renais';

  @override
  String get assessmentBreedHighCalories =>
      'Comida rica em calorias pode favorecer o aumento de peso nesta raça';

  @override
  String get assessmentBreedWeightManagement =>
      'Fórmula de controlo de peso; adequada a raças propensas a engordar';

  @override
  String get assessmentBreedHighCarbsDiabetes =>
      'Rica em hidratos de carbono (>20%); pode não convir a raças propensas à diabetes';

  @override
  String get assessmentUrinaryLowAsh =>
      'Formulado com baixo teor de cinzas, favorável para problemas urinários';

  @override
  String get assessmentUrinarySupport =>
      'Inclui ingredientes de apoio urinário como arando vermelho ou DL-metionina';

  @override
  String get assessmentUrinaryHighMinerals =>
      'O elevado teor de minerais pode não ser ideal para problemas urinários';

  @override
  String get assessmentKidneyHighProtein =>
      'Rico em proteína (>32%); pode não ser ideal para a doença renal';

  @override
  String get assessmentKidneyPhosphorus =>
      'Contém fontes de fósforo que podem ser problemáticas na doença renal';

  @override
  String get assessmentKidneyRenalSupport =>
      'Formulado como dieta de apoio renal';

  @override
  String get assessmentSensitiveStomachLimitedIngredient =>
      'Uma receita tipo ingredientes limitados pode ajudar estômagos sensíveis';

  @override
  String get assessmentSensitiveStomachLongIngredients =>
      'Uma lista de ingredientes muito longa pode não convir a estômagos sensíveis';

  @override
  String get assessmentFoodAllergyCommonAllergens =>
      'Contém alérgenos comuns como frango, peixe ou vaca';

  @override
  String get assessmentFoodAllergyNovelProteins =>
      'Usa proteínas alternativas (p. ex. pato, veado) que podem ajudar com as alergias';

  @override
  String get assessmentSkinAllergyOmega3 =>
      'Uma formulação rica em ómega-3 pode favorecer a saúde da pele e da pelagem';

  @override
  String get assessmentSkinAllergyArtificialColor =>
      'Contém corantes artificiais que podem agravar as alergias cutâneas';

  @override
  String get assessmentDiabetesHighCarbs =>
      'Rico em hidratos de carbono (>20%); menos adequado para gatos diabéticos';

  @override
  String get assessmentDiabetesHighProtein =>
      'Muito rico em proteína (>40%); pode ajudar no controlo da glicemia na diabetes';

  @override
  String get assessmentDentalHighMoisture =>
      'A comida com alta humidade (tipo húmida) é mais fácil de comer com problemas dentários';

  @override
  String get assessmentDentalLargeKibble =>
      'As croquetes muito grandes podem ser difíceis de mastigar com problemas dentários';

  @override
  String get assessmentHairballControl =>
      'Dieta tipo controlo de bolas de pelo (fibra 4–6% ou indicações para bolas de pelo)';

  @override
  String get homeScanProduct => 'Digitalize um produto';

  @override
  String get homeScanProductSubtitle => 'Fotografe a embalagem';

  @override
  String get homeScanEyebrow => 'O scan YuCat';

  @override
  String get homeScanHeadline => 'Esta embalagem é boa para o seu gato?';

  @override
  String get homeGreetingHey => 'Bem-vindo de volta';

  @override
  String get homeGreetingWelcome => 'Bem-vindo';

  @override
  String homeReadyForCat(String name) {
    return 'Pronto para encontrar comida para $name?';
  }

  @override
  String get homeReadyToScan => 'Pronto para digitalizar um produto?';

  @override
  String get homeAddCatShort => 'Adicionar';

  @override
  String homeProfileCompletionTitle(String name) {
    return 'Completar o perfil de $name';
  }

  @override
  String get homeProfileCompletionBody =>
      'Mais alguns detalhes para melhores recomendações.';

  @override
  String homeProfileCompletionProgress(int filled, int total) {
    return '$filled/$total';
  }

  @override
  String get homeProfileCompletionButton => 'Completar perfil';

  @override
  String get homeMyCatsTitle => 'Os meus gatos';

  @override
  String get homeSavedProductsTitle => 'Produtos guardados';

  @override
  String get homeSeeAll => 'Ver todos';

  @override
  String get homeNewsEyebrow => 'Bom saber hoje';

  @override
  String get homeNewsLearnMore => 'Saber mais';

  @override
  String get articlesCategoryAll => 'Todos';

  @override
  String get articlesCategoryNutrition => 'Alimentação';

  @override
  String get articlesCategoryHealth => 'Saúde';

  @override
  String get articlesCategoryBehaviour => 'Comportamento';

  @override
  String get articlesCategoryOther => 'Outros';

  @override
  String get articlesTitle => 'Artigos';

  @override
  String get articlesSearchHint => 'Pesquisar um artigo';

  @override
  String get articlesErrorBody => 'Algo correu mal ao carregar os artigos.';

  @override
  String get articlesEmptyHeadline => 'Nenhum artigo corresponde';

  @override
  String get articlesEmptyBody =>
      'Tente outra pesquisa ou escolha outra categoria.';

  @override
  String get homeArticlesSectionTitle => 'Artigos para si';

  @override
  String articlesReadMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String articleDetailReadTime(int minutes) {
    return '$minutes min de leitura';
  }

  @override
  String get homeFoodGuideTitle => 'Guia dos alimentos';

  @override
  String get foodGuideWhyGood => 'Porque é bom';

  @override
  String get foodGuideHowToServe => 'Como dar';

  @override
  String get foodGuideAvoid => 'O que evitar';

  @override
  String get foodGuideTip => 'Dica YuCat';

  @override
  String get foodGuideSafetySafe => 'Pode comer';

  @override
  String get foodGuideSafetyCaution => 'Com atenção';

  @override
  String get foodGuideSafetyUnsafe => 'Evitar';

  @override
  String get foodGuideListTitle => 'Guia dos alimentos';

  @override
  String get foodGuideErrorBody =>
      'Algo correu mal ao carregar o guia dos alimentos.';

  @override
  String get foodGuideEmptyBody =>
      'O guia dos alimentos está vazio por agora. Volte em breve.';

  @override
  String get homeRecipesSectionTitle => 'Receitas para o seu gato';

  @override
  String get homeMissionTitle => 'A nossa missão';

  @override
  String get homeMissionBody =>
      'Ajudar cada dono a compreender a alimentação do seu gato, para lhe dar uma vida mais saudável e feliz.';

  @override
  String get homeNoSavedProductsTitle => 'Ainda não há produtos guardados';

  @override
  String get homeNoSavedProductsBody =>
      'Toque no marcador de um produto para o guardar aqui.';

  @override
  String get homeLoadingEyebrow => 'Um momento';

  @override
  String get homeLoadingMsgReading => 'A ler a embalagem…';

  @override
  String get homeLoadingMsgSniffing => 'A cheirar os ingredientes…';

  @override
  String get homeLoadingMsgMatching => 'A comparar com a nossa base de dados…';

  @override
  String get homeLoadingMsgCrunching => 'A analisar os números…';

  @override
  String get homeLoadingMsgAlmost => 'Está quase…';

  @override
  String get homeCameraUnavailable => 'Câmara indisponível';

  @override
  String get homeCameraUnavailableBody =>
      'Ative o acesso à câmara para a YuCat nas Definições, ou escolha uma foto da sua galeria.';

  @override
  String get homeChooseFromGallery => 'Escolher da galeria';

  @override
  String get homeScannerHint => 'Aponte para o produto';

  @override
  String get homeErrorProductNotFound => 'Produto não encontrado';

  @override
  String get homeErrorTimeout => 'O pedido demorou demasiado. Tente novamente.';

  @override
  String get homeErrorNoInternet =>
      'Sem ligação à internet. Verifique a sua rede e tente novamente.';

  @override
  String get homeErrorGeneric => 'Algo correu mal. Tente novamente.';

  @override
  String get homeErrorServiceBusy =>
      'O nosso serviço de análise está ocupado neste momento. Tente novamente dentro de alguns minutos.';

  @override
  String get homeScannerLabelTitle => 'Fotografe o rótulo de trás';

  @override
  String get homeScannerLabelHint =>
      'Enquadre a composição e os constituintes analíticos';

  @override
  String get homeErrorNotCatProductTitle =>
      'Isso não parece um produto para gatos';

  @override
  String get homeErrorNotCatProductBody =>
      'O YuCat lê comida e areia para gatos. Tente outra embalagem ou pesquise por nome.';

  @override
  String get homeErrorUnreadableTitle => 'Não conseguimos ler essa embalagem';

  @override
  String get homeErrorUnreadableBody =>
      'Tente de novo com a frente da embalagem e boa luz, ou fotografe o rótulo de trás e lemos a análise diretamente.';

  @override
  String homeErrorAnalysisFailedTitle(String name) {
    return 'Encontrámos $name, mas não a sua análise';
  }

  @override
  String get homeErrorAnalysisFailedBody =>
      'A análise não está online em lado nenhum onde procurámos. Fotografe o rótulo de trás e lemos da embalagem.';

  @override
  String get homeErrorLabelUnreadableTitle => 'Não conseguimos ler esse rótulo';

  @override
  String get homeErrorLabelUnreadableBody =>
      'Preencha o enquadramento com a tabela de análise e os ingredientes, com boa luz, e tente mais uma vez.';

  @override
  String get homeErrorLabelNoDataTitle => 'Sem análise nesse painel';

  @override
  String get homeErrorLabelNoDataBody =>
      'A foto estava nítida, mas não tinha tabela nutricional. Tente o lado ou a parte de trás com «Constituintes analíticos».';

  @override
  String get homeErrorExitScanAgain => 'Digitalizar de novo';

  @override
  String get homeErrorExitScanLabel => 'Fotografar o rótulo de trás';

  @override
  String get homeErrorExitSearch => 'Pesquisar por nome';

  @override
  String get productDetailScanLabelCta => 'Fotografar o rótulo de trás';

  @override
  String get productDetailIngredientsTitle => 'INGREDIENTES';

  @override
  String productDetailIngredientsShowAll(int count) {
    return 'Ver todos os $count';
  }

  @override
  String get productDetailIngredientsShowLess => 'Ver menos';

  @override
  String get productDetailIngredientsFlaggedNote =>
      'Destacados: alergénios declarados nos perfis dos seus gatos.';

  @override
  String get productDetailIngredientsSource =>
      'Conforme indicado pelo fabricante.';

  @override
  String get productDetailComplementaryTreat =>
      'Snack · não é uma refeição completa';

  @override
  String get productDetailComplementaryTopper =>
      'Topping · não é uma refeição completa';

  @override
  String get productDetailComplementarySupplement =>
      'Suplemento · não é uma refeição completa';

  @override
  String get productDetailComplementaryNote =>
      'Pontuado como snack: acompanha um alimento completo, não o substitui. Mantenha os snacks abaixo de 10% das calorias diárias.';

  @override
  String get productDetailNutritionTitle => 'ANÁLISE GARANTIDA';

  @override
  String get productDetailBasisAsFed => 'Tal qual';

  @override
  String get productDetailBasisDryMatter => 'Matéria seca';

  @override
  String get productDetailBasisAsFedHint =>
      'Percentagens tal como impressas na embalagem. A energia é uma estimativa.';

  @override
  String get productDetailBasisDryMatterHint =>
      'Sem a água, para comparar húmido e seco na mesma escala. A energia é uma estimativa.';

  @override
  String get productDetailNutrientAsh => 'Cinzas';

  @override
  String get productDetailNutrientEnergy => 'Energia';

  @override
  String productDetailEnergyValue(int kcal) {
    return '~$kcal kcal';
  }

  @override
  String productDetailPortionTitle(String name) {
    return 'PORÇÃO DIÁRIA PARA $name';
  }

  @override
  String productDetailPortionNeedsWeight(String name) {
    return 'Adicione o peso de $name para ver uma porção diária.';
  }

  @override
  String productDetailPortionGrams(int grams) {
    return '≈ $grams g';
  }

  @override
  String productDetailPortionKcal(int kcal) {
    return '≈ $kcal kcal por dia';
  }

  @override
  String productDetailPortionUnits(String count, String unit) {
    return '≈ $count × $unit por dia';
  }

  @override
  String productDetailPortionTreatBudget(int kcal, int grams) {
    return 'Orçamento de snacks: até ≈ $kcal kcal por dia, cerca de $grams g deste snack.';
  }

  @override
  String get productDetailPortionDisclaimer =>
      'Uma estimativa com base no peso, idade e atividade. Ajuste à condição corporal e ao conselho do veterinário.';

  @override
  String get productDetailShare => 'Partilhar resultado';

  @override
  String get productDetailReport => 'Comunicar um problema';

  @override
  String get productDetailReportDescription =>
      'Produto, nutrição ou pontuação errados';

  @override
  String get productDetailReportTitle => 'O que está errado?';

  @override
  String get productDetailReportWrongProduct =>
      'Não é o produto que digitalizei';

  @override
  String get productDetailReportWrongNutrition =>
      'Os valores nutricionais estão errados';

  @override
  String get productDetailReportWrongScore => 'A pontuação parece errada';

  @override
  String get productDetailReportWrongImage => 'A foto está errada';

  @override
  String get productDetailReportOther => 'Outra coisa';

  @override
  String get productDetailReportThanks => 'Obrigado, vamos verificar.';

  @override
  String productDetailShareText(
    String name,
    String brand,
    int score,
    String verdict,
    String url,
  ) {
    return '$name da $brand obtém $score/100 no YuCat: $verdict. Verifique a comida do seu gato: $url';
  }

  @override
  String productDetailShareTextNoScore(String name, String brand, String url) {
    return 'Consultei $name da $brand no YuCat. Verifique a comida do seu gato: $url';
  }

  @override
  String get homeLoadingLabelEyebrow => 'A ler o rótulo';

  @override
  String get homeLoadingMsgReadingLabel => 'A ler a tabela de análise…';

  @override
  String get homeLoadingMsgScoring => 'A pontuar os ingredientes…';

  @override
  String get homeLoadingMsgSearching => 'A procurar em páginas de lojas…';

  @override
  String get homeLoadingHint => 'Normalmente 20–40 segundos';

  @override
  String get homeLoadingLabelHint => 'Normalmente menos de 15 segundos';

  @override
  String get homeLoadingCancel => 'Cancelar';

  @override
  String get homeCatKitten => 'Gatinho';

  @override
  String get homeCatAdult => 'Adulto';

  @override
  String get homeCatSenior => 'Sénior';

  @override
  String get homeCatUnderweight => 'Abaixo do peso';

  @override
  String get homeCatHealthyWeight => 'Peso saudável';

  @override
  String get homeCatOverweight => 'Com excesso de peso';

  @override
  String get homeCatObese => 'Obeso';

  @override
  String homeCatConditionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count condições',
      one: '1 condição',
    );
    return '$_temp0';
  }

  @override
  String get scanHistoryTitle => 'Histórico de digitalizações';

  @override
  String scanHistoryScanCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count digitalizações',
      one: '1 digitalização',
    );
    return '$_temp0';
  }

  @override
  String get scanHistoryEmptyTitle => 'Ainda não há digitalizações';

  @override
  String get scanHistoryEmptyBody => 'Tudo o que digitalizares aparece aqui.';

  @override
  String get commonTryAgain => 'Tentar novamente';

  @override
  String get productRowNoData => 'Ainda sem dados';

  @override
  String get searchTabTitle => 'Pesquisar';

  @override
  String get searchHint => 'Pesquise um alimento para gatos';

  @override
  String get searchRecentLabel => 'Recentes';

  @override
  String get searchClearLabel => 'Limpar';

  @override
  String get searchPopularBrands => 'Marcas populares';

  @override
  String get searchNoMatchesHeadline => 'Sem resultados';

  @override
  String get searchNoMatchesBody =>
      'Experimente outro nome ou explore marcas populares.';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
    );
    return '$_temp0';
  }

  @override
  String get searchErrorBody => 'Algo correu mal durante a pesquisa.';

  @override
  String get bottomNavHome => 'Início';

  @override
  String get bottomNavScan => 'Digitalizar';

  @override
  String get bottomNavRecipes => 'Receitas';

  @override
  String get bottomNavProfile => 'Perfil';

  @override
  String get recipesTabTitle => 'Receitas';

  @override
  String get recipesEmptyHeadline => 'Nenhuma receita corresponde';

  @override
  String get recipesEmptyBody =>
      'Experimenta outra pesquisa ou escolhe outra categoria.';

  @override
  String get recipesSearchHint => 'Procurar uma receita';

  @override
  String get recipesCategoryAll => 'Todas';

  @override
  String get recipesCategoryBiscuits => 'Bolachas';

  @override
  String get recipesCategoryCakes => 'Bolos';

  @override
  String get recipesCategoryFrozenTreats => 'Guloseimas geladas';

  @override
  String get recipesCategoryMeals => 'Refeições';

  @override
  String get recipesCategoryOther => 'Outras';

  @override
  String get recipesErrorBody => 'Algo correu mal ao carregar as receitas.';

  @override
  String get recipesDifficultyEasy => 'Fácil';

  @override
  String get recipesDifficultyMedium => 'Média';

  @override
  String get recipesDifficultyHard => 'Difícil';

  @override
  String recipesPrepMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String recipesPrepMinutesPlusFreezing(int minutes) {
    return '$minutes min + congelação';
  }

  @override
  String get recipesCompatible => 'Compatível com o perfil';

  @override
  String get recipesCaution => 'Confirma com o veterinário';

  @override
  String get recipesIncompatible => 'Não indicada para o perfil';

  @override
  String get recipeDetailIngredients => 'Ingredientes';

  @override
  String get recipeDetailPreparation => 'Preparação';

  @override
  String get recipeDetailTip => 'Dica';

  @override
  String get productListingEmpty =>
      'Não foram encontrados produtos para esta marca.';

  @override
  String get commonAgeGroupKitten => 'Gatinho';

  @override
  String get commonAgeGroupAdult => 'Adulto';

  @override
  String get commonAgeGroupSenior => 'Idoso';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileLinkError => 'Não foi possível abrir a ligação.';

  @override
  String get profileSubscriptionLinkError =>
      'Não foi possível abrir as subscrições da App Store.';

  @override
  String profileEmailError(String email) {
    return 'Não foi possível abrir $email.';
  }

  @override
  String get profilePrivacyError =>
      'Não foi possível abrir a Política de Privacidade.';

  @override
  String get profileTermsError =>
      'Não foi possível abrir os Termos e Condições.';

  @override
  String get profileSubscriptionActive => 'Subscrição ativa';

  @override
  String get profileRestorePurchases => 'Restaurar compras';

  @override
  String get profileManageSubscription => 'Gerir subscrição';

  @override
  String get profileYourCats => 'Os seus gatos';

  @override
  String get profileManage => 'Gerir';

  @override
  String get profileAddCat => 'Adicionar gato';

  @override
  String get profileSavedProductsLabel => 'Produtos guardados';

  @override
  String get profileSavedProductsEmpty => 'Ainda sem produtos guardados';

  @override
  String profileSavedProductsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produtos guardados',
      one: '1 produto guardado',
    );
    return '$_temp0';
  }

  @override
  String get profileScanHistoryLabel => 'Histórico de digitalizações';

  @override
  String get profileScanHistoryEmpty => 'Ainda sem digitalizações';

  @override
  String profileScanHistoryCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count digitalizações',
      one: '1 digitalização',
    );
    return '$_temp0';
  }

  @override
  String get profileContactUs => 'Contacte-nos';

  @override
  String get profilePrivacyPolicy => 'Política de Privacidade';

  @override
  String get profileTermsAndConditions => 'Termos e Condições';

  @override
  String get profileResetOnboarding => 'Repor introdução';

  @override
  String get profileResetTestUser => 'Repor utilizador de teste';

  @override
  String get profileResetTestUserConfirmTitle =>
      'Começar como novo utilizador?';

  @override
  String get profileResetTestUserConfirmBody =>
      'Termina sessão no Firebase, RevenueCat e OneSignal, limpa os dados locais e reinicia a partir do ecrã inicial. Os gatos ficam no Firestore no utilizador antigo.';

  @override
  String get profileResetTestUserConfirm => 'Repor';

  @override
  String get profileDebugOnly => 'Apenas versões de teste';

  @override
  String get profileRestoreNotAvailable =>
      'A restauração só está disponível no iOS.';

  @override
  String get profileRestoreSuccess => 'Subscrição restaurada com sucesso!';

  @override
  String get profileNoSubscriptionFound =>
      'Não foi encontrada nenhuma subscrição ativa.';

  @override
  String get profileRestoreError =>
      'Não foi possível restaurar as suas compras. Tente novamente.';

  @override
  String get savedProductsTitle => 'Produtos guardados';

  @override
  String savedProductsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produtos',
      one: '1 produto',
    );
    return '$_temp0';
  }

  @override
  String get savedProductsEmptyHeadline => 'Ainda sem produtos guardados';

  @override
  String get savedProductsEmptyBody => 'Marque produtos para os encontrar aqui';

  @override
  String get catDetailDeleteError =>
      'Não foi possível eliminar o seu gato. Tente novamente.';

  @override
  String catDetailDeleteTitle(String name) {
    return 'Eliminar o $name?';
  }

  @override
  String get catDetailDeleteBody =>
      'Isto eliminará o perfil de forma permanente.';

  @override
  String get catDetailDeleteCancel => 'Cancelar';

  @override
  String get catDetailDeleteConfirm => 'Eliminar';

  @override
  String get catDetailProfileCompletion => 'Conclusão do perfil';

  @override
  String get catDetailNotSet => 'Não definido';

  @override
  String get catDetailBreedLabel => 'Raça';

  @override
  String get catDetailAgeLabel => 'Idade';

  @override
  String get catDetailAgeYears => 'anos';

  @override
  String get catDetailGenderLabel => 'Género';

  @override
  String get catDetailCoatLabel => 'Pelagem';

  @override
  String get catDetailActivityLabel => 'Atividade';

  @override
  String get catDetailBodyLabel => 'Condição corporal';

  @override
  String get catDetailStatusLabel => 'Estado';

  @override
  String get catDetailStatusNeutered => 'Castrado / Esterilizado';

  @override
  String get catDetailStatusSpayed => 'Esterilizada';

  @override
  String get catDetailDetailsSection => 'Detalhes';

  @override
  String get catDetailActivityModerate => 'Moderada';

  @override
  String get catDetailBodyNormal => 'Normal';

  @override
  String get catDetailCoatMedium => 'Pelo médio';

  @override
  String get catDetailHealthConditionsSection => 'Condições de saúde';

  @override
  String get catDetailDeleteProfile => 'Eliminar perfil';

  @override
  String get catDetailChangePhoto => 'Alterar foto';

  @override
  String get catDetailPhotoUpdateError =>
      'Não foi possível atualizar a foto. Tenta novamente.';

  @override
  String catDetailHealthRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registos',
      one: '1 registo',
    );
    return '$_temp0';
  }

  @override
  String catDetailHealthLastWeight(String kg) {
    return 'último peso $kg kg';
  }

  @override
  String get catDetailHealthAllClear => 'Tudo em dia';

  @override
  String get catDetailHealthSetup =>
      'Ainda por configurar · demora 30 segundos';

  @override
  String get catListingTitle => 'Os seus gatos';

  @override
  String get catListingErrorGeneric => 'Algo correu mal';

  @override
  String get catListingEmptyHeadline => 'Ainda não há gatos';

  @override
  String get catListingEmptyBody =>
      'Adicione o seu primeiro gato para obter recomendações personalizadas';

  @override
  String get catListingEmptyCta => 'Adicione o seu gato';

  @override
  String get catListingAddAnotherCat => 'Adicionar outro gato';

  @override
  String get catListingCreateNewProfile => 'Criar um novo perfil';

  @override
  String get catListingCatFallback => 'Gato';

  @override
  String catListingConditionsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count condições',
      one: '1 condição',
    );
    return '$_temp0';
  }

  @override
  String get catDetailDietaryTipsSection => 'Conselhos de alimentação';

  @override
  String get dietTipsDisclaimer =>
      'Orientação geral — consulte sempre o seu veterinário para questões médicas.';

  @override
  String homeCatTipsTitle(String name) {
    return 'Conselhos para $name';
  }

  @override
  String get dietTitleMoreProtein => 'Mais proteína';

  @override
  String get dietTitleLessProtein => 'Menos proteína';

  @override
  String get dietTitleMoreFat => 'Mais gordura saudável';

  @override
  String get dietTitleLessFat => 'Menos gordura';

  @override
  String get dietTitleLessCarbs => 'Menos hidratos de carbono';

  @override
  String get dietTitleMoreFiber => 'Mais fibra';

  @override
  String get dietTitleMoreMoisture => 'Mais humidade';

  @override
  String get dietTitleMoreOmega3 => 'Mais ómega-3';

  @override
  String get dietTitleLessPhosphorus => 'Menos fósforo';

  @override
  String get dietTitleMoreCalories => 'Mais calorias';

  @override
  String get dietTitleLessCalories => 'Menos calorias';

  @override
  String get dietTitleMoreWater => 'Mais água';

  @override
  String get dietWhyKittenProtein =>
      'Os gatinhos em crescimento precisam de mais proteína para formar músculo.';

  @override
  String get dietWhyKittenFat =>
      'As gorduras saudáveis impulsionam o rápido crescimento e a energia do gatinho.';

  @override
  String get dietWhySeniorOmega3 =>
      'Os ómega-3 cuidam das articulações, dos rins e da pelagem na velhice.';

  @override
  String get dietWhySeniorPhosphorus =>
      'Menos fósforo reduz a carga sobre uns rins que envelhecem.';

  @override
  String get dietWhyUnderweightCalories =>
      'Uma comida rica em calorias ajuda o seu gato a atingir um peso saudável.';

  @override
  String get dietWhyUnderweightFat =>
      'Mais gordura saudável fornece as calorias necessárias para ganhar peso.';

  @override
  String get dietWhyOverweightCalories =>
      'Menos calorias favorecem uma perda de peso gradual e saudável.';

  @override
  String get dietWhyOverweightFat =>
      'Reduzir a gordura diminui as calorias para controlar o peso.';

  @override
  String get dietWhyOverweightFiber =>
      'A fibra mantém o seu gato saciado comendo menos.';

  @override
  String get dietWhyOverweightProtein =>
      'A proteína magra conserva o músculo durante a perda de peso.';

  @override
  String get dietWhyLowActivityCalories =>
      'Um gato mais calmo precisa de menos calorias para não engordar.';

  @override
  String get dietWhyHighActivityProtein =>
      'Os gatos ativos precisam de mais proteína para manter o músculo.';

  @override
  String get dietWhyHighActivityCalories =>
      'Um gato enérgico gasta mais e precisa de mais calorias.';

  @override
  String get dietWhyNeuteredCalories =>
      'Os gatos esterilizados gastam menos energia e engordam com facilidade.';

  @override
  String get dietWhyNeuteredFat =>
      'Menos gordura ajuda um gato esterilizado a manter-se em forma.';

  @override
  String get dietWhyPregnantProtein =>
      'A gestação e a amamentação exigem mais proteína.';

  @override
  String get dietWhyPregnantFat =>
      'Mais gordura cobre as elevadas necessidades de energia da amamentação.';

  @override
  String get dietWhyPregnantCalories =>
      'Mais calorias sustentam a gestação e a produção de leite.';

  @override
  String get dietWhyMaineCoonProtein =>
      'As raças grandes e musculadas prosperam com muita proteína.';

  @override
  String get dietWhyMaineCoonOmega3 =>
      'Os ómega-3 cuidam das articulações das raças grandes.';

  @override
  String get dietWhyPersianOmega3 =>
      'Os ómega-3 mantêm saudável a longa pelagem do persa.';

  @override
  String get dietWhyPersianFiber =>
      'A fibra ajuda a mover as bolas de pelo pelo intestino.';

  @override
  String get dietWhyPersianCarbs =>
      'Os persas costumam tolerar melhor as dietas pobres em hidratos de carbono.';

  @override
  String get dietWhySphynxFat =>
      'Os gatos sem pelo gastam energia depressa e precisam de mais gordura.';

  @override
  String get dietWhyBengalProtein =>
      'Os bengalis, muito enérgicos, precisam de muita proteína.';

  @override
  String get dietWhyBritishCalories =>
      'Esta raça tranquila engorda com facilidade.';

  @override
  String get dietWhyBreedProtein =>
      'As raças grandes e musculosas prosperam com muita proteína.';

  @override
  String get dietWhyBreedOmega3 =>
      'O ómega-3 mantém o pelo e as articulações desta raça saudáveis.';

  @override
  String get dietWhyBreedFat =>
      'As raças de pelo fino queimam energia depressa e precisam de mais gordura.';

  @override
  String get dietWhyBreedFiber =>
      'A fibra ajuda a mover as bolas de pelo pelo intestino.';

  @override
  String get dietWhyBreedCarbs =>
      'Esta raça lida melhor com dietas com menos hidratos de carbono.';

  @override
  String get dietWhyBreedDigestibility =>
      'As raças magras e ativas dão-se melhor com alimentos fáceis de digerir.';

  @override
  String get dietWhyBreedPhosphorus =>
      'Menos fósforo alivia a carga em raças propensas a problemas renais.';

  @override
  String get dietWhyBreedCalories =>
      'Esta raça engorda com facilidade e precisa de menos calorias.';

  @override
  String get dietWhyLongCoatOmega3 =>
      'Os ómega-3 nutrem uma pelagem longa e abundante.';

  @override
  String get dietWhyLongCoatFiber =>
      'A fibra ajuda a prevenir as bolas de pelo em gatos de pelo comprido.';

  @override
  String get dietWhyHairlessFat =>
      'Os gatos sem pelo precisam de mais gordura para se manterem quentes e com energia.';

  @override
  String get dietWhyUrinaryWater =>
      'Mais água dilui a urina e protege as vias urinárias.';

  @override
  String get dietWhyKidneyPhosphorus =>
      'Pouco fósforo ajuda a abrandar a doença renal.';

  @override
  String get dietWhyKidneyProtein =>
      'Moderar a proteína alivia a carga sobre os rins.';

  @override
  String get dietWhyKidneyOmega3 =>
      'Os ómega-3 ajudam a cuidar de uns rins afetados.';

  @override
  String get dietWhyDiabetesCarbs =>
      'Poucos hidratos de carbono ajudam a manter estável o açúcar no sangue.';

  @override
  String get dietWhyDiabetesProtein =>
      'A proteína favorece o controlo da glicose e o músculo.';

  @override
  String get dietWhySkinOmega3 =>
      'Os ómega-3 acalmam a inflamação e a irritação da pele.';

  @override
  String get dietWhyHairballFiber =>
      'A fibra ajuda o seu gato a expulsar as bolas de pelo de forma natural.';

  @override
  String get dietWhyHairballOmega3 =>
      'Os ómega-3 melhoram a saúde da pelagem e reduzem a queda.';

  @override
  String get dietWhyJointOmega3 =>
      'Os ómega-3 reduzem a inflamação e a rigidez articular.';

  @override
  String get dietWhyDentalMoisture =>
      'A comida húmida é mais suave para dentes e gengivas doridos.';

  @override
  String get dietWhyWaterGeneral =>
      'Os gatos tendem a desidratar-se — a comida húmida e a água fresca ajudam.';

  @override
  String get assessmentHeartTaurine =>
      'Contém taurina, essencial para a saúde do coração';

  @override
  String get assessmentHeartLowSodium =>
      'Pobre em sódio, o que reduz o esforço do coração';

  @override
  String get assessmentHeartOmega3 =>
      'Os ómega-3 cuidam do coração e da circulação';

  @override
  String get assessmentHeartHighSodium =>
      'Rico em sódio, o que sobrecarrega o coração';

  @override
  String get onboardingNarrativeTitle => 'Personalizado para o seu gato';

  @override
  String onboardingNarrativeFallback(String name) {
    return 'Este é o início do plano nutricional do $name — algumas coisas em que nos focaríamos para o ajudar a ficar em plena forma.';
  }

  @override
  String get dietTitleMoreTaurine => 'Mais taurina';

  @override
  String get dietTitleLessSodium => 'Menos sódio';

  @override
  String get dietTitleNovelProtein => 'Proteínas alternativas';

  @override
  String get dietTitleDigestible => 'Comida fácil de digerir';

  @override
  String get dietWhyHeartOmega3 =>
      'Os ómega-3 (EPA e DHA) cuidam do músculo cardíaco e da circulação.';

  @override
  String get dietWhyHeartTaurine =>
      'A taurina é essencial para um coração felino saudável.';

  @override
  String get dietWhyHeartSodium => 'Menos sódio reduz o esforço do coração.';

  @override
  String get dietWhyAllergyNovelProtein =>
      'As proteínas alternativas ou limitadas ajudam a evitar os desencadeantes habituais de alergia.';

  @override
  String get dietWhySensitiveDigestible =>
      'As receitas suaves e muito digeríveis são mais amigas do estômago.';

  @override
  String get onboardingNarrativeOutlookTitle => 'Em cerca de 2 semanas';

  @override
  String onboardingNarrativeOutlookFallback(String name) {
    return 'Com a comida adequada, em cerca de duas semanas pode começar a notar que o $name tem mais energia e uma pelagem mais saudável e brilhante.';
  }

  @override
  String onboardingNarrativeFocusTitle(String name) {
    return 'Em que se focar para $name';
  }

  @override
  String get onboardingAnalyzeEyebrow => 'A personalizar';

  @override
  String onboardingAnalyzeStep1(String name) {
    return 'A rever o perfil do $name';
  }

  @override
  String get onboardingAnalyzeStep2 => 'A verificar as necessidades de saúde';

  @override
  String get onboardingAnalyzeStep3 =>
      'A encontrar a orientação nutricional adequada';

  @override
  String get onboardingAnalyzeStep4 => 'A personalizar as recomendações';

  @override
  String productPicksTitle(String name) {
    return 'Melhores opções para $name';
  }

  @override
  String productDetailBetterForCat(String name) {
    return 'Melhor para $name';
  }

  @override
  String get onboardingResultContinue => 'Continuar';

  @override
  String onboardingBrandTitle(String name) {
    return 'O que dá de comer ao $name?';
  }

  @override
  String get onboardingBrandSubtitle =>
      'Vamos verificar como é realmente para o seu gato.';

  @override
  String get onboardingBrandHint =>
      'Pesquise uma marca (p. ex. Whiskas, Royal Canin)';

  @override
  String get onboardingBrandAnalyzeCta => 'Analisar esta comida';

  @override
  String get onboardingBrandSkip => 'Não tenho a certeza';

  @override
  String onboardingBrandAnalyzing(String brand) {
    return 'A analisar $brand…';
  }

  @override
  String onboardingBrandUnavailable(String brand) {
    return 'Não conseguimos analisar $brand neste momento, mas é isto o que recomendaríamos.';
  }

  @override
  String get brandTeaserLockedHint =>
      'Subscreva para as ver — à medida das necessidades do seu gato.';

  @override
  String get brandTeaserRowLocked => 'Desbloquear para ver';

  @override
  String get onboardingScanSubtitle =>
      'Digitalize a embalagem e avaliá-la-emos para o seu gato.';

  @override
  String get onboardingScanVerdictIntro => 'Eis como essa comida pontua:';

  @override
  String onboardingScanPersonalCon(String name, String con) {
    return 'Para $name: $con';
  }

  @override
  String onboardingResultWhyTitle(String name) {
    return 'Porque é que não é o ideal para $name';
  }

  @override
  String get ratingLabelExcellent => 'Excelente';

  @override
  String get ratingLabelGood => 'Bom';

  @override
  String get ratingLabelAverage => 'Razoável';

  @override
  String get ratingLabelPoor => 'Fraco';

  @override
  String get litterDetailScoreLabel => 'PONTUAÇÃO DA AREIA';

  @override
  String get litterDetailNoDataBody =>
      'Ainda não encontrámos informação suficiente sobre esta areia. Tenta digitalizar a parte de trás da embalagem ou volta mais tarde — continuamos à procura.';

  @override
  String get litterDetailAttributesTitle => 'O que tem dentro';

  @override
  String get litterDetailAdditives => 'Aditivos';

  @override
  String get litterDetailNoCatPrompt =>
      'Cria um perfil de gato para veres o que esta areia significa para o teu gato.';

  @override
  String litterDetailNoFlags(String name) {
    return 'Não há nada que exija atenção especial para $name.';
  }

  @override
  String get litterAttrClumping => 'Aglomerante';

  @override
  String get litterAttrNonClumping => 'Não aglomerante';

  @override
  String get litterAttrDustLow => 'Pouco pó';

  @override
  String get litterAttrDustModerate => 'Algum pó';

  @override
  String get litterAttrDustHigh => 'Muito pó';

  @override
  String get litterAttrUnscented => 'Sem perfume';

  @override
  String get litterAttrScented => 'Perfumada';

  @override
  String get litterAttrTrackingLow => 'Espalha-se pouco';

  @override
  String get litterAttrTrackingModerate => 'Espalha-se um pouco';

  @override
  String get litterAttrTrackingHigh => 'Espalha-se muito';

  @override
  String get litterAttrOdorLow => 'Fraco controlo de odores';

  @override
  String get litterAttrOdorModerate => 'Controlo de odores moderado';

  @override
  String get litterAttrOdorHigh => 'Bom controlo de odores';

  @override
  String get litterAttrFlushable => 'Pode ir à sanita';

  @override
  String get litterAttrBiodegradable => 'Biodegradável';

  @override
  String get litterMaterialClayBentonite => 'Argila de bentonite';

  @override
  String get litterMaterialClayNonClumping => 'Argila não aglomerante';

  @override
  String get litterMaterialSilicaCrystal => 'Cristais de sílica';

  @override
  String get litterMaterialCorn => 'Milho';

  @override
  String get litterMaterialWheat => 'Trigo';

  @override
  String get litterMaterialTofu => 'Tofu';

  @override
  String get litterMaterialPaper => 'Papel reciclado';

  @override
  String get litterMaterialWood => 'Madeira';

  @override
  String get litterMaterialWalnut => 'Casca de noz';

  @override
  String get litterMaterialGrass => 'Erva';

  @override
  String get litterMaterialMixed => 'Substrato misto';

  @override
  String get litterMaterialOther => 'Outro substrato';

  @override
  String litterFlagKittenClumpingClay(String name) {
    return 'A argila aglomerante pode formar uma obstrução se $name a engolir enquanto se lambe. Os veterinários costumam recomendar uma areia não aglomerante ou vegetal até aos 4 meses.';
  }

  @override
  String litterFlagKittenSilica(String name) {
    return 'Os gatinhos costumam provar a areia, e os cristais de sílica são afiados e não devem ser engolidos. Por agora, algo mais macio é mais seguro para $name.';
  }

  @override
  String litterFlagMonitoringClumping(String name) {
    return 'Os grumos permitem ver facilmente quanto $name urina — algo a vigiar com a sua condição.';
  }

  @override
  String litterFlagMonitoringNonClumping(String name) {
    return 'Sem grumos é difícil notar mudanças na quantidade de urina de $name, o que importa com a sua condição.';
  }

  @override
  String litterFlagSensitiveScented(String name) {
    return 'O perfume adicionado pode irritar a pele e as patas sensíveis como as de $name.';
  }

  @override
  String litterFlagSensitiveDust(String name) {
    return 'Muito pó deposita-se na pele e nas patas e pode irritar as vias respiratórias de $name.';
  }

  @override
  String litterFlagPawComfortCoarse(String name) {
    return 'Cristais e grânulos grossos são duros para articulações rígidas. $name deve preferir um grão fino, tipo areia.';
  }

  @override
  String litterFlagPawComfortFine(String name) {
    return 'Um grão fino, tipo areia, é suave para as articulações de $name e fácil de escavar.';
  }

  @override
  String litterFlagLongCoatTracking(String name) {
    return 'A areia que se espalha facilmente fica presa num pelo comprido como o de $name e acaba por toda a casa.';
  }

  @override
  String get litterSectionTitle => 'Areias';

  @override
  String litterSectionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count areias',
      one: '1 areia',
    );
    return '$_temp0';
  }

  @override
  String get litterAdditiveBakingSoda => 'Bicarbonato de sódio';

  @override
  String get litterAdditiveActivatedCharcoal => 'Carvão ativado';

  @override
  String get litterAdditiveFragrance => 'Perfume';

  @override
  String get litterAdditivePlantStarch => 'Amido vegetal';

  @override
  String get litterAdditiveZeolite => 'Zeólito';

  @override
  String get litterAdditiveSilica => 'Sílica';

  @override
  String get litterAdditiveEssentialOils => 'Óleos essenciais';

  @override
  String get litterAdditiveDeodorizer => 'Neutralizador de odores';

  @override
  String get foodSectionTitle => 'Comida';

  @override
  String get healthProtocolAnnualCheckup => 'Consulta anual';

  @override
  String get healthProtocolAnnualCheckupDesc =>
      'Exame completo, pesagem e controlo dentário na mesma consulta.';

  @override
  String get healthProtocolFvrcp => 'Reforço FVRCP';

  @override
  String get healthProtocolFvrcpDesc =>
      'Protege contra panleucopenia, herpesvírus e calicivírus.';

  @override
  String get healthProtocolRabies => 'Reforço da raiva';

  @override
  String get healthProtocolRabiesDesc =>
      'Vacina essencial na maioria das regiões e a mais exigida.';

  @override
  String get healthProtocolFelv => 'Leucemia felina (FeLV)';

  @override
  String get healthProtocolFelvDesc =>
      'Recomendada para todos os gatinhos, após um teste FeLV/FIV.';

  @override
  String get healthProtocolFelvBooster => 'Reforço de FeLV';

  @override
  String get healthProtocolFelvBoosterDesc =>
      'Para gatos com acesso ao exterior ou que vivem com outros gatos.';

  @override
  String get healthProtocolDewormingInternal => 'Desparasitação';

  @override
  String get healthProtocolDewormingInternalDesc =>
      'Tratamento contra parasitas internos.';

  @override
  String get healthProtocolDewormingMonthly => 'Desparasitação mensal';

  @override
  String get healthProtocolDewormingMonthlyDesc =>
      'Para caçadores, gatos com dieta crua ou casas com crianças pequenas.';

  @override
  String get healthProtocolParasiteExternal => 'Antiparasitário externo';

  @override
  String get healthProtocolParasiteExternalDesc =>
      'Proteção contra pulgas e carraças, todo o ano.';

  @override
  String get healthProtocolHeartworm => 'Prevenção da dirofilariose';

  @override
  String get healthProtocolHeartwormDesc =>
      'Só necessária em regiões onde a doença existe.';

  @override
  String get healthProtocolDentalScaling => 'Destartarização';

  @override
  String get healthProtocolDentalScalingDesc =>
      'Sob anestesia, quando o veterinário aconselhar.';

  @override
  String get healthProtocolSeniorPanel => 'Análises sénior';

  @override
  String get healthProtocolSeniorPanelDesc =>
      'Hemograma, bioquímica, tiroide, urina e tensão arterial.';

  @override
  String get healthProtocolRetrovirusTest => 'Teste FeLV/FIV';

  @override
  String get healthProtocolRetrovirusTestDesc =>
      'Na adoção e após qualquer mordedura.';

  @override
  String get healthProtocolConditionFollowUp => 'Acompanhamento da doença';

  @override
  String get healthProtocolConditionFollowUpDesc =>
      'Reavaliação da doença diagnosticada do seu gato.';

  @override
  String get healthProtocolNeutering => 'Esterilização';

  @override
  String get healthProtocolNeuteringDesc => 'Recomendada até aos cinco meses.';

  @override
  String get healthProtocolMicrochip => 'Microchip / identificação';

  @override
  String get healthProtocolMicrochipDesc =>
      'Obrigatório para viajar e em muitos países.';

  @override
  String get healthCategoryVaccine => 'Vacina';

  @override
  String get healthCategoryParasite => 'Parasitas';

  @override
  String get healthCategoryExam => 'Consulta';

  @override
  String get healthCategoryDental => 'Dentário';

  @override
  String get healthCategorySurgery => 'Cirurgia';

  @override
  String get healthCategoryLab => 'Análises';

  @override
  String get healthCategoryIdentification => 'Identificação';

  @override
  String get healthCategoryTreatment => 'Tratamento';

  @override
  String get healthCategoryWeight => 'Peso';

  @override
  String get healthCategoryOther => 'Outro';

  @override
  String get healthCarnetTitle => 'Boletim de saúde';

  @override
  String healthCarnetUpdatedOn(String date) {
    return 'Atualizado a $date';
  }

  @override
  String get healthCarnetStatWeightLabel => 'PESO';

  @override
  String get healthCarnetStatTodoLabel => 'A FAZER';

  @override
  String healthCarnetWeightDelta(String delta, String month) {
    return '$delta kg desde $month';
  }

  @override
  String get healthCarnetWeightNoData => 'Ainda sem pesagem';

  @override
  String get healthCarnetWeightAdd => 'Adicionar uma pesagem';

  @override
  String healthCarnetTodoUrgent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count urgentes',
      one: '1 urgente',
    );
    return '$_temp0';
  }

  @override
  String get healthCarnetTodoNone => 'Nada urgente';

  @override
  String get healthCarnetTabUpcoming => 'Próximos';

  @override
  String get healthCarnetTabHistory => 'Histórico';

  @override
  String get healthCarnetTabCalendar => 'Calendário';

  @override
  String get healthCarnetAddCta => 'Adicionar um registo';

  @override
  String get healthCarnetErrorBody => 'Não foi possível carregar o boletim.';

  @override
  String get healthCarnetRetry => 'Tentar novamente';

  @override
  String get healthCarnetUpcomingEmpty =>
      'Nada pendente de momento. Adicione um registo anterior para criar o calendário.';

  @override
  String get healthCarnetDisclaimerTitle => 'Orientação, não uma prescrição';

  @override
  String get healthCarnetDisclaimerBody =>
      'Estas datas seguem orientações veterinárias gerais. O seu veterinário conhece o seu gato — siga sempre o conselho dele e verifique o que o seu país exige.';

  @override
  String get healthCarnetDisclaimerSource => 'Diretrizes de vacinação WSAVA';

  @override
  String get healthCarnetMarkDone => 'Marcar como feito';

  @override
  String get healthCarnetSnooze => 'Adiar';

  @override
  String healthCarnetDueBy(String date) {
    return 'Até $date';
  }

  @override
  String get healthCarnetToSchedule => 'A agendar';

  @override
  String get healthCarnetToday => 'Hoje';

  @override
  String get healthCarnetTomorrow => 'Amanhã';

  @override
  String healthCarnetInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Daqui a $count dias',
      one: 'Daqui a 1 dia',
    );
    return '$_temp0';
  }

  @override
  String healthCarnetInMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Daqui a $count meses',
      one: 'Daqui a 1 mês',
    );
    return '$_temp0';
  }

  @override
  String healthCarnetInYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Daqui a $count anos',
      one: 'Daqui a 1 ano',
    );
    return '$_temp0';
  }

  @override
  String healthCarnetLateDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias de atraso',
      one: '1 dia de atraso',
    );
    return '$_temp0';
  }

  @override
  String healthCarnetLateMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses de atraso',
      one: '1 mês de atraso',
    );
    return '$_temp0';
  }

  @override
  String healthCarnetLateYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anos de atraso',
      one: '1 ano de atraso',
    );
    return '$_temp0';
  }

  @override
  String healthCarnetEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A cada $count dias',
      one: 'Todos os dias',
    );
    return '$_temp0';
  }

  @override
  String healthCarnetEveryMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A cada $count meses',
      one: 'Todos os meses',
    );
    return '$_temp0';
  }

  @override
  String healthCarnetEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A cada $count anos',
      one: 'Todos os anos',
    );
    return '$_temp0';
  }

  @override
  String healthCarnetLastDoneOn(String date) {
    return 'Última vez a $date.';
  }

  @override
  String get healthCarnetNoRecordYet => 'Ainda sem registos.';

  @override
  String get healthCarnetSeriesNote => 'Faz parte da vacinação inicial.';

  @override
  String get healthCarnetRabiesIntervalNote =>
      'O intervalo depende da vacina utilizada.';

  @override
  String get healthCarnetLegalNote =>
      'Os requisitos variam por país — verifique as regras locais.';

  @override
  String get healthCarnetSnoozeTitle => 'Adiar por';

  @override
  String get healthCarnetSnoozeWeek => 'Uma semana';

  @override
  String get healthCarnetSnoozeMonth => 'Um mês';

  @override
  String get healthCarnetSnoozeThreeMonths => 'Três meses';

  @override
  String get healthCarnetSaveError => 'Não foi guardado. Tente novamente.';

  @override
  String get healthAddSheetTitle => 'O que pretende registar?';

  @override
  String get healthAddSectionCare => 'Cuidados de rotina';

  @override
  String get healthAddSectionOther => 'Outra coisa';

  @override
  String get healthAddFieldTitleLabel => 'Título';

  @override
  String get healthAddFieldTitleHint => 'Consulta anual';

  @override
  String get healthAddFieldDateLabel => 'Data';

  @override
  String get healthAddFieldNotesLabel => 'Notas';

  @override
  String get healthAddFieldNotesHint => 'Algo que valha a pena recordar';

  @override
  String get healthAddFieldVetLabel => 'Veterinário';

  @override
  String get healthAddFieldVetHint => 'Dr. Haddad';

  @override
  String get healthAddFieldClinicLabel => 'Clínica';

  @override
  String get healthAddFieldClinicHint => 'Clínica Al Wasl';

  @override
  String get healthAddFieldWeightLabel => 'Peso (kg)';

  @override
  String get healthAddFieldWeightHint => 'Opcional';

  @override
  String get healthAddRabiesIntervalLabel => 'Próximo reforço';

  @override
  String get healthAddRabiesOneYear => 'Daqui a 1 ano';

  @override
  String get healthAddRabiesThreeYears => 'Daqui a 3 anos';

  @override
  String get healthAddSave => 'Guardar';

  @override
  String get healthAddCancel => 'Cancelar';

  @override
  String healthSetupTitle(String catName) {
    return 'Configurar a caderneta de $catName';
  }

  @override
  String get healthSetupIntro =>
      'Três datas, e o calendário parte do que realmente aconteceu.';

  @override
  String get healthSetupQuestionVaccine => 'Quando foi a última vacina?';

  @override
  String get healthSetupQuestionDeworming =>
      'Quando foi a última desparasitação?';

  @override
  String get healthSetupQuestionCheckup =>
      'Quando foi a última visita ao veterinário?';

  @override
  String get healthSetupPickDate => 'Escolher uma data';

  @override
  String get healthSetupDontKnow => 'Não sei';

  @override
  String get healthSetupFinish => 'Concluir';

  @override
  String get healthSetupCardTitle => 'Configure em 30 segundos';

  @override
  String get healthSetupCardBody =>
      'Indique a última vacina, desparasitação e visita ao veterinário, e datamos o que vem a seguir.';

  @override
  String get healthSetupCardCta => 'Começar';

  @override
  String homeHealthEyebrow(String catName) {
    return 'Saúde de $catName';
  }

  @override
  String get healthAddTitleRequired => 'Dê um título a este registo.';

  @override
  String get homeHealthAllClearTitle => 'Tudo em dia';

  @override
  String homeHealthAllClearNext(String protocol, String date) {
    return 'A seguir: $protocol · $date';
  }

  @override
  String get homeHealthAllClearNone => 'Nada previsto nos próximos 12 meses';

  @override
  String homeHealthOthersDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count mais pendentes entre os teus gatos',
      one: '+1 mais pendente entre os teus gatos',
    );
    return '$_temp0';
  }

  @override
  String get profileHealthLabel => 'Registo de saúde';

  @override
  String profileHealthCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count em breve',
      one: '1 em breve',
    );
    return '$_temp0';
  }

  @override
  String profileHealthSetup(String catName) {
    return 'Configurar o registo de $catName';
  }

  @override
  String get healthCatPickerTitle => 'Registo de qual gato?';

  @override
  String get healthVetTitle => 'O seu veterinário';

  @override
  String get healthVetEmpty =>
      'Ainda não há veterinário guardado. Adicione um para ligar num toque e preencher os novos registos.';

  @override
  String get healthVetAdd => 'Adicionar';

  @override
  String get healthVetEdit => 'Editar';

  @override
  String get healthVetCall => 'Ligar';

  @override
  String get healthVetCallError =>
      'Não foi possível abrir a aplicação de telefone.';

  @override
  String get healthVetFieldName => 'Nome do veterinário';

  @override
  String get healthVetFieldClinic => 'Clínica';

  @override
  String get healthVetFieldPhone => 'Telefone';

  @override
  String get healthVetFieldAddress => 'Morada';

  @override
  String get healthVetSave => 'Guardar';

  @override
  String get healthVetRemove => 'Remover veterinário';

  @override
  String get healthVetNameRequired =>
      'Indique o nome do veterinário ou da clínica.';

  @override
  String healthLifestyleQuestion(String catName) {
    return 'O $catName sai à rua?';
  }

  @override
  String get healthLifestyleIndoor => 'Só em casa';

  @override
  String get healthLifestyleOutdoor => 'Sai à rua';

  @override
  String get healthLifestyleTitle => 'Estilo de vida';

  @override
  String get healthLifestyleChange => 'Alterar';

  @override
  String get healthLifestyleUnset => 'Ainda por indicar';

  @override
  String get healthLifestyleOutdoorNote =>
      'Os gatos que saem têm o reforço FeLV e a desparasitação mensal agendados.';

  @override
  String get healthLifestyleIndoorNote =>
      'Os gatos de interior mantêm o calendário padrão.';

  @override
  String healthLifestyleUnsetNote(String catName) {
    return 'Diga-nos se o $catName sai e adaptamos o calendário.';
  }

  @override
  String get healthCarnetLearnMore => 'Saber mais';

  @override
  String get healthAddPhotoLabel => 'Foto';

  @override
  String get healthAddPhotoHint =>
      'Adicione uma página do boletim ou um resultado de análise';

  @override
  String get healthAddPhotoRemove => 'Remover';

  @override
  String get healthAttachmentUploadFailed =>
      'O registo foi guardado, mas não foi possível enviar a foto.';

  @override
  String get healthAttachmentViewerTitle => 'Foto';

  @override
  String get healthBookletScanCta => 'Digitalizar o boletim';

  @override
  String get healthBookletPickerRow => 'Digitalizar o boletim de vacinas';

  @override
  String get healthBookletPickerRowDesc =>
      'Fotografe uma página e nós preenchemos os registos';

  @override
  String get healthBookletReading => 'A ler a página…';

  @override
  String get healthBookletReviewTitle => 'Registos encontrados';

  @override
  String get healthBookletReviewIntro =>
      'Desmarque o que estiver errado. As linhas duvidosas começam desmarcadas.';

  @override
  String get healthBookletUnreadable =>
      'Não conseguimos ler essa página. Tente uma foto mais nítida e de frente.';

  @override
  String get healthBookletNotBooklet =>
      'Isso não parece uma página do boletim de vacinas.';

  @override
  String get healthBookletNone => 'Nenhum registo datado nessa página.';

  @override
  String healthBookletAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adicionar $count registos',
      one: 'Adicionar 1 registo',
    );
    return '$_temp0';
  }

  @override
  String get healthBookletLowConfidence => 'Duvidoso';

  @override
  String get healthBookletEditDate => 'Editar data';

  @override
  String get healthBookletError =>
      'Não foi possível contactar o leitor. Verifique a ligação e tente novamente.';

  @override
  String get healthBookletTryAgain => 'Tentar novamente';

  @override
  String get healthShareTooltip => 'Partilhar';

  @override
  String healthShareSubject(String catName) {
    return 'Registo de saúde de $catName';
  }

  @override
  String healthShareHeading(String catName) {
    return '$catName · Registo de saúde';
  }

  @override
  String get healthShareBirthday => 'Nascimento';

  @override
  String get healthShareAge => 'Idade';

  @override
  String get healthShareWeight => 'Último peso';

  @override
  String get healthShareLifestyle => 'Estilo de vida';

  @override
  String get healthShareVaccines => 'Vacinas';

  @override
  String get healthShareUpcoming => 'A seguir';

  @override
  String get healthShareAllergies => 'Alergias';

  @override
  String get healthShareVet => 'Veterinário';

  @override
  String healthShareValidUntil(String date) {
    return 'válida até $date';
  }

  @override
  String get healthShareNoRecord => 'sem registo';

  @override
  String get healthShareFooter => 'Partilhado a partir do YuCat';

  @override
  String get healthAddFieldCourseDaysLabel => 'Duração (dias)';

  @override
  String get healthAddFieldCourseDaysHint => 'ex. 7';

  @override
  String get healthAddFieldDosesPerDayLabel => 'Tomas por dia';

  @override
  String get healthAddFieldDosesPerDayHint => 'ex. 2';

  @override
  String get healthCarnetMedicationTitle => 'Medicação';

  @override
  String healthCarnetDosesPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count×/dia',
      one: '1×/dia',
    );
    return '$_temp0';
  }

  @override
  String healthCarnetCourseDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count dias',
      one: 'Falta 1 dia',
      zero: 'Último dia',
    );
    return '$_temp0';
  }

  @override
  String get healthCarnetEntryEmpty => 'Vacinas, consultas e peso';

  @override
  String get healthCarnetWeightChartTitle => 'Evolução do peso';

  @override
  String healthCarnetWeightChartSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Últimos $count meses',
      one: 'Último mês',
    );
    return '$_temp0';
  }

  @override
  String get healthCarnetHistoryTitle => 'Todos os registos';

  @override
  String healthCarnetHistoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registos',
      one: '1 registo',
    );
    return '$_temp0';
  }

  @override
  String get healthCarnetHistoryEmpty =>
      'Ainda sem registos. Adicione a última consulta ou vacina do seu gato para começar o boletim.';

  @override
  String get healthCarnetDeleteTitle => 'Eliminar este registo?';

  @override
  String get healthCarnetDeleteBody =>
      'Será removido do boletim e as próximas datas serão recalculadas.';

  @override
  String get healthCarnetDeleteConfirm => 'Eliminar';

  @override
  String get healthCarnetDeleteCancel => 'Manter';

  @override
  String get allergenChicken => 'Frango';

  @override
  String get allergenTurkey => 'Peru';

  @override
  String get allergenBeef => 'Vaca';

  @override
  String get allergenLamb => 'Borrego';

  @override
  String get allergenPork => 'Porco';

  @override
  String get allergenDuck => 'Pato';

  @override
  String get allergenFish => 'Peixe';

  @override
  String get allergenSalmon => 'Salmão';

  @override
  String get allergenTuna => 'Atum';

  @override
  String get allergenShellfish => 'Marisco';

  @override
  String get allergenDairy => 'Lacticínios';

  @override
  String get allergenEgg => 'Ovo';

  @override
  String get allergenGrain => 'Cereais / glúten';

  @override
  String get allergenSoy => 'Soja';

  @override
  String get allergenDust => 'Pó';

  @override
  String get allergenPollen => 'Pólen';

  @override
  String get allergenGrass => 'Erva';

  @override
  String get allergenMould => 'Bolor';

  @override
  String get allergenFleaBite => 'Picadas de pulga';

  @override
  String get healthCarnetAllergiesTitle => 'Alergias e sensibilidades';

  @override
  String get healthCarnetAllergiesFooter =>
      'Os alimentos desta lista são assinalados ao digitalizar um produto e as receitas que os usam ficam ocultas.';

  @override
  String get healthCarnetAllergiesEmpty => 'Nada registado.';

  @override
  String get healthCarnetAllergiesEdit => 'Editar';

  @override
  String get healthCarnetAllergiesSheetTitle => 'A que reage o seu gato?';

  @override
  String get healthCarnetAllergiesSectionFood => 'Alimentos';

  @override
  String get healthCarnetAllergiesSectionEnvironment => 'Ambiente';

  @override
  String get healthCarnetAllergiesSave => 'Guardar';

  @override
  String get healthCarnetOngoingTitle => 'Tratamentos em curso';

  @override
  String healthCarnetOngoingNext(String date) {
    return 'Próximo $date';
  }

  @override
  String recipesHiddenByAllergies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receitas ocultas devido às alergias dos seus gatos',
      one: '1 receita oculta devido às alergias dos seus gatos',
    );
    return '$_temp0';
  }

  @override
  String assessmentDeclaredAllergen(String allergen) {
    return 'Contém $allergen, que assinalou como alergia';
  }

  @override
  String get healthCarnetCalendarSectionDone => 'Registado';

  @override
  String get healthCarnetCalendarSectionDue => 'Próximo';

  @override
  String get healthCarnetCalendarEmptyDay => 'Nada neste dia.';

  @override
  String get healthCarnetCalendarPreviousMonth => 'Mês anterior';

  @override
  String get healthCarnetCalendarNextMonth => 'Mês seguinte';

  @override
  String get healthCarnetCalendarLegendDone => 'Registado';

  @override
  String get healthCarnetCalendarLegendDue => 'Agendado';

  @override
  String get healthCarnetCalendarUnscheduledNote =>
      'O que está por agendar ainda não tem data, por isso não aparece aqui.';
}
