// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get commonNext => 'Siguiente';

  @override
  String get commonGotIt => 'Entendido';

  @override
  String get commonSkip => 'Omitir';

  @override
  String get catNameQuestion => '¿Cómo se llama tu gato?';

  @override
  String get catNameLabel => 'Nombra a tu gato';

  @override
  String get catNameHint => 'Caramelo';

  @override
  String get catNameValidationEmpty => 'Introduce un nombre para el gato';

  @override
  String get genderQuestion => '¿Cuál es el sexo de tu gato?';

  @override
  String get genderFemale => 'Hembra';

  @override
  String get genderMale => 'Macho';

  @override
  String get photoTapHint => 'Toca aquí';

  @override
  String get photoQuestion => 'Añade una foto de tu gato';

  @override
  String get photoSheetTitle => 'Añadir una foto';

  @override
  String get photoSheetTakePhoto => 'Hacer una foto';

  @override
  String get photoSheetUploadLibrary => 'Subir desde la galería';

  @override
  String get photoCameraError =>
      'No se pudo acceder a la cámara. Revisa los permisos en Ajustes.';

  @override
  String get photoLibraryError =>
      'No se pudieron abrir tus fotos. Revisa los permisos en Ajustes.';

  @override
  String get ageQuestion => '¿Qué edad tiene tu gato?';

  @override
  String get ageColumnYears => 'Años';

  @override
  String get ageColumnMonths => 'Meses';

  @override
  String get ageUnitYear => 'a';

  @override
  String get ageUnitMonth => 'm';

  @override
  String ageStageKitten(String years) {
    return 'Unos $years años — un gatito.';
  }

  @override
  String ageStageAdult(String years) {
    return 'Unos $years años — un adulto.';
  }

  @override
  String ageStageSenior(String years) {
    return 'Unos $years años — un gato senior.';
  }

  @override
  String get bodyConditionQuestion => '¿Cuál es la complexión de tu gato?';

  @override
  String get bodyUnderweightLabel => 'Bajo de peso';

  @override
  String get bodyUnderweightDesc =>
      'Se ven costillas y columna, muy poca grasa';

  @override
  String get bodyNormalLabel => 'En su punto';

  @override
  String get bodyNormalDesc => 'Costillas fáciles de palpar, cintura visible';

  @override
  String get bodyOverweightLabel => 'Con sobrepeso';

  @override
  String get bodyOverweightDesc =>
      'Costillas difíciles de palpar, barriga redondeada';

  @override
  String get bodyObeseLabel => 'Obeso';

  @override
  String get bodyObeseDesc => 'Mucha grasa, sin cintura';

  @override
  String get activityQuestion => '¿Qué tan activo es tu gato?';

  @override
  String get activityLowLabel => 'Baja';

  @override
  String get activityLowDesc => 'Duerme casi siempre, rara vez persigue';

  @override
  String get activityMediumLabel => 'Media';

  @override
  String get activityMediumDesc => 'Juega varias veces al día';

  @override
  String get activityHighLabel => 'Alta';

  @override
  String get activityHighDesc => 'Trepa, corre y caza juguetes';

  @override
  String get waterFactHeadline =>
      'La hidratación protege los riñones y la salud urinaria de tu gato';

  @override
  String get waterFactHighlight => 'los riñones y la salud urinaria';

  @override
  String get waterFactBody =>
      'La comida rica en humedad reduce el riesgo de problemas urinarios y renales: tenemos en cuenta la hidratación en cada evaluación.';

  @override
  String get neuteredQuestion => '¿Tu gato está castrado o esterilizado?';

  @override
  String get neuteredIntact => 'Entero';

  @override
  String get neuteredNeutered => 'Castrado / Esterilizado';

  @override
  String get neuteredPregnant => 'Gestante';

  @override
  String get neuteredLactating => 'Lactante';

  @override
  String get coatQuestion => '¿Qué tipo de pelaje?';

  @override
  String get coatShortHair => 'Pelo corto';

  @override
  String get coatLongHair => 'Pelo largo';

  @override
  String get coatHairless => 'Sin pelo';

  @override
  String get coatFactHeadline =>
      'Los gatos de pelo largo necesitan\nmás omega-3';

  @override
  String get coatFactHighlight => 'más omega-3';

  @override
  String get coatFactBody =>
      'El omega-3 mantiene su pelaje brillante y la piel sana.';

  @override
  String get coatFactHeadlineShort =>
      'Los gatos de pelo corto se benefician de\nmás fibra';

  @override
  String get coatFactHighlightShort => 'más fibra';

  @override
  String get coatFactBodyShort =>
      'La fibra ayuda a reducir las bolas de pelo del acicalado.';

  @override
  String get coatFactHeadlineHairless =>
      'Los gatos sin pelo queman\nmás energía';

  @override
  String get coatFactHighlightHairless => 'más energía';

  @override
  String get coatFactBodyHairless =>
      'Sin pelaje necesitan más calorías para mantenerse calientes.';

  @override
  String get healthQuestion => '¿Alguna consideración de salud?';

  @override
  String get healthNone => 'Ninguna';

  @override
  String get healthUrinaryIssues => 'Problemas urinarios';

  @override
  String get healthKidneyDisease => 'Enfermedad renal';

  @override
  String get healthSensitiveStomach => 'Estómago sensible';

  @override
  String get healthSkinAllergies => 'Alergias en la piel';

  @override
  String get healthFoodAllergies => 'Alergias alimentarias';

  @override
  String get healthDiabetes => 'Diabetes';

  @override
  String get healthDentalProblems => 'Problemas dentales';

  @override
  String get healthHairballIssues => 'Bolas de pelo';

  @override
  String get healthHeartCondition => 'Problema cardíaco';

  @override
  String get healthJointIssues => 'Problemas de articulaciones o movilidad';

  @override
  String get breedQuestion => '¿Qué raza es tu gato?';

  @override
  String get breedUnknownPrefix => '¿No sabes la raza? ';

  @override
  String get breedMixedUnknown => 'Mestizo / desconocida';

  @override
  String get disclaimerTitle => 'Orientamos, no recetamos';

  @override
  String get disclaimerBody1 =>
      'YuCat sugiere alimentos según el perfil de tu gato y los ingredientes que leemos de cada producto. No sustituye el consejo veterinario.';

  @override
  String get disclaimerBody2 =>
      'Ante enfermedades diagnosticadas o cambios bruscos de peso, apetito o comportamiento, consulta con un veterinario colegiado.';

  @override
  String get catCreateCtaCreateProfile => 'Crear perfil';

  @override
  String get catCreateCtaSaveChanges => 'Guardar cambios';

  @override
  String get catCreateCtaNoneOfThese => 'Ninguna de estas';

  @override
  String get catCreateErrorCreate =>
      'No se pudo crear el perfil. Inténtalo de nuevo.';

  @override
  String get catCreateErrorSave =>
      'No se pudieron guardar los cambios. Inténtalo de nuevo.';

  @override
  String get onboardingWelcomeHeadline =>
      'Descifra\ncada\nalimento\npara gatos';

  @override
  String get onboardingGetStarted => 'Comenzar';

  @override
  String get onboardingLegalPrefix => 'Al continuar aceptas nuestros\n';

  @override
  String get onboardingTermsOfUse => 'Términos de Uso';

  @override
  String get onboardingLegalAnd => ' y ';

  @override
  String get onboardingPrivacyNotice => 'Aviso de Privacidad';

  @override
  String get onboardingWhyYucatTitle =>
      'Por qué el enfoque\núnico de YuCat\nfunciona';

  @override
  String get onboardingLetsGo => '¡Vamos!';

  @override
  String get onboardingHealthIntroTitle =>
      'Ahora cuéntanos\nsobre la salud\nde tu gato';

  @override
  String get onboardingCouldNotOpenLink => 'No se pudo abrir este enlace.';

  @override
  String get onboardingNutritionFactHeadlinePart1 => 'Un gatito necesita\n';

  @override
  String get onboardingNutritionFactHighlight => '2,5× más proteína';

  @override
  String get onboardingNutritionFactHeadlinePart2 => '\nque un gato mayor';

  @override
  String get onboardingNutritionFactBody =>
      'La etapa de vida, el peso, la actividad y las condiciones de salud cambian lo que debe ir en el plato de tu gato.';

  @override
  String get onboardingMerckManualName => 'Manual Veterinario Merck ';

  @override
  String get onboardingMerckManualQuote =>
      'señala que las necesidades de proteínas y aminoácidos de un gato cambian con la etapa de vida: los gatitos requieren más proteínas que los adultos y son más sensibles al equilibrio de aminoácidos.';

  @override
  String get onboardingSourceLink => 'Fuente de recomendaciones';

  @override
  String get onboardingScanDemoTitle => 'Rastrea\nlo que hay dentro';

  @override
  String get onboardingScanDemoSubtitle =>
      'Apunta tu cámara a cualquier\nalimento para gatos y obtén un veredicto';

  @override
  String get onboardingProfileIntroTitle =>
      'Configuremos\nel perfil de tu gato';

  @override
  String get onboardingProfileIntroTime => '2 min';

  @override
  String get onboardingProfileIntroQuote =>
      'Un perfil rápido desbloquea veredictos personalizados en cada bolsa';

  @override
  String get onboardingProfileNameLabel => 'Dale un nombre a tu gato';

  @override
  String get onboardingProfileNameHint => 'Mochi';

  @override
  String get onboardingProofChartTitle =>
      'YuCat ofrece\nresultados a largo plazo';

  @override
  String get onboardingProofChartCalloutBold => 'Un alimento más adecuado ';

  @override
  String get onboardingProofChartCalloutRest =>
      'adaptado a las necesidades de tu gato, en solo unos escaneos';

  @override
  String get onboardingRatingEyebrow => 'Ayúdanos a crecer';

  @override
  String get onboardingRatingTitle => 'Danos una valoración';

  @override
  String get onboardingRatingStatValue => 'Adorado';

  @override
  String get onboardingRatingStatLabel => 'por dueños de gatos';

  @override
  String get onboardingRatingPeopleLabel => 'Dueños de gatos como tú';

  @override
  String get onboardingReview1Headline => '¡Exactamente lo que necesitaba!';

  @override
  String get onboardingReview1Body =>
      'Escaneé las croquetas de mi gato y finalmente entendí qué contenían. Cambié de marca esa misma semana y no me arrepentí.';

  @override
  String get onboardingReview2Headline => '¡Me encanta esta app!!!';

  @override
  String get onboardingReview2Body =>
      'Una app increíble, muy fácil de usar. Solo subo fotos del alimento y me dice todo. ¡Genial!';

  @override
  String get onboardingReview3Headline => 'Un salvavidas para gatos mayores';

  @override
  String get onboardingReview3Body =>
      'YuCat encontró un alimento para mayores que le sienta bien al estómago de Lulú en una tarde.';

  @override
  String get onboardingReview4Headline => 'Por fin me siento segura';

  @override
  String get onboardingReview4Body =>
      'Antes compraba lo que hubiera en oferta. Ahora sé qué alimentos se adaptan a las necesidades de mi gatito. Tranquilidad total.';

  @override
  String get onboardingReview5Headline => 'Tan simple de usar';

  @override
  String get onboardingReview5Body =>
      'Toma una foto y obtienes un análisis claro en segundos. Hasta mi veterinaria quedó impresionada.';

  @override
  String get onboardingReview6Headline => 'Dos gatos, dos dietas';

  @override
  String get onboardingReview6Body =>
      'Gestionar el alimento de un atigrado con sobrepeso y un siamés exigente era una pesadilla. YuCat lo hizo fácil para ambos.';

  @override
  String get onboardingAttributionTitle => '¿Cómo te enteraste\nde nosotros?';

  @override
  String get onboardingAttributionInstagram => 'Instagram';

  @override
  String get onboardingAttributionTikTok => 'TikTok';

  @override
  String get onboardingAttributionYouTube => 'YouTube';

  @override
  String get onboardingAttributionAppStore => 'Búsqueda en App Store';

  @override
  String get onboardingAttributionFriends => 'Amigos/familia';

  @override
  String get onboardingNotifPrimerTitle =>
      'Vigilaremos\nel alimento de tu gato';

  @override
  String get onboardingSetUpReminders => 'Configurar recordatorios';

  @override
  String get onboardingNotifMatchDropped => 'Compatibilidad reducida';

  @override
  String get onboardingNotifMockBody =>
      'El alimento de Luna cambió de receta — mira el nuevo veredicto 🔍';

  @override
  String get onboardingRemindersTitle => '¿Sobre qué deberíamos\nnotificarte?';

  @override
  String get commonDone => 'Listo';

  @override
  String get onboardingSetUpLater => 'Configurar después';

  @override
  String get onboardingRemindersOptionFoodChange =>
      'Cuando cambia un alimento guardado';

  @override
  String get onboardingRemindersOptionBetterFit =>
      'Cuando se encuentra una mejor opción';

  @override
  String get onboardingRemindersOptionMonthly => 'Revisión mensual';

  @override
  String get onboardingRemindersCalloutPart1 =>
      'Los recordatorios crean hábitos alimentarios saludables ';

  @override
  String get onboardingRemindersCalloutBold => '2 veces más rápido';

  @override
  String onboardingSuccessWithName(String name) {
    return '¡$name está\nlisto!';
  }

  @override
  String get onboardingSuccessNoName => '¡Todo\nlisto!';

  @override
  String get onboardingStartScanning => 'Empezar a escanear';

  @override
  String get onboardingSuccessNotSet => 'No establecido';

  @override
  String get onboardingSuccessNone => 'Ninguno';

  @override
  String get onboardingSuccessRowAge => 'Edad';

  @override
  String get onboardingSuccessRowActivity => 'Actividad';

  @override
  String get onboardingSuccessRowBodyCondition => 'Condición corporal';

  @override
  String get onboardingSuccessRowCoat => 'Pelaje';

  @override
  String get onboardingSuccessRowNeuterStatus => 'Estado de esterilización';

  @override
  String get onboardingSuccessRowBreed => 'Raza';

  @override
  String get onboardingSuccessRowHealthConditions => 'Condiciones de salud';

  @override
  String get onboardingSuccessProfileReadyTitle => 'Perfil listo';

  @override
  String get onboardingSuccessProfileReadyBody =>
      'Puedes editar estos datos en cualquier momento en el perfil de tu gato.';

  @override
  String get paywallHeroHeadline => 'Sabe exactamente\nlo que hay en el tazón';

  @override
  String get paywallHeroHighlight => 'exactamente';

  @override
  String get paywallPlusBadge => 'Plus';

  @override
  String paywallBadgeFreeTrial(int days) {
    return '$days DÍAS GRATIS';
  }

  @override
  String get paywallEverythingYouGet => 'Todo lo que obtienes';

  @override
  String get paywallFeatureIngredientScannerTitle => 'Escáner de ingredientes';

  @override
  String get paywallFeatureIngredientScannerBenefit =>
      'Escanea cualquier etiqueta en segundos';

  @override
  String get paywallFeaturePersonalizedVerdictsTitle =>
      'Veredictos personalizados';

  @override
  String get paywallFeaturePersonalizedVerdictsBenefit =>
      'Adaptado a la edad, raza y salud de tu gato';

  @override
  String get paywallFeatureUnlimitedScansTitle => 'Escaneos ilimitados';

  @override
  String get paywallFeatureUnlimitedScansBenefit =>
      'Sin límites diarios, nunca';

  @override
  String get paywallFeatureReformulationAlertsTitle =>
      'Alertas de reformulación';

  @override
  String get paywallFeatureReformulationAlertsBenefit =>
      'Entérate en cuanto cambie una receta';

  @override
  String get paywallFeatureSavedFoodsTitle => 'Alimentos guardados e historial';

  @override
  String get paywallFeatureSavedFoodsBenefit =>
      'Cada alimento que revisaste, en un solo lugar';

  @override
  String get paywallFeatureMultiCatTitle => 'Perfiles para varios gatos';

  @override
  String get paywallFeatureMultiCatBenefit =>
      'Un perfil personalizado para cada uno de tus gatos';

  @override
  String get paywallSuccessStoriesHeading =>
      'Historias de éxito\nde dueños de gatos';

  @override
  String get paywallTestimonial1Quote =>
      'Llevaba años adivinando. YuCat encontró un alimento para gatos senior suave para el estómago de Lulu en una tarde.';

  @override
  String get paywallTestimonial1Name => 'Sophie';

  @override
  String get paywallTestimonial1Detail => 'Gato senior · estómago sensible';

  @override
  String get paywallTestimonial2Quote =>
      'Escaneé el pienso de nuestro gatito y por fin entendí qué contenía. Cambié de marca esa misma semana.';

  @override
  String get paywallTestimonial2Name => 'Marco';

  @override
  String get paywallTestimonial2Detail => 'Gatito · come con caprichos';

  @override
  String get paywallTestimonial3Quote =>
      'Dos gatos, dos necesidades muy distintas. Ahora sé qué alimento le va a cada uno.';

  @override
  String get paywallTestimonial3Name => 'Priya';

  @override
  String get paywallTestimonial3Detail => 'Hogar con varios gatos';

  @override
  String get paywallStatRatingLabel => 'calificación\npromedio';

  @override
  String get paywallStatCatParentsLabel => 'dueños de gatos\nen todo el mundo';

  @override
  String get paywallCancelAnytime => 'Cancela cuando quieras.';

  @override
  String get paywallPeriodSuffixWeekly => 'semana';

  @override
  String get paywallPeriodSuffixMonthly => 'mes';

  @override
  String get paywallPeriodSuffixAnnual => 'año';

  @override
  String paywallPerPeriodPrice(String price, String period) {
    return '$price/$period';
  }

  @override
  String paywallThenPrice(String price, String period) {
    return 'luego $price/$period';
  }

  @override
  String paywallTrialDisclosure(int days, String price, String period) {
    return '$days días gratis, luego $price/$period. Cancela cuando quieras.';
  }

  @override
  String paywallPriceDisclosure(String price, String period) {
    return '$price/$period. Cancela cuando quieras.';
  }

  @override
  String paywallAutoRenewDisclosure(String price, String period, String store) {
    return 'Yucat Plus cuesta $price/$period y se renueva automáticamente salvo que lo canceles al menos 24 horas antes del final del período vigente. Gestiona o cancela cuando quieras en los ajustes de tu cuenta de $store.';
  }

  @override
  String paywallAutoRenewDisclosureTrial(
    int days,
    String price,
    String period,
    String store,
  ) {
    return 'Tu prueba gratuita de $days días pasa automáticamente a una suscripción de pago a Yucat Plus por $price/$period salvo que la canceles al menos 24 horas antes de que termine. Después se renueva automáticamente al mismo precio hasta que la canceles. Gestiona o cancela cuando quieras en los ajustes de tu cuenta de $store.';
  }

  @override
  String get paywallRestorePurchases => 'Restaurar compras';

  @override
  String get commonTerms => 'Términos';

  @override
  String get commonPrivacy => 'Privacidad';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get paywallPeriodAnnual => 'Anual';

  @override
  String get paywallPeriod6Months => '6 meses';

  @override
  String get paywallPeriod3Months => '3 meses';

  @override
  String get paywallPeriod2Months => '2 meses';

  @override
  String get paywallPeriodMonthly => 'Mensual';

  @override
  String get paywallPeriodWeekly => 'Semanal';

  @override
  String get paywallPeriodLifetime => 'De por vida';

  @override
  String get paywallCtaUnlockPlus => 'Empecemos';

  @override
  String paywallCtaRedeemTrial(int days) {
    return 'Consigue $days días gratis';
  }

  @override
  String get paywallNoPaymentDue => 'No se cobra nada ahora';

  @override
  String get paywallRetry => 'Reintentar';

  @override
  String get paywallSkipDebug => 'Omitir paywall (debug)';

  @override
  String get paywallErroriOSOnly =>
      'Las suscripciones solo están disponibles en iOS.';

  @override
  String get paywallErrorCouldNotLoadPlans =>
      'No se pudieron cargar los planes.';

  @override
  String get paywallErrorNoPlansAvailable =>
      'No hay planes de suscripción disponibles en este momento.';

  @override
  String get paywallErrorPurchaseNotComplete =>
      'La compra no se completó. Por favor, inténtalo de nuevo.';

  @override
  String get paywallErrorPurchaseFailed =>
      'La compra falló. Por favor, inténtalo de nuevo.';

  @override
  String get paywallErrorSomethingWentWrong =>
      'Algo salió mal. Por favor, inténtalo de nuevo.';

  @override
  String get paywallErrorNoActiveSubscription =>
      'No se encontró ninguna suscripción activa.';

  @override
  String get paywallErrorRestoreFailed =>
      'No se pudieron restaurar las compras. Por favor, inténtalo de nuevo.';

  @override
  String get commonGoBack => 'Volver';

  @override
  String get productDetailLoadError => 'No se pudo cargar este producto.';

  @override
  String get productDetailOverallAnalysis => 'ANÁLISIS GENERAL';

  @override
  String get productDetailAiIdentifiedPill => '* IDENTIFICADO POR IA';

  @override
  String get productDetailMyCatScore => 'Puntuación de mi gato';

  @override
  String get productDetailNoCatPrompt =>
      'Crea un perfil para tu gato y verás una puntuación personalizada.';

  @override
  String get productDetailAddACat => 'Agregar un gato';

  @override
  String get productDetailForYourCats => 'Para tus gatos';

  @override
  String productDetailCatsCount(int count) {
    return '$count GATOS';
  }

  @override
  String get productDetailPickACat =>
      'Elige un gato para ver cómo este producto se adapta a su perfil.';

  @override
  String get productDetailPersonalizedScore =>
      'Puntuación personalizada según el perfil de tu gato.';

  @override
  String get productDetailDimHealth => 'SALUD';

  @override
  String get productDetailDimWeight => 'PESO';

  @override
  String get productDetailDimAge => 'EDAD';

  @override
  String get productDetailDimActivity => 'ACTIVIDAD';

  @override
  String get productDetailDimNeuteredStatus => 'ESTADO DE CASTRACIÓN';

  @override
  String get productDetailDimBreed => 'RAZA';

  @override
  String get productDetailNeutralFit =>
      'Sin coincidencias destacadas para este gato — ajuste neutro.';

  @override
  String get productDetailAgeGroupKitten => 'Cachorro';

  @override
  String get productDetailAgeGroupAdult => 'Adulto';

  @override
  String get productDetailAgeGroupSenior => 'Senior';

  @override
  String get productDetailNutrientProtein => 'Proteína';

  @override
  String get productDetailNutrientFat => 'Grasa';

  @override
  String get productDetailNutrientMoisture => 'Humedad';

  @override
  String get productDetailNutrientFiber => 'Fibra';

  @override
  String get productDetailNutrientCarbs => 'Carbohidratos';

  @override
  String get productDetailVerdictExcellent => 'Una excelente opción diaria';

  @override
  String get productDetailVerdictGood => 'Una buena opción diaria';

  @override
  String get productDetailVerdictAverage => 'Una opción razonable';

  @override
  String get productDetailVerdictPoor => 'Mejor evitar este';

  @override
  String get productDetailNoDataHeadline => 'Aún no encontramos los detalles';

  @override
  String get productDetailNoDataBody =>
      'No pudimos encontrar el análisis garantizado de este producto. Prueba a escanear la etiqueta nutricional o vuelve más tarde: seguimos buscando.';

  @override
  String get productDetailNoDataCatsNote =>
      'Te mostraremos cómo le sienta a tus gatos cuando tengamos los datos nutricionales.';

  @override
  String get productDetailImagePlaceholder => 'PRODUCTO';

  @override
  String productDetailScoreSemantics(int score, int maxScore) {
    return 'Puntuación $score de $maxScore';
  }

  @override
  String get assessmentKittenHighProtein =>
      'Alto en proteína (>35%), beneficioso para gatitos';

  @override
  String get assessmentKittenHighFat =>
      'Alto en grasa (>18%), que favorece el crecimiento del gatito';

  @override
  String get assessmentKittenSeniorFormula =>
      'La fórmula para gatos senior no es ideal para gatitos';

  @override
  String get assessmentKittenLowProtein =>
      'Baja en proteína (<28%); puede no cubrir las necesidades del gatito';

  @override
  String get assessmentSeniorModerateProtein =>
      'Proteína moderada (30–35%), apropiada para gatos senior';

  @override
  String get assessmentSeniorHighFat =>
      'Muy alta en grasa (>20%); puede no ser adecuada para gatos senior';

  @override
  String get assessmentSeniorJointSupport =>
      'Contiene ingredientes de soporte articular (p. ej. glucosamina, condroitina)';

  @override
  String get assessmentSeniorKidneyFriendly =>
      'Formulación amable con los riñones (p. ej. menos fósforo)';

  @override
  String get assessmentUnderweightHighCalories =>
      'Alta en calorías (>380 kcal/100g); puede ayudar a un gato con bajo peso a ganar peso';

  @override
  String get assessmentUnderweightHighFat =>
      'Alta en grasa (>18%); favorece el aumento de peso en gatos con bajo peso';

  @override
  String get assessmentOverweightHighCalories =>
      'Alta en calorías (>360 kcal/100g); puede no ser ideal para un gato con sobrepeso';

  @override
  String get assessmentOverweightLowCalories =>
      'Menos calorías (<320 kcal/100g); ayudan a controlar el peso en gatos con sobrepeso';

  @override
  String get assessmentOverweightHighFiber =>
      'Más fibra (>4%); puede ayudar con la saciedad en gatos con sobrepeso';

  @override
  String get assessmentObeseHighFat =>
      'Alta en grasa (>15%); no es adecuada para gatos obesos';

  @override
  String get assessmentObeseHighCalories =>
      'Alta en calorías (>330 kcal/100g); no es ideal para gatos obesos';

  @override
  String get assessmentObeseLeanProtein =>
      'Fórmula magra y rica en proteína (>40% proteína, <12% grasa); buena para gatos obesos';

  @override
  String get assessmentLowActivityHighCalories =>
      'Alta en calorías (>360 kcal/100g); puede no convenir a un gato poco activo';

  @override
  String get assessmentLowActivityModerateCalories =>
      'Calorías moderadas (<330 kcal/100g); mejores para gatos poco activos';

  @override
  String get assessmentHighActivityHighCalories =>
      'Más calorías (>380 kcal/100g); apoyan a un gato muy activo';

  @override
  String get assessmentHighActivityHighProtein =>
      'Alta en proteína (>35%); ayuda a mantener el músculo en gatos activos';

  @override
  String get assessmentNeuteredHighCalories =>
      'Comida muy densa en calorías (>380 kcal/100g); puede favorecer el aumento de peso en gatos esterilizados';

  @override
  String get assessmentNeuteredUrinarySupport =>
      'Contiene ingredientes de soporte urinario, buenos para gatos esterilizados';

  @override
  String get assessmentNeuteredHighFat =>
      'Alta en grasa (>16%); puede no ser ideal para gatos esterilizados';

  @override
  String get assessmentPregnantHighProtein =>
      'Muy alta en proteína (>35%); cubre las mayores necesidades de gatas gestantes/lactantes';

  @override
  String get assessmentPregnantHighFat =>
      'Alta en grasa (>20%); aporta energía extra para gatas gestantes/lactantes';

  @override
  String get assessmentPregnantHighCalories =>
      'Comida muy densa en calorías (>400 kcal/100g); ayuda a cubrir las demandas energéticas en gestación/lactancia';

  @override
  String get assessmentMaineCoonJointSupport =>
      'Contiene ingredientes de soporte articular, útiles para los Maine Coon';

  @override
  String get assessmentMaineCoonHighProtein =>
      'Alta en proteína (>35%); apoya a los Maine Coon de raza grande';

  @override
  String get assessmentPersianHairball =>
      'Fórmula tipo control de bolas de pelo (fibra 4–6% o indicaciones para bolas de pelo)';

  @override
  String get assessmentPersianOmega3 =>
      'Incluye ingredientes ricos en omega-3, buenos para el pelaje/piel del Persa';

  @override
  String get assessmentPersianHighCarbs =>
      'Alta en carbohidratos (>30%); puede no ser ideal para los Persas';

  @override
  String get assessmentSiameseDigestible =>
      'Usa proteínas fácilmente digeribles, buenas para los gatos Siameses';

  @override
  String get assessmentSiameseFillers =>
      'Contiene muchos rellenos (maíz, trigo, soja) que pueden no convenir a los gatos Siameses';

  @override
  String get assessmentSphynxHighFat =>
      'Más grasa (>18%); puede favorecer la salud de la piel del Sphynx';

  @override
  String get assessmentSphynxLowFat =>
      'Fórmula baja en grasa (<12%); puede no dar suficiente soporte a la piel del Sphynx';

  @override
  String get assessmentBritishHighCalories =>
      'La comida alta en calorías puede favorecer el aumento de peso en los British Shorthair';

  @override
  String get assessmentBritishWeightManagement =>
      'La fórmula tipo control de peso es adecuada para los British Shorthair';

  @override
  String get assessmentBengalHighProtein =>
      'Alta en proteína (>38%); coincide con las necesidades energéticas del Bengala';

  @override
  String get assessmentBengalLowProtein =>
      'Baja en proteína (<30%); puede ser insuficiente para los Bengala';

  @override
  String get assessmentBreedHighProtein =>
      'Alta en proteína (>35%); apoya a razas grandes y musculosas';

  @override
  String get assessmentBreedHighFat =>
      'Mayor contenido de grasa (>18%); adecuado para razas de pelo fino y metabolismo rápido';

  @override
  String get assessmentBreedLowFat =>
      'Baja en grasa (<12%); puede ser insuficiente para razas de pelo fino';

  @override
  String get assessmentBreedHairball =>
      'Fórmula control de bolas de pelo (fibra 4–6% o indicaciones de bolas de pelo); adecuada para razas de pelo largo';

  @override
  String get assessmentBreedOmega3 =>
      'Incluye ingredientes ricos en omega-3, buenos para el pelaje y la piel';

  @override
  String get assessmentBreedHighCarbs =>
      'Alto en carbohidratos (>30%); no es ideal para esta raza';

  @override
  String get assessmentBreedDigestible =>
      'Usa proteínas fácilmente digeribles, buenas para razas delgadas y activas';

  @override
  String get assessmentBreedFillers =>
      'Contiene muchos rellenos (maíz, trigo, soja) que pueden no convenir a esta raza';

  @override
  String get assessmentBreedJointSupport =>
      'Contiene ingredientes para el apoyo articular, útiles para esta raza';

  @override
  String get assessmentBreedLowPhosphorus =>
      'Fórmula renal con bajo contenido de fósforo; adecuada para razas propensas a problemas renales';

  @override
  String get assessmentBreedHighMinerals =>
      'Alto contenido de minerales; puede no convenir a razas propensas a problemas renales';

  @override
  String get assessmentBreedHighCalories =>
      'La comida alta en calorías puede favorecer el aumento de peso en esta raza';

  @override
  String get assessmentBreedWeightManagement =>
      'Fórmula de control de peso; adecuada para razas propensas a engordar';

  @override
  String get assessmentBreedHighCarbsDiabetes =>
      'Alto en carbohidratos (>20%); puede no convenir a razas propensas a la diabetes';

  @override
  String get assessmentUrinaryLowAsh =>
      'Formulada con bajo contenido de cenizas, favorable para problemas urinarios';

  @override
  String get assessmentUrinarySupport =>
      'Incluye ingredientes de soporte urinario como arándano rojo o DL-metionina';

  @override
  String get assessmentUrinaryHighMinerals =>
      'El alto contenido de minerales puede no ser ideal para problemas urinarios';

  @override
  String get assessmentKidneyHighProtein =>
      'Alta en proteína (>32%); puede no ser ideal para la enfermedad renal';

  @override
  String get assessmentKidneyPhosphorus =>
      'Contiene fuentes de fósforo que pueden ser problemáticas en la enfermedad renal';

  @override
  String get assessmentKidneyRenalSupport =>
      'Formulada como dieta de soporte renal';

  @override
  String get assessmentSensitiveStomachLimitedIngredient =>
      'Una receta tipo ingredientes limitados puede ayudar a estómagos sensibles';

  @override
  String get assessmentSensitiveStomachLongIngredients =>
      'Una lista de ingredientes muy larga puede no convenir a estómagos sensibles';

  @override
  String get assessmentFoodAllergyCommonAllergens =>
      'Contiene alérgenos comunes como pollo, pescado o ternera';

  @override
  String get assessmentFoodAllergyNovelProteins =>
      'Usa proteínas novedosas (p. ej. pato, venado) que pueden ayudar con las alergias';

  @override
  String get assessmentSkinAllergyOmega3 =>
      'Una formulación rica en omega-3 puede favorecer la salud de la piel y el pelaje';

  @override
  String get assessmentSkinAllergyArtificialColor =>
      'Contiene colorantes artificiales que pueden agravar las alergias cutáneas';

  @override
  String get assessmentDiabetesHighCarbs =>
      'Alta en carbohidratos (>20%); menos adecuada para gatos diabéticos';

  @override
  String get assessmentDiabetesHighProtein =>
      'Muy alta en proteína (>40%); puede ayudar al control de la glucemia en la diabetes';

  @override
  String get assessmentDentalHighMoisture =>
      'La comida con alta humedad (tipo húmeda) es más fácil de comer con problemas dentales';

  @override
  String get assessmentDentalLargeKibble =>
      'Las croquetas muy grandes pueden ser difíciles de masticar con problemas dentales';

  @override
  String get assessmentHairballControl =>
      'Dieta tipo control de bolas de pelo (fibra 4–6% o indicaciones para bolas de pelo)';

  @override
  String get homeScanProduct => 'Escanea un producto';

  @override
  String get homeScanProductSubtitle => 'Fotografía el envase';

  @override
  String get homeGreetingHey => 'Bienvenido de nuevo';

  @override
  String get homeGreetingWelcome => 'Bienvenido';

  @override
  String homeReadyForCat(String name) {
    return '¿Listo para encontrar comida para $name?';
  }

  @override
  String get homeReadyToScan => '¿Listo para escanear un producto?';

  @override
  String get homeAddCatTitle => 'Añade tu gato';

  @override
  String get homeAddCatBody =>
      'Crea un perfil para obtener puntuaciones personalizadas.';

  @override
  String get homeAddCatButton => 'Añadir un gato';

  @override
  String homeProfileCompletionTitle(String name) {
    return 'Completa el perfil de $name';
  }

  @override
  String get homeProfileCompletionBody =>
      'Añade unos detalles para mejores recomendaciones.';

  @override
  String homeProfileCompletionProgress(int filled, int total) {
    return '$filled/$total';
  }

  @override
  String get homeProfileCompletionButton => 'Completar perfil';

  @override
  String get homeMyCatsTitle => 'Mis gatos';

  @override
  String get homeSavedProductsTitle => 'Productos guardados';

  @override
  String get homeSeeAll => 'Ver todos';

  @override
  String get homeNoSavedProductsTitle => 'Aún no hay productos guardados';

  @override
  String get homeNoSavedProductsBody =>
      'Toca el marcador de un producto para guardarlo aquí.';

  @override
  String get homeLoadingEyebrow => 'Un momento';

  @override
  String get homeLoadingMsgReading => 'Leyendo la etiqueta…';

  @override
  String get homeLoadingMsgSniffing => 'Olfateando los ingredientes…';

  @override
  String get homeLoadingMsgMatching => 'Comparando con nuestra base de datos…';

  @override
  String get homeLoadingMsgCrunching => 'Analizando los números…';

  @override
  String get homeLoadingMsgAlmost => 'Ya casi está…';

  @override
  String get homeCameraUnavailable => 'Cámara no disponible';

  @override
  String get homeCameraUnavailableBody =>
      'Activa el acceso a la cámara para YuCat en Ajustes, o elige una foto de tu galería.';

  @override
  String get homeChooseFromGallery => 'Elegir de la galería';

  @override
  String get homeScannerHint => 'Apunta a la etiqueta del producto';

  @override
  String get homeErrorProductNotFound => 'Producto no encontrado';

  @override
  String get homeErrorTimeout =>
      'La solicitud tardó demasiado. Inténtalo de nuevo.';

  @override
  String get homeErrorNoInternet =>
      'Sin conexión a internet. Comprueba tu red e inténtalo de nuevo.';

  @override
  String get homeErrorGeneric => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get homeCatKitten => 'Gatito';

  @override
  String get homeCatAdult => 'Adulto';

  @override
  String get homeCatSenior => 'Senior';

  @override
  String get homeCatUnderweight => 'Bajo de peso';

  @override
  String get homeCatHealthyWeight => 'Peso saludable';

  @override
  String get homeCatOverweight => 'Con sobrepeso';

  @override
  String get homeCatObese => 'Obeso';

  @override
  String homeCatConditionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count afecciones',
      one: '1 afección',
    );
    return '$_temp0';
  }

  @override
  String get scanHistoryTitle => 'Historial de escaneos';

  @override
  String scanHistoryScanCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count escaneos',
      one: '1 escaneo',
    );
    return '$_temp0';
  }

  @override
  String get scanHistoryEmptyTitle => 'Aún no hay escaneos';

  @override
  String get scanHistoryEmptyBody =>
      'Los alimentos que escanees aparecerán aquí.';

  @override
  String get commonTryAgain => 'Intentar de nuevo';

  @override
  String get searchTabTitle => 'Buscar';

  @override
  String get searchHint => 'Busca un alimento para gatos';

  @override
  String get searchRecentLabel => 'Recientes';

  @override
  String get searchClearLabel => 'Borrar';

  @override
  String get searchPopularBrands => 'Marcas populares';

  @override
  String get searchNoMatchesHeadline => 'Sin resultados';

  @override
  String get searchNoMatchesBody =>
      'Prueba con otro nombre o explora marcas populares.';

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
  String get searchErrorBody => 'Algo salió mal al buscar.';

  @override
  String get bottomNavSearch => 'Buscar';

  @override
  String get bottomNavHome => 'Inicio';

  @override
  String get bottomNavProfile => 'Perfil';

  @override
  String get productListingEmpty =>
      'No se encontraron productos para esta marca.';

  @override
  String get commonAgeGroupKitten => 'Gatito';

  @override
  String get commonAgeGroupAdult => 'Adulto';

  @override
  String get commonAgeGroupSenior => 'Mayor';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileLinkError => 'No se pudo abrir el enlace.';

  @override
  String get profileSubscriptionLinkError =>
      'No se pudo abrir las suscripciones de App Store.';

  @override
  String profileEmailError(String email) {
    return 'No se pudo abrir $email.';
  }

  @override
  String get profilePrivacyError =>
      'No se pudo abrir la Política de privacidad.';

  @override
  String get profileTermsError =>
      'No se pudo abrir los Términos y condiciones.';

  @override
  String get profileSubscriptionActive => 'Suscripción activa';

  @override
  String get profileRestorePurchases => 'Restaurar compras';

  @override
  String get profileManageSubscription => 'Gestionar suscripción';

  @override
  String get profileYourCats => 'Tus gatos';

  @override
  String get profileManage => 'Gestionar';

  @override
  String get profileAddCat => 'Agregar gato';

  @override
  String get profileSavedProductsLabel => 'Productos guardados';

  @override
  String get profileSavedProductsEmpty => 'Sin productos guardados aún';

  @override
  String profileSavedProductsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count productos guardados',
      one: '1 producto guardado',
    );
    return '$_temp0';
  }

  @override
  String get profileScanHistoryLabel => 'Historial de escaneos';

  @override
  String get profileScanHistoryEmpty => 'Sin escaneos aún';

  @override
  String profileScanHistoryCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count escaneos',
      one: '1 escaneo',
    );
    return '$_temp0';
  }

  @override
  String get profileContactUs => 'Contáctanos';

  @override
  String get profilePrivacyPolicy => 'Política de privacidad';

  @override
  String get profileTermsAndConditions => 'Términos y condiciones';

  @override
  String get profileResetOnboarding => 'Restablecer introducción';

  @override
  String get profileDebugOnly => 'Solo depuración';

  @override
  String get profileRestoreNotAvailable =>
      'La restauración solo está disponible en iOS.';

  @override
  String get profileRestoreSuccess => '¡Suscripción restaurada con éxito!';

  @override
  String get profileNoSubscriptionFound =>
      'No se encontró ninguna suscripción activa.';

  @override
  String get profileRestoreError =>
      'No se pudieron restaurar tus compras. Por favor, inténtalo de nuevo.';

  @override
  String get savedProductsTitle => 'Productos guardados';

  @override
  String savedProductsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count productos',
      one: '1 producto',
    );
    return '$_temp0';
  }

  @override
  String get savedProductsEmptyHeadline => 'Sin productos guardados aún';

  @override
  String get savedProductsEmptyBody => 'Marca productos para encontrarlos aquí';

  @override
  String get catDetailDeleteError =>
      'No se pudo eliminar a tu gato. Por favor, inténtalo de nuevo.';

  @override
  String catDetailDeleteTitle(String name) {
    return '¿Eliminar a $name?';
  }

  @override
  String get catDetailDeleteBody =>
      'Esto eliminará su perfil de forma permanente.';

  @override
  String get catDetailDeleteCancel => 'Cancelar';

  @override
  String get catDetailDeleteConfirm => 'Eliminar';

  @override
  String get catDetailProfileCompletion => 'Completitud del perfil';

  @override
  String get catDetailNotSet => 'No establecido';

  @override
  String get catDetailBreedLabel => 'Raza';

  @override
  String get catDetailAgeLabel => 'Edad';

  @override
  String get catDetailAgeYears => 'años';

  @override
  String get catDetailGenderLabel => 'Género';

  @override
  String get catDetailCoatLabel => 'Pelaje';

  @override
  String get catDetailActivityLabel => 'Actividad';

  @override
  String get catDetailBodyLabel => 'Condición corporal';

  @override
  String get catDetailStatusLabel => 'Estado';

  @override
  String get catDetailStatusNeutered => 'Castrado / Esterilizado';

  @override
  String get catDetailStatusSpayed => 'Esterilizada';

  @override
  String get catDetailDetailsSection => 'Detalles';

  @override
  String get catDetailActivityModerate => 'Moderado';

  @override
  String get catDetailBodyNormal => 'Normal';

  @override
  String get catDetailCoatMedium => 'Pelo mediano';

  @override
  String get catDetailHealthConditionsSection => 'Condiciones de salud';

  @override
  String get catDetailDeleteProfile => 'Eliminar perfil';

  @override
  String get catListingTitle => 'Tus gatos';

  @override
  String get catListingErrorGeneric => 'Algo salió mal';

  @override
  String get catListingEmptyHeadline => 'Aún no hay gatos';

  @override
  String get catListingEmptyBody =>
      'Agrega tu primer gato para obtener recomendaciones personalizadas';

  @override
  String get catListingEmptyCta => 'Agrega tu gato';

  @override
  String get catListingAddAnotherCat => 'Agregar otro gato';

  @override
  String get catListingCreateNewProfile => 'Crear un nuevo perfil';

  @override
  String get catListingCatFallback => 'Gato';

  @override
  String catListingConditionsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count condiciones',
      one: '1 condición',
    );
    return '$_temp0';
  }

  @override
  String get catDetailDietaryTipsSection => 'Consejos de alimentación';

  @override
  String get dietTipsDisclaimer =>
      'Orientación general: consulta siempre a tu veterinario para temas médicos.';

  @override
  String homeCatTipsTitle(String name) {
    return 'Consejos para $name';
  }

  @override
  String get dietTitleMoreProtein => 'Más proteína';

  @override
  String get dietTitleLessProtein => 'Menos proteína';

  @override
  String get dietTitleMoreFat => 'Más grasa saludable';

  @override
  String get dietTitleLessFat => 'Menos grasa';

  @override
  String get dietTitleLessCarbs => 'Menos carbohidratos';

  @override
  String get dietTitleMoreFiber => 'Más fibra';

  @override
  String get dietTitleMoreMoisture => 'Más humedad';

  @override
  String get dietTitleMoreOmega3 => 'Más omega-3';

  @override
  String get dietTitleLessPhosphorus => 'Menos fósforo';

  @override
  String get dietTitleMoreCalories => 'Más calorías';

  @override
  String get dietTitleLessCalories => 'Menos calorías';

  @override
  String get dietTitleMoreWater => 'Más agua';

  @override
  String get dietWhyKittenProtein =>
      'Los gatitos en crecimiento necesitan más proteína para formar músculo.';

  @override
  String get dietWhyKittenFat =>
      'Las grasas saludables impulsan el rápido crecimiento y la energía del gatito.';

  @override
  String get dietWhySeniorOmega3 =>
      'Los omega-3 cuidan las articulaciones, los riñones y el pelaje en la vejez.';

  @override
  String get dietWhySeniorPhosphorus =>
      'Menos fósforo reduce la carga sobre unos riñones que envejecen.';

  @override
  String get dietWhyUnderweightCalories =>
      'Una comida rica en calorías ayuda a tu gato a alcanzar un peso saludable.';

  @override
  String get dietWhyUnderweightFat =>
      'Más grasa saludable aporta las calorías necesarias para ganar peso.';

  @override
  String get dietWhyOverweightCalories =>
      'Menos calorías favorecen una pérdida de peso gradual y saludable.';

  @override
  String get dietWhyOverweightFat =>
      'Reducir la grasa disminuye las calorías para controlar el peso.';

  @override
  String get dietWhyOverweightFiber =>
      'La fibra mantiene a tu gato saciado comiendo menos.';

  @override
  String get dietWhyOverweightProtein =>
      'La proteína magra conserva el músculo durante la pérdida de peso.';

  @override
  String get dietWhyLowActivityCalories =>
      'Un gato más tranquilo necesita menos calorías para no engordar.';

  @override
  String get dietWhyHighActivityProtein =>
      'Los gatos activos necesitan más proteína para mantener el músculo.';

  @override
  String get dietWhyHighActivityCalories =>
      'Un gato enérgico gasta más y necesita más calorías.';

  @override
  String get dietWhyNeuteredCalories =>
      'Los gatos esterilizados gastan menos energía y engordan con facilidad.';

  @override
  String get dietWhyNeuteredFat =>
      'Menos grasa ayuda a un gato esterilizado a mantenerse en forma.';

  @override
  String get dietWhyPregnantProtein =>
      'La gestación y la lactancia exigen más proteína.';

  @override
  String get dietWhyPregnantFat =>
      'Más grasa cubre las altas necesidades de energía de la lactancia.';

  @override
  String get dietWhyPregnantCalories =>
      'Más calorías sostienen la gestación y la producción de leche.';

  @override
  String get dietWhyMaineCoonProtein =>
      'Las razas grandes y musculosas prosperan con mucha proteína.';

  @override
  String get dietWhyMaineCoonOmega3 =>
      'Los omega-3 cuidan las articulaciones de las razas grandes.';

  @override
  String get dietWhyPersianOmega3 =>
      'Los omega-3 mantienen sano el largo pelaje del persa.';

  @override
  String get dietWhyPersianFiber =>
      'La fibra ayuda a mover las bolas de pelo por el intestino.';

  @override
  String get dietWhyPersianCarbs =>
      'Los persas suelen tolerar mejor las dietas bajas en carbohidratos.';

  @override
  String get dietWhySphynxFat =>
      'Los gatos sin pelo gastan energía rápido y necesitan más grasa.';

  @override
  String get dietWhyBengalProtein =>
      'Los bengalíes, muy enérgicos, necesitan mucha proteína.';

  @override
  String get dietWhyBritishCalories =>
      'Esta raza tranquila engorda con facilidad.';

  @override
  String get dietWhyBreedProtein =>
      'Las razas grandes y musculosas prosperan con mucha proteína.';

  @override
  String get dietWhyBreedOmega3 =>
      'El omega-3 mantiene sano el pelaje y las articulaciones de esta raza.';

  @override
  String get dietWhyBreedFat =>
      'Las razas de pelo fino queman energía rápido y necesitan más grasa.';

  @override
  String get dietWhyBreedFiber =>
      'La fibra ayuda a mover las bolas de pelo por el intestino.';

  @override
  String get dietWhyBreedCarbs =>
      'A esta raza le va mejor con dietas bajas en carbohidratos.';

  @override
  String get dietWhyBreedDigestibility =>
      'Las razas delgadas y activas rinden mejor con alimentos fáciles de digerir.';

  @override
  String get dietWhyBreedPhosphorus =>
      'Menos fósforo alivia la carga en razas propensas a problemas renales.';

  @override
  String get dietWhyBreedCalories =>
      'Esta raza engorda con facilidad y necesita menos calorías.';

  @override
  String get dietWhyLongCoatOmega3 =>
      'Los omega-3 nutren un pelaje largo y abundante.';

  @override
  String get dietWhyLongCoatFiber =>
      'La fibra ayuda a prevenir las bolas de pelo en gatos de pelo largo.';

  @override
  String get dietWhyHairlessFat =>
      'Los gatos sin pelo necesitan más grasa para mantenerse calientes y con energía.';

  @override
  String get dietWhyUrinaryWater =>
      'Más agua diluye la orina y protege las vías urinarias.';

  @override
  String get dietWhyKidneyPhosphorus =>
      'Poco fósforo ayuda a frenar la enfermedad renal.';

  @override
  String get dietWhyKidneyProtein =>
      'Moderar la proteína alivia la carga sobre los riñones.';

  @override
  String get dietWhyKidneyOmega3 =>
      'Los omega-3 ayudan a cuidar unos riñones afectados.';

  @override
  String get dietWhyDiabetesCarbs =>
      'Pocos carbohidratos ayudan a mantener estable el azúcar en sangre.';

  @override
  String get dietWhyDiabetesProtein =>
      'La proteína favorece el control de la glucosa y el músculo.';

  @override
  String get dietWhySkinOmega3 =>
      'Los omega-3 calman la inflamación y la irritación de la piel.';

  @override
  String get dietWhyHairballFiber =>
      'La fibra ayuda a tu gato a expulsar las bolas de pelo de forma natural.';

  @override
  String get dietWhyHairballOmega3 =>
      'Los omega-3 mejoran la salud del pelaje y reducen la caída.';

  @override
  String get dietWhyJointOmega3 =>
      'Los omega-3 reducen la inflamación y la rigidez articular.';

  @override
  String get dietWhyDentalMoisture =>
      'La comida húmeda es más suave con dientes y encías doloridos.';

  @override
  String get dietWhyWaterGeneral =>
      'Los gatos tienden a deshidratarse: la comida húmeda y el agua fresca ayudan.';

  @override
  String get assessmentHeartTaurine =>
      'Contiene taurina, esencial para la salud del corazón';

  @override
  String get assessmentHeartLowSodium =>
      'Bajo en sodio, lo que reduce el esfuerzo del corazón';

  @override
  String get assessmentHeartOmega3 =>
      'Los omega-3 cuidan el corazón y la circulación';

  @override
  String get assessmentHeartHighSodium =>
      'Alto en sodio, lo que sobrecarga el corazón';

  @override
  String get onboardingNarrativeTitle => 'Personalizado para tu gato';

  @override
  String onboardingNarrativeFallback(String name) {
    return 'Este es el comienzo del plan nutricional de $name: algunas cosas en las que nos centraríamos para ayudarle a estar en plena forma.';
  }

  @override
  String get dietTitleMoreTaurine => 'Más taurina';

  @override
  String get dietTitleLessSodium => 'Menos sodio';

  @override
  String get dietTitleNovelProtein => 'Proteínas novedosas';

  @override
  String get dietTitleDigestible => 'Comida fácil de digerir';

  @override
  String get dietWhyHeartOmega3 =>
      'Los omega-3 (EPA y DHA) cuidan el músculo cardíaco y la circulación.';

  @override
  String get dietWhyHeartTaurine =>
      'La taurina es esencial para un corazón felino sano.';

  @override
  String get dietWhyHeartSodium =>
      'Menos sodio reduce el esfuerzo del corazón.';

  @override
  String get dietWhyAllergyNovelProtein =>
      'Las proteínas novedosas o limitadas ayudan a evitar los desencadenantes habituales de alergia.';

  @override
  String get dietWhySensitiveDigestible =>
      'Las recetas suaves y muy digeribles son más amables con el estómago.';

  @override
  String get onboardingNarrativeOutlookTitle => 'En unas 2 semanas';

  @override
  String onboardingNarrativeOutlookFallback(String name) {
    return 'Con la comida adecuada, en un par de semanas podrías empezar a notar que $name tiene más energía y un pelaje más sano y brillante.';
  }

  @override
  String onboardingNarrativeFocusTitle(String name) {
    return 'En qué centrarse para $name';
  }

  @override
  String get onboardingAnalyzeEyebrow => 'Personalizando';

  @override
  String onboardingAnalyzeStep1(String name) {
    return 'Revisando el perfil de $name';
  }

  @override
  String get onboardingAnalyzeStep2 => 'Comprobando sus necesidades de salud';

  @override
  String get onboardingAnalyzeStep3 => 'Buscando la guía nutricional adecuada';

  @override
  String get onboardingAnalyzeStep4 => 'Personalizando las recomendaciones';

  @override
  String onboardingResultTitle(String name) {
    return 'El plan de $name está listo';
  }

  @override
  String productPicksTitle(String name) {
    return 'Mejores opciones para $name';
  }

  @override
  String get onboardingResultContinue => 'Continuar';

  @override
  String onboardingBrandTitle(String name) {
    return '¿Qué le das de comer a $name?';
  }

  @override
  String get onboardingBrandSubtitle =>
      'Comprobaremos qué tal es realmente para tu gato.';

  @override
  String get onboardingBrandHint =>
      'Busca una marca (p. ej. Whiskas, Royal Canin)';

  @override
  String get onboardingBrandAnalyzeCta => 'Analizar esta comida';

  @override
  String get onboardingBrandSkip => 'No estoy seguro';

  @override
  String onboardingBrandAnalyzing(String brand) {
    return 'Analizando $brand…';
  }

  @override
  String onboardingBrandUnavailable(String brand) {
    return 'No pudimos analizar $brand ahora mismo, pero esto es lo que recomendaríamos.';
  }

  @override
  String onboardingBrandUnlockCta(String name) {
    return 'Descubre las mejores opciones de $name';
  }

  @override
  String brandTeaserFound(num count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comidas mejores',
      one: '1 comida mejor',
    );
    return 'Encontramos $_temp0 para $name';
  }

  @override
  String get brandTeaserLockedHint =>
      'Suscríbete para verlas, adaptadas a las necesidades de tu gato.';

  @override
  String get brandTeaserRowLocked => 'Desbloquea para ver';

  @override
  String get onboardingScanTitle => 'Escaneemos su\nprimer paquete';

  @override
  String get onboardingScanSubtitle =>
      'Escanea el paquete y lo evaluaremos para tu gato.';

  @override
  String get onboardingScanCta => 'Vamos a escanear';

  @override
  String get onboardingScanSkip => 'Omitir por ahora';

  @override
  String get onboardingScanVerdictIntro => 'Así puntúa esa comida:';

  @override
  String get onboardingScanFailed =>
      'No pudimos leer esa etiqueta. Inténtalo de nuevo con la parte frontal del paquete a la vista.';

  @override
  String get onboardingScanRetry => 'Escanear de nuevo';

  @override
  String onboardingScanPersonalCon(String name, String con) {
    return 'Para $name: $con';
  }

  @override
  String onboardingResultWhyTitle(String name) {
    return 'Por qué no es lo ideal para $name';
  }

  @override
  String onboardingResultProfileTitle(String name) {
    return 'Perfil de $name';
  }

  @override
  String get ratingLabelExcellent => 'Excelente';

  @override
  String get ratingLabelGood => 'Bueno';

  @override
  String get ratingLabelAverage => 'Aceptable';

  @override
  String get ratingLabelPoor => 'Deficiente';
}
