// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Jaiza';

  @override
  String get academyCredit => 'A project by Al Islaah Academy';

  @override
  String get startWithSalaam => 'Start with Salaam';

  @override
  String get welcomeSubtitle =>
      'Track and mark your daily prayers, set reminders, and keep a complete history of your worship.';

  @override
  String get namazMarkedSuccess => 'Namaz marked successfully 🤍';

  @override
  String get noPrayersYet => 'No prayers recorded yet';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonBody =>
      'We are preparing this section. Check back in a future update.';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerZuhr => 'Zuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get prayerWitr => 'Witr';

  @override
  String get prayerTahajjud => 'Tahajjud';

  @override
  String get prayerIshraq => 'Ishraq';

  @override
  String get prayerChasht => 'Chasht (Duha)';

  @override
  String get prayerAwwabin => 'Salat al-Awwabin';

  @override
  String get prayerRawatib => 'Rawatib';

  @override
  String get prayerTaraweeh => 'Taraweeh';

  @override
  String get prayerQazaGeneric => 'Qaza';

  @override
  String get fardFajrStartHint => 'Begins at dawn';

  @override
  String get fardFajrEndHint => 'Until sunrise';

  @override
  String get fardZuhrStartHint => 'After zenith';

  @override
  String get fardZuhrEndHint => 'Before Asr';

  @override
  String get fardAsrStartHint => 'Afternoon';

  @override
  String get fardAsrEndHint => 'Before sunset';

  @override
  String get fardMaghribStartHint => 'Just after sunset';

  @override
  String get fardMaghribEndHint => 'Until Isha';

  @override
  String get fardIshaStartHint => 'Night begins';

  @override
  String get fardIshaEndHint => 'Until Fajr';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionOk => 'OK';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionClose => 'Close';

  @override
  String get actionDone => 'Done';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionBack => 'Back';

  @override
  String get actionNext => 'Next';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionSignOut => 'Sign out';

  @override
  String get actionUndo => 'Undo';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorSaveFailed => 'Could not save. Try again.';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle =>
      'Choose the app language. Urdu text is reviewed by Al Islaah Academy.';

  @override
  String get languageSystem => 'Device';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacyAnalyticsTitle => 'Share anonymous usage data';

  @override
  String get privacyAnalyticsSubtitle =>
      'Helps us improve Jaiza. Never includes your name, email, phone or location.';

  @override
  String get authErrorWrongPassword => 'Incorrect password. Please try again.';

  @override
  String get authErrorUserNotFound => 'No account found.';

  @override
  String get authErrorEmailInUse => 'Email already registered.';

  @override
  String get authErrorInvalidEmail => 'Please enter a valid email.';

  @override
  String get errorNetwork => 'Check your connection and try again.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Please wait and try again.';

  @override
  String get authErrorUserDisabled => 'This account has been disabled.';

  @override
  String get authErrorRecentLogin => 'Please sign in again to continue.';

  @override
  String get authErrorWeakPassword =>
      'Password is too weak. Use at least 8 characters with a letter and a number.';

  @override
  String get authErrorNoEmail => 'No email associated with this account.';

  @override
  String get stripTitle => 'Jaiza · Today\'s Prayers';

  @override
  String get statusPrayed => 'Prayed';

  @override
  String get statusMissed => 'Missed';

  @override
  String get statusNotRecorded => 'Not recorded';

  @override
  String get markAsPrayed => 'Mark as prayed';

  @override
  String get recordedAsMissed => 'Recorded as missed. Stay steadfast.';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get importantNoteTitle => 'Important Note';

  @override
  String get qazaEstimateNote =>
      'This calculation is only an estimate. Islam encourages sincere effort when the exact number is unknown. Enter your best estimate and remain consistent.';

  @override
  String get mosqueSearchHint => 'Mosque name or area';

  @override
  String quoteFormat(String quote) {
    return '“$quote”';
  }

  @override
  String quoteSource(String source) {
    return '($source)';
  }

  @override
  String get badgeFirstStepTitle => 'First step';

  @override
  String get badgeFirstStepDescription =>
      'Complete all Fard prayers for one day.';

  @override
  String get badgeWeekWarriorTitle => 'Week warrior';

  @override
  String get badgeWeekWarriorDescription => '7-day Fard streak.';

  @override
  String get badgeMonthOfLightTitle => 'Month of light';

  @override
  String get badgeMonthOfLightDescription => '30-day Fard streak.';

  @override
  String get badgeNawafilNurTitle => 'Nawafil Nur';

  @override
  String get badgeNawafilNurDescription => 'Offer nawafil 10 times (tracked).';

  @override
  String get hijriSuffix => 'AH';

  @override
  String dateLineSeparator(String gregorian, String hijri) {
    return '$gregorian · $hijri';
  }

  @override
  String get hijriMonth1 => 'Muharram';

  @override
  String get hijriMonth2 => 'Safar';

  @override
  String get hijriMonth3 => 'Rabi al-Awwal';

  @override
  String get hijriMonth4 => 'Rabi al-Thani';

  @override
  String get hijriMonth5 => 'Jumada al-Ula';

  @override
  String get hijriMonth6 => 'Jumada al-Thaniyah';

  @override
  String get hijriMonth7 => 'Rajab';

  @override
  String get hijriMonth8 => 'Sha\'ban';

  @override
  String get hijriMonth9 => 'Ramadan';

  @override
  String get hijriMonth10 => 'Shawwal';

  @override
  String get hijriMonth11 => 'Dhul Qa\'dah';

  @override
  String get hijriMonth12 => 'Dhul Hijjah';

  @override
  String notifPrayerStarted(String prayer) {
    return '$prayer time has begun. Don’t miss your prayer.';
  }

  @override
  String notifPrayerEndsSoon(String prayer, int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$prayer ends in $minutesString minutes. Have you prayed?';
  }

  @override
  String notifPrayerEnded(String prayer) {
    return '$prayer time has ended. Did you pray?';
  }

  @override
  String get notifTest => 'Test notification — prayer reminders are working.';

  @override
  String get notifChannelPrayerName => 'Prayer time reminders';

  @override
  String get notifChannelPrayerDescription =>
      'Prayer start and reminder notifications';

  @override
  String get calcMethodKarachi => 'Karachi (UIS)';

  @override
  String get calcMethodMwl => 'Muslim World League';

  @override
  String get calcMethodUmmAlQura => 'Umm al-Qura';

  @override
  String get calcMethodIsna => 'ISNA (North America)';

  @override
  String get calcMethodEgyptian => 'Egyptian';

  @override
  String get calcMethodTehran => 'Tehran';

  @override
  String get calcMethodSingapore => 'Singapore';

  @override
  String get madhabHanafi => 'Hanafi';

  @override
  String get madhabShafii => 'Shafi’i';

  @override
  String get widgetPrayerTimesTitle => 'Jaiza · Prayer times';

  @override
  String widgetTimesSubtitle(String method, String madhab, String place) {
    return '$method · $madhab · $place';
  }

  @override
  String get passwordUpdated => 'Password updated.';

  @override
  String get changePasswordIntro =>
      'Re-enter your current password, then choose a new one.';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmNewPasswordLabel => 'Confirm new password';

  @override
  String get validationRequired => 'Required';

  @override
  String get validationPasswordRule =>
      'Use at least 8 characters with a letter and a number';

  @override
  String get validationNoMatch => 'Does not match';

  @override
  String get validationPasswordsNoMatch => 'Passwords do not match';

  @override
  String get updatePasswordButton => 'Update password';

  @override
  String get verifyEmailNotYet =>
      'Email not verified yet. Open the link we sent, then try again.';

  @override
  String get verifyEmailSent => 'Verification email sent.';

  @override
  String get verifyEmailTitle => 'Verify Your Email';

  @override
  String get verifyEmailSentTo => 'We sent a verification link to:';

  @override
  String get verifyEmailInstructions =>
      'Tap the link in the email, then press “I’ve verified” below.';

  @override
  String get verifyEmailDone => 'I’ve verified';

  @override
  String get verifyEmailResendAgain => 'Resend again';

  @override
  String get verifyEmailResend => 'Resend email';

  @override
  String get getStartedWelcome => 'WELCOME TO JAIZA';

  @override
  String get getStartedTagline =>
      'Track your Salah, stay consistent, and earn Allah\'s pleasure.';

  @override
  String get chooseAccountType => 'CHOOSE YOUR ACCOUNT TYPE';

  @override
  String get roleIndividual => 'Individual';

  @override
  String get roleIndividualSubtitle =>
      'Track and manage your own Salah attendance.';

  @override
  String get roleParents => 'Parents';

  @override
  String get roleParentsSubtitle =>
      'Monitor and manage your children\'s Salah attendance.';

  @override
  String get roleInstitute => 'Institute';

  @override
  String get roleInstituteSubtitle =>
      'Manage Salah attendance for your school, madrasa or organization.';

  @override
  String get quoteAnkaboot =>
      'Indeed, Salah prohibits from indecency and wrongdoing.';

  @override
  String get quoteAnkabootSource => 'Surah Al-Ankaboot 29:45';

  @override
  String get haveAccount => 'Have an account?';

  @override
  String get logInButton => 'Log In';

  @override
  String get teacherSwitchTitle => 'Switch to a teacher account?';

  @override
  String teacherSwitchBody(String org) {
    return '$org has invited you as a teacher. Accepting will move your account to the Teacher dashboard for that organization.';
  }

  @override
  String get notNow => 'Not now';

  @override
  String get switchButton => 'Switch';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Log in to continue tracking your Salah.';

  @override
  String get emailLabel => 'Email';

  @override
  String get validationEnterEmail => 'Enter your email';

  @override
  String get validationValidEmail => 'Enter a valid email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get validationEnterPassword => 'Enter your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get logInLower => 'Log in';

  @override
  String get newHere => 'New here?';

  @override
  String get createAccount => 'Create account';

  @override
  String get resetCheckInbox => 'Check your inbox for reset instructions.';

  @override
  String get resetTitle => 'Reset Password';

  @override
  String get resetIntro =>
      'Enter the email for your account. We\'ll send a link to choose a new password.';

  @override
  String get resetSendLink => 'Send reset link';

  @override
  String get signupTitle => 'Create Your Account';

  @override
  String get signupSubtitle => 'Start tracking your Salah with Jaiza.';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get validationEnterName => 'Enter your name';

  @override
  String get instituteNameLabel => 'Institute name';

  @override
  String get instituteNameHint => 'e.g. Al Falah Madarsa';

  @override
  String get validationEnterInstitute => 'Enter your institute name';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get signUpButton => 'Sign up';

  @override
  String get academyIntroTitle => 'الاصلاح اکیڈمی کا مختصر تعارف';

  @override
  String get academyIntroIntroParagraph =>
      'الاصلاح اکیڈمی ایک ایسا تعلیمی ادارہ ہے جو مختلف شعبہ جات میں اپنی خدمات انجام دے رہا ہے۔ اس کا نصب العین یہی ہے کہ لوگوں کی جاری زندگیوں میں بہتری لائی جائے۔ معاشرے میں ہر ممکن مثبت تبدیلیاں پیدا ہوں، اور مسلمان اپنی حقیقی پہچان کو سمجھیں اور اپنے اسلام پر عمل کرنے والے بنیں۔';

  @override
  String get academyIntroSectionAghaz => 'آغاز:';

  @override
  String get academyIntroAghazBody1 =>
      'الحمدللہ! ابتدا کا کام الاصلاح اکیڈمی نے نہایت سادگی سے کیا۔ یہ چند دوستوں کی خواہش تھی کہ عام مسلمانوں کے لیے سستا مگر معیاری دینی کورس کروایا جائے۔ اس کورس کے دوران سب مشکلات کا سامنا کرنا پڑا، لیکن الحمدللہ آہستہ آہستہ کام آگے بڑھتا گیا۔ کچھ عرصہ کے بعد ایک مستقل ادارہ قائم کیا گیا، اور اس کا نام الاصلاح اکیڈمی رکھا گیا اور اس کی بنیاد پر اساتذہ کرام نے دین کی تعلیم کو عام کرنے کا عزم کیا۔ اس دوران حضرت عثمان غنی رضی اللہ عنہ کی خدمات کو سامنے رکھا گیا اور اس نام کو چننے کا مقصد بھی یہی تھا کہ معاشرے میں اصلاح کا کام عام ہو۔';

  @override
  String get academyIntroAghazBody2 =>
      'الاصلاح اکیڈمی کا باقاعدہ نظام قائم کرنے کے لیے حافظ محمد فاروق صاحب نے نمایاں کردار ادا کیا، اور پھر ان کے ساتھ دیگر اساتذہ بھی شامل ہوتے گئے۔ الاصلاح اکیڈمی میں اس وقت قرآن، حدیث، فقہ اور دیگر علوم کی تعلیم دی جا رہی ہے۔';

  @override
  String get academyIntroAghazBody3 =>
      'الاصلاح اکیڈمی کے قیام میں ہمیں اساتذہ کرام کا تعاون حاصل رہا، اور پھر حضرت استاد محترم مولانا مشتاق صاحب کی نگرانی میں یہ ادارہ ترقی کرتا گیا۔';

  @override
  String get academyIntroDepartmentsLead =>
      'الاصلاح اکیڈمی کے چند ایک شعبہ جات درج ذیل ہیں:';

  @override
  String get academyIntroEducationDeptTitle => '☆ تعلیمی شعبہ';

  @override
  String get academyIntroEducationDeptBody =>
      'اس شعبہ میں علومِ شرعیہ وغیرہ کی تعلیم دی جاتی ہے۔ الاصلاح اکیڈمی میں مختلف کورسز کا انعقاد مختلف اوقات میں ہوتا رہتا ہے جن میں کثیر تعداد میں طلبہ شریک ہوتے ہیں۔';

  @override
  String get academyIntroDetailedCoursesHeading => 'تفصیلی کورسز:';

  @override
  String get academyIntroShortCoursesHeading => 'مختصر کورسز:';

  @override
  String get academyIntroClosingLine =>
      'ان کے علاوہ بھی کئی کورسز کی کلاسز جاری ہیں';

  @override
  String get academyIntroDetailedCourses1 =>
      'آٹھ سالہ درسِ نظامی (وفاق المدارس العربیہ پاکستان)';

  @override
  String get academyIntroDetailedCourses2 =>
      'آن لائن چھ سالہ درسِ نظامی (وفاق المدارس العربیہ پاکستان)';

  @override
  String get academyIntroDetailedCourses3 => 'دو سالہ درسِ حدیث للبنات';

  @override
  String get academyIntroShortCourses1 => 'سیرت النبی ﷺ کورس';

  @override
  String get academyIntroShortCourses2 => 'مثالی اسلامی کورس';

  @override
  String get academyIntroShortCourses3 => 'منتخب احادیث';

  @override
  String get academyIntroShortCourses4 => 'آسان تفسیر کورس';

  @override
  String get academyIntroShortCourses5 => 'تجوید کورس';

  @override
  String get academyIntroShortCourses6 => 'آسان عربی';

  @override
  String get academyIntroShortCourses7 => 'عقیدہ کورس';

  @override
  String get academyIntroShortCourses8 => 'ترجمہ قرآن کورس';

  @override
  String get academyIntroShortCourses9 => 'حفظِ قرآن کورس';

  @override
  String get academyIntroShortCourses10 => 'عقائد و ایمانیات کورس';

  @override
  String get academyIntroShortCourses11 => 'تصوف و اصلاحی تربیت';

  @override
  String get onboardTrackTitle => 'Track Every Salah';

  @override
  String get onboardTrackBody =>
      'Mark your Fard, Nawafil and Qaza prayers with a tap, and see your progress build day by day.';

  @override
  String get onboardFamiliesTitle => 'For Families & Institutes';

  @override
  String get onboardFamiliesBody =>
      'Parents can track their children, and madaris can manage teachers, classes and students — all in one place.';

  @override
  String get onboardConsistentTitle => 'Stay Consistent';

  @override
  String get onboardConsistentBody =>
      'Gentle reminders at the right times help you never miss a prayer and stay steadfast on your journey.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get nameYourOrganization => 'Name your organization';

  @override
  String get roleSelectTitle => 'How will you use Jaiza?';

  @override
  String get roleSelectSubtitle =>
      'Pick the setup that fits you. You can\'t change this later.';

  @override
  String get roleIndividualSelectSubtitle =>
      'Track your own daily prayers, streaks and badges.';

  @override
  String get roleParent => 'Parent';

  @override
  String get roleParentSelectSubtitle =>
      'Mark and track prayer attendance for your children.';

  @override
  String get roleOrganization => 'Madarsa / Organization';

  @override
  String get roleOrganizationSelectSubtitle =>
      'Run a school or institute: teachers, classes and student attendance.';

  @override
  String get aboutBody =>
      'Jaiza helps Muslims track obligatory prayers, optional nawafil, and qaza with gentle motivation — clear progress, no clutter.';

  @override
  String get aboutAcademyIntroSubtitle => 'Brief introduction (Urdu)';

  @override
  String get academyName => 'Al Islaah Academy';

  @override
  String get aboutCoursesSubtitle => 'Courses and admissions';

  @override
  String get contactTitle => 'Contact';

  @override
  String get aboutContactSubtitle => 'Reach Al Islaah Academy';

  @override
  String get fazailTitle => 'Fazail of Prayers';

  @override
  String get fazailClosenessTitle => 'Closeness to Allah';

  @override
  String get fazailClosenessBody =>
      'Salah is a direct link between the servant and the Lord. It reminds us that we turn to Him in every state.';

  @override
  String get fazailDisciplineTitle => 'Discipline & structure';

  @override
  String get fazailDisciplineBody =>
      'Praying on time builds patience, order, and mindfulness throughout the day.';

  @override
  String get fazailPurificationTitle => 'Purification';

  @override
  String get fazailPurificationBody =>
      'Regular prayer washes away slips, renews intention, and keeps the heart soft.';

  @override
  String get fazailCommunityTitle => 'Community';

  @override
  String get fazailCommunityBody =>
      'Congregational prayer strengthens brotherhood and sisterhood in faith.';

  @override
  String get contactIntro =>
      'Reach out to Al Islaah Academy for questions about the app, classes, or general support.';

  @override
  String get contactBriefIntro => 'مختصر تعارف · Brief intro';

  @override
  String get contactEmailPlaceholder =>
      'Add your official contact email in the console';

  @override
  String get donationTitle => 'Support the project';

  @override
  String donationIntro(String app, String academy) {
    return '$app is offered by $academy. Your sadaqah helps maintain the app, content, and community programs.';
  }

  @override
  String get donationHowTitle => 'How to donate';

  @override
  String get donationHowBody =>
      'Connect your real donation link (bank, gateway, or campaign) here when ready. This screen is structured for future integration.';

  @override
  String get donationLinkMissing => 'Link your donation URL in the codebase.';

  @override
  String get donationOpenPlaceholder => 'Open donation (placeholder)';

  @override
  String get titleFamilyReminders => 'Family reminders';

  @override
  String get titleQaza => 'Qaza';

  @override
  String get titleFamily => 'Family';

  @override
  String get titleMyEstimate => 'My estimate';

  @override
  String get titleAddPastQaza => 'Add past Qaza';

  @override
  String titleQazaPrayer(String prayer) {
    return 'Qaza $prayer';
  }

  @override
  String get titleRegisterMosque => 'Register a mosque';

  @override
  String get titleMosque => 'Mosque';

  @override
  String get titleMosques => 'Mosques';

  @override
  String get titleRecords => 'Records';

  @override
  String get titleMore => 'More';

  @override
  String get titleToday => 'Today';

  @override
  String get titleFaraiz => 'Faraiz';

  @override
  String get titleNawafil => 'Nawafil';

  @override
  String get titleAboutJaiza => 'About Jaiza';

  @override
  String get titleDonation => 'Donation';

  @override
  String get titleNotificationsWidgets => 'Notifications & widgets';

  @override
  String get titleProfile => 'Profile';

  @override
  String get titleChangePassword => 'Change password';

  @override
  String get titleTeacher => 'Teacher';

  @override
  String get titleStudent => 'Student';

  @override
  String get titleAddStudents => 'Add students';

  @override
  String get titleClass => 'Class';

  @override
  String get titleChildren => 'Children';

  @override
  String get titleClasses => 'Classes';

  @override
  String titleChildQaza(String name) {
    return '$name’s Qaza';
  }

  @override
  String titleClassReport(String className) {
    return '$className report';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navWidgetsNotifications => 'Widgets & Notifications';

  @override
  String unmarkTitle(String prayer) {
    return 'Unmark $prayer?';
  }

  @override
  String get unmarkBody => 'It will be recorded as not prayed.';

  @override
  String get unmarkButton => 'Unmark';

  @override
  String addedToYourQaza(String prayer) {
    return '$prayer added to your Qaza list.';
  }

  @override
  String addedToQaza(String prayer) {
    return '$prayer added to the Qaza list.';
  }

  @override
  String get missedDot => 'Missed · ';

  @override
  String get addToQaza => 'Add to Qaza';

  @override
  String durationMinutes(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '${minutesString}m';
  }

  @override
  String durationHours(int hours) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);

    return '${hoursString}h';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '${hoursString}h ${minutesString}m';
  }

  @override
  String nawafilDoneToday(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$doneString of $totalString done today';
  }

  @override
  String get nawafilTrackingOff => 'Tracking off — tap to turn on';

  @override
  String get qazaNothingToMakeUp => 'Nothing to make up';

  @override
  String qazaPrayersToMakeUp(String count) {
    return '$count prayers to make up';
  }

  @override
  String qazaToMakeUpSince(String count, String date) {
    return '$count to make up · since $date';
  }

  @override
  String get currentPrayer => 'Current prayer';

  @override
  String get nextPrayer => 'Next prayer';

  @override
  String get setPrimaryMosqueTitle => 'Set your primary mosque';

  @override
  String get setPrimaryMosqueSubtitle =>
      'To see Jama\'at times for every prayer';

  @override
  String get findButton => 'Find';

  @override
  String get startsLabel => 'Starts';

  @override
  String get endsLabel => 'Ends';

  @override
  String jamaatStartsIn(String duration) {
    return ' · starts in $duration';
  }

  @override
  String jamaatStartedAgo(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return ' · started $minutesString min ago';
  }

  @override
  String get jamaat => 'Jama\'at';

  @override
  String streakDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString-day streak';
  }

  @override
  String streakBestSoFar(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Best so far — $countString days',
      one: 'Best so far — 1 day',
    );
    return '$_temp0';
  }

  @override
  String get streakStartHint => 'Pray all five to start one';

  @override
  String doneOfTotalToday(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$doneString of $totalString today';
  }

  @override
  String nowRange(String range) {
    return 'Now · $range';
  }

  @override
  String timeRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String hintRange(String start, String end) {
    return '$start — $end';
  }

  @override
  String get missedInYourQaza => 'Missed · in your Qaza list';

  @override
  String get missedInTheQaza => 'Missed · in the Qaza list';

  @override
  String get addChildren => 'Add children';

  @override
  String get addChildrenSubtitle => 'Mark their prayers from this same screen';

  @override
  String childNameAge(String name, int age) {
    final intl.NumberFormat ageNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String ageString = ageNumberFormat.format(age);

    return '$name · $ageString years';
  }

  @override
  String childTodayWeek(int done, int total, int week, int weekTotal) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);
    final intl.NumberFormat weekNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String weekString = weekNumberFormat.format(week);
    final intl.NumberFormat weekTotalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weekTotalString = weekTotalNumberFormat.format(weekTotal);

    return 'Today $doneString of $totalString · this week $weekString of $weekTotalString';
  }

  @override
  String get historyButton => 'History';

  @override
  String childStreak(String name, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$name — $countString-day streak';
  }

  @override
  String get childStreakStartHint => 'All five in a day starts a streak';

  @override
  String get seeAll => 'See all';

  @override
  String doneSlashTotal(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$doneString/$totalString';
  }

  @override
  String get sectionMadrasa => 'Madrasa';

  @override
  String get sectionOrganization => 'Organization';

  @override
  String get moreOrgSubtitle => 'Teachers, classes and reports';

  @override
  String get myClasses => 'My classes';

  @override
  String get noClassesYet => 'No classes yet';

  @override
  String get addYourChildren => 'Add your children';

  @override
  String get moreFamilySubtitle => 'Children, progress and their reminders';

  @override
  String get moreFamilyRemindersSubtitle => 'Nudges when a prayer isn’t marked';

  @override
  String get sectionAccount => 'Account';

  @override
  String get sectionApp => 'App';

  @override
  String get moreNotificationsParentSubtitle =>
      'Your prayers, Jama’at, widgets';

  @override
  String get moreNotificationsSubtitle => 'Reminders, Jama’at alerts, location';

  @override
  String get qazaPlan => 'Qaza plan';

  @override
  String qazaRemaining(String count) {
    return '$count remaining';
  }

  @override
  String get trackingOn => 'Tracking on';

  @override
  String get trackingOff => 'Tracking off';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeSystem => 'System';

  @override
  String get fazailOfPrayers => 'Fazail of prayers';

  @override
  String get aboutJaizaAndAcademy => 'About Jaiza & Al Islaah Academy';

  @override
  String get contactUs => 'Contact us';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountSubtitle => 'Removes your record permanently';

  @override
  String get nawafilSheetBody =>
      'Track Tahajjud, Ishraq, Chasht, Awwabin, Rawatib and Taraweeh alongside your Fard. Nawafil are never counted as Qaza.';

  @override
  String get trackNawafil => 'Track Nawafil';

  @override
  String get trackNawafilSubtitle => 'Shows a Nawafil card on Today';

  @override
  String get openTodaysNawafil => 'Open today’s Nawafil';

  @override
  String get deleteLostPrayerRecord => 'Your prayer record and streaks';

  @override
  String get deleteLostQazaList => 'Your Qaza list';

  @override
  String get deleteLostMosques => 'Saved mosques and Jama’at alerts';

  @override
  String get deleteLostChildren => 'Children you added, and their records';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get cannotBeUndone => 'This cannot be undone.';

  @override
  String get deleteTypePrefix => 'Type ';

  @override
  String get deleteTypeSuffix => ' to confirm.';

  @override
  String get deleteNotConnected =>
      'Account deletion is not connected yet — please contact Al Islaah Academy to remove your data.';

  @override
  String get deleteMyAccount => 'Delete my account';

  @override
  String get keepMyAccount => 'Keep my account';

  @override
  String get profileSaved => 'Profile saved.';

  @override
  String get profileSaveFailed => 'Could not save profile.';

  @override
  String get signInRequired => 'Sign in required';

  @override
  String get yourProfile => 'Your profile';

  @override
  String get tapCameraToChangePhoto => 'Tap the camera to change your photo';

  @override
  String get nameLabel => 'Name';

  @override
  String get ageLabel => 'Age';

  @override
  String get cityLabel => 'City';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get completeProfileHint =>
      'Complete your profile — your document will be created on save.';

  @override
  String get appearanceSubtitle =>
      'Switch between light and dark to check both — this overrides your device setting.';

  @override
  String get profilePhotosComingSoon =>
      'Profile photos arrive with photo storage — coming soon.';

  @override
  String get profilePhotoTitle => 'Profile photo';

  @override
  String get profilePhotoSubtitle => 'Choose where the picture comes from.';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get openCamera => 'Open the camera';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get pickExistingPicture => 'Pick an existing picture';

  @override
  String get removeCurrentPhoto => 'Remove current photo';

  @override
  String get backToDefaultAvatar => 'Go back to the default avatar';

  @override
  String qazaRecorded(String prayer) {
    return 'Qaza $prayer recorded. May Allah accept it.';
  }

  @override
  String get couldNotSave => 'Could not save.';

  @override
  String get qazaHowTwoKindsTitle => 'Two kinds, one list';

  @override
  String get qazaHowTwoKindsBody =>
      'Prayers you miss while using Jaiza are added for you, with their date. Prayers from before Jaiza are whatever estimate you enter.';

  @override
  String get qazaHowBulughTitle => 'Count from Bulugh';

  @override
  String get qazaHowBulughBody =>
      'Your backlog starts the day you became Islamically accountable — not from birth.';

  @override
  String get qazaHowEstimateTitle => 'An estimate is enough';

  @override
  String get qazaHowEstimateBody =>
      'If you do not remember exactly, enter your most reasonable guess. Islam asks for sincere effort where the exact number is unknown.';

  @override
  String get qazaHowFardTitle => 'Only the five Fard';

  @override
  String get qazaHowFardBody =>
      'Fajr, Zuhr, Asr, Maghrib and Isha. Nawafil are never counted as Qaza.';

  @override
  String get qazaHowTitle => 'How Qaza works in Jaiza';

  @override
  String get gotIt => 'Got it';

  @override
  String get totalQaza => 'Total Qaza';

  @override
  String get trackedByJaiza => 'Tracked by Jaiza';

  @override
  String missedSince(String date) {
    return 'Missed since $date';
  }

  @override
  String get yourEstimate => 'Your estimate';

  @override
  String get beforeInstalledJaiza => 'Before you installed Jaiza';

  @override
  String get addAnEstimate => 'Add an estimate';

  @override
  String get addAnEstimateSubtitle =>
      'Have Qaza from before Jaiza? Add it once.';

  @override
  String qazaLeft(String count) {
    return '$count left';
  }

  @override
  String qazaDoneOfTotal(String done, String total) {
    return '$done of $total done';
  }

  @override
  String get doneForToday => 'Done for today';

  @override
  String get markQazaDone => 'Mark Qaza done';

  @override
  String get qazaEstimateOnlyMissedPrefix =>
      'This is only for the prayers you missed ';

  @override
  String get qazaEstimateBeforeInstalled => 'before you installed Jaiza';

  @override
  String qazaEstimateOnlyMissedSuffix(String date) {
    return ' — $date. Everything after that date is counted for you, so nothing is added twice.';
  }

  @override
  String get qazaEstimateEachIntro =>
      'Enter what you already know. Leave a prayer blank if you are not sure — you can come back and change it any time.';

  @override
  String get qazaEstimateHowEnter => 'How do you want to enter it?';

  @override
  String get qazaEstimateSameForAll => 'Same for all';

  @override
  String get qazaEstimateEachPrayer => 'Each prayer';

  @override
  String get qazaTotalEstimate => 'Total estimate';

  @override
  String get qazaSaveEstimate => 'Save estimate';

  @override
  String get qazaHowLongNotPraying => 'How long were you not praying?';

  @override
  String get qazaBestGuessEnough => 'Your best guess is enough.';

  @override
  String get unitYears => 'Years';

  @override
  String get unitMonths => 'Months';

  @override
  String get unitDays => 'Days';

  @override
  String qazaThatIsAboutDays(String count) {
    return 'That is about $count days';
  }

  @override
  String qazaEach(String count) {
    return '$count each';
  }

  @override
  String get qazaEveryPrayerSame => 'Every prayer gets the same figure';

  @override
  String get qazaHowManyEach => 'How many of each?';

  @override
  String spanYears(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String spanMonths(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String spanDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get qazaEstimateSaved => 'Your estimate is saved';

  @override
  String qazaEstimateSavedBody(String estimate, String tracked) {
    return '$estimate prayers from before Jaiza, plus the $tracked counted since you installed it.';
  }

  @override
  String get qazaSetDailyGoal => 'Set a daily goal';

  @override
  String get qazaSetDailyGoalBody =>
      'How many Qaza will you pray each day? Start small — you can change this whenever you like.';

  @override
  String get aDay => 'a day';

  @override
  String qazaFinishPrefix(int goal) {
    final intl.NumberFormat goalNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String goalString = goalNumberFormat.format(goal);

    return 'At $goalString a day you will finish in about ';
  }

  @override
  String qazaFinishSuffix(String monthYear) {
    return ' — around $monthYear.';
  }

  @override
  String get remindMeDaily => 'Remind me daily';

  @override
  String get remindMeDailySubtitle =>
      'One nudge after Isha if the day\'s Qaza is not done';

  @override
  String get qazaFiveFardOnly => 'Qaza is tracked for the five Fard only.';

  @override
  String qazaIPrayedSome(String prayer) {
    return 'I prayed some Qaza $prayer';
  }

  @override
  String qazaTodayRecorded(String prayer) {
    return 'Today\'s Qaza $prayer is recorded. Come back tomorrow for the next one.';
  }

  @override
  String get markDone => 'Mark done';

  @override
  String trackedByJaizaCount(String count) {
    return 'Tracked by Jaiza · $count';
  }

  @override
  String qazaNoMissedSince(String prayer) {
    return 'No missed $prayer since you started using Jaiza.';
  }

  @override
  String madeUpOn(String date) {
    return 'Made up on $date';
  }

  @override
  String earlierDays(String count) {
    return '+ $count earlier days';
  }

  @override
  String get fromYourEstimate => 'From your estimate';

  @override
  String estimateRemainingNoDate(String count) {
    return '$count remaining · these carry no date';
  }

  @override
  String get qazaCalculateYour => 'CALCULATE YOUR\n';

  @override
  String get qazaPrayersCaps => 'QAZA PRAYERS';

  @override
  String get qazaIntroBody =>
      'Work out the prayers you missed from the time you reached Bulugh (puberty) until today.';

  @override
  String get chooseHowToStart => 'CHOOSE HOW TO START';

  @override
  String get qazaOptionEstimateTitle => 'I will enter my own estimate';

  @override
  String get qazaOptionEstimateBody =>
      'Type how much you missed before Jaiza — the same figure for all five prayers, or each prayer separately.';

  @override
  String get qazaOptionCountTitle => 'Let Jaiza count from today';

  @override
  String get qazaOptionCountBody =>
      'From now on, every prayer you do not mark becomes Qaza by itself, with its date. Nothing to type — and you can still add an estimate later.';

  @override
  String get qazaDashboardWithEstimate =>
      'Everything you still owe, in one place — what Jaiza counted for you since install, plus the backlog you estimated. Tap any prayer to mark some as prayed.';

  @override
  String get qazaDashboardNoEstimate =>
      'Jaiza has been counting missed prayers for you since the day you installed it. If you also have Qaza from before that, add an estimate once and both are kept in one list.';

  @override
  String get dailyGoal => 'Daily goal';

  @override
  String perDay(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString a day';
  }

  @override
  String get qazaPacePrefix => 'At this pace you will finish in about ';

  @override
  String get qazaPaceSuffix => '.';

  @override
  String countDone(String count) {
    return '$count done';
  }

  @override
  String get byPrayer => 'By prayer';

  @override
  String get prayerHistory => 'Prayer history';

  @override
  String selectADate(String date) {
    return 'Select a date ($date)';
  }

  @override
  String statusFor(String date) {
    return 'Status for $date';
  }

  @override
  String couldNotLoad(String error) {
    return 'Could not load. $error';
  }

  @override
  String get todaysFardProgress => 'Today\'s Fard progress';

  @override
  String completedOfTotal(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$doneString / $totalString completed';
  }

  @override
  String windowHint(String start, String end) {
    return 'Window: $start — $end';
  }

  @override
  String get couldNotUpdatePreference => 'Could not update preference.';

  @override
  String get nawafilTrackingIsOff => 'Nawafil tracking is off';

  @override
  String get nawafilTurnOnBody =>
      'Turn it on to tick off your optional prayers each day.';

  @override
  String get turnOnNawafil => 'Turn on Nawafil';

  @override
  String get nawafilTurnOffHint =>
      'To stop tracking Nawafil, turn it off in More → Nawafil.';

  @override
  String get remindersOn => 'Reminders are on';

  @override
  String get remindersOff => 'Reminders are off';

  @override
  String get manage => 'Manage';

  @override
  String get todaysPrayers => 'Today\'s prayers';

  @override
  String get prayerTimesUnavailable => 'Prayer times unavailable';

  @override
  String get reminderStart => 'Start';

  @override
  String get reminderEnd => 'End';

  @override
  String get enterValidLatLon => 'Enter valid latitude and longitude';

  @override
  String get notificationsBlocked =>
      'Notifications blocked — open system settings to enable.';

  @override
  String get couldNotGetLocation =>
      'Could not get location (permission or services off).';

  @override
  String get locationDetected => 'Location detected';

  @override
  String get homeWidgets => 'Home widgets';

  @override
  String get homeWidgetsBody =>
      'Prayer Times (4×2) and Prayer Tracker (4×3) — add them from your launcher. Refresh after changing location or calculation settings.';

  @override
  String get widgetsRefreshed => 'Widgets refreshed';

  @override
  String get refreshWidgetsNow => 'Refresh widgets now';

  @override
  String get locationTitle => 'Location';

  @override
  String get useMyCurrentLocation => 'Use my current location';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get placeLabel => 'Place label';

  @override
  String get saveManualLocation => 'Save manual location';

  @override
  String get detectNow => 'Detect now';

  @override
  String get prayerTimeCalculation => 'Prayer time calculation';

  @override
  String get calcMethodLabel => 'Method';

  @override
  String get madhabLabel => 'Madhab';

  @override
  String get testNotificationIn30 => 'Test notification in 30 seconds';

  @override
  String get debugTestNotification => 'Debug: test notification in 30 s';

  @override
  String get prayerReminders => 'Prayer reminders';

  @override
  String get prayerRemindersBody =>
      'Each prayer is separate — turn on only the ones you want to be reminded about.';

  @override
  String get atStart => 'At start';

  @override
  String minBeforeEnd(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString min before end';
  }

  @override
  String get jamaatAlerts => 'Jama’at alerts';

  @override
  String get newBadge => 'New';

  @override
  String get jamaatAlertsBody =>
      'A reminder before Jama’at at your favourite mosques.';

  @override
  String get jamaatAlertsOn => 'Jama’at alerts on';

  @override
  String get howEarly => 'How early';

  @override
  String minutesCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString minutes';
  }

  @override
  String minCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString min';
  }

  @override
  String get jamaatAlertsNoMosque =>
      'Save a mosque or set a primary one on the Mosques tab to get alerts.';

  @override
  String get primaryBadge => 'Primary';

  @override
  String get classReminders => 'Class reminders';

  @override
  String get classRemindersBody =>
      'A nudge when a prayer window is closing and your class is still unmarked.';

  @override
  String get unmarkedClassAlerts => 'Unmarked class alerts';

  @override
  String distanceMeters(int meters) {
    final intl.NumberFormat metersNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String metersString = metersNumberFormat.format(meters);

    return '$metersString m';
  }

  @override
  String distanceKm(String km) {
    return '$km km';
  }

  @override
  String dotJoin(String a, String b) {
    return '$a · $b';
  }

  @override
  String get mosqueNotFound => 'Mosque not found';

  @override
  String get jamaatTimes => 'Jama’at times';

  @override
  String get timesWrong => 'Times wrong? ';

  @override
  String get reportThanks =>
      'Thanks — the Al Islaah team will check these times.';

  @override
  String get reportThem => 'Report them';

  @override
  String get myPrimaryMosque => 'My primary mosque';

  @override
  String get myPrimaryMosqueSubtitle => 'Its times show on your Today screen';

  @override
  String get inFavourites => 'In favourites';

  @override
  String get alertBeforeJamaat => 'Alert before Jama’at';

  @override
  String minutesBefore(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString minutes before';
  }

  @override
  String get yourMosque => 'Your mosque';

  @override
  String get noPrimaryMosqueYet =>
      'No primary mosque yet. Open any mosque below and turn on “My primary mosque” to see its Jama\'at times on Today.';

  @override
  String get savedSection => 'Saved';

  @override
  String get tapStarToRemove => 'Tap the star to remove';

  @override
  String get nearbySection => 'Nearby';

  @override
  String get tapStarToSave => 'Tap the star to save';

  @override
  String get primaryMosqueTimesNote =>
      'Jama\'at times from this mosque show on your Today screen.';

  @override
  String get linkYourMosque => 'Link Your Mosque';

  @override
  String get linkMosqueBody =>
      'Jama\'at times will show on your Today screen, with a reminder before each prayer.';

  @override
  String get noMosqueFoundRegisterLater =>
      'No mosque found. You can register it later from the Mosques tab.';

  @override
  String get setAsMyMosque => 'Set as my mosque';

  @override
  String resultsCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String noMosqueMatches(String query) {
    return 'No mosque matches “$query”. You can register it above.';
  }

  @override
  String get removeFromSaved => 'Remove from saved';

  @override
  String get saveTooltip => 'Save';

  @override
  String get registerNewMosque => 'Register a new mosque';

  @override
  String get registerNewMosqueSubtitle => 'If yours isn\'t listed yet';

  @override
  String get connImam => 'Imam';

  @override
  String get connCommittee => 'Committee member';

  @override
  String get connMutawalli => 'Mutawalli';

  @override
  String get connCaretaker => 'Caretaker';

  @override
  String get connWorshipper => 'Regular worshipper';

  @override
  String get gpsFailedSamplePin =>
      'Could not read GPS — a sample pin was placed. Tap the map to move it.';

  @override
  String get sampleFileAttached =>
      'Sample file attached — real uploads arrive with the registration backend.';

  @override
  String get mosqueAlreadyRegistered => 'This mosque is already registered';

  @override
  String mosqueSameNameAway(String distance) {
    return 'A registered mosque with the same name sits $distance away.';
  }

  @override
  String get useThisMosque => 'Yes, that’s it — use this one';

  @override
  String get differentMosque => 'No, this is a different mosque';

  @override
  String get differentMosqueNote =>
      'Choosing “different” sends your request to the Al Islaah team. The same mosque cannot be registered twice.';

  @override
  String get stepMosqueDetails => 'Mosque details';

  @override
  String get stepYourDetails => 'Your details';

  @override
  String get stepReview => 'Review';

  @override
  String stepOf(int step, int total) {
    final intl.NumberFormat stepNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String stepString = stepNumberFormat.format(step);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Step $stepString of $totalString';
  }

  @override
  String fieldsStillNeeded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString fields still needed',
      one: '1 field still needed',
    );
    return '$_temp0';
  }

  @override
  String get mosqueNeedsEveryField =>
      'A mosque cannot be registered until every field is filled.';

  @override
  String get everyFieldRequired =>
      'Every field is required. A mosque cannot be registered until all of them are filled — that is what keeps duplicate and fake entries out.';

  @override
  String get sectionIdentity => 'Identity';

  @override
  String get fullMosqueName => 'Full mosque name';

  @override
  String get enterMosqueName => 'Enter the mosque name';

  @override
  String get streetAddress => 'Street address';

  @override
  String get enterStreetAddress => 'Enter the street address';

  @override
  String get cityArea => 'City / area';

  @override
  String get enterCityArea => 'Enter the city or area';

  @override
  String get dropPinOnMap => 'Drop a pin on the map';

  @override
  String get tapGpsOrDrag => 'Tap GPS, or drag the pin to the mosque';

  @override
  String get dragPinHint =>
      'Drag the pin, or tap GPS. An accurate location is what stops duplicate entries.';

  @override
  String get signBoardPhoto => 'Sign board photo';

  @override
  String get addAPhoto => 'Add a photo';

  @override
  String get addAPhotoSubtitle =>
      'One where the mosque’s name is clearly readable';

  @override
  String get jamaatAddedAfterVerify =>
      'Jama’at times are not entered here. The Al Islaah team adds them once the mosque is verified, so the times people see are always confirmed.';

  @override
  String get continueTurnsOn => 'Continue turns on once every field is filled.';

  @override
  String get yourConnection => 'Your connection';

  @override
  String get howConnected => 'How are you connected to this mosque?';

  @override
  String get chooseOne => 'Choose one';

  @override
  String get yourFullName => 'Your full name';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get cnicNumber => 'CNIC number';

  @override
  String get enterAll13Digits => 'Enter all 13 digits';

  @override
  String get phoneCnicPrivacy =>
      'Your phone number and CNIC are used only to verify you. Neither is ever shown in the app, and the Al Islaah team calls the number before approving.';

  @override
  String get proofOfRole => 'Proof of role';

  @override
  String get addADocument => 'Add a document';

  @override
  String get addADocumentSubtitle =>
      'Appointment letter, committee resolution, or CNIC';

  @override
  String get verificationOnly =>
      'For verification only — never shown in the app, and deleted once verified.';

  @override
  String get worshipperCnicNote =>
      'A regular worshipper can upload their CNIC here instead. The mosque is still listed either way — only an Imam or committee member can later edit its Jama’at times.';

  @override
  String get mosqueContact => 'Mosque contact';

  @override
  String get mosquePhoneNumber => 'Mosque phone number';

  @override
  String get enterMosquePhone => 'Enter the mosque phone number';

  @override
  String get auqafOptional => 'Auqaf registration number — optional';

  @override
  String get leaveBlankIfNone => 'Leave blank if none';

  @override
  String get reviewName => 'Name';

  @override
  String get reviewAddress => 'Address';

  @override
  String get reviewLocation => 'Location';

  @override
  String get reviewPhoto => 'Photo';

  @override
  String get reviewMosquePhone => 'Mosque phone';

  @override
  String get reviewConnection => 'Connection';

  @override
  String get reviewPhone => 'Phone';

  @override
  String get reviewCnic => 'CNIC';

  @override
  String get reviewProof => 'Proof';

  @override
  String notShownPublicly(String value) {
    return '$value · not shown publicly';
  }

  @override
  String addressJoin(String street, String city) {
    return '$street, $city';
  }

  @override
  String get confirmInfoCorrect =>
      'I confirm this information is correct and that this mosque really exists.';

  @override
  String get submitForRegistration => 'Submit for registration';

  @override
  String get submittedStepForm => 'Form submitted';

  @override
  String get submittedStepPhone =>
      'Phone verification — a call within 2–3 days';

  @override
  String get submittedStepDocs => 'Photo and documents reviewed';

  @override
  String get submittedStepListed => 'Listed in search once approved';

  @override
  String get requestSubmitted => 'Request submitted';

  @override
  String requestWithTeam(String mosque) {
    return '$mosque’s details are now with the Al Islaah team.';
  }

  @override
  String get notifiedWhenApproved =>
      'You’ll be notified as soon as it’s approved.';

  @override
  String get backToMosques => 'Back to Mosques';

  @override
  String get noPinYet => 'No pin yet';

  @override
  String get gpsButton => 'GPS';

  @override
  String get familyRemindersIntro =>
      'You are nudged only while a prayer can still be prayed — never after the window has closed.';

  @override
  String get notificationNow => 'now';

  @override
  String get previewChildName => 'Bilal';

  @override
  String childHasntMarked(String name, String prayer) {
    return '$name hasn’t marked $prayer';
  }

  @override
  String minutesLeftInWindow(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString minutes left in the window';
  }

  @override
  String get whatAlertLooksLike => 'What the alert looks like';

  @override
  String get whenYouAreAlerted => 'When you are alerted';

  @override
  String get beforeWindowCloses => 'Before a window closes';

  @override
  String get oneNudgePerPrayer => 'One nudge per prayer, per child';

  @override
  String get whichPrayers => 'Which prayers';

  @override
  String get whichPrayersBody =>
      'Turn off the ones your children pray at the madrasa — you won’t be nudged about those.';

  @override
  String get eveningSummary => 'Evening summary';

  @override
  String get eveningSummarySubtitle =>
      'One message after Isha with everyone’s day';

  @override
  String get summaryTime => 'Summary time';

  @override
  String get keepingItQuiet => 'Keeping it quiet';

  @override
  String get quietHours => 'Quiet hours';

  @override
  String get quietHoursSubtitle =>
      'No alerts 8:00 AM – 2:00 PM and after 10:00 PM';

  @override
  String get dailyLimit => 'Daily limit';

  @override
  String get dailyLimitSubtitle =>
      'Extra nudges are rolled into the evening summary';

  @override
  String get childrenMuteBody =>
      'Turn a child off to stop every alert about them.';

  @override
  String get addChildToSetUp => 'Add a child to set this up.';

  @override
  String ageYears(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String get streakBreakAlert => 'Tell me when a streak breaks';

  @override
  String get onceADayAtMost => 'Once a day at most';

  @override
  String get ownRemindersHint =>
      'Your own prayer reminders are under More → Notifications & widgets.';

  @override
  String get addAChild => 'Add a child';

  @override
  String get noChildrenYet => 'No children added yet';

  @override
  String get noChildrenYetBody => 'Add a child to mark and track their Salah.';

  @override
  String get barToday => 'Today';

  @override
  String get barWeek => 'Week';

  @override
  String get streakLabel => 'Streak';

  @override
  String get qazaToMakeUp => 'Qaza to make up';

  @override
  String get none => 'None';

  @override
  String get me => 'Me';

  @override
  String childAdded(String name) {
    return '$name added.';
  }

  @override
  String get couldNotAddChild => 'Could not add child.';

  @override
  String get addChildBody =>
      'A child gets no account of their own — you mark their prayers.';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderBoy => 'Boy';

  @override
  String get genderGirl => 'Girl';

  @override
  String get childQazaIntro =>
      'Jaiza counts this child\'s missed prayers from the day they were added. Mark each Qaza as it is made up.';

  @override
  String studentsAdded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString students added.',
      one: '1 student added.',
    );
    return '$_temp0';
  }

  @override
  String get couldNotAddStudents => 'Could not add students.';

  @override
  String get oneByOne => 'One by one';

  @override
  String get pasteAList => 'Paste a list';

  @override
  String get studentNameLabel => 'Student\'s name';

  @override
  String get addStudent => 'Add student';

  @override
  String get pasteListNote =>
      'One name per line. Thirty students take about a minute this way instead of thirty separate forms.';

  @override
  String get namesSection => 'Names';

  @override
  String namesFound(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString names found',
      one: '1 name found',
    );
    return '$_temp0';
  }

  @override
  String addNStudents(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $countString students',
      one: 'Add 1 student',
    );
    return '$_temp0';
  }

  @override
  String get removeFromOrgTitle => 'Remove from organization?';

  @override
  String removeFromOrgBody(String name) {
    return '$name will lose access to this organization\'s classes and students. Their classes stay; you can reassign them.';
  }

  @override
  String get organizationNotFound => 'Organization not found.';

  @override
  String get teacherNotFound => 'Teacher not found.';

  @override
  String emailJoined(String email, String date) {
    return '$email · joined $date';
  }

  @override
  String get readOnlyTeacherNote =>
      'Read-only. Marking attendance stays with the teacher.';

  @override
  String get teacherNoClasses => 'This teacher has no classes yet.';

  @override
  String studentsCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString students',
      one: '1 student',
    );
    return '$_temp0';
  }

  @override
  String percent(int value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString%';
  }

  @override
  String get removeFromOrg => 'Remove from organization';

  @override
  String get removeFromOrgSubtitle =>
      'Their classes stay; you can reassign them';

  @override
  String get notAttachedToOrg => 'Not attached to an organization yet.';

  @override
  String get classReport => 'Class report';

  @override
  String slashTotal(int total) {
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return ' / $totalString';
  }

  @override
  String get markAllPresent => 'Mark all present';

  @override
  String get unmarkedFilter => 'Unmarked';

  @override
  String get noStudentsAddBelow => 'No students yet. Add some below.';

  @override
  String get savedAsYouTap => 'Saved as you tap — there is no submit button.';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get classAverage => 'Class average';

  @override
  String classReportSummary(
    String students,
    String month,
    int done,
    int possible,
  ) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat possibleNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String possibleString = possibleNumberFormat.format(possible);

    return '$students · $month · $doneString of $possibleString prayers';
  }

  @override
  String get byStudent => 'By student';

  @override
  String get noStudentsYet => 'No students yet.';

  @override
  String get sharingComingSoon =>
      'Sharing arrives with the reports backend — for now, tell families the numbers directly.';

  @override
  String get shareReport => 'Share report';

  @override
  String get pdfComingSoon => 'PDF export is coming soon.';

  @override
  String get pdfButton => 'PDF';

  @override
  String get statTeachers => 'Teachers';

  @override
  String get statStudents => 'Students';

  @override
  String get todayAcrossMadrasa => 'Today across the madrasa';

  @override
  String get inviteTeacher => 'Invite teacher';

  @override
  String get noTeachersYet => 'No teachers yet — invite one above.';

  @override
  String get allClasses => 'All classes';

  @override
  String get unassigned => 'Unassigned';

  @override
  String classesStudents(String classes, String students) {
    return '$classes · $students';
  }

  @override
  String classesCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString classes',
      one: '1 class',
    );
    return '$_temp0';
  }

  @override
  String get accessRemoved =>
      'Your access to this organization has been removed.';

  @override
  String get residentialStudentsNote =>
      'Residential students — all five prayers are marked here.';

  @override
  String get newClass => 'New class';

  @override
  String get noClassesCreateOne => 'No classes yet — create one above.';

  @override
  String inviteSent(String email) {
    return 'Invite sent. They\'ll get teacher access when they sign up or log in with $email.';
  }

  @override
  String get couldNotSendInvite => 'Could not send invite.';

  @override
  String get inviteATeacher => 'Invite a teacher';

  @override
  String get inviteTeacherBody =>
      'They get teacher access the moment they sign up or log in with this email.';

  @override
  String get teacherEmailHint => 'teacher@example.com';

  @override
  String get teacherPermissionsNote =>
      'A teacher can create classes, add students and mark attendance. They cannot invite other teachers or see classes that are not theirs.';

  @override
  String get sendInvite => 'Send invite';

  @override
  String get enterClassName => 'Enter a class name';

  @override
  String get couldNotCreateClass => 'Could not create the class.';

  @override
  String get newClassBody =>
      'Students living at the madrasa — all five prayers are marked for them.';

  @override
  String get classNameLabel => 'Class name';

  @override
  String get classNameHint => 'e.g. Batch C';

  @override
  String get sectionOptional => 'Section — optional';

  @override
  String get sectionHint => 'e.g. Dars-e-Nizami year 1';

  @override
  String get createClass => 'Create class';

  @override
  String get addedRecently => 'Added recently';

  @override
  String addedOn(String date) {
    return 'Added $date';
  }

  @override
  String doneSlashTotalSpaced(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$doneString / $totalString';
  }

  @override
  String pctOnTimeComplete(int pct, String days) {
    final intl.NumberFormat pctNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String pctString = pctNumberFormat.format(pct);

    return '$pctString% on time · $days';
  }

  @override
  String completeDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString complete days',
      one: '1 complete day',
    );
    return '$_temp0';
  }

  @override
  String get fullHistory => 'Full history';

  @override
  String nameFullHistory(String name) {
    return '$name — full history';
  }

  @override
  String get noPrayersLoggedYet => 'No prayers logged yet.';

  @override
  String qazaCompletedCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString completed';
  }

  @override
  String monthSummary(String month) {
    return '$month summary';
  }

  @override
  String pctPrayedComplete(int pct, String days) {
    final intl.NumberFormat pctNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String pctString = pctNumberFormat.format(pct);

    return '$pctString% prayed · $days';
  }

  @override
  String get teacherAlreadyActive => 'This person is already a teacher here.';

  @override
  String get anOrganization => 'an organization';

  @override
  String get studentNamesHint => 'Abdullah Khan\nIbrahim Siddiqui\nYusuf Malik';

  @override
  String get updateRequiredTitle => 'Update Jaiza';

  @override
  String get updateRequiredBody =>
      'This version of Jaiza is no longer supported. Please update to continue.';

  @override
  String get updateRequiredButton => 'Update now';
}
