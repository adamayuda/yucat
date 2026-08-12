import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hu'),
    Locale('pt'),
  ];

  /// Generic wizard CTA to advance to the next step
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// Generic acknowledgement CTA (interstitials, disclaimer)
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get commonGotIt;

  /// Generic CTA to skip an optional step
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// Mascot question on the cat-create name step
  ///
  /// In en, this message translates to:
  /// **'What\'s your cat\'s name?'**
  String get catNameQuestion;

  /// Label above the cat name input
  ///
  /// In en, this message translates to:
  /// **'Name your cat'**
  String get catNameLabel;

  /// Placeholder example cat name in the name input
  ///
  /// In en, this message translates to:
  /// **'Caramel'**
  String get catNameHint;

  /// Validation error when the cat name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a cat name'**
  String get catNameValidationEmpty;

  /// Mascot question on the gender step
  ///
  /// In en, this message translates to:
  /// **'What\'s your cat\'s gender?'**
  String get genderQuestion;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @photoTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap here'**
  String get photoTapHint;

  /// Mascot question on the profile photo step
  ///
  /// In en, this message translates to:
  /// **'Add a photo of your cat'**
  String get photoQuestion;

  /// Title of the photo source bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get photoSheetTitle;

  /// No description provided for @photoSheetTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get photoSheetTakePhoto;

  /// No description provided for @photoSheetUploadLibrary.
  ///
  /// In en, this message translates to:
  /// **'Upload from library'**
  String get photoSheetUploadLibrary;

  /// Snackbar when the camera can't be opened
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t access the camera. Check permissions in Settings.'**
  String get photoCameraError;

  /// Snackbar when the photo library can't be opened
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open your photos. Check permissions in Settings.'**
  String get photoLibraryError;

  /// No description provided for @ageQuestion.
  ///
  /// In en, this message translates to:
  /// **'How old is your cat?'**
  String get ageQuestion;

  /// No description provided for @ageColumnYears.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get ageColumnYears;

  /// No description provided for @ageColumnMonths.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get ageColumnMonths;

  /// Short unit suffix for years on the age picker
  ///
  /// In en, this message translates to:
  /// **'yr'**
  String get ageUnitYear;

  /// Short unit suffix for months on the age picker
  ///
  /// In en, this message translates to:
  /// **'mo'**
  String get ageUnitMonth;

  /// Age summary line shown for cats under 1 year
  ///
  /// In en, this message translates to:
  /// **'About {years} years old — a kitten.'**
  String ageStageKitten(String years);

  /// Age summary line shown for adult cats (1–7 years)
  ///
  /// In en, this message translates to:
  /// **'About {years} years old — an adult.'**
  String ageStageAdult(String years);

  /// Age summary line shown for senior cats (7+ years)
  ///
  /// In en, this message translates to:
  /// **'About {years} years old — a senior.'**
  String ageStageSenior(String years);

  /// No description provided for @bodyConditionQuestion.
  ///
  /// In en, this message translates to:
  /// **'What\'s your cat\'s body shape?'**
  String get bodyConditionQuestion;

  /// No description provided for @bodyUnderweightLabel.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get bodyUnderweightLabel;

  /// No description provided for @bodyUnderweightDesc.
  ///
  /// In en, this message translates to:
  /// **'Ribs and spine show, very little fat'**
  String get bodyUnderweightDesc;

  /// No description provided for @bodyNormalLabel.
  ///
  /// In en, this message translates to:
  /// **'Just right'**
  String get bodyNormalLabel;

  /// No description provided for @bodyNormalDesc.
  ///
  /// In en, this message translates to:
  /// **'Ribs felt easily, visible waist'**
  String get bodyNormalDesc;

  /// No description provided for @bodyOverweightLabel.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get bodyOverweightLabel;

  /// No description provided for @bodyOverweightDesc.
  ///
  /// In en, this message translates to:
  /// **'Ribs hard to feel, rounded belly'**
  String get bodyOverweightDesc;

  /// No description provided for @bodyObeseLabel.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get bodyObeseLabel;

  /// No description provided for @bodyObeseDesc.
  ///
  /// In en, this message translates to:
  /// **'Heavy fat cover, no waist'**
  String get bodyObeseDesc;

  /// No description provided for @activityQuestion.
  ///
  /// In en, this message translates to:
  /// **'How active is your cat?'**
  String get activityQuestion;

  /// No description provided for @activityLowLabel.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get activityLowLabel;

  /// No description provided for @activityLowDesc.
  ///
  /// In en, this message translates to:
  /// **'Mostly naps, rarely chases'**
  String get activityLowDesc;

  /// No description provided for @activityMediumLabel.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get activityMediumLabel;

  /// No description provided for @activityMediumDesc.
  ///
  /// In en, this message translates to:
  /// **'Plays a few times a day'**
  String get activityMediumDesc;

  /// No description provided for @activityHighLabel.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get activityHighLabel;

  /// No description provided for @activityHighDesc.
  ///
  /// In en, this message translates to:
  /// **'Climbs, sprints, hunts toys'**
  String get activityHighDesc;

  /// Headline of the hydration interstitial. Must contain waterFactHighlight verbatim so it can be colour-highlighted.
  ///
  /// In en, this message translates to:
  /// **'Hydration protects your cat\'s kidneys and urinary health'**
  String get waterFactHeadline;

  /// Substring of waterFactHeadline that is colour-highlighted. Keep it identical to the matching part of the headline.
  ///
  /// In en, this message translates to:
  /// **'kidneys and urinary health'**
  String get waterFactHighlight;

  /// No description provided for @waterFactBody.
  ///
  /// In en, this message translates to:
  /// **'Moisture-rich food lowers the risk of urinary and kidney issues — we weigh hydration into every assessment.'**
  String get waterFactBody;

  /// No description provided for @neuteredQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is your cat neutered or spayed?'**
  String get neuteredQuestion;

  /// No description provided for @neuteredIntact.
  ///
  /// In en, this message translates to:
  /// **'Intact'**
  String get neuteredIntact;

  /// No description provided for @neuteredNeutered.
  ///
  /// In en, this message translates to:
  /// **'Neutered / Spayed'**
  String get neuteredNeutered;

  /// No description provided for @neuteredPregnant.
  ///
  /// In en, this message translates to:
  /// **'Pregnant'**
  String get neuteredPregnant;

  /// No description provided for @neuteredLactating.
  ///
  /// In en, this message translates to:
  /// **'Lactating'**
  String get neuteredLactating;

  /// No description provided for @coatQuestion.
  ///
  /// In en, this message translates to:
  /// **'What type of coat?'**
  String get coatQuestion;

  /// No description provided for @coatShortHair.
  ///
  /// In en, this message translates to:
  /// **'Short hair'**
  String get coatShortHair;

  /// No description provided for @coatLongHair.
  ///
  /// In en, this message translates to:
  /// **'Long hair'**
  String get coatLongHair;

  /// No description provided for @coatHairless.
  ///
  /// In en, this message translates to:
  /// **'Hairless'**
  String get coatHairless;

  /// Headline of the coat-health interstitial. Must contain coatFactHighlight verbatim so it can be colour-highlighted.
  ///
  /// In en, this message translates to:
  /// **'Long-haired cats need\nmore omega-3'**
  String get coatFactHeadline;

  /// Substring of coatFactHeadline that is colour-highlighted. Keep it identical to the matching part of the headline.
  ///
  /// In en, this message translates to:
  /// **'more omega-3'**
  String get coatFactHighlight;

  /// No description provided for @coatFactBody.
  ///
  /// In en, this message translates to:
  /// **'Omega-3 keeps their coat glossy and skin healthy.'**
  String get coatFactBody;

  /// Headline of the coat-health interstitial for short-haired cats. Must contain coatFactHighlightShort verbatim so it can be colour-highlighted.
  ///
  /// In en, this message translates to:
  /// **'Short-haired cats benefit from\nextra fiber'**
  String get coatFactHeadlineShort;

  /// Substring of coatFactHeadlineShort that is colour-highlighted. Keep it identical to the matching part of the headline.
  ///
  /// In en, this message translates to:
  /// **'extra fiber'**
  String get coatFactHighlightShort;

  /// No description provided for @coatFactBodyShort.
  ///
  /// In en, this message translates to:
  /// **'Fiber helps reduce hairballs from grooming.'**
  String get coatFactBodyShort;

  /// Headline of the coat-health interstitial for hairless cats. Must contain coatFactHighlightHairless verbatim so it can be colour-highlighted.
  ///
  /// In en, this message translates to:
  /// **'Hairless cats burn\nmore energy'**
  String get coatFactHeadlineHairless;

  /// Substring of coatFactHeadlineHairless that is colour-highlighted. Keep it identical to the matching part of the headline.
  ///
  /// In en, this message translates to:
  /// **'more energy'**
  String get coatFactHighlightHairless;

  /// No description provided for @coatFactBodyHairless.
  ///
  /// In en, this message translates to:
  /// **'Without a coat they need extra calories to stay warm.'**
  String get coatFactBodyHairless;

  /// No description provided for @healthQuestion.
  ///
  /// In en, this message translates to:
  /// **'Any health considerations?'**
  String get healthQuestion;

  /// No description provided for @healthNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get healthNone;

  /// No description provided for @healthUrinaryIssues.
  ///
  /// In en, this message translates to:
  /// **'Urinary issues'**
  String get healthUrinaryIssues;

  /// No description provided for @healthKidneyDisease.
  ///
  /// In en, this message translates to:
  /// **'Kidney disease'**
  String get healthKidneyDisease;

  /// No description provided for @healthSensitiveStomach.
  ///
  /// In en, this message translates to:
  /// **'Sensitive stomach'**
  String get healthSensitiveStomach;

  /// No description provided for @healthSkinAllergies.
  ///
  /// In en, this message translates to:
  /// **'Skin allergies'**
  String get healthSkinAllergies;

  /// No description provided for @healthFoodAllergies.
  ///
  /// In en, this message translates to:
  /// **'Food allergies'**
  String get healthFoodAllergies;

  /// No description provided for @healthDiabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes'**
  String get healthDiabetes;

  /// No description provided for @healthDentalProblems.
  ///
  /// In en, this message translates to:
  /// **'Dental problems'**
  String get healthDentalProblems;

  /// No description provided for @healthHairballIssues.
  ///
  /// In en, this message translates to:
  /// **'Hairball issues'**
  String get healthHairballIssues;

  /// No description provided for @healthHeartCondition.
  ///
  /// In en, this message translates to:
  /// **'Heart condition'**
  String get healthHeartCondition;

  /// No description provided for @healthJointIssues.
  ///
  /// In en, this message translates to:
  /// **'Joint or mobility issues'**
  String get healthJointIssues;

  /// No description provided for @breedQuestion.
  ///
  /// In en, this message translates to:
  /// **'What breed is your cat?'**
  String get breedQuestion;

  /// Leading text before the tappable 'Mixed / unknown' affordance
  ///
  /// In en, this message translates to:
  /// **'Don\'t know the breed? '**
  String get breedUnknownPrefix;

  /// No description provided for @breedMixedUnknown.
  ///
  /// In en, this message translates to:
  /// **'Mixed / unknown'**
  String get breedMixedUnknown;

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Guiding, not prescribing'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerBody1.
  ///
  /// In en, this message translates to:
  /// **'YuCat suggests foods based on your cat\'s profile and the ingredients we read off each product. It is not a substitute for veterinary advice.'**
  String get disclaimerBody1;

  /// No description provided for @disclaimerBody2.
  ///
  /// In en, this message translates to:
  /// **'For diagnosed conditions or sudden changes in weight, appetite, or behavior, please consult a licensed veterinarian.'**
  String get disclaimerBody2;

  /// Final CTA when creating a new cat
  ///
  /// In en, this message translates to:
  /// **'Create profile'**
  String get catCreateCtaCreateProfile;

  /// Final CTA when editing an existing cat
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get catCreateCtaSaveChanges;

  /// Alt CTA on the health-conditions step to proceed with no selection
  ///
  /// In en, this message translates to:
  /// **'None of these'**
  String get catCreateCtaNoneOfThese;

  /// Snackbar shown when creating a cat profile fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the profile. Please try again.'**
  String get catCreateErrorCreate;

  /// Snackbar shown when saving edits to a cat fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your changes. Please try again.'**
  String get catCreateErrorSave;

  /// No description provided for @onboardingWelcomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Decode\nevery\ncat\nfood'**
  String get onboardingWelcomeHeadline;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingLegalPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing you\'re accepting our\n'**
  String get onboardingLegalPrefix;

  /// No description provided for @onboardingTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get onboardingTermsOfUse;

  /// No description provided for @onboardingLegalAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get onboardingLegalAnd;

  /// No description provided for @onboardingPrivacyNotice.
  ///
  /// In en, this message translates to:
  /// **'Privacy Notice'**
  String get onboardingPrivacyNotice;

  /// No description provided for @onboardingWhyYucatTitle.
  ///
  /// In en, this message translates to:
  /// **'Why YuCat\'s\nunique approach\nworks'**
  String get onboardingWhyYucatTitle;

  /// No description provided for @onboardingLetsGo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get onboardingLetsGo;

  /// No description provided for @onboardingHealthIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Now tell us\nabout your cat\'s\nhealth'**
  String get onboardingHealthIntroTitle;

  /// No description provided for @onboardingCouldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open this link.'**
  String get onboardingCouldNotOpenLink;

  /// No description provided for @onboardingNutritionFactHeadlinePart1.
  ///
  /// In en, this message translates to:
  /// **'A kitten needs\n'**
  String get onboardingNutritionFactHeadlinePart1;

  /// No description provided for @onboardingNutritionFactHighlight.
  ///
  /// In en, this message translates to:
  /// **'2.5× more protein'**
  String get onboardingNutritionFactHighlight;

  /// No description provided for @onboardingNutritionFactHeadlinePart2.
  ///
  /// In en, this message translates to:
  /// **'\nthan a senior cat'**
  String get onboardingNutritionFactHeadlinePart2;

  /// No description provided for @onboardingNutritionFactBody.
  ///
  /// In en, this message translates to:
  /// **'Life stage, weight, activity and health conditions all change what belongs in your cat\'s bowl.'**
  String get onboardingNutritionFactBody;

  /// No description provided for @onboardingMerckManualName.
  ///
  /// In en, this message translates to:
  /// **'Merck Veterinary Manual '**
  String get onboardingMerckManualName;

  /// No description provided for @onboardingMerckManualQuote.
  ///
  /// In en, this message translates to:
  /// **'notes a cat\'s protein and amino-acid needs change with life stage — kittens require more protein than adults and are more sensitive to amino-acid balance.'**
  String get onboardingMerckManualQuote;

  /// No description provided for @onboardingSourceLink.
  ///
  /// In en, this message translates to:
  /// **'Source of recommendations'**
  String get onboardingSourceLink;

  /// No description provided for @onboardingScanDemoTitle.
  ///
  /// In en, this message translates to:
  /// **'Track\nwhat\'s inside'**
  String get onboardingScanDemoTitle;

  /// No description provided for @onboardingScanDemoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at any\ncat food and get a verdict'**
  String get onboardingScanDemoSubtitle;

  /// No description provided for @onboardingProfileIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up\nyour cat\'s profile'**
  String get onboardingProfileIntroTitle;

  /// No description provided for @onboardingProfileIntroTime.
  ///
  /// In en, this message translates to:
  /// **'2 min'**
  String get onboardingProfileIntroTime;

  /// No description provided for @onboardingProfileIntroQuote.
  ///
  /// In en, this message translates to:
  /// **'A quick profile unlocks tailored verdicts on every bag'**
  String get onboardingProfileIntroQuote;

  /// No description provided for @onboardingProfileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name your cat'**
  String get onboardingProfileNameLabel;

  /// No description provided for @onboardingProfileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Mochi'**
  String get onboardingProfileNameHint;

  /// No description provided for @onboardingProofChartTitle.
  ///
  /// In en, this message translates to:
  /// **'YuCat provides\nlong-term results'**
  String get onboardingProofChartTitle;

  /// No description provided for @onboardingProofChartCalloutBold.
  ///
  /// In en, this message translates to:
  /// **'A better-fit food '**
  String get onboardingProofChartCalloutBold;

  /// No description provided for @onboardingProofChartCalloutRest.
  ///
  /// In en, this message translates to:
  /// **'tailored to your cat\'s needs, in just a few scans'**
  String get onboardingProofChartCalloutRest;

  /// No description provided for @onboardingRatingEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Help us grow'**
  String get onboardingRatingEyebrow;

  /// No description provided for @onboardingRatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Give us rating'**
  String get onboardingRatingTitle;

  /// No description provided for @onboardingRatingStatValue.
  ///
  /// In en, this message translates to:
  /// **'Loved'**
  String get onboardingRatingStatValue;

  /// No description provided for @onboardingRatingStatLabel.
  ///
  /// In en, this message translates to:
  /// **'by cat parents'**
  String get onboardingRatingStatLabel;

  /// No description provided for @onboardingRatingPeopleLabel.
  ///
  /// In en, this message translates to:
  /// **'Cat parents like you'**
  String get onboardingRatingPeopleLabel;

  /// No description provided for @onboardingReview1Headline.
  ///
  /// In en, this message translates to:
  /// **'Exactly what I needed!'**
  String get onboardingReview1Headline;

  /// No description provided for @onboardingReview1Body.
  ///
  /// In en, this message translates to:
  /// **'I scanned my cat\'s kibble and finally understood what was in it. Switched brands the same week and never looked back.'**
  String get onboardingReview1Body;

  /// No description provided for @onboardingReview2Headline.
  ///
  /// In en, this message translates to:
  /// **'Loving this app!!!'**
  String get onboardingReview2Headline;

  /// No description provided for @onboardingReview2Body.
  ///
  /// In en, this message translates to:
  /// **'Amazing app, so easy to use. I just upload pictures of the food and it tells me everything great!'**
  String get onboardingReview2Body;

  /// No description provided for @onboardingReview3Headline.
  ///
  /// In en, this message translates to:
  /// **'A senior-cat lifesaver'**
  String get onboardingReview3Headline;

  /// No description provided for @onboardingReview3Body.
  ///
  /// In en, this message translates to:
  /// **'YuCat narrowed down a senior food that\'s gentle on Lulu\'s stomach in one afternoon.'**
  String get onboardingReview3Body;

  /// No description provided for @onboardingReview4Headline.
  ///
  /// In en, this message translates to:
  /// **'Finally feel confident'**
  String get onboardingReview4Headline;

  /// No description provided for @onboardingReview4Body.
  ///
  /// In en, this message translates to:
  /// **'I used to just grab whatever was on sale. Now I actually know which foods match my kitten\'s needs. Total peace of mind.'**
  String get onboardingReview4Body;

  /// No description provided for @onboardingReview5Headline.
  ///
  /// In en, this message translates to:
  /// **'So simple to use'**
  String get onboardingReview5Headline;

  /// No description provided for @onboardingReview5Body.
  ///
  /// In en, this message translates to:
  /// **'Snap a photo and you get a clear breakdown in seconds. My vet was even impressed when I showed her.'**
  String get onboardingReview5Body;

  /// No description provided for @onboardingReview6Headline.
  ///
  /// In en, this message translates to:
  /// **'Two cats, two diets'**
  String get onboardingReview6Headline;

  /// No description provided for @onboardingReview6Body.
  ///
  /// In en, this message translates to:
  /// **'Managing food for an overweight tabby and a picky Siamese was a nightmare. YuCat made it effortless for both.'**
  String get onboardingReview6Body;

  /// No description provided for @onboardingAttributionTitle.
  ///
  /// In en, this message translates to:
  /// **'How did you hear\nabout us?'**
  String get onboardingAttributionTitle;

  /// No description provided for @onboardingAttributionInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get onboardingAttributionInstagram;

  /// No description provided for @onboardingAttributionTikTok.
  ///
  /// In en, this message translates to:
  /// **'TikTok'**
  String get onboardingAttributionTikTok;

  /// No description provided for @onboardingAttributionYouTube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get onboardingAttributionYouTube;

  /// No description provided for @onboardingAttributionAppStore.
  ///
  /// In en, this message translates to:
  /// **'App Store search'**
  String get onboardingAttributionAppStore;

  /// No description provided for @onboardingAttributionFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends/family'**
  String get onboardingAttributionFriends;

  /// No description provided for @onboardingNotifPrimerTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll keep an eye on\nyour cat\'s food'**
  String get onboardingNotifPrimerTitle;

  /// No description provided for @onboardingSetUpReminders.
  ///
  /// In en, this message translates to:
  /// **'Set up reminders'**
  String get onboardingSetUpReminders;

  /// No description provided for @onboardingNotifMatchDropped.
  ///
  /// In en, this message translates to:
  /// **'Match dropped'**
  String get onboardingNotifMatchDropped;

  /// No description provided for @onboardingNotifMockBody.
  ///
  /// In en, this message translates to:
  /// **'Luna\'s food changed recipe — see the new verdict 🔍'**
  String get onboardingNotifMockBody;

  /// No description provided for @onboardingRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we\nping you about?'**
  String get onboardingRemindersTitle;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @onboardingSetUpLater.
  ///
  /// In en, this message translates to:
  /// **'Set up later'**
  String get onboardingSetUpLater;

  /// No description provided for @onboardingRemindersOptionFoodChange.
  ///
  /// In en, this message translates to:
  /// **'When a saved food changes'**
  String get onboardingRemindersOptionFoodChange;

  /// No description provided for @onboardingRemindersOptionBetterFit.
  ///
  /// In en, this message translates to:
  /// **'When a better fit is found'**
  String get onboardingRemindersOptionBetterFit;

  /// No description provided for @onboardingRemindersOptionMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly check-in'**
  String get onboardingRemindersOptionMonthly;

  /// No description provided for @onboardingRemindersCalloutPart1.
  ///
  /// In en, this message translates to:
  /// **'Reminders build healthy eating habits '**
  String get onboardingRemindersCalloutPart1;

  /// No description provided for @onboardingRemindersCalloutBold.
  ///
  /// In en, this message translates to:
  /// **'2x faster'**
  String get onboardingRemindersCalloutBold;

  /// No description provided for @onboardingSuccessWithName.
  ///
  /// In en, this message translates to:
  /// **'{name} is\nall set!'**
  String onboardingSuccessWithName(String name);

  /// No description provided for @onboardingSuccessNoName.
  ///
  /// In en, this message translates to:
  /// **'You\'re all\nset!'**
  String get onboardingSuccessNoName;

  /// No description provided for @onboardingStartScanning.
  ///
  /// In en, this message translates to:
  /// **'Start scanning'**
  String get onboardingStartScanning;

  /// No description provided for @onboardingSuccessNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get onboardingSuccessNotSet;

  /// No description provided for @onboardingSuccessNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get onboardingSuccessNone;

  /// No description provided for @onboardingSuccessRowAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get onboardingSuccessRowAge;

  /// No description provided for @onboardingSuccessRowActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get onboardingSuccessRowActivity;

  /// No description provided for @onboardingSuccessRowBodyCondition.
  ///
  /// In en, this message translates to:
  /// **'Body condition'**
  String get onboardingSuccessRowBodyCondition;

  /// No description provided for @onboardingSuccessRowCoat.
  ///
  /// In en, this message translates to:
  /// **'Coat'**
  String get onboardingSuccessRowCoat;

  /// No description provided for @onboardingSuccessRowNeuterStatus.
  ///
  /// In en, this message translates to:
  /// **'Neuter status'**
  String get onboardingSuccessRowNeuterStatus;

  /// No description provided for @onboardingSuccessRowBreed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get onboardingSuccessRowBreed;

  /// No description provided for @onboardingSuccessRowHealthConditions.
  ///
  /// In en, this message translates to:
  /// **'Health conditions'**
  String get onboardingSuccessRowHealthConditions;

  /// No description provided for @onboardingSuccessProfileReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile ready'**
  String get onboardingSuccessProfileReadyTitle;

  /// No description provided for @onboardingSuccessProfileReadyBody.
  ///
  /// In en, this message translates to:
  /// **'You can edit these details anytime in your cat\'s profile.'**
  String get onboardingSuccessProfileReadyBody;

  /// No description provided for @paywallHeroHeadline.
  ///
  /// In en, this message translates to:
  /// **'Know exactly\nwhat\'s in the bowl'**
  String get paywallHeroHeadline;

  /// No description provided for @paywallHeroHighlight.
  ///
  /// In en, this message translates to:
  /// **'exactly'**
  String get paywallHeroHighlight;

  /// No description provided for @paywallPlusBadge.
  ///
  /// In en, this message translates to:
  /// **'Plus'**
  String get paywallPlusBadge;

  /// No description provided for @paywallBadgeFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'{days} DAYS FREE'**
  String paywallBadgeFreeTrial(int days);

  /// No description provided for @paywallEverythingYouGet.
  ///
  /// In en, this message translates to:
  /// **'Everything you get'**
  String get paywallEverythingYouGet;

  /// No description provided for @paywallFeatureIngredientScannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredient scanner'**
  String get paywallFeatureIngredientScannerTitle;

  /// No description provided for @paywallFeatureIngredientScannerBenefit.
  ///
  /// In en, this message translates to:
  /// **'Scan any label in seconds'**
  String get paywallFeatureIngredientScannerBenefit;

  /// No description provided for @paywallFeaturePersonalizedVerdictsTitle.
  ///
  /// In en, this message translates to:
  /// **'Personalized verdicts'**
  String get paywallFeaturePersonalizedVerdictsTitle;

  /// No description provided for @paywallFeaturePersonalizedVerdictsBenefit.
  ///
  /// In en, this message translates to:
  /// **'Matched to your cat\'s age, breed & health'**
  String get paywallFeaturePersonalizedVerdictsBenefit;

  /// No description provided for @paywallFeatureUnlimitedScansTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited scans'**
  String get paywallFeatureUnlimitedScansTitle;

  /// No description provided for @paywallFeatureUnlimitedScansBenefit.
  ///
  /// In en, this message translates to:
  /// **'No daily caps, ever'**
  String get paywallFeatureUnlimitedScansBenefit;

  /// No description provided for @paywallFeatureReformulationAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reformulation alerts'**
  String get paywallFeatureReformulationAlertsTitle;

  /// No description provided for @paywallFeatureReformulationAlertsBenefit.
  ///
  /// In en, this message translates to:
  /// **'Know the moment a recipe changes'**
  String get paywallFeatureReformulationAlertsBenefit;

  /// No description provided for @paywallFeatureSavedFoodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved foods & history'**
  String get paywallFeatureSavedFoodsTitle;

  /// No description provided for @paywallFeatureSavedFoodsBenefit.
  ///
  /// In en, this message translates to:
  /// **'Every food you\'ve checked, in one place'**
  String get paywallFeatureSavedFoodsBenefit;

  /// No description provided for @paywallFeatureMultiCatTitle.
  ///
  /// In en, this message translates to:
  /// **'Multi-cat profiles'**
  String get paywallFeatureMultiCatTitle;

  /// No description provided for @paywallFeatureMultiCatBenefit.
  ///
  /// In en, this message translates to:
  /// **'A tailored profile for each of your cats'**
  String get paywallFeatureMultiCatBenefit;

  /// No description provided for @paywallSuccessStoriesHeading.
  ///
  /// In en, this message translates to:
  /// **'Success stories\nfrom cat parents'**
  String get paywallSuccessStoriesHeading;

  /// No description provided for @paywallTestimonial1Quote.
  ///
  /// In en, this message translates to:
  /// **'I\'d been guessing for years. YuCat narrowed down a senior food that\'s gentle on Lulu\'s stomach in one afternoon.'**
  String get paywallTestimonial1Quote;

  /// No description provided for @paywallTestimonial1Name.
  ///
  /// In en, this message translates to:
  /// **'Sophie'**
  String get paywallTestimonial1Name;

  /// No description provided for @paywallTestimonial1Detail.
  ///
  /// In en, this message translates to:
  /// **'Senior cat · sensitive stomach'**
  String get paywallTestimonial1Detail;

  /// No description provided for @paywallTestimonial2Quote.
  ///
  /// In en, this message translates to:
  /// **'Scanned our kitten\'s kibble and finally understood what was in it. Switched brands the same week.'**
  String get paywallTestimonial2Quote;

  /// No description provided for @paywallTestimonial2Name.
  ///
  /// In en, this message translates to:
  /// **'Marco'**
  String get paywallTestimonial2Name;

  /// No description provided for @paywallTestimonial2Detail.
  ///
  /// In en, this message translates to:
  /// **'Kitten · picky eater'**
  String get paywallTestimonial2Detail;

  /// No description provided for @paywallTestimonial3Quote.
  ///
  /// In en, this message translates to:
  /// **'Two cats, two very different needs. Now I know which food actually fits each of them.'**
  String get paywallTestimonial3Quote;

  /// No description provided for @paywallTestimonial3Name.
  ///
  /// In en, this message translates to:
  /// **'Priya'**
  String get paywallTestimonial3Name;

  /// No description provided for @paywallTestimonial3Detail.
  ///
  /// In en, this message translates to:
  /// **'Multi-cat household'**
  String get paywallTestimonial3Detail;

  /// No description provided for @paywallStatRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'average\nrating'**
  String get paywallStatRatingLabel;

  /// No description provided for @paywallStatCatParentsLabel.
  ///
  /// In en, this message translates to:
  /// **'cat parents\nworldwide'**
  String get paywallStatCatParentsLabel;

  /// No description provided for @paywallCancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime.'**
  String get paywallCancelAnytime;

  /// No description provided for @paywallPeriodSuffixWeekly.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get paywallPeriodSuffixWeekly;

  /// No description provided for @paywallPeriodSuffixMonthly.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get paywallPeriodSuffixMonthly;

  /// No description provided for @paywallPeriodSuffixAnnual.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get paywallPeriodSuffixAnnual;

  /// No description provided for @paywallPerPeriodPrice.
  ///
  /// In en, this message translates to:
  /// **'{price}/{period}'**
  String paywallPerPeriodPrice(String price, String period);

  /// No description provided for @paywallThenPrice.
  ///
  /// In en, this message translates to:
  /// **'then {price}/{period}'**
  String paywallThenPrice(String price, String period);

  /// No description provided for @paywallTrialDisclosure.
  ///
  /// In en, this message translates to:
  /// **'{days} days free, then {price}/{period}. Cancel anytime.'**
  String paywallTrialDisclosure(int days, String price, String period);

  /// No description provided for @paywallPriceDisclosure.
  ///
  /// In en, this message translates to:
  /// **'{price}/{period}. Cancel anytime.'**
  String paywallPriceDisclosure(String price, String period);

  /// No description provided for @paywallAutoRenewDisclosure.
  ///
  /// In en, this message translates to:
  /// **'Yucat Plus costs {price}/{period} and renews automatically unless you cancel at least 24 hours before the end of the current period. Manage or cancel anytime in your {store} account settings.'**
  String paywallAutoRenewDisclosure(String price, String period, String store);

  /// No description provided for @paywallAutoRenewDisclosureTrial.
  ///
  /// In en, this message translates to:
  /// **'Your {days}-day free trial converts to a paid Yucat Plus subscription at {price}/{period} unless you cancel at least 24 hours before it ends. It then renews automatically at the same price until you cancel. Manage or cancel anytime in your {store} account settings.'**
  String paywallAutoRenewDisclosureTrial(
    int days,
    String price,
    String period,
    String store,
  );

  /// No description provided for @paywallRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestorePurchases;

  /// No description provided for @commonTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get commonTerms;

  /// No description provided for @commonPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get commonPrivacy;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @paywallPeriodAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get paywallPeriodAnnual;

  /// No description provided for @paywallPeriod6Months.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get paywallPeriod6Months;

  /// No description provided for @paywallPeriod3Months.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get paywallPeriod3Months;

  /// No description provided for @paywallPeriod2Months.
  ///
  /// In en, this message translates to:
  /// **'2 months'**
  String get paywallPeriod2Months;

  /// No description provided for @paywallPeriodMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get paywallPeriodMonthly;

  /// No description provided for @paywallPeriodWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get paywallPeriodWeekly;

  /// No description provided for @paywallPeriodLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get paywallPeriodLifetime;

  /// No description provided for @paywallCtaUnlockPlus.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get started'**
  String get paywallCtaUnlockPlus;

  /// No description provided for @paywallCtaRedeemTrial.
  ///
  /// In en, this message translates to:
  /// **'Redeem {days} days for free'**
  String paywallCtaRedeemTrial(int days);

  /// No description provided for @paywallNoPaymentDue.
  ///
  /// In en, this message translates to:
  /// **'No payment due now'**
  String get paywallNoPaymentDue;

  /// No description provided for @paywallRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get paywallRetry;

  /// No description provided for @paywallSkipDebug.
  ///
  /// In en, this message translates to:
  /// **'Skip paywall (debug)'**
  String get paywallSkipDebug;

  /// No description provided for @paywallErroriOSOnly.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions are only available on iOS.'**
  String get paywallErroriOSOnly;

  /// No description provided for @paywallErrorCouldNotLoadPlans.
  ///
  /// In en, this message translates to:
  /// **'Could not load plans.'**
  String get paywallErrorCouldNotLoadPlans;

  /// No description provided for @paywallErrorNoPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'No subscription plans are available right now.'**
  String get paywallErrorNoPlansAvailable;

  /// No description provided for @paywallErrorPurchaseNotComplete.
  ///
  /// In en, this message translates to:
  /// **'Purchase did not complete. Please try again.'**
  String get paywallErrorPurchaseNotComplete;

  /// No description provided for @paywallErrorPurchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get paywallErrorPurchaseFailed;

  /// No description provided for @paywallErrorSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get paywallErrorSomethingWentWrong;

  /// No description provided for @paywallErrorNoActiveSubscription.
  ///
  /// In en, this message translates to:
  /// **'No active subscription found.'**
  String get paywallErrorNoActiveSubscription;

  /// No description provided for @paywallErrorRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not restore purchases. Please try again.'**
  String get paywallErrorRestoreFailed;

  /// No description provided for @commonGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get commonGoBack;

  /// No description provided for @productDetailLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this product.'**
  String get productDetailLoadError;

  /// No description provided for @productDetailOverallAnalysis.
  ///
  /// In en, this message translates to:
  /// **'OVERALL ANALYSIS'**
  String get productDetailOverallAnalysis;

  /// No description provided for @productDetailAiIdentifiedPill.
  ///
  /// In en, this message translates to:
  /// **'* AI IDENTIFIED'**
  String get productDetailAiIdentifiedPill;

  /// No description provided for @productDetailMyCatScore.
  ///
  /// In en, this message translates to:
  /// **'My cat\'s score'**
  String get productDetailMyCatScore;

  /// No description provided for @productDetailNoCatPrompt.
  ///
  /// In en, this message translates to:
  /// **'Create a cat profile to see a personalized score for your cat.'**
  String get productDetailNoCatPrompt;

  /// No description provided for @productDetailAddACat.
  ///
  /// In en, this message translates to:
  /// **'Add a cat'**
  String get productDetailAddACat;

  /// No description provided for @productDetailForYourCats.
  ///
  /// In en, this message translates to:
  /// **'For your cats'**
  String get productDetailForYourCats;

  /// No description provided for @productDetailCatsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} CATS'**
  String productDetailCatsCount(int count);

  /// No description provided for @productDetailPickACat.
  ///
  /// In en, this message translates to:
  /// **'Pick a cat to see how this product fits its profile.'**
  String get productDetailPickACat;

  /// No description provided for @productDetailPersonalizedScore.
  ///
  /// In en, this message translates to:
  /// **'Personalized score based on your cat\'s profile.'**
  String get productDetailPersonalizedScore;

  /// No description provided for @productDetailDimHealth.
  ///
  /// In en, this message translates to:
  /// **'HEALTH'**
  String get productDetailDimHealth;

  /// No description provided for @productDetailDimWeight.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get productDetailDimWeight;

  /// No description provided for @productDetailDimAge.
  ///
  /// In en, this message translates to:
  /// **'AGE'**
  String get productDetailDimAge;

  /// No description provided for @productDetailDimActivity.
  ///
  /// In en, this message translates to:
  /// **'ACTIVITY'**
  String get productDetailDimActivity;

  /// No description provided for @productDetailDimNeuteredStatus.
  ///
  /// In en, this message translates to:
  /// **'NEUTERED STATUS'**
  String get productDetailDimNeuteredStatus;

  /// No description provided for @productDetailDimBreed.
  ///
  /// In en, this message translates to:
  /// **'BREED'**
  String get productDetailDimBreed;

  /// No description provided for @productDetailNeutralFit.
  ///
  /// In en, this message translates to:
  /// **'No strong matches for this cat — neutral fit.'**
  String get productDetailNeutralFit;

  /// No description provided for @productDetailAgeGroupKitten.
  ///
  /// In en, this message translates to:
  /// **'Kitten'**
  String get productDetailAgeGroupKitten;

  /// No description provided for @productDetailAgeGroupAdult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get productDetailAgeGroupAdult;

  /// No description provided for @productDetailAgeGroupSenior.
  ///
  /// In en, this message translates to:
  /// **'Senior'**
  String get productDetailAgeGroupSenior;

  /// No description provided for @productDetailNutrientProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get productDetailNutrientProtein;

  /// No description provided for @productDetailNutrientFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get productDetailNutrientFat;

  /// No description provided for @productDetailNutrientMoisture.
  ///
  /// In en, this message translates to:
  /// **'Moisture'**
  String get productDetailNutrientMoisture;

  /// No description provided for @productDetailNutrientFiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get productDetailNutrientFiber;

  /// No description provided for @productDetailNutrientCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get productDetailNutrientCarbs;

  /// No description provided for @productDetailVerdictExcellent.
  ///
  /// In en, this message translates to:
  /// **'A great everyday pick'**
  String get productDetailVerdictExcellent;

  /// No description provided for @productDetailVerdictGood.
  ///
  /// In en, this message translates to:
  /// **'A solid everyday pick'**
  String get productDetailVerdictGood;

  /// No description provided for @productDetailVerdictAverage.
  ///
  /// In en, this message translates to:
  /// **'A reasonable choice'**
  String get productDetailVerdictAverage;

  /// No description provided for @productDetailVerdictPoor.
  ///
  /// In en, this message translates to:
  /// **'Best to skip this one'**
  String get productDetailVerdictPoor;

  /// No description provided for @productDetailNoDataHeadline.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find the details yet'**
  String get productDetailNoDataHeadline;

  /// No description provided for @productDetailNoDataBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find the guaranteed analysis for this product. Try scanning the nutrition label, or check back later — we keep looking.'**
  String get productDetailNoDataBody;

  /// No description provided for @productDetailNoDataCatsNote.
  ///
  /// In en, this message translates to:
  /// **'We\'ll show how this fits your cats once we have the nutrition details.'**
  String get productDetailNoDataCatsNote;

  /// No description provided for @productDetailImagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT'**
  String get productDetailImagePlaceholder;

  /// No description provided for @productDetailScoreSemantics.
  ///
  /// In en, this message translates to:
  /// **'Score {score} out of {maxScore}'**
  String productDetailScoreSemantics(int score, int maxScore);

  /// No description provided for @assessmentKittenHighProtein.
  ///
  /// In en, this message translates to:
  /// **'High protein (>35%) which is beneficial for kittens'**
  String get assessmentKittenHighProtein;

  /// No description provided for @assessmentKittenHighFat.
  ///
  /// In en, this message translates to:
  /// **'High fat (>18%) which supports kitten growth'**
  String get assessmentKittenHighFat;

  /// No description provided for @assessmentKittenSeniorFormula.
  ///
  /// In en, this message translates to:
  /// **'Senior-targeted formula is not ideal for kittens'**
  String get assessmentKittenSeniorFormula;

  /// No description provided for @assessmentKittenLowProtein.
  ///
  /// In en, this message translates to:
  /// **'Low protein (<28%) may not meet kitten needs'**
  String get assessmentKittenLowProtein;

  /// No description provided for @assessmentSeniorModerateProtein.
  ///
  /// In en, this message translates to:
  /// **'Moderate protein (30–35%) is appropriate for seniors'**
  String get assessmentSeniorModerateProtein;

  /// No description provided for @assessmentSeniorHighFat.
  ///
  /// In en, this message translates to:
  /// **'Very high fat (>20%) may be unsuitable for seniors'**
  String get assessmentSeniorHighFat;

  /// No description provided for @assessmentSeniorJointSupport.
  ///
  /// In en, this message translates to:
  /// **'Contains joint support ingredients (e.g. glucosamine, chondroitin)'**
  String get assessmentSeniorJointSupport;

  /// No description provided for @assessmentSeniorKidneyFriendly.
  ///
  /// In en, this message translates to:
  /// **'Kidney-friendly formulation (e.g. lower phosphorus)'**
  String get assessmentSeniorKidneyFriendly;

  /// No description provided for @assessmentUnderweightHighCalories.
  ///
  /// In en, this message translates to:
  /// **'High calories (>380 kcal/100g) can help an underweight cat gain weight'**
  String get assessmentUnderweightHighCalories;

  /// No description provided for @assessmentUnderweightHighFat.
  ///
  /// In en, this message translates to:
  /// **'High fat (>18%) supports weight gain for underweight cats'**
  String get assessmentUnderweightHighFat;

  /// No description provided for @assessmentOverweightHighCalories.
  ///
  /// In en, this message translates to:
  /// **'High calories (>360 kcal/100g) may not be ideal for an overweight cat'**
  String get assessmentOverweightHighCalories;

  /// No description provided for @assessmentOverweightLowCalories.
  ///
  /// In en, this message translates to:
  /// **'Lower calories (<320 kcal/100g) help manage weight in overweight cats'**
  String get assessmentOverweightLowCalories;

  /// No description provided for @assessmentOverweightHighFiber.
  ///
  /// In en, this message translates to:
  /// **'Higher fiber (>4%) can help with satiety for overweight cats'**
  String get assessmentOverweightHighFiber;

  /// No description provided for @assessmentObeseHighFat.
  ///
  /// In en, this message translates to:
  /// **'High fat (>15%) is not suitable for obese cats'**
  String get assessmentObeseHighFat;

  /// No description provided for @assessmentObeseHighCalories.
  ///
  /// In en, this message translates to:
  /// **'High calories (>330 kcal/100g) are not ideal for obese cats'**
  String get assessmentObeseHighCalories;

  /// No description provided for @assessmentObeseLeanProtein.
  ///
  /// In en, this message translates to:
  /// **'Lean, high-protein formula (>40% protein, <12% fat) is good for obese cats'**
  String get assessmentObeseLeanProtein;

  /// No description provided for @assessmentLowActivityHighCalories.
  ///
  /// In en, this message translates to:
  /// **'High calories (>360 kcal/100g) may not suit a low-activity cat'**
  String get assessmentLowActivityHighCalories;

  /// No description provided for @assessmentLowActivityModerateCalories.
  ///
  /// In en, this message translates to:
  /// **'Moderate calories (<330 kcal/100g) are better for low-activity cats'**
  String get assessmentLowActivityModerateCalories;

  /// No description provided for @assessmentHighActivityHighCalories.
  ///
  /// In en, this message translates to:
  /// **'Higher calories (>380 kcal/100g) support a highly active cat'**
  String get assessmentHighActivityHighCalories;

  /// No description provided for @assessmentHighActivityHighProtein.
  ///
  /// In en, this message translates to:
  /// **'High protein (>35%) helps maintain muscle in active cats'**
  String get assessmentHighActivityHighProtein;

  /// No description provided for @assessmentNeuteredHighCalories.
  ///
  /// In en, this message translates to:
  /// **'Very calorie-dense food (>380 kcal/100g) can promote weight gain in neutered cats'**
  String get assessmentNeuteredHighCalories;

  /// No description provided for @assessmentNeuteredUrinarySupport.
  ///
  /// In en, this message translates to:
  /// **'Contains urinary support ingredients, good for neutered cats'**
  String get assessmentNeuteredUrinarySupport;

  /// No description provided for @assessmentNeuteredHighFat.
  ///
  /// In en, this message translates to:
  /// **'High fat (>16%) may not be ideal for neutered cats'**
  String get assessmentNeuteredHighFat;

  /// No description provided for @assessmentPregnantHighProtein.
  ///
  /// In en, this message translates to:
  /// **'Very high protein (>35%) supports the increased needs of pregnant/lactating cats'**
  String get assessmentPregnantHighProtein;

  /// No description provided for @assessmentPregnantHighFat.
  ///
  /// In en, this message translates to:
  /// **'High fat (>20%) provides extra energy for pregnant/lactating cats'**
  String get assessmentPregnantHighFat;

  /// No description provided for @assessmentPregnantHighCalories.
  ///
  /// In en, this message translates to:
  /// **'Very calorie-dense food (>400 kcal/100g) helps meet energy demands in pregnancy/lactation'**
  String get assessmentPregnantHighCalories;

  /// No description provided for @assessmentMaineCoonJointSupport.
  ///
  /// In en, this message translates to:
  /// **'Contains joint support ingredients, helpful for Maine Coons'**
  String get assessmentMaineCoonJointSupport;

  /// No description provided for @assessmentMaineCoonHighProtein.
  ///
  /// In en, this message translates to:
  /// **'High protein (>35%) supports large-breed Maine Coons'**
  String get assessmentMaineCoonHighProtein;

  /// No description provided for @assessmentPersianHairball.
  ///
  /// In en, this message translates to:
  /// **'Hairball-control style formula (fiber 4–6% or hairball claims)'**
  String get assessmentPersianHairball;

  /// No description provided for @assessmentPersianOmega3.
  ///
  /// In en, this message translates to:
  /// **'Includes omega-3 rich ingredients, good for Persian coat/skin'**
  String get assessmentPersianOmega3;

  /// No description provided for @assessmentPersianHighCarbs.
  ///
  /// In en, this message translates to:
  /// **'High carbohydrate (>30%) may not be ideal for Persians'**
  String get assessmentPersianHighCarbs;

  /// No description provided for @assessmentSiameseDigestible.
  ///
  /// In en, this message translates to:
  /// **'Uses easily digestible proteins, good for Siamese cats'**
  String get assessmentSiameseDigestible;

  /// No description provided for @assessmentSiameseFillers.
  ///
  /// In en, this message translates to:
  /// **'Contains many fillers (corn, wheat, soy) which may not suit Siamese cats'**
  String get assessmentSiameseFillers;

  /// No description provided for @assessmentSphynxHighFat.
  ///
  /// In en, this message translates to:
  /// **'Higher fat (>18%) can support Sphynx skin health'**
  String get assessmentSphynxHighFat;

  /// No description provided for @assessmentSphynxLowFat.
  ///
  /// In en, this message translates to:
  /// **'Low-fat formula (<12%) may not provide enough support for Sphynx skin'**
  String get assessmentSphynxLowFat;

  /// No description provided for @assessmentBritishHighCalories.
  ///
  /// In en, this message translates to:
  /// **'High-calorie food may promote weight gain in British Shorthairs'**
  String get assessmentBritishHighCalories;

  /// No description provided for @assessmentBritishWeightManagement.
  ///
  /// In en, this message translates to:
  /// **'Weight-management style formula is suitable for British Shorthairs'**
  String get assessmentBritishWeightManagement;

  /// No description provided for @assessmentBengalHighProtein.
  ///
  /// In en, this message translates to:
  /// **'High protein (>38%) matches Bengal energy needs'**
  String get assessmentBengalHighProtein;

  /// No description provided for @assessmentBengalLowProtein.
  ///
  /// In en, this message translates to:
  /// **'Low protein (<30%) may be insufficient for Bengals'**
  String get assessmentBengalLowProtein;

  /// No description provided for @assessmentBreedHighProtein.
  ///
  /// In en, this message translates to:
  /// **'High protein (>35%) supports large, muscular breeds'**
  String get assessmentBreedHighProtein;

  /// No description provided for @assessmentBreedHighFat.
  ///
  /// In en, this message translates to:
  /// **'Higher fat (>18%) suits fine-coated, high-metabolism breeds'**
  String get assessmentBreedHighFat;

  /// No description provided for @assessmentBreedLowFat.
  ///
  /// In en, this message translates to:
  /// **'Low fat (<12%) may not be enough for fine-coated breeds'**
  String get assessmentBreedLowFat;

  /// No description provided for @assessmentBreedHairball.
  ///
  /// In en, this message translates to:
  /// **'Hairball-control style formula (fiber 4–6% or hairball claims) suits long-coated breeds'**
  String get assessmentBreedHairball;

  /// No description provided for @assessmentBreedOmega3.
  ///
  /// In en, this message translates to:
  /// **'Includes omega-3 rich ingredients, good for coat and skin'**
  String get assessmentBreedOmega3;

  /// No description provided for @assessmentBreedHighCarbs.
  ///
  /// In en, this message translates to:
  /// **'High carbohydrate (>30%) is not ideal for this breed'**
  String get assessmentBreedHighCarbs;

  /// No description provided for @assessmentBreedDigestible.
  ///
  /// In en, this message translates to:
  /// **'Uses easily digestible proteins, good for lean, active breeds'**
  String get assessmentBreedDigestible;

  /// No description provided for @assessmentBreedFillers.
  ///
  /// In en, this message translates to:
  /// **'Contains many fillers (corn, wheat, soy) which may not suit this breed'**
  String get assessmentBreedFillers;

  /// No description provided for @assessmentBreedJointSupport.
  ///
  /// In en, this message translates to:
  /// **'Contains joint support ingredients, helpful for this breed'**
  String get assessmentBreedJointSupport;

  /// No description provided for @assessmentBreedLowPhosphorus.
  ///
  /// In en, this message translates to:
  /// **'Kidney-friendly, lower-phosphorus formula suits breeds prone to renal issues'**
  String get assessmentBreedLowPhosphorus;

  /// No description provided for @assessmentBreedHighMinerals.
  ///
  /// In en, this message translates to:
  /// **'High mineral content may not suit breeds prone to renal issues'**
  String get assessmentBreedHighMinerals;

  /// No description provided for @assessmentBreedHighCalories.
  ///
  /// In en, this message translates to:
  /// **'High-calorie food may promote weight gain in this breed'**
  String get assessmentBreedHighCalories;

  /// No description provided for @assessmentBreedWeightManagement.
  ///
  /// In en, this message translates to:
  /// **'Weight-management style formula suits breeds prone to weight gain'**
  String get assessmentBreedWeightManagement;

  /// No description provided for @assessmentBreedHighCarbsDiabetes.
  ///
  /// In en, this message translates to:
  /// **'High carbohydrate (>20%) may not suit breeds prone to diabetes'**
  String get assessmentBreedHighCarbsDiabetes;

  /// No description provided for @assessmentUrinaryLowAsh.
  ///
  /// In en, this message translates to:
  /// **'Formulated with low ash content, supportive for urinary issues'**
  String get assessmentUrinaryLowAsh;

  /// No description provided for @assessmentUrinarySupport.
  ///
  /// In en, this message translates to:
  /// **'Includes urinary-support ingredients like cranberry or DL-methionine'**
  String get assessmentUrinarySupport;

  /// No description provided for @assessmentUrinaryHighMinerals.
  ///
  /// In en, this message translates to:
  /// **'High mineral content may not be ideal for urinary issues'**
  String get assessmentUrinaryHighMinerals;

  /// No description provided for @assessmentKidneyHighProtein.
  ///
  /// In en, this message translates to:
  /// **'High protein (>32%) may not be ideal for kidney disease'**
  String get assessmentKidneyHighProtein;

  /// No description provided for @assessmentKidneyPhosphorus.
  ///
  /// In en, this message translates to:
  /// **'Contains phosphorus sources that may be problematic in kidney disease'**
  String get assessmentKidneyPhosphorus;

  /// No description provided for @assessmentKidneyRenalSupport.
  ///
  /// In en, this message translates to:
  /// **'Formulated as a renal-support diet'**
  String get assessmentKidneyRenalSupport;

  /// No description provided for @assessmentSensitiveStomachLimitedIngredient.
  ///
  /// In en, this message translates to:
  /// **'Limited-ingredient style recipe can help sensitive stomachs'**
  String get assessmentSensitiveStomachLimitedIngredient;

  /// No description provided for @assessmentSensitiveStomachLongIngredients.
  ///
  /// In en, this message translates to:
  /// **'Very long ingredient list may not suit sensitive stomachs'**
  String get assessmentSensitiveStomachLongIngredients;

  /// No description provided for @assessmentFoodAllergyCommonAllergens.
  ///
  /// In en, this message translates to:
  /// **'Contains common allergens like chicken, fish, or beef'**
  String get assessmentFoodAllergyCommonAllergens;

  /// No description provided for @assessmentFoodAllergyNovelProteins.
  ///
  /// In en, this message translates to:
  /// **'Uses novel proteins (e.g. duck, venison) which may help with allergies'**
  String get assessmentFoodAllergyNovelProteins;

  /// No description provided for @assessmentSkinAllergyOmega3.
  ///
  /// In en, this message translates to:
  /// **'Omega-3 rich formulation can support skin and coat health'**
  String get assessmentSkinAllergyOmega3;

  /// No description provided for @assessmentSkinAllergyArtificialColor.
  ///
  /// In en, this message translates to:
  /// **'Contains artificial colors which may aggravate skin allergies'**
  String get assessmentSkinAllergyArtificialColor;

  /// No description provided for @assessmentDiabetesHighCarbs.
  ///
  /// In en, this message translates to:
  /// **'High carbohydrates (>20%) are less suitable for diabetic cats'**
  String get assessmentDiabetesHighCarbs;

  /// No description provided for @assessmentDiabetesHighProtein.
  ///
  /// In en, this message translates to:
  /// **'Very high protein (>40%) can support blood sugar control in diabetes'**
  String get assessmentDiabetesHighProtein;

  /// No description provided for @assessmentDentalHighMoisture.
  ///
  /// In en, this message translates to:
  /// **'High-moisture (wet-style) food is easier to eat with dental problems'**
  String get assessmentDentalHighMoisture;

  /// No description provided for @assessmentDentalLargeKibble.
  ///
  /// In en, this message translates to:
  /// **'Very large kibble pieces may be hard to chew with dental issues'**
  String get assessmentDentalLargeKibble;

  /// No description provided for @assessmentHairballControl.
  ///
  /// In en, this message translates to:
  /// **'Hairball control style diet (fiber 4–6% or hairball claims)'**
  String get assessmentHairballControl;

  /// No description provided for @homeScanProduct.
  ///
  /// In en, this message translates to:
  /// **'Scan a product'**
  String get homeScanProduct;

  /// No description provided for @homeScanProductSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the package'**
  String get homeScanProductSubtitle;

  /// No description provided for @homeGreetingHey.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get homeGreetingHey;

  /// No description provided for @homeGreetingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get homeGreetingWelcome;

  /// No description provided for @homeReadyForCat.
  ///
  /// In en, this message translates to:
  /// **'Ready to find food for {name}?'**
  String homeReadyForCat(String name);

  /// No description provided for @homeReadyToScan.
  ///
  /// In en, this message translates to:
  /// **'Ready to scan a product?'**
  String get homeReadyToScan;

  /// No description provided for @homeAddCatTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your cat'**
  String get homeAddCatTitle;

  /// No description provided for @homeAddCatBody.
  ///
  /// In en, this message translates to:
  /// **'Create a profile to get personalized food scores.'**
  String get homeAddCatBody;

  /// No description provided for @homeAddCatButton.
  ///
  /// In en, this message translates to:
  /// **'Add a cat'**
  String get homeAddCatButton;

  /// No description provided for @homeProfileCompletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete {name}\'s profile'**
  String homeProfileCompletionTitle(String name);

  /// No description provided for @homeProfileCompletionBody.
  ///
  /// In en, this message translates to:
  /// **'Add a few details for sharper picks.'**
  String get homeProfileCompletionBody;

  /// No description provided for @homeProfileCompletionProgress.
  ///
  /// In en, this message translates to:
  /// **'{filled}/{total}'**
  String homeProfileCompletionProgress(int filled, int total);

  /// No description provided for @homeProfileCompletionButton.
  ///
  /// In en, this message translates to:
  /// **'Complete profile'**
  String get homeProfileCompletionButton;

  /// No description provided for @homeMyCatsTitle.
  ///
  /// In en, this message translates to:
  /// **'My cats'**
  String get homeMyCatsTitle;

  /// No description provided for @homeSavedProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved products'**
  String get homeSavedProductsTitle;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeNoSavedProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved products yet'**
  String get homeNoSavedProductsTitle;

  /// No description provided for @homeNoSavedProductsBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark on a product to save it here.'**
  String get homeNoSavedProductsBody;

  /// No description provided for @homeLoadingEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Hang tight'**
  String get homeLoadingEyebrow;

  /// No description provided for @homeLoadingMsgReading.
  ///
  /// In en, this message translates to:
  /// **'Reading the label…'**
  String get homeLoadingMsgReading;

  /// No description provided for @homeLoadingMsgSniffing.
  ///
  /// In en, this message translates to:
  /// **'Sniffing the ingredients…'**
  String get homeLoadingMsgSniffing;

  /// No description provided for @homeLoadingMsgMatching.
  ///
  /// In en, this message translates to:
  /// **'Matching our database…'**
  String get homeLoadingMsgMatching;

  /// No description provided for @homeLoadingMsgCrunching.
  ///
  /// In en, this message translates to:
  /// **'Crunching the numbers…'**
  String get homeLoadingMsgCrunching;

  /// No description provided for @homeLoadingMsgAlmost.
  ///
  /// In en, this message translates to:
  /// **'Almost there…'**
  String get homeLoadingMsgAlmost;

  /// No description provided for @homeCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable'**
  String get homeCameraUnavailable;

  /// No description provided for @homeCameraUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Enable camera access for YuCat in Settings, or pick a photo from your gallery instead.'**
  String get homeCameraUnavailableBody;

  /// No description provided for @homeChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get homeChooseFromGallery;

  /// No description provided for @homeScannerHint.
  ///
  /// In en, this message translates to:
  /// **'Point at the product label'**
  String get homeScannerHint;

  /// No description provided for @homeErrorProductNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get homeErrorProductNotFound;

  /// No description provided for @homeErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request took too long. Please try again.'**
  String get homeErrorTimeout;

  /// No description provided for @homeErrorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network and try again.'**
  String get homeErrorNoInternet;

  /// No description provided for @homeErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get homeErrorGeneric;

  /// No description provided for @homeCatKitten.
  ///
  /// In en, this message translates to:
  /// **'Kitten'**
  String get homeCatKitten;

  /// No description provided for @homeCatAdult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get homeCatAdult;

  /// No description provided for @homeCatSenior.
  ///
  /// In en, this message translates to:
  /// **'Senior'**
  String get homeCatSenior;

  /// No description provided for @homeCatUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get homeCatUnderweight;

  /// No description provided for @homeCatHealthyWeight.
  ///
  /// In en, this message translates to:
  /// **'Healthy weight'**
  String get homeCatHealthyWeight;

  /// No description provided for @homeCatOverweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get homeCatOverweight;

  /// No description provided for @homeCatObese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get homeCatObese;

  /// No description provided for @homeCatConditionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 condition} other{{count} conditions}}'**
  String homeCatConditionCount(num count);

  /// No description provided for @scanHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan history'**
  String get scanHistoryTitle;

  /// No description provided for @scanHistoryScanCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 scan} other{{count} scans}}'**
  String scanHistoryScanCount(num count);

  /// No description provided for @scanHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No scans yet'**
  String get scanHistoryEmptyTitle;

  /// No description provided for @scanHistoryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Foods you scan will show up here.'**
  String get scanHistoryEmptyBody;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @searchTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTabTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a cat food'**
  String get searchHint;

  /// No description provided for @searchRecentLabel.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get searchRecentLabel;

  /// No description provided for @searchClearLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClearLabel;

  /// No description provided for @searchPopularBrands.
  ///
  /// In en, this message translates to:
  /// **'Popular brands'**
  String get searchPopularBrands;

  /// No description provided for @searchNoMatchesHeadline.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get searchNoMatchesHeadline;

  /// No description provided for @searchNoMatchesBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different name, or browse popular brands.'**
  String get searchNoMatchesBody;

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String searchResultsCount(int count);

  /// No description provided for @searchErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while searching.'**
  String get searchErrorBody;

  /// No description provided for @bottomNavSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get bottomNavSearch;

  /// No description provided for @bottomNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomNavHome;

  /// No description provided for @bottomNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get bottomNavProfile;

  /// No description provided for @productListingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No products found for this brand.'**
  String get productListingEmpty;

  /// No description provided for @commonAgeGroupKitten.
  ///
  /// In en, this message translates to:
  /// **'Kitten'**
  String get commonAgeGroupKitten;

  /// No description provided for @commonAgeGroupAdult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get commonAgeGroupAdult;

  /// No description provided for @commonAgeGroupSenior.
  ///
  /// In en, this message translates to:
  /// **'Senior'**
  String get commonAgeGroupSenior;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileLinkError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open that link.'**
  String get profileLinkError;

  /// No description provided for @profileSubscriptionLinkError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open App Store subscriptions.'**
  String get profileSubscriptionLinkError;

  /// No description provided for @profileEmailError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open {email}.'**
  String profileEmailError(String email);

  /// No description provided for @profilePrivacyError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open Privacy Policy.'**
  String get profilePrivacyError;

  /// No description provided for @profileTermsError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open Terms and Conditions.'**
  String get profileTermsError;

  /// No description provided for @profileSubscriptionActive.
  ///
  /// In en, this message translates to:
  /// **'Active subscription'**
  String get profileSubscriptionActive;

  /// No description provided for @profileRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get profileRestorePurchases;

  /// No description provided for @profileManageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get profileManageSubscription;

  /// No description provided for @profileYourCats.
  ///
  /// In en, this message translates to:
  /// **'Your cats'**
  String get profileYourCats;

  /// No description provided for @profileManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get profileManage;

  /// No description provided for @profileAddCat.
  ///
  /// In en, this message translates to:
  /// **'Add cat'**
  String get profileAddCat;

  /// No description provided for @profileSavedProductsLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved products'**
  String get profileSavedProductsLabel;

  /// No description provided for @profileSavedProductsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved products yet'**
  String get profileSavedProductsEmpty;

  /// No description provided for @profileSavedProductsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 product saved} other{{count} products saved}}'**
  String profileSavedProductsCount(num count);

  /// No description provided for @profileScanHistoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan history'**
  String get profileScanHistoryLabel;

  /// No description provided for @profileScanHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No scans yet'**
  String get profileScanHistoryEmpty;

  /// No description provided for @profileScanHistoryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 scan} other{{count} scans}}'**
  String profileScanHistoryCount(num count);

  /// No description provided for @profileContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get profileContactUs;

  /// No description provided for @profilePrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profilePrivacyPolicy;

  /// No description provided for @profileTermsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get profileTermsAndConditions;

  /// No description provided for @profileResetOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Reset onboarding'**
  String get profileResetOnboarding;

  /// No description provided for @profileDebugOnly.
  ///
  /// In en, this message translates to:
  /// **'Debug only'**
  String get profileDebugOnly;

  /// No description provided for @profileRestoreNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Restore is only available on iOS.'**
  String get profileRestoreNotAvailable;

  /// No description provided for @profileRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription restored successfully!'**
  String get profileRestoreSuccess;

  /// No description provided for @profileNoSubscriptionFound.
  ///
  /// In en, this message translates to:
  /// **'No active subscription found.'**
  String get profileNoSubscriptionFound;

  /// No description provided for @profileRestoreError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t restore your purchases. Please try again.'**
  String get profileRestoreError;

  /// No description provided for @savedProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved products'**
  String get savedProductsTitle;

  /// No description provided for @savedProductsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 product} other{{count} products}}'**
  String savedProductsCount(num count);

  /// No description provided for @savedProductsEmptyHeadline.
  ///
  /// In en, this message translates to:
  /// **'No saved products yet'**
  String get savedProductsEmptyHeadline;

  /// No description provided for @savedProductsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Bookmark products to find them here'**
  String get savedProductsEmptyBody;

  /// No description provided for @catDetailDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete your cat. Please try again.'**
  String get catDetailDeleteError;

  /// No description provided for @catDetailDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String catDetailDeleteTitle(String name);

  /// No description provided for @catDetailDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete their profile.'**
  String get catDetailDeleteBody;

  /// No description provided for @catDetailDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get catDetailDeleteCancel;

  /// No description provided for @catDetailDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get catDetailDeleteConfirm;

  /// No description provided for @catDetailProfileCompletion.
  ///
  /// In en, this message translates to:
  /// **'Profile completion'**
  String get catDetailProfileCompletion;

  /// No description provided for @catDetailNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get catDetailNotSet;

  /// No description provided for @catDetailBreedLabel.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get catDetailBreedLabel;

  /// No description provided for @catDetailAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get catDetailAgeLabel;

  /// No description provided for @catDetailAgeYears.
  ///
  /// In en, this message translates to:
  /// **'yrs'**
  String get catDetailAgeYears;

  /// No description provided for @catDetailGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get catDetailGenderLabel;

  /// No description provided for @catDetailCoatLabel.
  ///
  /// In en, this message translates to:
  /// **'Coat'**
  String get catDetailCoatLabel;

  /// No description provided for @catDetailActivityLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get catDetailActivityLabel;

  /// No description provided for @catDetailBodyLabel.
  ///
  /// In en, this message translates to:
  /// **'Body condition'**
  String get catDetailBodyLabel;

  /// No description provided for @catDetailStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get catDetailStatusLabel;

  /// No description provided for @catDetailStatusNeutered.
  ///
  /// In en, this message translates to:
  /// **'Neutered / Spayed'**
  String get catDetailStatusNeutered;

  /// No description provided for @catDetailStatusSpayed.
  ///
  /// In en, this message translates to:
  /// **'Spayed'**
  String get catDetailStatusSpayed;

  /// No description provided for @catDetailDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get catDetailDetailsSection;

  /// No description provided for @catDetailActivityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get catDetailActivityModerate;

  /// No description provided for @catDetailBodyNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get catDetailBodyNormal;

  /// No description provided for @catDetailCoatMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium hair'**
  String get catDetailCoatMedium;

  /// No description provided for @catDetailHealthConditionsSection.
  ///
  /// In en, this message translates to:
  /// **'Health conditions'**
  String get catDetailHealthConditionsSection;

  /// No description provided for @catDetailDeleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Delete profile'**
  String get catDetailDeleteProfile;

  /// No description provided for @catListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cats'**
  String get catListingTitle;

  /// No description provided for @catListingErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get catListingErrorGeneric;

  /// No description provided for @catListingEmptyHeadline.
  ///
  /// In en, this message translates to:
  /// **'No cats yet'**
  String get catListingEmptyHeadline;

  /// No description provided for @catListingEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first cat to get personalized recommendations'**
  String get catListingEmptyBody;

  /// No description provided for @catListingEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Add your cat'**
  String get catListingEmptyCta;

  /// No description provided for @catListingAddAnotherCat.
  ///
  /// In en, this message translates to:
  /// **'Add another cat'**
  String get catListingAddAnotherCat;

  /// No description provided for @catListingCreateNewProfile.
  ///
  /// In en, this message translates to:
  /// **'Create a new profile'**
  String get catListingCreateNewProfile;

  /// No description provided for @catListingCatFallback.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get catListingCatFallback;

  /// No description provided for @catListingConditionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 condition} other{{count} conditions}}'**
  String catListingConditionsCount(num count);

  /// No description provided for @catDetailDietaryTipsSection.
  ///
  /// In en, this message translates to:
  /// **'Dietary tips'**
  String get catDetailDietaryTipsSection;

  /// No description provided for @dietTipsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'General guidance — always consult your vet for medical advice.'**
  String get dietTipsDisclaimer;

  /// No description provided for @homeCatTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips for {name}'**
  String homeCatTipsTitle(String name);

  /// No description provided for @dietTitleMoreProtein.
  ///
  /// In en, this message translates to:
  /// **'More protein'**
  String get dietTitleMoreProtein;

  /// No description provided for @dietTitleLessProtein.
  ///
  /// In en, this message translates to:
  /// **'Less protein'**
  String get dietTitleLessProtein;

  /// No description provided for @dietTitleMoreFat.
  ///
  /// In en, this message translates to:
  /// **'More healthy fat'**
  String get dietTitleMoreFat;

  /// No description provided for @dietTitleLessFat.
  ///
  /// In en, this message translates to:
  /// **'Less fat'**
  String get dietTitleLessFat;

  /// No description provided for @dietTitleLessCarbs.
  ///
  /// In en, this message translates to:
  /// **'Fewer carbs'**
  String get dietTitleLessCarbs;

  /// No description provided for @dietTitleMoreFiber.
  ///
  /// In en, this message translates to:
  /// **'More fiber'**
  String get dietTitleMoreFiber;

  /// No description provided for @dietTitleMoreMoisture.
  ///
  /// In en, this message translates to:
  /// **'More moisture'**
  String get dietTitleMoreMoisture;

  /// No description provided for @dietTitleMoreOmega3.
  ///
  /// In en, this message translates to:
  /// **'More omega-3'**
  String get dietTitleMoreOmega3;

  /// No description provided for @dietTitleLessPhosphorus.
  ///
  /// In en, this message translates to:
  /// **'Less phosphorus'**
  String get dietTitleLessPhosphorus;

  /// No description provided for @dietTitleMoreCalories.
  ///
  /// In en, this message translates to:
  /// **'More calories'**
  String get dietTitleMoreCalories;

  /// No description provided for @dietTitleLessCalories.
  ///
  /// In en, this message translates to:
  /// **'Fewer calories'**
  String get dietTitleLessCalories;

  /// No description provided for @dietTitleMoreWater.
  ///
  /// In en, this message translates to:
  /// **'More water'**
  String get dietTitleMoreWater;

  /// No description provided for @dietWhyKittenProtein.
  ///
  /// In en, this message translates to:
  /// **'Growing kittens need extra protein to build muscle.'**
  String get dietWhyKittenProtein;

  /// No description provided for @dietWhyKittenFat.
  ///
  /// In en, this message translates to:
  /// **'Healthy fats fuel a kitten\'s rapid growth and energy.'**
  String get dietWhyKittenFat;

  /// No description provided for @dietWhySeniorOmega3.
  ///
  /// In en, this message translates to:
  /// **'Omega-3s support aging joints, kidneys, and coat.'**
  String get dietWhySeniorOmega3;

  /// No description provided for @dietWhySeniorPhosphorus.
  ///
  /// In en, this message translates to:
  /// **'Lower phosphorus eases the load on aging kidneys.'**
  String get dietWhySeniorPhosphorus;

  /// No description provided for @dietWhyUnderweightCalories.
  ///
  /// In en, this message translates to:
  /// **'Calorie-dense food helps your cat reach a healthy weight.'**
  String get dietWhyUnderweightCalories;

  /// No description provided for @dietWhyUnderweightFat.
  ///
  /// In en, this message translates to:
  /// **'Extra healthy fat adds the calories needed to gain weight.'**
  String get dietWhyUnderweightFat;

  /// No description provided for @dietWhyOverweightCalories.
  ///
  /// In en, this message translates to:
  /// **'Fewer calories support gradual, healthy weight loss.'**
  String get dietWhyOverweightCalories;

  /// No description provided for @dietWhyOverweightFat.
  ///
  /// In en, this message translates to:
  /// **'Trimming fat lowers calorie intake for weight control.'**
  String get dietWhyOverweightFat;

  /// No description provided for @dietWhyOverweightFiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber keeps your cat full while eating less.'**
  String get dietWhyOverweightFiber;

  /// No description provided for @dietWhyOverweightProtein.
  ///
  /// In en, this message translates to:
  /// **'Lean protein preserves muscle during weight loss.'**
  String get dietWhyOverweightProtein;

  /// No description provided for @dietWhyLowActivityCalories.
  ///
  /// In en, this message translates to:
  /// **'A calmer cat needs fewer calories to avoid weight gain.'**
  String get dietWhyLowActivityCalories;

  /// No description provided for @dietWhyHighActivityProtein.
  ///
  /// In en, this message translates to:
  /// **'Active cats need more protein to maintain muscle.'**
  String get dietWhyHighActivityProtein;

  /// No description provided for @dietWhyHighActivityCalories.
  ///
  /// In en, this message translates to:
  /// **'An energetic cat burns more and needs more calories.'**
  String get dietWhyHighActivityCalories;

  /// No description provided for @dietWhyNeuteredCalories.
  ///
  /// In en, this message translates to:
  /// **'Neutered cats burn less energy and gain weight easily.'**
  String get dietWhyNeuteredCalories;

  /// No description provided for @dietWhyNeuteredFat.
  ///
  /// In en, this message translates to:
  /// **'Lower fat helps a neutered cat stay trim.'**
  String get dietWhyNeuteredFat;

  /// No description provided for @dietWhyPregnantProtein.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy and nursing demand extra protein.'**
  String get dietWhyPregnantProtein;

  /// No description provided for @dietWhyPregnantFat.
  ///
  /// In en, this message translates to:
  /// **'Extra fat meets the high energy needs of nursing.'**
  String get dietWhyPregnantFat;

  /// No description provided for @dietWhyPregnantCalories.
  ///
  /// In en, this message translates to:
  /// **'More calories sustain pregnancy and milk production.'**
  String get dietWhyPregnantCalories;

  /// No description provided for @dietWhyMaineCoonProtein.
  ///
  /// In en, this message translates to:
  /// **'Large, muscular breeds thrive on high protein.'**
  String get dietWhyMaineCoonProtein;

  /// No description provided for @dietWhyMaineCoonOmega3.
  ///
  /// In en, this message translates to:
  /// **'Omega-3s support the joints of big-boned breeds.'**
  String get dietWhyMaineCoonOmega3;

  /// No description provided for @dietWhyPersianOmega3.
  ///
  /// In en, this message translates to:
  /// **'Omega-3s keep a Persian\'s long coat healthy.'**
  String get dietWhyPersianOmega3;

  /// No description provided for @dietWhyPersianFiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber helps move hairballs through the gut.'**
  String get dietWhyPersianFiber;

  /// No description provided for @dietWhyPersianCarbs.
  ///
  /// In en, this message translates to:
  /// **'Persians tend to do better on lower-carb diets.'**
  String get dietWhyPersianCarbs;

  /// No description provided for @dietWhySphynxFat.
  ///
  /// In en, this message translates to:
  /// **'Hairless cats burn energy fast and need more fat.'**
  String get dietWhySphynxFat;

  /// No description provided for @dietWhyBengalProtein.
  ///
  /// In en, this message translates to:
  /// **'High-energy Bengals need plenty of protein.'**
  String get dietWhyBengalProtein;

  /// No description provided for @dietWhyBritishCalories.
  ///
  /// In en, this message translates to:
  /// **'This laid-back breed gains weight easily.'**
  String get dietWhyBritishCalories;

  /// No description provided for @dietWhyBreedProtein.
  ///
  /// In en, this message translates to:
  /// **'Large, muscular breeds thrive on high protein.'**
  String get dietWhyBreedProtein;

  /// No description provided for @dietWhyBreedOmega3.
  ///
  /// In en, this message translates to:
  /// **'Omega-3s keep this breed\'s coat and joints healthy.'**
  String get dietWhyBreedOmega3;

  /// No description provided for @dietWhyBreedFat.
  ///
  /// In en, this message translates to:
  /// **'Fine-coated breeds burn energy fast and need more fat.'**
  String get dietWhyBreedFat;

  /// No description provided for @dietWhyBreedFiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber helps move hairballs through the gut.'**
  String get dietWhyBreedFiber;

  /// No description provided for @dietWhyBreedCarbs.
  ///
  /// In en, this message translates to:
  /// **'This breed tends to do better on lower-carb diets.'**
  String get dietWhyBreedCarbs;

  /// No description provided for @dietWhyBreedDigestibility.
  ///
  /// In en, this message translates to:
  /// **'Lean, active breeds do best on easily digestible food.'**
  String get dietWhyBreedDigestibility;

  /// No description provided for @dietWhyBreedPhosphorus.
  ///
  /// In en, this message translates to:
  /// **'Lower phosphorus eases the load on breeds prone to kidney issues.'**
  String get dietWhyBreedPhosphorus;

  /// No description provided for @dietWhyBreedCalories.
  ///
  /// In en, this message translates to:
  /// **'This breed gains weight easily and needs fewer calories.'**
  String get dietWhyBreedCalories;

  /// No description provided for @dietWhyLongCoatOmega3.
  ///
  /// In en, this message translates to:
  /// **'Omega-3s nourish a long, thick coat.'**
  String get dietWhyLongCoatOmega3;

  /// No description provided for @dietWhyLongCoatFiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber helps prevent hairballs in long-haired cats.'**
  String get dietWhyLongCoatFiber;

  /// No description provided for @dietWhyHairlessFat.
  ///
  /// In en, this message translates to:
  /// **'Hairless cats need more fat to stay warm and energized.'**
  String get dietWhyHairlessFat;

  /// No description provided for @dietWhyUrinaryWater.
  ///
  /// In en, this message translates to:
  /// **'More water dilutes urine and protects the urinary tract.'**
  String get dietWhyUrinaryWater;

  /// No description provided for @dietWhyKidneyPhosphorus.
  ///
  /// In en, this message translates to:
  /// **'Low phosphorus helps slow kidney disease.'**
  String get dietWhyKidneyPhosphorus;

  /// No description provided for @dietWhyKidneyProtein.
  ///
  /// In en, this message translates to:
  /// **'Moderating protein eases strain on the kidneys.'**
  String get dietWhyKidneyProtein;

  /// No description provided for @dietWhyKidneyOmega3.
  ///
  /// In en, this message translates to:
  /// **'Omega-3s help support compromised kidneys.'**
  String get dietWhyKidneyOmega3;

  /// No description provided for @dietWhyDiabetesCarbs.
  ///
  /// In en, this message translates to:
  /// **'Low carbs help keep blood sugar stable.'**
  String get dietWhyDiabetesCarbs;

  /// No description provided for @dietWhyDiabetesProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein supports glucose control and muscle.'**
  String get dietWhyDiabetesProtein;

  /// No description provided for @dietWhySkinOmega3.
  ///
  /// In en, this message translates to:
  /// **'Omega-3s calm skin inflammation and irritation.'**
  String get dietWhySkinOmega3;

  /// No description provided for @dietWhyHairballFiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber helps your cat pass hairballs naturally.'**
  String get dietWhyHairballFiber;

  /// No description provided for @dietWhyHairballOmega3.
  ///
  /// In en, this message translates to:
  /// **'Omega-3s improve coat health to reduce shedding.'**
  String get dietWhyHairballOmega3;

  /// No description provided for @dietWhyJointOmega3.
  ///
  /// In en, this message translates to:
  /// **'Omega-3s reduce joint inflammation and stiffness.'**
  String get dietWhyJointOmega3;

  /// No description provided for @dietWhyDentalMoisture.
  ///
  /// In en, this message translates to:
  /// **'Moist food is gentler on sore teeth and gums.'**
  String get dietWhyDentalMoisture;

  /// No description provided for @dietWhyWaterGeneral.
  ///
  /// In en, this message translates to:
  /// **'Cats are prone to dehydration — wet food and fresh water help.'**
  String get dietWhyWaterGeneral;

  /// No description provided for @assessmentHeartTaurine.
  ///
  /// In en, this message translates to:
  /// **'Contains taurine, essential for heart health'**
  String get assessmentHeartTaurine;

  /// No description provided for @assessmentHeartLowSodium.
  ///
  /// In en, this message translates to:
  /// **'Low sodium, which eases the heart\'s workload'**
  String get assessmentHeartLowSodium;

  /// No description provided for @assessmentHeartOmega3.
  ///
  /// In en, this message translates to:
  /// **'Omega-3s support heart and circulation'**
  String get assessmentHeartOmega3;

  /// No description provided for @assessmentHeartHighSodium.
  ///
  /// In en, this message translates to:
  /// **'High sodium, which strains the heart'**
  String get assessmentHeartHighSodium;

  /// No description provided for @onboardingNarrativeTitle.
  ///
  /// In en, this message translates to:
  /// **'Personalized for your cat'**
  String get onboardingNarrativeTitle;

  /// No description provided for @onboardingNarrativeFallback.
  ///
  /// In en, this message translates to:
  /// **'Here\'s the start of {name}\'s nutrition plan — a few things we\'d focus on to help them thrive.'**
  String onboardingNarrativeFallback(String name);

  /// No description provided for @dietTitleMoreTaurine.
  ///
  /// In en, this message translates to:
  /// **'More taurine'**
  String get dietTitleMoreTaurine;

  /// No description provided for @dietTitleLessSodium.
  ///
  /// In en, this message translates to:
  /// **'Less sodium'**
  String get dietTitleLessSodium;

  /// No description provided for @dietTitleNovelProtein.
  ///
  /// In en, this message translates to:
  /// **'Novel proteins'**
  String get dietTitleNovelProtein;

  /// No description provided for @dietTitleDigestible.
  ///
  /// In en, this message translates to:
  /// **'Easy-to-digest food'**
  String get dietTitleDigestible;

  /// No description provided for @dietWhyHeartOmega3.
  ///
  /// In en, this message translates to:
  /// **'Omega-3s (EPA & DHA) support heart muscle and circulation.'**
  String get dietWhyHeartOmega3;

  /// No description provided for @dietWhyHeartTaurine.
  ///
  /// In en, this message translates to:
  /// **'Taurine is essential for a healthy feline heart.'**
  String get dietWhyHeartTaurine;

  /// No description provided for @dietWhyHeartSodium.
  ///
  /// In en, this message translates to:
  /// **'Lower sodium eases the workload on the heart.'**
  String get dietWhyHeartSodium;

  /// No description provided for @dietWhyAllergyNovelProtein.
  ///
  /// In en, this message translates to:
  /// **'Novel or limited proteins help avoid common allergy triggers.'**
  String get dietWhyAllergyNovelProtein;

  /// No description provided for @dietWhySensitiveDigestible.
  ///
  /// In en, this message translates to:
  /// **'Gentle, highly digestible recipes are easier on the stomach.'**
  String get dietWhySensitiveDigestible;

  /// No description provided for @onboardingNarrativeOutlookTitle.
  ///
  /// In en, this message translates to:
  /// **'In about 2 weeks'**
  String get onboardingNarrativeOutlookTitle;

  /// No description provided for @onboardingNarrativeOutlookFallback.
  ///
  /// In en, this message translates to:
  /// **'With the right food, you may start to notice {name} has more energy and a healthier, shinier coat within a couple of weeks.'**
  String onboardingNarrativeOutlookFallback(String name);

  /// No description provided for @onboardingNarrativeFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'What to focus on for {name}'**
  String onboardingNarrativeFocusTitle(String name);

  /// No description provided for @onboardingAnalyzeEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Personalizing'**
  String get onboardingAnalyzeEyebrow;

  /// No description provided for @onboardingAnalyzeStep1.
  ///
  /// In en, this message translates to:
  /// **'Reviewing {name}\'s profile'**
  String onboardingAnalyzeStep1(String name);

  /// No description provided for @onboardingAnalyzeStep2.
  ///
  /// In en, this message translates to:
  /// **'Checking health needs'**
  String get onboardingAnalyzeStep2;

  /// No description provided for @onboardingAnalyzeStep3.
  ///
  /// In en, this message translates to:
  /// **'Matching nutrition guidance'**
  String get onboardingAnalyzeStep3;

  /// No description provided for @onboardingAnalyzeStep4.
  ///
  /// In en, this message translates to:
  /// **'Personalizing recommendations'**
  String get onboardingAnalyzeStep4;

  /// No description provided for @onboardingResultTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s plan is ready'**
  String onboardingResultTitle(String name);

  /// No description provided for @productPicksTitle.
  ///
  /// In en, this message translates to:
  /// **'Top picks for {name}'**
  String productPicksTitle(String name);

  /// No description provided for @onboardingResultContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingResultContinue;

  /// No description provided for @onboardingBrandTitle.
  ///
  /// In en, this message translates to:
  /// **'What are you feeding {name}?'**
  String onboardingBrandTitle(String name);

  /// No description provided for @onboardingBrandSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll check how it really stacks up for your cat.'**
  String get onboardingBrandSubtitle;

  /// No description provided for @onboardingBrandHint.
  ///
  /// In en, this message translates to:
  /// **'Search a brand (e.g. Whiskas, Royal Canin)'**
  String get onboardingBrandHint;

  /// No description provided for @onboardingBrandAnalyzeCta.
  ///
  /// In en, this message translates to:
  /// **'Check this food'**
  String get onboardingBrandAnalyzeCta;

  /// No description provided for @onboardingBrandSkip.
  ///
  /// In en, this message translates to:
  /// **'I\'m not sure'**
  String get onboardingBrandSkip;

  /// No description provided for @onboardingBrandAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing {brand}…'**
  String onboardingBrandAnalyzing(String brand);

  /// No description provided for @onboardingBrandUnavailable.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t analyze {brand} right now — but here\'s what we\'d recommend instead.'**
  String onboardingBrandUnavailable(String brand);

  /// No description provided for @onboardingBrandUnlockCta.
  ///
  /// In en, this message translates to:
  /// **'Discover {name}\'s top picks'**
  String onboardingBrandUnlockCta(String name);

  /// No description provided for @brandTeaserFound.
  ///
  /// In en, this message translates to:
  /// **'We found {count, plural, =1{1 better food} other{{count} better foods}} for {name}'**
  String brandTeaserFound(num count, String name);

  /// No description provided for @brandTeaserLockedHint.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to see them — matched to your cat\'s needs.'**
  String get brandTeaserLockedHint;

  /// No description provided for @brandTeaserRowLocked.
  ///
  /// In en, this message translates to:
  /// **'Unlock to see'**
  String get brandTeaserRowLocked;

  /// No description provided for @onboardingScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s scan your\nfirst package'**
  String get onboardingScanTitle;

  /// No description provided for @onboardingScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan the package and we\'ll grade it for your cat.'**
  String get onboardingScanSubtitle;

  /// No description provided for @onboardingScanCta.
  ///
  /// In en, this message translates to:
  /// **'Let\'s scan'**
  String get onboardingScanCta;

  /// No description provided for @onboardingScanSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get onboardingScanSkip;

  /// No description provided for @onboardingScanVerdictIntro.
  ///
  /// In en, this message translates to:
  /// **'Here\'s how that food scores:'**
  String get onboardingScanVerdictIntro;

  /// No description provided for @onboardingScanFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t read that label. Try again with the front of the package in frame.'**
  String get onboardingScanFailed;

  /// No description provided for @onboardingScanRetry.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get onboardingScanRetry;

  /// No description provided for @onboardingScanPersonalCon.
  ///
  /// In en, this message translates to:
  /// **'For {name}: {con}'**
  String onboardingScanPersonalCon(String name, String con);

  /// No description provided for @onboardingResultWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why this isn\'t ideal for {name}'**
  String onboardingResultWhyTitle(String name);

  /// No description provided for @onboardingResultProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s profile'**
  String onboardingResultProfileTitle(String name);

  /// No description provided for @ratingLabelExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get ratingLabelExcellent;

  /// No description provided for @ratingLabelGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingLabelGood;

  /// No description provided for @ratingLabelAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get ratingLabelAverage;

  /// No description provided for @ratingLabelPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get ratingLabelPoor;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'hu',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hu':
      return AppLocalizationsHu();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
