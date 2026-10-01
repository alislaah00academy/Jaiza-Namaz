import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
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
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

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
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Jaiza'**
  String get appName;

  /// No description provided for @academyCredit.
  ///
  /// In en, this message translates to:
  /// **'A project by Al Islaah Academy'**
  String get academyCredit;

  /// No description provided for @startWithSalaam.
  ///
  /// In en, this message translates to:
  /// **'Start with Salaam'**
  String get startWithSalaam;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track and mark your daily prayers, set reminders, and keep a complete history of your worship.'**
  String get welcomeSubtitle;

  /// No description provided for @namazMarkedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Namaz marked successfully 🤍'**
  String get namazMarkedSuccess;

  /// No description provided for @noPrayersYet.
  ///
  /// In en, this message translates to:
  /// **'No prayers recorded yet'**
  String get noPrayersYet;

  /// No description provided for @comingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'We are preparing this section. Check back in a future update.'**
  String get comingSoonBody;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerZuhr.
  ///
  /// In en, this message translates to:
  /// **'Zuhr'**
  String get prayerZuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @prayerWitr.
  ///
  /// In en, this message translates to:
  /// **'Witr'**
  String get prayerWitr;

  /// No description provided for @prayerTahajjud.
  ///
  /// In en, this message translates to:
  /// **'Tahajjud'**
  String get prayerTahajjud;

  /// No description provided for @prayerIshraq.
  ///
  /// In en, this message translates to:
  /// **'Ishraq'**
  String get prayerIshraq;

  /// No description provided for @prayerChasht.
  ///
  /// In en, this message translates to:
  /// **'Chasht (Duha)'**
  String get prayerChasht;

  /// No description provided for @prayerAwwabin.
  ///
  /// In en, this message translates to:
  /// **'Salat al-Awwabin'**
  String get prayerAwwabin;

  /// No description provided for @prayerRawatib.
  ///
  /// In en, this message translates to:
  /// **'Rawatib'**
  String get prayerRawatib;

  /// No description provided for @prayerTaraweeh.
  ///
  /// In en, this message translates to:
  /// **'Taraweeh'**
  String get prayerTaraweeh;

  /// No description provided for @prayerQazaGeneric.
  ///
  /// In en, this message translates to:
  /// **'Qaza'**
  String get prayerQazaGeneric;

  /// No description provided for @fardFajrStartHint.
  ///
  /// In en, this message translates to:
  /// **'Begins at dawn'**
  String get fardFajrStartHint;

  /// No description provided for @fardFajrEndHint.
  ///
  /// In en, this message translates to:
  /// **'Until sunrise'**
  String get fardFajrEndHint;

  /// No description provided for @fardZuhrStartHint.
  ///
  /// In en, this message translates to:
  /// **'After zenith'**
  String get fardZuhrStartHint;

  /// No description provided for @fardZuhrEndHint.
  ///
  /// In en, this message translates to:
  /// **'Before Asr'**
  String get fardZuhrEndHint;

  /// No description provided for @fardAsrStartHint.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get fardAsrStartHint;

  /// No description provided for @fardAsrEndHint.
  ///
  /// In en, this message translates to:
  /// **'Before sunset'**
  String get fardAsrEndHint;

  /// No description provided for @fardMaghribStartHint.
  ///
  /// In en, this message translates to:
  /// **'Just after sunset'**
  String get fardMaghribStartHint;

  /// No description provided for @fardMaghribEndHint.
  ///
  /// In en, this message translates to:
  /// **'Until Isha'**
  String get fardMaghribEndHint;

  /// No description provided for @fardIshaStartHint.
  ///
  /// In en, this message translates to:
  /// **'Night begins'**
  String get fardIshaStartHint;

  /// No description provided for @fardIshaEndHint.
  ///
  /// In en, this message translates to:
  /// **'Until Fajr'**
  String get fardIshaEndHint;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @actionSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get actionSignOut;

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Try again.'**
  String get errorSaveFailed;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the app language. Urdu text is reviewed by Al Islaah Academy.'**
  String get languageSubtitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageUrdu.
  ///
  /// In en, this message translates to:
  /// **'اردو'**
  String get languageUrdu;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyTitle;

  /// No description provided for @privacyAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Share anonymous usage data'**
  String get privacyAnalyticsTitle;

  /// No description provided for @privacyAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Helps us improve Jaiza. Never includes your name, email, phone or location.'**
  String get privacyAnalyticsSubtitle;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found.'**
  String get authErrorUserNotFound;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'Email already registered.'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get authErrorInvalidEmail;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get errorNetwork;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait and try again.'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to continue.'**
  String get authErrorRecentLogin;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Use at least 8 characters with a letter and a number.'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorNoEmail.
  ///
  /// In en, this message translates to:
  /// **'No email associated with this account.'**
  String get authErrorNoEmail;

  /// No description provided for @stripTitle.
  ///
  /// In en, this message translates to:
  /// **'Jaiza · Today\'s Prayers'**
  String get stripTitle;

  /// No description provided for @statusPrayed.
  ///
  /// In en, this message translates to:
  /// **'Prayed'**
  String get statusPrayed;

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get statusMissed;

  /// No description provided for @statusNotRecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded'**
  String get statusNotRecorded;

  /// No description provided for @markAsPrayed.
  ///
  /// In en, this message translates to:
  /// **'Mark as prayed'**
  String get markAsPrayed;

  /// No description provided for @recordedAsMissed.
  ///
  /// In en, this message translates to:
  /// **'Recorded as missed. Stay steadfast.'**
  String get recordedAsMissed;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @importantNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Important Note'**
  String get importantNoteTitle;

  /// No description provided for @qazaEstimateNote.
  ///
  /// In en, this message translates to:
  /// **'This calculation is only an estimate. Islam encourages sincere effort when the exact number is unknown. Enter your best estimate and remain consistent.'**
  String get qazaEstimateNote;

  /// No description provided for @mosqueSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Mosque name or area'**
  String get mosqueSearchHint;

  /// No description provided for @quoteFormat.
  ///
  /// In en, this message translates to:
  /// **'“{quote}”'**
  String quoteFormat(String quote);

  /// No description provided for @quoteSource.
  ///
  /// In en, this message translates to:
  /// **'({source})'**
  String quoteSource(String source);

  /// No description provided for @badgeFirstStepTitle.
  ///
  /// In en, this message translates to:
  /// **'First step'**
  String get badgeFirstStepTitle;

  /// No description provided for @badgeFirstStepDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete all Fard prayers for one day.'**
  String get badgeFirstStepDescription;

  /// No description provided for @badgeWeekWarriorTitle.
  ///
  /// In en, this message translates to:
  /// **'Week warrior'**
  String get badgeWeekWarriorTitle;

  /// No description provided for @badgeWeekWarriorDescription.
  ///
  /// In en, this message translates to:
  /// **'7-day Fard streak.'**
  String get badgeWeekWarriorDescription;

  /// No description provided for @badgeMonthOfLightTitle.
  ///
  /// In en, this message translates to:
  /// **'Month of light'**
  String get badgeMonthOfLightTitle;

  /// No description provided for @badgeMonthOfLightDescription.
  ///
  /// In en, this message translates to:
  /// **'30-day Fard streak.'**
  String get badgeMonthOfLightDescription;

  /// No description provided for @badgeNawafilNurTitle.
  ///
  /// In en, this message translates to:
  /// **'Nawafil Nur'**
  String get badgeNawafilNurTitle;

  /// No description provided for @badgeNawafilNurDescription.
  ///
  /// In en, this message translates to:
  /// **'Offer nawafil 10 times (tracked).'**
  String get badgeNawafilNurDescription;

  /// No description provided for @hijriSuffix.
  ///
  /// In en, this message translates to:
  /// **'AH'**
  String get hijriSuffix;

  /// No description provided for @dateLineSeparator.
  ///
  /// In en, this message translates to:
  /// **'{gregorian} · {hijri}'**
  String dateLineSeparator(String gregorian, String hijri);

  /// No description provided for @hijriMonth1.
  ///
  /// In en, this message translates to:
  /// **'Muharram'**
  String get hijriMonth1;

  /// No description provided for @hijriMonth2.
  ///
  /// In en, this message translates to:
  /// **'Safar'**
  String get hijriMonth2;

  /// No description provided for @hijriMonth3.
  ///
  /// In en, this message translates to:
  /// **'Rabi al-Awwal'**
  String get hijriMonth3;

  /// No description provided for @hijriMonth4.
  ///
  /// In en, this message translates to:
  /// **'Rabi al-Thani'**
  String get hijriMonth4;

  /// No description provided for @hijriMonth5.
  ///
  /// In en, this message translates to:
  /// **'Jumada al-Ula'**
  String get hijriMonth5;

  /// No description provided for @hijriMonth6.
  ///
  /// In en, this message translates to:
  /// **'Jumada al-Thaniyah'**
  String get hijriMonth6;

  /// No description provided for @hijriMonth7.
  ///
  /// In en, this message translates to:
  /// **'Rajab'**
  String get hijriMonth7;

  /// No description provided for @hijriMonth8.
  ///
  /// In en, this message translates to:
  /// **'Sha\'ban'**
  String get hijriMonth8;

  /// No description provided for @hijriMonth9.
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get hijriMonth9;

  /// No description provided for @hijriMonth10.
  ///
  /// In en, this message translates to:
  /// **'Shawwal'**
  String get hijriMonth10;

  /// No description provided for @hijriMonth11.
  ///
  /// In en, this message translates to:
  /// **'Dhul Qa\'dah'**
  String get hijriMonth11;

  /// No description provided for @hijriMonth12.
  ///
  /// In en, this message translates to:
  /// **'Dhul Hijjah'**
  String get hijriMonth12;

  /// No description provided for @notifPrayerStarted.
  ///
  /// In en, this message translates to:
  /// **'{prayer} time has begun. Don’t miss your prayer.'**
  String notifPrayerStarted(String prayer);

  /// No description provided for @notifPrayerEndsSoon.
  ///
  /// In en, this message translates to:
  /// **'{prayer} ends in {minutes} minutes. Have you prayed?'**
  String notifPrayerEndsSoon(String prayer, int minutes);

  /// No description provided for @notifPrayerEnded.
  ///
  /// In en, this message translates to:
  /// **'{prayer} time has ended. Did you pray?'**
  String notifPrayerEnded(String prayer);

  /// No description provided for @notifTest.
  ///
  /// In en, this message translates to:
  /// **'Test notification — prayer reminders are working.'**
  String get notifTest;

  /// No description provided for @notifChannelPrayerName.
  ///
  /// In en, this message translates to:
  /// **'Prayer time reminders'**
  String get notifChannelPrayerName;

  /// No description provided for @notifChannelPrayerDescription.
  ///
  /// In en, this message translates to:
  /// **'Prayer start and reminder notifications'**
  String get notifChannelPrayerDescription;

  /// No description provided for @calcMethodKarachi.
  ///
  /// In en, this message translates to:
  /// **'Karachi (UIS)'**
  String get calcMethodKarachi;

  /// No description provided for @calcMethodMwl.
  ///
  /// In en, this message translates to:
  /// **'Muslim World League'**
  String get calcMethodMwl;

  /// No description provided for @calcMethodUmmAlQura.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura'**
  String get calcMethodUmmAlQura;

  /// No description provided for @calcMethodIsna.
  ///
  /// In en, this message translates to:
  /// **'ISNA (North America)'**
  String get calcMethodIsna;

  /// No description provided for @calcMethodEgyptian.
  ///
  /// In en, this message translates to:
  /// **'Egyptian'**
  String get calcMethodEgyptian;

  /// No description provided for @calcMethodTehran.
  ///
  /// In en, this message translates to:
  /// **'Tehran'**
  String get calcMethodTehran;

  /// No description provided for @calcMethodSingapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get calcMethodSingapore;

  /// No description provided for @madhabHanafi.
  ///
  /// In en, this message translates to:
  /// **'Hanafi'**
  String get madhabHanafi;

  /// No description provided for @madhabShafii.
  ///
  /// In en, this message translates to:
  /// **'Shafi’i'**
  String get madhabShafii;

  /// No description provided for @widgetPrayerTimesTitle.
  ///
  /// In en, this message translates to:
  /// **'Jaiza · Prayer times'**
  String get widgetPrayerTimesTitle;

  /// No description provided for @widgetTimesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{method} · {madhab} · {place}'**
  String widgetTimesSubtitle(String method, String madhab, String place);

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated.'**
  String get passwordUpdated;

  /// No description provided for @changePasswordIntro.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your current password, then choose a new one.'**
  String get changePasswordIntro;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @confirmNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPasswordLabel;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get validationRequired;

  /// No description provided for @validationPasswordRule.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters with a letter and a number'**
  String get validationPasswordRule;

  /// No description provided for @validationNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Does not match'**
  String get validationNoMatch;

  /// No description provided for @validationPasswordsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordsNoMatch;

  /// No description provided for @updatePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePasswordButton;

  /// No description provided for @verifyEmailNotYet.
  ///
  /// In en, this message translates to:
  /// **'Email not verified yet. Open the link we sent, then try again.'**
  String get verifyEmailNotYet;

  /// No description provided for @verifyEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent.'**
  String get verifyEmailSent;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to:'**
  String get verifyEmailSentTo;

  /// No description provided for @verifyEmailInstructions.
  ///
  /// In en, this message translates to:
  /// **'Tap the link in the email, then press “I’ve verified” below.'**
  String get verifyEmailInstructions;

  /// No description provided for @verifyEmailDone.
  ///
  /// In en, this message translates to:
  /// **'I’ve verified'**
  String get verifyEmailDone;

  /// No description provided for @verifyEmailResendAgain.
  ///
  /// In en, this message translates to:
  /// **'Resend again'**
  String get verifyEmailResendAgain;

  /// No description provided for @verifyEmailResend.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get verifyEmailResend;

  /// No description provided for @getStartedWelcome.
  ///
  /// In en, this message translates to:
  /// **'WELCOME TO JAIZA'**
  String get getStartedWelcome;

  /// No description provided for @getStartedTagline.
  ///
  /// In en, this message translates to:
  /// **'Track your Salah, stay consistent, and earn Allah\'s pleasure.'**
  String get getStartedTagline;

  /// No description provided for @chooseAccountType.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE YOUR ACCOUNT TYPE'**
  String get chooseAccountType;

  /// No description provided for @roleIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get roleIndividual;

  /// No description provided for @roleIndividualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track and manage your own Salah attendance.'**
  String get roleIndividualSubtitle;

  /// No description provided for @roleParents.
  ///
  /// In en, this message translates to:
  /// **'Parents'**
  String get roleParents;

  /// No description provided for @roleParentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor and manage your children\'s Salah attendance.'**
  String get roleParentsSubtitle;

  /// No description provided for @roleInstitute.
  ///
  /// In en, this message translates to:
  /// **'Institute'**
  String get roleInstitute;

  /// No description provided for @roleInstituteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Salah attendance for your school, madrasa or organization.'**
  String get roleInstituteSubtitle;

  /// No description provided for @quoteAnkaboot.
  ///
  /// In en, this message translates to:
  /// **'Indeed, Salah prohibits from indecency and wrongdoing.'**
  String get quoteAnkaboot;

  /// No description provided for @quoteAnkabootSource.
  ///
  /// In en, this message translates to:
  /// **'Surah Al-Ankaboot 29:45'**
  String get quoteAnkabootSource;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Have an account?'**
  String get haveAccount;

  /// No description provided for @logInButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logInButton;

  /// No description provided for @teacherSwitchTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch to a teacher account?'**
  String get teacherSwitchTitle;

  /// No description provided for @teacherSwitchBody.
  ///
  /// In en, this message translates to:
  /// **'{org} has invited you as a teacher. Accepting will move your account to the Teacher dashboard for that organization.'**
  String teacherSwitchBody(String org);

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @switchButton.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchButton;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue tracking your Salah.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @validationEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get validationEnterEmail;

  /// No description provided for @validationValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validationValidEmail;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @validationEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get validationEnterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @logInLower.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logInLower;

  /// No description provided for @newHere.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get newHere;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @resetCheckInbox.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox for reset instructions.'**
  String get resetCheckInbox;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetTitle;

  /// No description provided for @resetIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter the email for your account. We\'ll send a link to choose a new password.'**
  String get resetIntro;

  /// No description provided for @resetSendLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get resetSendLink;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your Salah with Jaiza.'**
  String get signupSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @validationEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get validationEnterName;

  /// No description provided for @instituteNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Institute name'**
  String get instituteNameLabel;

  /// No description provided for @instituteNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Al Falah Madarsa'**
  String get instituteNameHint;

  /// No description provided for @validationEnterInstitute.
  ///
  /// In en, this message translates to:
  /// **'Enter your institute name'**
  String get validationEnterInstitute;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpButton;

  /// No description provided for @academyIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'الاصلاح اکیڈمی کا مختصر تعارف'**
  String get academyIntroTitle;

  /// No description provided for @academyIntroIntroParagraph.
  ///
  /// In en, this message translates to:
  /// **'الاصلاح اکیڈمی ایک ایسا تعلیمی ادارہ ہے جو مختلف شعبہ جات میں اپنی خدمات انجام دے رہا ہے۔ اس کا نصب العین یہی ہے کہ لوگوں کی جاری زندگیوں میں بہتری لائی جائے۔ معاشرے میں ہر ممکن مثبت تبدیلیاں پیدا ہوں، اور مسلمان اپنی حقیقی پہچان کو سمجھیں اور اپنے اسلام پر عمل کرنے والے بنیں۔'**
  String get academyIntroIntroParagraph;

  /// No description provided for @academyIntroSectionAghaz.
  ///
  /// In en, this message translates to:
  /// **'آغاز:'**
  String get academyIntroSectionAghaz;

  /// No description provided for @academyIntroAghazBody1.
  ///
  /// In en, this message translates to:
  /// **'الحمدللہ! ابتدا کا کام الاصلاح اکیڈمی نے نہایت سادگی سے کیا۔ یہ چند دوستوں کی خواہش تھی کہ عام مسلمانوں کے لیے سستا مگر معیاری دینی کورس کروایا جائے۔ اس کورس کے دوران سب مشکلات کا سامنا کرنا پڑا، لیکن الحمدللہ آہستہ آہستہ کام آگے بڑھتا گیا۔ کچھ عرصہ کے بعد ایک مستقل ادارہ قائم کیا گیا، اور اس کا نام الاصلاح اکیڈمی رکھا گیا اور اس کی بنیاد پر اساتذہ کرام نے دین کی تعلیم کو عام کرنے کا عزم کیا۔ اس دوران حضرت عثمان غنی رضی اللہ عنہ کی خدمات کو سامنے رکھا گیا اور اس نام کو چننے کا مقصد بھی یہی تھا کہ معاشرے میں اصلاح کا کام عام ہو۔'**
  String get academyIntroAghazBody1;

  /// No description provided for @academyIntroAghazBody2.
  ///
  /// In en, this message translates to:
  /// **'الاصلاح اکیڈمی کا باقاعدہ نظام قائم کرنے کے لیے حافظ محمد فاروق صاحب نے نمایاں کردار ادا کیا، اور پھر ان کے ساتھ دیگر اساتذہ بھی شامل ہوتے گئے۔ الاصلاح اکیڈمی میں اس وقت قرآن، حدیث، فقہ اور دیگر علوم کی تعلیم دی جا رہی ہے۔'**
  String get academyIntroAghazBody2;

  /// No description provided for @academyIntroAghazBody3.
  ///
  /// In en, this message translates to:
  /// **'الاصلاح اکیڈمی کے قیام میں ہمیں اساتذہ کرام کا تعاون حاصل رہا، اور پھر حضرت استاد محترم مولانا مشتاق صاحب کی نگرانی میں یہ ادارہ ترقی کرتا گیا۔'**
  String get academyIntroAghazBody3;

  /// No description provided for @academyIntroDepartmentsLead.
  ///
  /// In en, this message translates to:
  /// **'الاصلاح اکیڈمی کے چند ایک شعبہ جات درج ذیل ہیں:'**
  String get academyIntroDepartmentsLead;

  /// No description provided for @academyIntroEducationDeptTitle.
  ///
  /// In en, this message translates to:
  /// **'☆ تعلیمی شعبہ'**
  String get academyIntroEducationDeptTitle;

  /// No description provided for @academyIntroEducationDeptBody.
  ///
  /// In en, this message translates to:
  /// **'اس شعبہ میں علومِ شرعیہ وغیرہ کی تعلیم دی جاتی ہے۔ الاصلاح اکیڈمی میں مختلف کورسز کا انعقاد مختلف اوقات میں ہوتا رہتا ہے جن میں کثیر تعداد میں طلبہ شریک ہوتے ہیں۔'**
  String get academyIntroEducationDeptBody;

  /// No description provided for @academyIntroDetailedCoursesHeading.
  ///
  /// In en, this message translates to:
  /// **'تفصیلی کورسز:'**
  String get academyIntroDetailedCoursesHeading;

  /// No description provided for @academyIntroShortCoursesHeading.
  ///
  /// In en, this message translates to:
  /// **'مختصر کورسز:'**
  String get academyIntroShortCoursesHeading;

  /// No description provided for @academyIntroClosingLine.
  ///
  /// In en, this message translates to:
  /// **'ان کے علاوہ بھی کئی کورسز کی کلاسز جاری ہیں'**
  String get academyIntroClosingLine;

  /// No description provided for @academyIntroDetailedCourses1.
  ///
  /// In en, this message translates to:
  /// **'آٹھ سالہ درسِ نظامی (وفاق المدارس العربیہ پاکستان)'**
  String get academyIntroDetailedCourses1;

  /// No description provided for @academyIntroDetailedCourses2.
  ///
  /// In en, this message translates to:
  /// **'آن لائن چھ سالہ درسِ نظامی (وفاق المدارس العربیہ پاکستان)'**
  String get academyIntroDetailedCourses2;

  /// No description provided for @academyIntroDetailedCourses3.
  ///
  /// In en, this message translates to:
  /// **'دو سالہ درسِ حدیث للبنات'**
  String get academyIntroDetailedCourses3;

  /// No description provided for @academyIntroShortCourses1.
  ///
  /// In en, this message translates to:
  /// **'سیرت النبی ﷺ کورس'**
  String get academyIntroShortCourses1;

  /// No description provided for @academyIntroShortCourses2.
  ///
  /// In en, this message translates to:
  /// **'مثالی اسلامی کورس'**
  String get academyIntroShortCourses2;

  /// No description provided for @academyIntroShortCourses3.
  ///
  /// In en, this message translates to:
  /// **'منتخب احادیث'**
  String get academyIntroShortCourses3;

  /// No description provided for @academyIntroShortCourses4.
  ///
  /// In en, this message translates to:
  /// **'آسان تفسیر کورس'**
  String get academyIntroShortCourses4;

  /// No description provided for @academyIntroShortCourses5.
  ///
  /// In en, this message translates to:
  /// **'تجوید کورس'**
  String get academyIntroShortCourses5;

  /// No description provided for @academyIntroShortCourses6.
  ///
  /// In en, this message translates to:
  /// **'آسان عربی'**
  String get academyIntroShortCourses6;

  /// No description provided for @academyIntroShortCourses7.
  ///
  /// In en, this message translates to:
  /// **'عقیدہ کورس'**
  String get academyIntroShortCourses7;

  /// No description provided for @academyIntroShortCourses8.
  ///
  /// In en, this message translates to:
  /// **'ترجمہ قرآن کورس'**
  String get academyIntroShortCourses8;

  /// No description provided for @academyIntroShortCourses9.
  ///
  /// In en, this message translates to:
  /// **'حفظِ قرآن کورس'**
  String get academyIntroShortCourses9;

  /// No description provided for @academyIntroShortCourses10.
  ///
  /// In en, this message translates to:
  /// **'عقائد و ایمانیات کورس'**
  String get academyIntroShortCourses10;

  /// No description provided for @academyIntroShortCourses11.
  ///
  /// In en, this message translates to:
  /// **'تصوف و اصلاحی تربیت'**
  String get academyIntroShortCourses11;

  /// No description provided for @onboardTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Every Salah'**
  String get onboardTrackTitle;

  /// No description provided for @onboardTrackBody.
  ///
  /// In en, this message translates to:
  /// **'Mark your Fard, Nawafil and Qaza prayers with a tap, and see your progress build day by day.'**
  String get onboardTrackBody;

  /// No description provided for @onboardFamiliesTitle.
  ///
  /// In en, this message translates to:
  /// **'For Families & Institutes'**
  String get onboardFamiliesTitle;

  /// No description provided for @onboardFamiliesBody.
  ///
  /// In en, this message translates to:
  /// **'Parents can track their children, and madaris can manage teachers, classes and students — all in one place.'**
  String get onboardFamiliesBody;

  /// No description provided for @onboardConsistentTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay Consistent'**
  String get onboardConsistentTitle;

  /// No description provided for @onboardConsistentBody.
  ///
  /// In en, this message translates to:
  /// **'Gentle reminders at the right times help you never miss a prayer and stay steadfast on your journey.'**
  String get onboardConsistentBody;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @nameYourOrganization.
  ///
  /// In en, this message translates to:
  /// **'Name your organization'**
  String get nameYourOrganization;

  /// No description provided for @roleSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'How will you use Jaiza?'**
  String get roleSelectTitle;

  /// No description provided for @roleSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the setup that fits you. You can\'t change this later.'**
  String get roleSelectSubtitle;

  /// No description provided for @roleIndividualSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your own daily prayers, streaks and badges.'**
  String get roleIndividualSelectSubtitle;

  /// No description provided for @roleParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get roleParent;

  /// No description provided for @roleParentSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mark and track prayer attendance for your children.'**
  String get roleParentSelectSubtitle;

  /// No description provided for @roleOrganization.
  ///
  /// In en, this message translates to:
  /// **'Madarsa / Organization'**
  String get roleOrganization;

  /// No description provided for @roleOrganizationSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Run a school or institute: teachers, classes and student attendance.'**
  String get roleOrganizationSelectSubtitle;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Jaiza helps Muslims track obligatory prayers, optional nawafil, and qaza with gentle motivation — clear progress, no clutter.'**
  String get aboutBody;

  /// No description provided for @aboutAcademyIntroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Brief introduction (Urdu)'**
  String get aboutAcademyIntroSubtitle;

  /// No description provided for @academyName.
  ///
  /// In en, this message translates to:
  /// **'Al Islaah Academy'**
  String get academyName;

  /// No description provided for @aboutCoursesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Courses and admissions'**
  String get aboutCoursesSubtitle;

  /// No description provided for @contactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactTitle;

  /// No description provided for @aboutContactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reach Al Islaah Academy'**
  String get aboutContactSubtitle;

  /// No description provided for @fazailTitle.
  ///
  /// In en, this message translates to:
  /// **'Fazail of Prayers'**
  String get fazailTitle;

  /// No description provided for @fazailClosenessTitle.
  ///
  /// In en, this message translates to:
  /// **'Closeness to Allah'**
  String get fazailClosenessTitle;

  /// No description provided for @fazailClosenessBody.
  ///
  /// In en, this message translates to:
  /// **'Salah is a direct link between the servant and the Lord. It reminds us that we turn to Him in every state.'**
  String get fazailClosenessBody;

  /// No description provided for @fazailDisciplineTitle.
  ///
  /// In en, this message translates to:
  /// **'Discipline & structure'**
  String get fazailDisciplineTitle;

  /// No description provided for @fazailDisciplineBody.
  ///
  /// In en, this message translates to:
  /// **'Praying on time builds patience, order, and mindfulness throughout the day.'**
  String get fazailDisciplineBody;

  /// No description provided for @fazailPurificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Purification'**
  String get fazailPurificationTitle;

  /// No description provided for @fazailPurificationBody.
  ///
  /// In en, this message translates to:
  /// **'Regular prayer washes away slips, renews intention, and keeps the heart soft.'**
  String get fazailPurificationBody;

  /// No description provided for @fazailCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get fazailCommunityTitle;

  /// No description provided for @fazailCommunityBody.
  ///
  /// In en, this message translates to:
  /// **'Congregational prayer strengthens brotherhood and sisterhood in faith.'**
  String get fazailCommunityBody;

  /// No description provided for @contactIntro.
  ///
  /// In en, this message translates to:
  /// **'Reach out to Al Islaah Academy for questions about the app, classes, or general support.'**
  String get contactIntro;

  /// No description provided for @contactBriefIntro.
  ///
  /// In en, this message translates to:
  /// **'مختصر تعارف · Brief intro'**
  String get contactBriefIntro;

  /// No description provided for @contactEmailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add your official contact email in the console'**
  String get contactEmailPlaceholder;

  /// No description provided for @donationTitle.
  ///
  /// In en, this message translates to:
  /// **'Support the project'**
  String get donationTitle;

  /// No description provided for @donationIntro.
  ///
  /// In en, this message translates to:
  /// **'{app} is offered by {academy}. Your sadaqah helps maintain the app, content, and community programs.'**
  String donationIntro(String app, String academy);

  /// No description provided for @donationHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How to donate'**
  String get donationHowTitle;

  /// No description provided for @donationHowBody.
  ///
  /// In en, this message translates to:
  /// **'Connect your real donation link (bank, gateway, or campaign) here when ready. This screen is structured for future integration.'**
  String get donationHowBody;

  /// No description provided for @donationLinkMissing.
  ///
  /// In en, this message translates to:
  /// **'Link your donation URL in the codebase.'**
  String get donationLinkMissing;

  /// No description provided for @donationOpenPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Open donation (placeholder)'**
  String get donationOpenPlaceholder;

  /// No description provided for @titleFamilyReminders.
  ///
  /// In en, this message translates to:
  /// **'Family reminders'**
  String get titleFamilyReminders;

  /// No description provided for @titleQaza.
  ///
  /// In en, this message translates to:
  /// **'Qaza'**
  String get titleQaza;

  /// No description provided for @titleFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get titleFamily;

  /// No description provided for @titleMyEstimate.
  ///
  /// In en, this message translates to:
  /// **'My estimate'**
  String get titleMyEstimate;

  /// No description provided for @titleAddPastQaza.
  ///
  /// In en, this message translates to:
  /// **'Add past Qaza'**
  String get titleAddPastQaza;

  /// No description provided for @titleQazaPrayer.
  ///
  /// In en, this message translates to:
  /// **'Qaza {prayer}'**
  String titleQazaPrayer(String prayer);

  /// No description provided for @titleRegisterMosque.
  ///
  /// In en, this message translates to:
  /// **'Register a mosque'**
  String get titleRegisterMosque;

  /// No description provided for @titleMosque.
  ///
  /// In en, this message translates to:
  /// **'Mosque'**
  String get titleMosque;

  /// No description provided for @titleMosques.
  ///
  /// In en, this message translates to:
  /// **'Mosques'**
  String get titleMosques;

  /// No description provided for @titleRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get titleRecords;

  /// No description provided for @titleMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get titleMore;

  /// No description provided for @titleToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get titleToday;

  /// No description provided for @titleFaraiz.
  ///
  /// In en, this message translates to:
  /// **'Faraiz'**
  String get titleFaraiz;

  /// No description provided for @titleNawafil.
  ///
  /// In en, this message translates to:
  /// **'Nawafil'**
  String get titleNawafil;

  /// No description provided for @titleAboutJaiza.
  ///
  /// In en, this message translates to:
  /// **'About Jaiza'**
  String get titleAboutJaiza;

  /// No description provided for @titleDonation.
  ///
  /// In en, this message translates to:
  /// **'Donation'**
  String get titleDonation;

  /// No description provided for @titleNotificationsWidgets.
  ///
  /// In en, this message translates to:
  /// **'Notifications & widgets'**
  String get titleNotificationsWidgets;

  /// No description provided for @titleProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get titleProfile;

  /// No description provided for @titleChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get titleChangePassword;

  /// No description provided for @titleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get titleTeacher;

  /// No description provided for @titleStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get titleStudent;

  /// No description provided for @titleAddStudents.
  ///
  /// In en, this message translates to:
  /// **'Add students'**
  String get titleAddStudents;

  /// No description provided for @titleClass.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get titleClass;

  /// No description provided for @titleChildren.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get titleChildren;

  /// No description provided for @titleClasses.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get titleClasses;

  /// No description provided for @titleChildQaza.
  ///
  /// In en, this message translates to:
  /// **'{name}’s Qaza'**
  String titleChildQaza(String name);

  /// No description provided for @titleClassReport.
  ///
  /// In en, this message translates to:
  /// **'{className} report'**
  String titleClassReport(String className);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navWidgetsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Widgets & Notifications'**
  String get navWidgetsNotifications;

  /// No description provided for @unmarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Unmark {prayer}?'**
  String unmarkTitle(String prayer);

  /// No description provided for @unmarkBody.
  ///
  /// In en, this message translates to:
  /// **'It will be recorded as not prayed.'**
  String get unmarkBody;

  /// No description provided for @unmarkButton.
  ///
  /// In en, this message translates to:
  /// **'Unmark'**
  String get unmarkButton;

  /// No description provided for @addedToYourQaza.
  ///
  /// In en, this message translates to:
  /// **'{prayer} added to your Qaza list.'**
  String addedToYourQaza(String prayer);

  /// No description provided for @addedToQaza.
  ///
  /// In en, this message translates to:
  /// **'{prayer} added to the Qaza list.'**
  String addedToQaza(String prayer);

  /// No description provided for @missedDot.
  ///
  /// In en, this message translates to:
  /// **'Missed · '**
  String get missedDot;

  /// No description provided for @addToQaza.
  ///
  /// In en, this message translates to:
  /// **'Add to Qaza'**
  String get addToQaza;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationMinutes(int minutes);

  /// No description provided for @durationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String durationHours(int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @nawafilDoneToday.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done today'**
  String nawafilDoneToday(int done, int total);

  /// No description provided for @nawafilTrackingOff.
  ///
  /// In en, this message translates to:
  /// **'Tracking off — tap to turn on'**
  String get nawafilTrackingOff;

  /// No description provided for @qazaNothingToMakeUp.
  ///
  /// In en, this message translates to:
  /// **'Nothing to make up'**
  String get qazaNothingToMakeUp;

  /// No description provided for @qazaPrayersToMakeUp.
  ///
  /// In en, this message translates to:
  /// **'{count} prayers to make up'**
  String qazaPrayersToMakeUp(String count);

  /// No description provided for @qazaToMakeUpSince.
  ///
  /// In en, this message translates to:
  /// **'{count} to make up · since {date}'**
  String qazaToMakeUpSince(String count, String date);

  /// No description provided for @currentPrayer.
  ///
  /// In en, this message translates to:
  /// **'Current prayer'**
  String get currentPrayer;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next prayer'**
  String get nextPrayer;

  /// No description provided for @setPrimaryMosqueTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your primary mosque'**
  String get setPrimaryMosqueTitle;

  /// No description provided for @setPrimaryMosqueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'To see Jama\'at times for every prayer'**
  String get setPrimaryMosqueSubtitle;

  /// No description provided for @findButton.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get findButton;

  /// No description provided for @startsLabel.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get startsLabel;

  /// No description provided for @endsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get endsLabel;

  /// No description provided for @jamaatStartsIn.
  ///
  /// In en, this message translates to:
  /// **' · starts in {duration}'**
  String jamaatStartsIn(String duration);

  /// No description provided for @jamaatStartedAgo.
  ///
  /// In en, this message translates to:
  /// **' · started {minutes} min ago'**
  String jamaatStartedAgo(int minutes);

  /// No description provided for @jamaat.
  ///
  /// In en, this message translates to:
  /// **'Jama\'at'**
  String get jamaat;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count}-day streak'**
  String streakDays(int count);

  /// No description provided for @streakBestSoFar.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Best so far — 1 day} other{Best so far — {count} days}}'**
  String streakBestSoFar(int count);

  /// No description provided for @streakStartHint.
  ///
  /// In en, this message translates to:
  /// **'Pray all five to start one'**
  String get streakStartHint;

  /// No description provided for @doneOfTotalToday.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} today'**
  String doneOfTotalToday(int done, int total);

  /// No description provided for @nowRange.
  ///
  /// In en, this message translates to:
  /// **'Now · {range}'**
  String nowRange(String range);

  /// No description provided for @timeRange.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String timeRange(String start, String end);

  /// No description provided for @hintRange.
  ///
  /// In en, this message translates to:
  /// **'{start} — {end}'**
  String hintRange(String start, String end);

  /// No description provided for @missedInYourQaza.
  ///
  /// In en, this message translates to:
  /// **'Missed · in your Qaza list'**
  String get missedInYourQaza;

  /// No description provided for @missedInTheQaza.
  ///
  /// In en, this message translates to:
  /// **'Missed · in the Qaza list'**
  String get missedInTheQaza;

  /// No description provided for @addChildren.
  ///
  /// In en, this message translates to:
  /// **'Add children'**
  String get addChildren;

  /// No description provided for @addChildrenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mark their prayers from this same screen'**
  String get addChildrenSubtitle;

  /// No description provided for @childNameAge.
  ///
  /// In en, this message translates to:
  /// **'{name} · {age} years'**
  String childNameAge(String name, int age);

  /// No description provided for @childTodayWeek.
  ///
  /// In en, this message translates to:
  /// **'Today {done} of {total} · this week {week} of {weekTotal}'**
  String childTodayWeek(int done, int total, int week, int weekTotal);

  /// No description provided for @historyButton.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyButton;

  /// No description provided for @childStreak.
  ///
  /// In en, this message translates to:
  /// **'{name} — {count}-day streak'**
  String childStreak(String name, int count);

  /// No description provided for @childStreakStartHint.
  ///
  /// In en, this message translates to:
  /// **'All five in a day starts a streak'**
  String get childStreakStartHint;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @doneSlashTotal.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total}'**
  String doneSlashTotal(int done, int total);

  /// No description provided for @sectionMadrasa.
  ///
  /// In en, this message translates to:
  /// **'Madrasa'**
  String get sectionMadrasa;

  /// No description provided for @sectionOrganization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get sectionOrganization;

  /// No description provided for @moreOrgSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Teachers, classes and reports'**
  String get moreOrgSubtitle;

  /// No description provided for @myClasses.
  ///
  /// In en, this message translates to:
  /// **'My classes'**
  String get myClasses;

  /// No description provided for @noClassesYet.
  ///
  /// In en, this message translates to:
  /// **'No classes yet'**
  String get noClassesYet;

  /// No description provided for @addYourChildren.
  ///
  /// In en, this message translates to:
  /// **'Add your children'**
  String get addYourChildren;

  /// No description provided for @moreFamilySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Children, progress and their reminders'**
  String get moreFamilySubtitle;

  /// No description provided for @moreFamilyRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nudges when a prayer isn’t marked'**
  String get moreFamilyRemindersSubtitle;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @sectionApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get sectionApp;

  /// No description provided for @moreNotificationsParentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your prayers, Jama’at, widgets'**
  String get moreNotificationsParentSubtitle;

  /// No description provided for @moreNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders, Jama’at alerts, location'**
  String get moreNotificationsSubtitle;

  /// No description provided for @qazaPlan.
  ///
  /// In en, this message translates to:
  /// **'Qaza plan'**
  String get qazaPlan;

  /// No description provided for @qazaRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} remaining'**
  String qazaRemaining(String count);

  /// No description provided for @trackingOn.
  ///
  /// In en, this message translates to:
  /// **'Tracking on'**
  String get trackingOn;

  /// No description provided for @trackingOff.
  ///
  /// In en, this message translates to:
  /// **'Tracking off'**
  String get trackingOff;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeAuto;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @fazailOfPrayers.
  ///
  /// In en, this message translates to:
  /// **'Fazail of prayers'**
  String get fazailOfPrayers;

  /// No description provided for @aboutJaizaAndAcademy.
  ///
  /// In en, this message translates to:
  /// **'About Jaiza & Al Islaah Academy'**
  String get aboutJaizaAndAcademy;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Removes your record permanently'**
  String get deleteAccountSubtitle;

  /// No description provided for @nawafilSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Track Tahajjud, Ishraq, Chasht, Awwabin, Rawatib and Taraweeh alongside your Fard. Nawafil are never counted as Qaza.'**
  String get nawafilSheetBody;

  /// No description provided for @trackNawafil.
  ///
  /// In en, this message translates to:
  /// **'Track Nawafil'**
  String get trackNawafil;

  /// No description provided for @trackNawafilSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shows a Nawafil card on Today'**
  String get trackNawafilSubtitle;

  /// No description provided for @openTodaysNawafil.
  ///
  /// In en, this message translates to:
  /// **'Open today’s Nawafil'**
  String get openTodaysNawafil;

  /// No description provided for @deleteLostPrayerRecord.
  ///
  /// In en, this message translates to:
  /// **'Your prayer record and streaks'**
  String get deleteLostPrayerRecord;

  /// No description provided for @deleteLostQazaList.
  ///
  /// In en, this message translates to:
  /// **'Your Qaza list'**
  String get deleteLostQazaList;

  /// No description provided for @deleteLostMosques.
  ///
  /// In en, this message translates to:
  /// **'Saved mosques and Jama’at alerts'**
  String get deleteLostMosques;

  /// No description provided for @deleteLostChildren.
  ///
  /// In en, this message translates to:
  /// **'Children you added, and their records'**
  String get deleteLostChildren;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountTitle;

  /// No description provided for @cannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get cannotBeUndone;

  /// No description provided for @deleteTypePrefix.
  ///
  /// In en, this message translates to:
  /// **'Type '**
  String get deleteTypePrefix;

  /// No description provided for @deleteTypeSuffix.
  ///
  /// In en, this message translates to:
  /// **' to confirm.'**
  String get deleteTypeSuffix;

  /// No description provided for @deleteNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Account deletion is not connected yet — please contact Al Islaah Academy to remove your data.'**
  String get deleteNotConnected;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteMyAccount;

  /// No description provided for @keepMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Keep my account'**
  String get keepMyAccount;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved.'**
  String get profileSaved;

  /// No description provided for @profileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save profile.'**
  String get profileSaveFailed;

  /// No description provided for @signInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get signInRequired;

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get yourProfile;

  /// No description provided for @tapCameraToChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap the camera to change your photo'**
  String get tapCameraToChangePhoto;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @completeProfileHint.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile — your document will be created on save.'**
  String get completeProfileHint;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark to check both — this overrides your device setting.'**
  String get appearanceSubtitle;

  /// No description provided for @profilePhotosComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Profile photos arrive with photo storage — coming soon.'**
  String get profilePhotosComingSoon;

  /// No description provided for @profilePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhotoTitle;

  /// No description provided for @profilePhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose where the picture comes from.'**
  String get profilePhotoSubtitle;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @openCamera.
  ///
  /// In en, this message translates to:
  /// **'Open the camera'**
  String get openCamera;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @pickExistingPicture.
  ///
  /// In en, this message translates to:
  /// **'Pick an existing picture'**
  String get pickExistingPicture;

  /// No description provided for @removeCurrentPhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove current photo'**
  String get removeCurrentPhoto;

  /// No description provided for @backToDefaultAvatar.
  ///
  /// In en, this message translates to:
  /// **'Go back to the default avatar'**
  String get backToDefaultAvatar;

  /// No description provided for @qazaRecorded.
  ///
  /// In en, this message translates to:
  /// **'Qaza {prayer} recorded. May Allah accept it.'**
  String qazaRecorded(String prayer);

  /// No description provided for @couldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save.'**
  String get couldNotSave;

  /// No description provided for @qazaHowTwoKindsTitle.
  ///
  /// In en, this message translates to:
  /// **'Two kinds, one list'**
  String get qazaHowTwoKindsTitle;

  /// No description provided for @qazaHowTwoKindsBody.
  ///
  /// In en, this message translates to:
  /// **'Prayers you miss while using Jaiza are added for you, with their date. Prayers from before Jaiza are whatever estimate you enter.'**
  String get qazaHowTwoKindsBody;

  /// No description provided for @qazaHowBulughTitle.
  ///
  /// In en, this message translates to:
  /// **'Count from Bulugh'**
  String get qazaHowBulughTitle;

  /// No description provided for @qazaHowBulughBody.
  ///
  /// In en, this message translates to:
  /// **'Your backlog starts the day you became Islamically accountable — not from birth.'**
  String get qazaHowBulughBody;

  /// No description provided for @qazaHowEstimateTitle.
  ///
  /// In en, this message translates to:
  /// **'An estimate is enough'**
  String get qazaHowEstimateTitle;

  /// No description provided for @qazaHowEstimateBody.
  ///
  /// In en, this message translates to:
  /// **'If you do not remember exactly, enter your most reasonable guess. Islam asks for sincere effort where the exact number is unknown.'**
  String get qazaHowEstimateBody;

  /// No description provided for @qazaHowFardTitle.
  ///
  /// In en, this message translates to:
  /// **'Only the five Fard'**
  String get qazaHowFardTitle;

  /// No description provided for @qazaHowFardBody.
  ///
  /// In en, this message translates to:
  /// **'Fajr, Zuhr, Asr, Maghrib and Isha. Nawafil are never counted as Qaza.'**
  String get qazaHowFardBody;

  /// No description provided for @qazaHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How Qaza works in Jaiza'**
  String get qazaHowTitle;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @totalQaza.
  ///
  /// In en, this message translates to:
  /// **'Total Qaza'**
  String get totalQaza;

  /// No description provided for @trackedByJaiza.
  ///
  /// In en, this message translates to:
  /// **'Tracked by Jaiza'**
  String get trackedByJaiza;

  /// No description provided for @missedSince.
  ///
  /// In en, this message translates to:
  /// **'Missed since {date}'**
  String missedSince(String date);

  /// No description provided for @yourEstimate.
  ///
  /// In en, this message translates to:
  /// **'Your estimate'**
  String get yourEstimate;

  /// No description provided for @beforeInstalledJaiza.
  ///
  /// In en, this message translates to:
  /// **'Before you installed Jaiza'**
  String get beforeInstalledJaiza;

  /// No description provided for @addAnEstimate.
  ///
  /// In en, this message translates to:
  /// **'Add an estimate'**
  String get addAnEstimate;

  /// No description provided for @addAnEstimateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Have Qaza from before Jaiza? Add it once.'**
  String get addAnEstimateSubtitle;

  /// No description provided for @qazaLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String qazaLeft(String count);

  /// No description provided for @qazaDoneOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String qazaDoneOfTotal(String done, String total);

  /// No description provided for @doneForToday.
  ///
  /// In en, this message translates to:
  /// **'Done for today'**
  String get doneForToday;

  /// No description provided for @markQazaDone.
  ///
  /// In en, this message translates to:
  /// **'Mark Qaza done'**
  String get markQazaDone;

  /// No description provided for @qazaEstimateOnlyMissedPrefix.
  ///
  /// In en, this message translates to:
  /// **'This is only for the prayers you missed '**
  String get qazaEstimateOnlyMissedPrefix;

  /// No description provided for @qazaEstimateBeforeInstalled.
  ///
  /// In en, this message translates to:
  /// **'before you installed Jaiza'**
  String get qazaEstimateBeforeInstalled;

  /// No description provided for @qazaEstimateOnlyMissedSuffix.
  ///
  /// In en, this message translates to:
  /// **' — {date}. Everything after that date is counted for you, so nothing is added twice.'**
  String qazaEstimateOnlyMissedSuffix(String date);

  /// No description provided for @qazaEstimateEachIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter what you already know. Leave a prayer blank if you are not sure — you can come back and change it any time.'**
  String get qazaEstimateEachIntro;

  /// No description provided for @qazaEstimateHowEnter.
  ///
  /// In en, this message translates to:
  /// **'How do you want to enter it?'**
  String get qazaEstimateHowEnter;

  /// No description provided for @qazaEstimateSameForAll.
  ///
  /// In en, this message translates to:
  /// **'Same for all'**
  String get qazaEstimateSameForAll;

  /// No description provided for @qazaEstimateEachPrayer.
  ///
  /// In en, this message translates to:
  /// **'Each prayer'**
  String get qazaEstimateEachPrayer;

  /// No description provided for @qazaTotalEstimate.
  ///
  /// In en, this message translates to:
  /// **'Total estimate'**
  String get qazaTotalEstimate;

  /// No description provided for @qazaSaveEstimate.
  ///
  /// In en, this message translates to:
  /// **'Save estimate'**
  String get qazaSaveEstimate;

  /// No description provided for @qazaHowLongNotPraying.
  ///
  /// In en, this message translates to:
  /// **'How long were you not praying?'**
  String get qazaHowLongNotPraying;

  /// No description provided for @qazaBestGuessEnough.
  ///
  /// In en, this message translates to:
  /// **'Your best guess is enough.'**
  String get qazaBestGuessEnough;

  /// No description provided for @unitYears.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get unitYears;

  /// No description provided for @unitMonths.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get unitMonths;

  /// No description provided for @unitDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get unitDays;

  /// No description provided for @qazaThatIsAboutDays.
  ///
  /// In en, this message translates to:
  /// **'That is about {count} days'**
  String qazaThatIsAboutDays(String count);

  /// No description provided for @qazaEach.
  ///
  /// In en, this message translates to:
  /// **'{count} each'**
  String qazaEach(String count);

  /// No description provided for @qazaEveryPrayerSame.
  ///
  /// In en, this message translates to:
  /// **'Every prayer gets the same figure'**
  String get qazaEveryPrayerSame;

  /// No description provided for @qazaHowManyEach.
  ///
  /// In en, this message translates to:
  /// **'How many of each?'**
  String get qazaHowManyEach;

  /// No description provided for @spanYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year} other{{count} years}}'**
  String spanYears(int count);

  /// No description provided for @spanMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month} other{{count} months}}'**
  String spanMonths(int count);

  /// No description provided for @spanDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String spanDays(int count);

  /// No description provided for @qazaEstimateSaved.
  ///
  /// In en, this message translates to:
  /// **'Your estimate is saved'**
  String get qazaEstimateSaved;

  /// No description provided for @qazaEstimateSavedBody.
  ///
  /// In en, this message translates to:
  /// **'{estimate} prayers from before Jaiza, plus the {tracked} counted since you installed it.'**
  String qazaEstimateSavedBody(String estimate, String tracked);

  /// No description provided for @qazaSetDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Set a daily goal'**
  String get qazaSetDailyGoal;

  /// No description provided for @qazaSetDailyGoalBody.
  ///
  /// In en, this message translates to:
  /// **'How many Qaza will you pray each day? Start small — you can change this whenever you like.'**
  String get qazaSetDailyGoalBody;

  /// No description provided for @aDay.
  ///
  /// In en, this message translates to:
  /// **'a day'**
  String get aDay;

  /// No description provided for @qazaFinishPrefix.
  ///
  /// In en, this message translates to:
  /// **'At {goal} a day you will finish in about '**
  String qazaFinishPrefix(int goal);

  /// No description provided for @qazaFinishSuffix.
  ///
  /// In en, this message translates to:
  /// **' — around {monthYear}.'**
  String qazaFinishSuffix(String monthYear);

  /// No description provided for @remindMeDaily.
  ///
  /// In en, this message translates to:
  /// **'Remind me daily'**
  String get remindMeDaily;

  /// No description provided for @remindMeDailySubtitle.
  ///
  /// In en, this message translates to:
  /// **'One nudge after Isha if the day\'s Qaza is not done'**
  String get remindMeDailySubtitle;

  /// No description provided for @qazaFiveFardOnly.
  ///
  /// In en, this message translates to:
  /// **'Qaza is tracked for the five Fard only.'**
  String get qazaFiveFardOnly;

  /// No description provided for @qazaIPrayedSome.
  ///
  /// In en, this message translates to:
  /// **'I prayed some Qaza {prayer}'**
  String qazaIPrayedSome(String prayer);

  /// No description provided for @qazaTodayRecorded.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Qaza {prayer} is recorded. Come back tomorrow for the next one.'**
  String qazaTodayRecorded(String prayer);

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get markDone;

  /// No description provided for @trackedByJaizaCount.
  ///
  /// In en, this message translates to:
  /// **'Tracked by Jaiza · {count}'**
  String trackedByJaizaCount(String count);

  /// No description provided for @qazaNoMissedSince.
  ///
  /// In en, this message translates to:
  /// **'No missed {prayer} since you started using Jaiza.'**
  String qazaNoMissedSince(String prayer);

  /// No description provided for @madeUpOn.
  ///
  /// In en, this message translates to:
  /// **'Made up on {date}'**
  String madeUpOn(String date);

  /// No description provided for @earlierDays.
  ///
  /// In en, this message translates to:
  /// **'+ {count} earlier days'**
  String earlierDays(String count);

  /// No description provided for @fromYourEstimate.
  ///
  /// In en, this message translates to:
  /// **'From your estimate'**
  String get fromYourEstimate;

  /// No description provided for @estimateRemainingNoDate.
  ///
  /// In en, this message translates to:
  /// **'{count} remaining · these carry no date'**
  String estimateRemainingNoDate(String count);

  /// No description provided for @qazaCalculateYour.
  ///
  /// In en, this message translates to:
  /// **'CALCULATE YOUR\n'**
  String get qazaCalculateYour;

  /// No description provided for @qazaPrayersCaps.
  ///
  /// In en, this message translates to:
  /// **'QAZA PRAYERS'**
  String get qazaPrayersCaps;

  /// No description provided for @qazaIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Work out the prayers you missed from the time you reached Bulugh (puberty) until today.'**
  String get qazaIntroBody;

  /// No description provided for @chooseHowToStart.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE HOW TO START'**
  String get chooseHowToStart;

  /// No description provided for @qazaOptionEstimateTitle.
  ///
  /// In en, this message translates to:
  /// **'I will enter my own estimate'**
  String get qazaOptionEstimateTitle;

  /// No description provided for @qazaOptionEstimateBody.
  ///
  /// In en, this message translates to:
  /// **'Type how much you missed before Jaiza — the same figure for all five prayers, or each prayer separately.'**
  String get qazaOptionEstimateBody;

  /// No description provided for @qazaOptionCountTitle.
  ///
  /// In en, this message translates to:
  /// **'Let Jaiza count from today'**
  String get qazaOptionCountTitle;

  /// No description provided for @qazaOptionCountBody.
  ///
  /// In en, this message translates to:
  /// **'From now on, every prayer you do not mark becomes Qaza by itself, with its date. Nothing to type — and you can still add an estimate later.'**
  String get qazaOptionCountBody;

  /// No description provided for @qazaDashboardWithEstimate.
  ///
  /// In en, this message translates to:
  /// **'Everything you still owe, in one place — what Jaiza counted for you since install, plus the backlog you estimated. Tap any prayer to mark some as prayed.'**
  String get qazaDashboardWithEstimate;

  /// No description provided for @qazaDashboardNoEstimate.
  ///
  /// In en, this message translates to:
  /// **'Jaiza has been counting missed prayers for you since the day you installed it. If you also have Qaza from before that, add an estimate once and both are kept in one list.'**
  String get qazaDashboardNoEstimate;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get dailyGoal;

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'{count} a day'**
  String perDay(int count);

  /// No description provided for @qazaPacePrefix.
  ///
  /// In en, this message translates to:
  /// **'At this pace you will finish in about '**
  String get qazaPacePrefix;

  /// No description provided for @qazaPaceSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get qazaPaceSuffix;

  /// No description provided for @countDone.
  ///
  /// In en, this message translates to:
  /// **'{count} done'**
  String countDone(String count);

  /// No description provided for @byPrayer.
  ///
  /// In en, this message translates to:
  /// **'By prayer'**
  String get byPrayer;

  /// No description provided for @prayerHistory.
  ///
  /// In en, this message translates to:
  /// **'Prayer history'**
  String get prayerHistory;

  /// No description provided for @selectADate.
  ///
  /// In en, this message translates to:
  /// **'Select a date ({date})'**
  String selectADate(String date);

  /// No description provided for @statusFor.
  ///
  /// In en, this message translates to:
  /// **'Status for {date}'**
  String statusFor(String date);

  /// No description provided for @couldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load. {error}'**
  String couldNotLoad(String error);

  /// No description provided for @todaysFardProgress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Fard progress'**
  String get todaysFardProgress;

  /// No description provided for @completedOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} completed'**
  String completedOfTotal(int done, int total);

  /// No description provided for @windowHint.
  ///
  /// In en, this message translates to:
  /// **'Window: {start} — {end}'**
  String windowHint(String start, String end);

  /// No description provided for @couldNotUpdatePreference.
  ///
  /// In en, this message translates to:
  /// **'Could not update preference.'**
  String get couldNotUpdatePreference;

  /// No description provided for @nawafilTrackingIsOff.
  ///
  /// In en, this message translates to:
  /// **'Nawafil tracking is off'**
  String get nawafilTrackingIsOff;

  /// No description provided for @nawafilTurnOnBody.
  ///
  /// In en, this message translates to:
  /// **'Turn it on to tick off your optional prayers each day.'**
  String get nawafilTurnOnBody;

  /// No description provided for @turnOnNawafil.
  ///
  /// In en, this message translates to:
  /// **'Turn on Nawafil'**
  String get turnOnNawafil;

  /// No description provided for @nawafilTurnOffHint.
  ///
  /// In en, this message translates to:
  /// **'To stop tracking Nawafil, turn it off in More → Nawafil.'**
  String get nawafilTurnOffHint;

  /// No description provided for @remindersOn.
  ///
  /// In en, this message translates to:
  /// **'Reminders are on'**
  String get remindersOn;

  /// No description provided for @remindersOff.
  ///
  /// In en, this message translates to:
  /// **'Reminders are off'**
  String get remindersOff;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @todaysPrayers.
  ///
  /// In en, this message translates to:
  /// **'Today\'s prayers'**
  String get todaysPrayers;

  /// No description provided for @prayerTimesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Prayer times unavailable'**
  String get prayerTimesUnavailable;

  /// No description provided for @reminderStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get reminderStart;

  /// No description provided for @reminderEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get reminderEnd;

  /// No description provided for @enterValidLatLon.
  ///
  /// In en, this message translates to:
  /// **'Enter valid latitude and longitude'**
  String get enterValidLatLon;

  /// No description provided for @notificationsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications blocked — open system settings to enable.'**
  String get notificationsBlocked;

  /// No description provided for @couldNotGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not get location (permission or services off).'**
  String get couldNotGetLocation;

  /// No description provided for @locationDetected.
  ///
  /// In en, this message translates to:
  /// **'Location detected'**
  String get locationDetected;

  /// No description provided for @homeWidgets.
  ///
  /// In en, this message translates to:
  /// **'Home widgets'**
  String get homeWidgets;

  /// No description provided for @homeWidgetsBody.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times (4×2) and Prayer Tracker (4×3) — add them from your launcher. Refresh after changing location or calculation settings.'**
  String get homeWidgetsBody;

  /// No description provided for @widgetsRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Widgets refreshed'**
  String get widgetsRefreshed;

  /// No description provided for @refreshWidgetsNow.
  ///
  /// In en, this message translates to:
  /// **'Refresh widgets now'**
  String get refreshWidgetsNow;

  /// No description provided for @locationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationTitle;

  /// No description provided for @useMyCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get useMyCurrentLocation;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @placeLabel.
  ///
  /// In en, this message translates to:
  /// **'Place label'**
  String get placeLabel;

  /// No description provided for @saveManualLocation.
  ///
  /// In en, this message translates to:
  /// **'Save manual location'**
  String get saveManualLocation;

  /// No description provided for @detectNow.
  ///
  /// In en, this message translates to:
  /// **'Detect now'**
  String get detectNow;

  /// No description provided for @prayerTimeCalculation.
  ///
  /// In en, this message translates to:
  /// **'Prayer time calculation'**
  String get prayerTimeCalculation;

  /// No description provided for @calcMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get calcMethodLabel;

  /// No description provided for @madhabLabel.
  ///
  /// In en, this message translates to:
  /// **'Madhab'**
  String get madhabLabel;

  /// No description provided for @testNotificationIn30.
  ///
  /// In en, this message translates to:
  /// **'Test notification in 30 seconds'**
  String get testNotificationIn30;

  /// No description provided for @debugTestNotification.
  ///
  /// In en, this message translates to:
  /// **'Debug: test notification in 30 s'**
  String get debugTestNotification;

  /// No description provided for @prayerReminders.
  ///
  /// In en, this message translates to:
  /// **'Prayer reminders'**
  String get prayerReminders;

  /// No description provided for @prayerRemindersBody.
  ///
  /// In en, this message translates to:
  /// **'Each prayer is separate — turn on only the ones you want to be reminded about.'**
  String get prayerRemindersBody;

  /// No description provided for @atStart.
  ///
  /// In en, this message translates to:
  /// **'At start'**
  String get atStart;

  /// No description provided for @minBeforeEnd.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min before end'**
  String minBeforeEnd(int minutes);

  /// No description provided for @jamaatAlerts.
  ///
  /// In en, this message translates to:
  /// **'Jama’at alerts'**
  String get jamaatAlerts;

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newBadge;

  /// No description provided for @jamaatAlertsBody.
  ///
  /// In en, this message translates to:
  /// **'A reminder before Jama’at at your favourite mosques.'**
  String get jamaatAlertsBody;

  /// No description provided for @jamaatAlertsOn.
  ///
  /// In en, this message translates to:
  /// **'Jama’at alerts on'**
  String get jamaatAlertsOn;

  /// No description provided for @howEarly.
  ///
  /// In en, this message translates to:
  /// **'How early'**
  String get howEarly;

  /// No description provided for @minutesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String minutesCount(int count);

  /// No description provided for @minCount.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minCount(int count);

  /// No description provided for @jamaatAlertsNoMosque.
  ///
  /// In en, this message translates to:
  /// **'Save a mosque or set a primary one on the Mosques tab to get alerts.'**
  String get jamaatAlertsNoMosque;

  /// No description provided for @primaryBadge.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primaryBadge;

  /// No description provided for @classReminders.
  ///
  /// In en, this message translates to:
  /// **'Class reminders'**
  String get classReminders;

  /// No description provided for @classRemindersBody.
  ///
  /// In en, this message translates to:
  /// **'A nudge when a prayer window is closing and your class is still unmarked.'**
  String get classRemindersBody;

  /// No description provided for @unmarkedClassAlerts.
  ///
  /// In en, this message translates to:
  /// **'Unmarked class alerts'**
  String get unmarkedClassAlerts;

  /// No description provided for @distanceMeters.
  ///
  /// In en, this message translates to:
  /// **'{meters} m'**
  String distanceMeters(int meters);

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String distanceKm(String km);

  /// No description provided for @dotJoin.
  ///
  /// In en, this message translates to:
  /// **'{a} · {b}'**
  String dotJoin(String a, String b);

  /// No description provided for @mosqueNotFound.
  ///
  /// In en, this message translates to:
  /// **'Mosque not found'**
  String get mosqueNotFound;

  /// No description provided for @jamaatTimes.
  ///
  /// In en, this message translates to:
  /// **'Jama’at times'**
  String get jamaatTimes;

  /// No description provided for @timesWrong.
  ///
  /// In en, this message translates to:
  /// **'Times wrong? '**
  String get timesWrong;

  /// No description provided for @reportThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks — the Al Islaah team will check these times.'**
  String get reportThanks;

  /// No description provided for @reportThem.
  ///
  /// In en, this message translates to:
  /// **'Report them'**
  String get reportThem;

  /// No description provided for @myPrimaryMosque.
  ///
  /// In en, this message translates to:
  /// **'My primary mosque'**
  String get myPrimaryMosque;

  /// No description provided for @myPrimaryMosqueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Its times show on your Today screen'**
  String get myPrimaryMosqueSubtitle;

  /// No description provided for @inFavourites.
  ///
  /// In en, this message translates to:
  /// **'In favourites'**
  String get inFavourites;

  /// No description provided for @alertBeforeJamaat.
  ///
  /// In en, this message translates to:
  /// **'Alert before Jama’at'**
  String get alertBeforeJamaat;

  /// No description provided for @minutesBefore.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes before'**
  String minutesBefore(int count);

  /// No description provided for @yourMosque.
  ///
  /// In en, this message translates to:
  /// **'Your mosque'**
  String get yourMosque;

  /// No description provided for @noPrimaryMosqueYet.
  ///
  /// In en, this message translates to:
  /// **'No primary mosque yet. Open any mosque below and turn on “My primary mosque” to see its Jama\'at times on Today.'**
  String get noPrimaryMosqueYet;

  /// No description provided for @savedSection.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedSection;

  /// No description provided for @tapStarToRemove.
  ///
  /// In en, this message translates to:
  /// **'Tap the star to remove'**
  String get tapStarToRemove;

  /// No description provided for @nearbySection.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearbySection;

  /// No description provided for @tapStarToSave.
  ///
  /// In en, this message translates to:
  /// **'Tap the star to save'**
  String get tapStarToSave;

  /// No description provided for @primaryMosqueTimesNote.
  ///
  /// In en, this message translates to:
  /// **'Jama\'at times from this mosque show on your Today screen.'**
  String get primaryMosqueTimesNote;

  /// No description provided for @linkYourMosque.
  ///
  /// In en, this message translates to:
  /// **'Link Your Mosque'**
  String get linkYourMosque;

  /// No description provided for @linkMosqueBody.
  ///
  /// In en, this message translates to:
  /// **'Jama\'at times will show on your Today screen, with a reminder before each prayer.'**
  String get linkMosqueBody;

  /// No description provided for @noMosqueFoundRegisterLater.
  ///
  /// In en, this message translates to:
  /// **'No mosque found. You can register it later from the Mosques tab.'**
  String get noMosqueFoundRegisterLater;

  /// No description provided for @setAsMyMosque.
  ///
  /// In en, this message translates to:
  /// **'Set as my mosque'**
  String get setAsMyMosque;

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String resultsCount(int count);

  /// No description provided for @noMosqueMatches.
  ///
  /// In en, this message translates to:
  /// **'No mosque matches “{query}”. You can register it above.'**
  String noMosqueMatches(String query);

  /// No description provided for @removeFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get removeFromSaved;

  /// No description provided for @saveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveTooltip;

  /// No description provided for @registerNewMosque.
  ///
  /// In en, this message translates to:
  /// **'Register a new mosque'**
  String get registerNewMosque;

  /// No description provided for @registerNewMosqueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If yours isn\'t listed yet'**
  String get registerNewMosqueSubtitle;

  /// No description provided for @connImam.
  ///
  /// In en, this message translates to:
  /// **'Imam'**
  String get connImam;

  /// No description provided for @connCommittee.
  ///
  /// In en, this message translates to:
  /// **'Committee member'**
  String get connCommittee;

  /// No description provided for @connMutawalli.
  ///
  /// In en, this message translates to:
  /// **'Mutawalli'**
  String get connMutawalli;

  /// No description provided for @connCaretaker.
  ///
  /// In en, this message translates to:
  /// **'Caretaker'**
  String get connCaretaker;

  /// No description provided for @connWorshipper.
  ///
  /// In en, this message translates to:
  /// **'Regular worshipper'**
  String get connWorshipper;

  /// No description provided for @gpsFailedSamplePin.
  ///
  /// In en, this message translates to:
  /// **'Could not read GPS — a sample pin was placed. Tap the map to move it.'**
  String get gpsFailedSamplePin;

  /// No description provided for @sampleFileAttached.
  ///
  /// In en, this message translates to:
  /// **'Sample file attached — real uploads arrive with the registration backend.'**
  String get sampleFileAttached;

  /// No description provided for @mosqueAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This mosque is already registered'**
  String get mosqueAlreadyRegistered;

  /// No description provided for @mosqueSameNameAway.
  ///
  /// In en, this message translates to:
  /// **'A registered mosque with the same name sits {distance} away.'**
  String mosqueSameNameAway(String distance);

  /// No description provided for @useThisMosque.
  ///
  /// In en, this message translates to:
  /// **'Yes, that’s it — use this one'**
  String get useThisMosque;

  /// No description provided for @differentMosque.
  ///
  /// In en, this message translates to:
  /// **'No, this is a different mosque'**
  String get differentMosque;

  /// No description provided for @differentMosqueNote.
  ///
  /// In en, this message translates to:
  /// **'Choosing “different” sends your request to the Al Islaah team. The same mosque cannot be registered twice.'**
  String get differentMosqueNote;

  /// No description provided for @stepMosqueDetails.
  ///
  /// In en, this message translates to:
  /// **'Mosque details'**
  String get stepMosqueDetails;

  /// No description provided for @stepYourDetails.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get stepYourDetails;

  /// No description provided for @stepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get stepReview;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String stepOf(int step, int total);

  /// No description provided for @fieldsStillNeeded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 field still needed} other{{count} fields still needed}}'**
  String fieldsStillNeeded(int count);

  /// No description provided for @mosqueNeedsEveryField.
  ///
  /// In en, this message translates to:
  /// **'A mosque cannot be registered until every field is filled.'**
  String get mosqueNeedsEveryField;

  /// No description provided for @everyFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Every field is required. A mosque cannot be registered until all of them are filled — that is what keeps duplicate and fake entries out.'**
  String get everyFieldRequired;

  /// No description provided for @sectionIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get sectionIdentity;

  /// No description provided for @fullMosqueName.
  ///
  /// In en, this message translates to:
  /// **'Full mosque name'**
  String get fullMosqueName;

  /// No description provided for @enterMosqueName.
  ///
  /// In en, this message translates to:
  /// **'Enter the mosque name'**
  String get enterMosqueName;

  /// No description provided for @streetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street address'**
  String get streetAddress;

  /// No description provided for @enterStreetAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter the street address'**
  String get enterStreetAddress;

  /// No description provided for @cityArea.
  ///
  /// In en, this message translates to:
  /// **'City / area'**
  String get cityArea;

  /// No description provided for @enterCityArea.
  ///
  /// In en, this message translates to:
  /// **'Enter the city or area'**
  String get enterCityArea;

  /// No description provided for @dropPinOnMap.
  ///
  /// In en, this message translates to:
  /// **'Drop a pin on the map'**
  String get dropPinOnMap;

  /// No description provided for @tapGpsOrDrag.
  ///
  /// In en, this message translates to:
  /// **'Tap GPS, or drag the pin to the mosque'**
  String get tapGpsOrDrag;

  /// No description provided for @dragPinHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the pin, or tap GPS. An accurate location is what stops duplicate entries.'**
  String get dragPinHint;

  /// No description provided for @signBoardPhoto.
  ///
  /// In en, this message translates to:
  /// **'Sign board photo'**
  String get signBoardPhoto;

  /// No description provided for @addAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addAPhoto;

  /// No description provided for @addAPhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One where the mosque’s name is clearly readable'**
  String get addAPhotoSubtitle;

  /// No description provided for @jamaatAddedAfterVerify.
  ///
  /// In en, this message translates to:
  /// **'Jama’at times are not entered here. The Al Islaah team adds them once the mosque is verified, so the times people see are always confirmed.'**
  String get jamaatAddedAfterVerify;

  /// No description provided for @continueTurnsOn.
  ///
  /// In en, this message translates to:
  /// **'Continue turns on once every field is filled.'**
  String get continueTurnsOn;

  /// No description provided for @yourConnection.
  ///
  /// In en, this message translates to:
  /// **'Your connection'**
  String get yourConnection;

  /// No description provided for @howConnected.
  ///
  /// In en, this message translates to:
  /// **'How are you connected to this mosque?'**
  String get howConnected;

  /// No description provided for @chooseOne.
  ///
  /// In en, this message translates to:
  /// **'Choose one'**
  String get chooseOne;

  /// No description provided for @yourFullName.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get yourFullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @cnicNumber.
  ///
  /// In en, this message translates to:
  /// **'CNIC number'**
  String get cnicNumber;

  /// No description provided for @enterAll13Digits.
  ///
  /// In en, this message translates to:
  /// **'Enter all 13 digits'**
  String get enterAll13Digits;

  /// No description provided for @phoneCnicPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your phone number and CNIC are used only to verify you. Neither is ever shown in the app, and the Al Islaah team calls the number before approving.'**
  String get phoneCnicPrivacy;

  /// No description provided for @proofOfRole.
  ///
  /// In en, this message translates to:
  /// **'Proof of role'**
  String get proofOfRole;

  /// No description provided for @addADocument.
  ///
  /// In en, this message translates to:
  /// **'Add a document'**
  String get addADocument;

  /// No description provided for @addADocumentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment letter, committee resolution, or CNIC'**
  String get addADocumentSubtitle;

  /// No description provided for @verificationOnly.
  ///
  /// In en, this message translates to:
  /// **'For verification only — never shown in the app, and deleted once verified.'**
  String get verificationOnly;

  /// No description provided for @worshipperCnicNote.
  ///
  /// In en, this message translates to:
  /// **'A regular worshipper can upload their CNIC here instead. The mosque is still listed either way — only an Imam or committee member can later edit its Jama’at times.'**
  String get worshipperCnicNote;

  /// No description provided for @mosqueContact.
  ///
  /// In en, this message translates to:
  /// **'Mosque contact'**
  String get mosqueContact;

  /// No description provided for @mosquePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Mosque phone number'**
  String get mosquePhoneNumber;

  /// No description provided for @enterMosquePhone.
  ///
  /// In en, this message translates to:
  /// **'Enter the mosque phone number'**
  String get enterMosquePhone;

  /// No description provided for @auqafOptional.
  ///
  /// In en, this message translates to:
  /// **'Auqaf registration number — optional'**
  String get auqafOptional;

  /// No description provided for @leaveBlankIfNone.
  ///
  /// In en, this message translates to:
  /// **'Leave blank if none'**
  String get leaveBlankIfNone;

  /// No description provided for @reviewName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get reviewName;

  /// No description provided for @reviewAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get reviewAddress;

  /// No description provided for @reviewLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get reviewLocation;

  /// No description provided for @reviewPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get reviewPhoto;

  /// No description provided for @reviewMosquePhone.
  ///
  /// In en, this message translates to:
  /// **'Mosque phone'**
  String get reviewMosquePhone;

  /// No description provided for @reviewConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get reviewConnection;

  /// No description provided for @reviewPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get reviewPhone;

  /// No description provided for @reviewCnic.
  ///
  /// In en, this message translates to:
  /// **'CNIC'**
  String get reviewCnic;

  /// No description provided for @reviewProof.
  ///
  /// In en, this message translates to:
  /// **'Proof'**
  String get reviewProof;

  /// No description provided for @notShownPublicly.
  ///
  /// In en, this message translates to:
  /// **'{value} · not shown publicly'**
  String notShownPublicly(String value);

  /// No description provided for @addressJoin.
  ///
  /// In en, this message translates to:
  /// **'{street}, {city}'**
  String addressJoin(String street, String city);

  /// No description provided for @confirmInfoCorrect.
  ///
  /// In en, this message translates to:
  /// **'I confirm this information is correct and that this mosque really exists.'**
  String get confirmInfoCorrect;

  /// No description provided for @submitForRegistration.
  ///
  /// In en, this message translates to:
  /// **'Submit for registration'**
  String get submitForRegistration;

  /// No description provided for @submittedStepForm.
  ///
  /// In en, this message translates to:
  /// **'Form submitted'**
  String get submittedStepForm;

  /// No description provided for @submittedStepPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone verification — a call within 2–3 days'**
  String get submittedStepPhone;

  /// No description provided for @submittedStepDocs.
  ///
  /// In en, this message translates to:
  /// **'Photo and documents reviewed'**
  String get submittedStepDocs;

  /// No description provided for @submittedStepListed.
  ///
  /// In en, this message translates to:
  /// **'Listed in search once approved'**
  String get submittedStepListed;

  /// No description provided for @requestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Request submitted'**
  String get requestSubmitted;

  /// No description provided for @requestWithTeam.
  ///
  /// In en, this message translates to:
  /// **'{mosque}’s details are now with the Al Islaah team.'**
  String requestWithTeam(String mosque);

  /// No description provided for @notifiedWhenApproved.
  ///
  /// In en, this message translates to:
  /// **'You’ll be notified as soon as it’s approved.'**
  String get notifiedWhenApproved;

  /// No description provided for @backToMosques.
  ///
  /// In en, this message translates to:
  /// **'Back to Mosques'**
  String get backToMosques;

  /// No description provided for @noPinYet.
  ///
  /// In en, this message translates to:
  /// **'No pin yet'**
  String get noPinYet;

  /// No description provided for @gpsButton.
  ///
  /// In en, this message translates to:
  /// **'GPS'**
  String get gpsButton;

  /// No description provided for @familyRemindersIntro.
  ///
  /// In en, this message translates to:
  /// **'You are nudged only while a prayer can still be prayed — never after the window has closed.'**
  String get familyRemindersIntro;

  /// No description provided for @notificationNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get notificationNow;

  /// No description provided for @previewChildName.
  ///
  /// In en, this message translates to:
  /// **'Bilal'**
  String get previewChildName;

  /// No description provided for @childHasntMarked.
  ///
  /// In en, this message translates to:
  /// **'{name} hasn’t marked {prayer}'**
  String childHasntMarked(String name, String prayer);

  /// No description provided for @minutesLeftInWindow.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes left in the window'**
  String minutesLeftInWindow(int count);

  /// No description provided for @whatAlertLooksLike.
  ///
  /// In en, this message translates to:
  /// **'What the alert looks like'**
  String get whatAlertLooksLike;

  /// No description provided for @whenYouAreAlerted.
  ///
  /// In en, this message translates to:
  /// **'When you are alerted'**
  String get whenYouAreAlerted;

  /// No description provided for @beforeWindowCloses.
  ///
  /// In en, this message translates to:
  /// **'Before a window closes'**
  String get beforeWindowCloses;

  /// No description provided for @oneNudgePerPrayer.
  ///
  /// In en, this message translates to:
  /// **'One nudge per prayer, per child'**
  String get oneNudgePerPrayer;

  /// No description provided for @whichPrayers.
  ///
  /// In en, this message translates to:
  /// **'Which prayers'**
  String get whichPrayers;

  /// No description provided for @whichPrayersBody.
  ///
  /// In en, this message translates to:
  /// **'Turn off the ones your children pray at the madrasa — you won’t be nudged about those.'**
  String get whichPrayersBody;

  /// No description provided for @eveningSummary.
  ///
  /// In en, this message translates to:
  /// **'Evening summary'**
  String get eveningSummary;

  /// No description provided for @eveningSummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'One message after Isha with everyone’s day'**
  String get eveningSummarySubtitle;

  /// No description provided for @summaryTime.
  ///
  /// In en, this message translates to:
  /// **'Summary time'**
  String get summaryTime;

  /// No description provided for @keepingItQuiet.
  ///
  /// In en, this message translates to:
  /// **'Keeping it quiet'**
  String get keepingItQuiet;

  /// No description provided for @quietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get quietHours;

  /// No description provided for @quietHoursSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No alerts 8:00 AM – 2:00 PM and after 10:00 PM'**
  String get quietHoursSubtitle;

  /// No description provided for @dailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily limit'**
  String get dailyLimit;

  /// No description provided for @dailyLimitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Extra nudges are rolled into the evening summary'**
  String get dailyLimitSubtitle;

  /// No description provided for @childrenMuteBody.
  ///
  /// In en, this message translates to:
  /// **'Turn a child off to stop every alert about them.'**
  String get childrenMuteBody;

  /// No description provided for @addChildToSetUp.
  ///
  /// In en, this message translates to:
  /// **'Add a child to set this up.'**
  String get addChildToSetUp;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year} other{{count} years}}'**
  String ageYears(int count);

  /// No description provided for @streakBreakAlert.
  ///
  /// In en, this message translates to:
  /// **'Tell me when a streak breaks'**
  String get streakBreakAlert;

  /// No description provided for @onceADayAtMost.
  ///
  /// In en, this message translates to:
  /// **'Once a day at most'**
  String get onceADayAtMost;

  /// No description provided for @ownRemindersHint.
  ///
  /// In en, this message translates to:
  /// **'Your own prayer reminders are under More → Notifications & widgets.'**
  String get ownRemindersHint;

  /// No description provided for @addAChild.
  ///
  /// In en, this message translates to:
  /// **'Add a child'**
  String get addAChild;

  /// No description provided for @noChildrenYet.
  ///
  /// In en, this message translates to:
  /// **'No children added yet'**
  String get noChildrenYet;

  /// No description provided for @noChildrenYetBody.
  ///
  /// In en, this message translates to:
  /// **'Add a child to mark and track their Salah.'**
  String get noChildrenYetBody;

  /// No description provided for @barToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get barToday;

  /// No description provided for @barWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get barWeek;

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakLabel;

  /// No description provided for @qazaToMakeUp.
  ///
  /// In en, this message translates to:
  /// **'Qaza to make up'**
  String get qazaToMakeUp;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @childAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added.'**
  String childAdded(String name);

  /// No description provided for @couldNotAddChild.
  ///
  /// In en, this message translates to:
  /// **'Could not add child.'**
  String get couldNotAddChild;

  /// No description provided for @addChildBody.
  ///
  /// In en, this message translates to:
  /// **'A child gets no account of their own — you mark their prayers.'**
  String get addChildBody;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderBoy.
  ///
  /// In en, this message translates to:
  /// **'Boy'**
  String get genderBoy;

  /// No description provided for @genderGirl.
  ///
  /// In en, this message translates to:
  /// **'Girl'**
  String get genderGirl;

  /// No description provided for @childQazaIntro.
  ///
  /// In en, this message translates to:
  /// **'Jaiza counts this child\'s missed prayers from the day they were added. Mark each Qaza as it is made up.'**
  String get childQazaIntro;

  /// No description provided for @studentsAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 student added.} other{{count} students added.}}'**
  String studentsAdded(int count);

  /// No description provided for @couldNotAddStudents.
  ///
  /// In en, this message translates to:
  /// **'Could not add students.'**
  String get couldNotAddStudents;

  /// No description provided for @oneByOne.
  ///
  /// In en, this message translates to:
  /// **'One by one'**
  String get oneByOne;

  /// No description provided for @pasteAList.
  ///
  /// In en, this message translates to:
  /// **'Paste a list'**
  String get pasteAList;

  /// No description provided for @studentNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Student\'s name'**
  String get studentNameLabel;

  /// No description provided for @addStudent.
  ///
  /// In en, this message translates to:
  /// **'Add student'**
  String get addStudent;

  /// No description provided for @pasteListNote.
  ///
  /// In en, this message translates to:
  /// **'One name per line. Thirty students take about a minute this way instead of thirty separate forms.'**
  String get pasteListNote;

  /// No description provided for @namesSection.
  ///
  /// In en, this message translates to:
  /// **'Names'**
  String get namesSection;

  /// No description provided for @namesFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 name found} other{{count} names found}}'**
  String namesFound(int count);

  /// No description provided for @addNStudents.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add 1 student} other{Add {count} students}}'**
  String addNStudents(int count);

  /// No description provided for @removeFromOrgTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from organization?'**
  String get removeFromOrgTitle;

  /// No description provided for @removeFromOrgBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will lose access to this organization\'s classes and students. Their classes stay; you can reassign them.'**
  String removeFromOrgBody(String name);

  /// No description provided for @organizationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Organization not found.'**
  String get organizationNotFound;

  /// No description provided for @teacherNotFound.
  ///
  /// In en, this message translates to:
  /// **'Teacher not found.'**
  String get teacherNotFound;

  /// No description provided for @emailJoined.
  ///
  /// In en, this message translates to:
  /// **'{email} · joined {date}'**
  String emailJoined(String email, String date);

  /// No description provided for @readOnlyTeacherNote.
  ///
  /// In en, this message translates to:
  /// **'Read-only. Marking attendance stays with the teacher.'**
  String get readOnlyTeacherNote;

  /// No description provided for @teacherNoClasses.
  ///
  /// In en, this message translates to:
  /// **'This teacher has no classes yet.'**
  String get teacherNoClasses;

  /// No description provided for @studentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 student} other{{count} students}}'**
  String studentsCount(int count);

  /// No description provided for @percent.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String percent(int value);

  /// No description provided for @removeFromOrg.
  ///
  /// In en, this message translates to:
  /// **'Remove from organization'**
  String get removeFromOrg;

  /// No description provided for @removeFromOrgSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Their classes stay; you can reassign them'**
  String get removeFromOrgSubtitle;

  /// No description provided for @notAttachedToOrg.
  ///
  /// In en, this message translates to:
  /// **'Not attached to an organization yet.'**
  String get notAttachedToOrg;

  /// No description provided for @classReport.
  ///
  /// In en, this message translates to:
  /// **'Class report'**
  String get classReport;

  /// No description provided for @slashTotal.
  ///
  /// In en, this message translates to:
  /// **' / {total}'**
  String slashTotal(int total);

  /// No description provided for @markAllPresent.
  ///
  /// In en, this message translates to:
  /// **'Mark all present'**
  String get markAllPresent;

  /// No description provided for @unmarkedFilter.
  ///
  /// In en, this message translates to:
  /// **'Unmarked'**
  String get unmarkedFilter;

  /// No description provided for @noStudentsAddBelow.
  ///
  /// In en, this message translates to:
  /// **'No students yet. Add some below.'**
  String get noStudentsAddBelow;

  /// No description provided for @savedAsYouTap.
  ///
  /// In en, this message translates to:
  /// **'Saved as you tap — there is no submit button.'**
  String get savedAsYouTap;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @classAverage.
  ///
  /// In en, this message translates to:
  /// **'Class average'**
  String get classAverage;

  /// No description provided for @classReportSummary.
  ///
  /// In en, this message translates to:
  /// **'{students} · {month} · {done} of {possible} prayers'**
  String classReportSummary(
    String students,
    String month,
    int done,
    int possible,
  );

  /// No description provided for @byStudent.
  ///
  /// In en, this message translates to:
  /// **'By student'**
  String get byStudent;

  /// No description provided for @noStudentsYet.
  ///
  /// In en, this message translates to:
  /// **'No students yet.'**
  String get noStudentsYet;

  /// No description provided for @sharingComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Sharing arrives with the reports backend — for now, tell families the numbers directly.'**
  String get sharingComingSoon;

  /// No description provided for @shareReport.
  ///
  /// In en, this message translates to:
  /// **'Share report'**
  String get shareReport;

  /// No description provided for @pdfComingSoon.
  ///
  /// In en, this message translates to:
  /// **'PDF export is coming soon.'**
  String get pdfComingSoon;

  /// No description provided for @pdfButton.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdfButton;

  /// No description provided for @statTeachers.
  ///
  /// In en, this message translates to:
  /// **'Teachers'**
  String get statTeachers;

  /// No description provided for @statStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get statStudents;

  /// No description provided for @todayAcrossMadrasa.
  ///
  /// In en, this message translates to:
  /// **'Today across the madrasa'**
  String get todayAcrossMadrasa;

  /// No description provided for @inviteTeacher.
  ///
  /// In en, this message translates to:
  /// **'Invite teacher'**
  String get inviteTeacher;

  /// No description provided for @noTeachersYet.
  ///
  /// In en, this message translates to:
  /// **'No teachers yet — invite one above.'**
  String get noTeachersYet;

  /// No description provided for @allClasses.
  ///
  /// In en, this message translates to:
  /// **'All classes'**
  String get allClasses;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @classesStudents.
  ///
  /// In en, this message translates to:
  /// **'{classes} · {students}'**
  String classesStudents(String classes, String students);

  /// No description provided for @classesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 class} other{{count} classes}}'**
  String classesCount(int count);

  /// No description provided for @accessRemoved.
  ///
  /// In en, this message translates to:
  /// **'Your access to this organization has been removed.'**
  String get accessRemoved;

  /// No description provided for @residentialStudentsNote.
  ///
  /// In en, this message translates to:
  /// **'Residential students — all five prayers are marked here.'**
  String get residentialStudentsNote;

  /// No description provided for @newClass.
  ///
  /// In en, this message translates to:
  /// **'New class'**
  String get newClass;

  /// No description provided for @noClassesCreateOne.
  ///
  /// In en, this message translates to:
  /// **'No classes yet — create one above.'**
  String get noClassesCreateOne;

  /// No description provided for @inviteSent.
  ///
  /// In en, this message translates to:
  /// **'Invite sent. They\'ll get teacher access when they sign up or log in with {email}.'**
  String inviteSent(String email);

  /// No description provided for @couldNotSendInvite.
  ///
  /// In en, this message translates to:
  /// **'Could not send invite.'**
  String get couldNotSendInvite;

  /// No description provided for @inviteATeacher.
  ///
  /// In en, this message translates to:
  /// **'Invite a teacher'**
  String get inviteATeacher;

  /// No description provided for @inviteTeacherBody.
  ///
  /// In en, this message translates to:
  /// **'They get teacher access the moment they sign up or log in with this email.'**
  String get inviteTeacherBody;

  /// No description provided for @teacherEmailHint.
  ///
  /// In en, this message translates to:
  /// **'teacher@example.com'**
  String get teacherEmailHint;

  /// No description provided for @teacherPermissionsNote.
  ///
  /// In en, this message translates to:
  /// **'A teacher can create classes, add students and mark attendance. They cannot invite other teachers or see classes that are not theirs.'**
  String get teacherPermissionsNote;

  /// No description provided for @sendInvite.
  ///
  /// In en, this message translates to:
  /// **'Send invite'**
  String get sendInvite;

  /// No description provided for @enterClassName.
  ///
  /// In en, this message translates to:
  /// **'Enter a class name'**
  String get enterClassName;

  /// No description provided for @couldNotCreateClass.
  ///
  /// In en, this message translates to:
  /// **'Could not create the class.'**
  String get couldNotCreateClass;

  /// No description provided for @newClassBody.
  ///
  /// In en, this message translates to:
  /// **'Students living at the madrasa — all five prayers are marked for them.'**
  String get newClassBody;

  /// No description provided for @classNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Class name'**
  String get classNameLabel;

  /// No description provided for @classNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Batch C'**
  String get classNameHint;

  /// No description provided for @sectionOptional.
  ///
  /// In en, this message translates to:
  /// **'Section — optional'**
  String get sectionOptional;

  /// No description provided for @sectionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dars-e-Nizami year 1'**
  String get sectionHint;

  /// No description provided for @createClass.
  ///
  /// In en, this message translates to:
  /// **'Create class'**
  String get createClass;

  /// No description provided for @addedRecently.
  ///
  /// In en, this message translates to:
  /// **'Added recently'**
  String get addedRecently;

  /// No description provided for @addedOn.
  ///
  /// In en, this message translates to:
  /// **'Added {date}'**
  String addedOn(String date);

  /// No description provided for @doneSlashTotalSpaced.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total}'**
  String doneSlashTotalSpaced(int done, int total);

  /// No description provided for @pctOnTimeComplete.
  ///
  /// In en, this message translates to:
  /// **'{pct}% on time · {days}'**
  String pctOnTimeComplete(int pct, String days);

  /// No description provided for @completeDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 complete day} other{{count} complete days}}'**
  String completeDays(int count);

  /// No description provided for @fullHistory.
  ///
  /// In en, this message translates to:
  /// **'Full history'**
  String get fullHistory;

  /// No description provided for @nameFullHistory.
  ///
  /// In en, this message translates to:
  /// **'{name} — full history'**
  String nameFullHistory(String name);

  /// No description provided for @noPrayersLoggedYet.
  ///
  /// In en, this message translates to:
  /// **'No prayers logged yet.'**
  String get noPrayersLoggedYet;

  /// No description provided for @qazaCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} completed'**
  String qazaCompletedCount(int count);

  /// No description provided for @monthSummary.
  ///
  /// In en, this message translates to:
  /// **'{month} summary'**
  String monthSummary(String month);

  /// No description provided for @pctPrayedComplete.
  ///
  /// In en, this message translates to:
  /// **'{pct}% prayed · {days}'**
  String pctPrayedComplete(int pct, String days);

  /// No description provided for @teacherAlreadyActive.
  ///
  /// In en, this message translates to:
  /// **'This person is already a teacher here.'**
  String get teacherAlreadyActive;

  /// No description provided for @anOrganization.
  ///
  /// In en, this message translates to:
  /// **'an organization'**
  String get anOrganization;

  /// No description provided for @studentNamesHint.
  ///
  /// In en, this message translates to:
  /// **'Abdullah Khan\nIbrahim Siddiqui\nYusuf Malik'**
  String get studentNamesHint;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Jaiza'**
  String get updateRequiredTitle;

  /// No description provided for @updateRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'This version of Jaiza is no longer supported. Please update to continue.'**
  String get updateRequiredBody;

  /// No description provided for @updateRequiredButton.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updateRequiredButton;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'ur':
      return L10nUr();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
