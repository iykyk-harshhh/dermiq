import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';

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
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
  ];

  /// The application name.
  ///
  /// In en, this message translates to:
  /// **'DermIQ'**
  String get appName;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @privacyAndData.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data'**
  String get privacyAndData;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @themeAndAppearance.
  ///
  /// In en, this message translates to:
  /// **'Theme & Appearance'**
  String get themeAndAppearance;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @aboutDermIQ.
  ///
  /// In en, this message translates to:
  /// **'About DermIQ'**
  String get aboutDermIQ;

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

  /// No description provided for @sectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get sectionSupport;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @skinProfile.
  ///
  /// In en, this message translates to:
  /// **'Skin Profile'**
  String get skinProfile;

  /// No description provided for @hairProfile.
  ///
  /// In en, this message translates to:
  /// **'Hair Profile'**
  String get hairProfile;

  /// No description provided for @myAppointments.
  ///
  /// In en, this message translates to:
  /// **'My Appointments'**
  String get myAppointments;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in anytime.'**
  String get signOutConfirmMessage;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navRoutine.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get navRoutine;

  /// No description provided for @navShelf.
  ///
  /// In en, this message translates to:
  /// **'Shelf'**
  String get navShelf;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @preferencesIntro.
  ///
  /// In en, this message translates to:
  /// **'Personalize how DermIQ reminds, alerts and measures things for you.'**
  String get preferencesIntro;

  /// No description provided for @routineReminders.
  ///
  /// In en, this message translates to:
  /// **'Routine Reminders'**
  String get routineReminders;

  /// No description provided for @amRoutine.
  ///
  /// In en, this message translates to:
  /// **'AM Routine'**
  String get amRoutine;

  /// No description provided for @amRoutineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Morning nudge at 7:00 AM'**
  String get amRoutineSubtitle;

  /// No description provided for @pmRoutine.
  ///
  /// In en, this message translates to:
  /// **'PM Routine'**
  String get pmRoutine;

  /// No description provided for @pmRoutineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Evening nudge at 9:30 PM'**
  String get pmRoutineSubtitle;

  /// No description provided for @skinCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Skin Check-In'**
  String get skinCheckIn;

  /// No description provided for @skinCheckInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily mood & skin rating'**
  String get skinCheckInSubtitle;

  /// No description provided for @productExpiryAlerts.
  ///
  /// In en, this message translates to:
  /// **'Product Expiry Alerts'**
  String get productExpiryAlerts;

  /// No description provided for @productExpiryAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Warn me before products expire'**
  String get productExpiryAlertsSubtitle;

  /// No description provided for @weeklyScoreUpdates.
  ///
  /// In en, this message translates to:
  /// **'Weekly Score Updates'**
  String get weeklyScoreUpdates;

  /// No description provided for @weeklyScoreUpdatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your skin score summary'**
  String get weeklyScoreUpdatesSubtitle;

  /// No description provided for @tipsAndArticles.
  ///
  /// In en, this message translates to:
  /// **'Tips & Articles'**
  String get tipsAndArticles;

  /// No description provided for @tipsAndArticlesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Skincare reads picked for you'**
  String get tipsAndArticlesSubtitle;

  /// No description provided for @appointmentReminders.
  ///
  /// In en, this message translates to:
  /// **'Appointment Reminders'**
  String get appointmentReminders;

  /// No description provided for @appointmentRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Before specialist consultations'**
  String get appointmentRemindersSubtitle;

  /// No description provided for @unitsAndRegion.
  ///
  /// In en, this message translates to:
  /// **'Units & Region'**
  String get unitsAndRegion;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @volumeUnits.
  ///
  /// In en, this message translates to:
  /// **'Volume Units'**
  String get volumeUnits;

  /// No description provided for @firstDayOfWeek.
  ///
  /// In en, this message translates to:
  /// **'First Day of Week'**
  String get firstDayOfWeek;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @moreSettings.
  ///
  /// In en, this message translates to:
  /// **'More Settings'**
  String get moreSettings;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @preferencesSavedAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Preferences are saved automatically'**
  String get preferencesSavedAutomatically;

  /// No description provided for @privacyBanner.
  ///
  /// In en, this message translates to:
  /// **'Your skin photos and health data are encrypted and never sold.'**
  String get privacyBanner;

  /// No description provided for @dataUsage.
  ///
  /// In en, this message translates to:
  /// **'Data Usage'**
  String get dataUsage;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @analyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us improve the app'**
  String get analyticsSubtitle;

  /// No description provided for @personalization.
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get personalization;

  /// No description provided for @personalizationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use my data for recommendations'**
  String get personalizationSubtitle;

  /// No description provided for @shareWithPartners.
  ///
  /// In en, this message translates to:
  /// **'Share with Partners'**
  String get shareWithPartners;

  /// No description provided for @shareWithPartnersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Anonymized data for research'**
  String get shareWithPartnersSubtitle;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @biometricLock.
  ///
  /// In en, this message translates to:
  /// **'Biometric Lock'**
  String get biometricLock;

  /// No description provided for @biometricLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require Face/Touch ID to open'**
  String get biometricLockSubtitle;

  /// No description provided for @yourData.
  ///
  /// In en, this message translates to:
  /// **'Your Data'**
  String get yourData;

  /// No description provided for @downloadMyData.
  ///
  /// In en, this message translates to:
  /// **'Download My Data'**
  String get downloadMyData;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteMyAccount;

  /// No description provided for @policies.
  ///
  /// In en, this message translates to:
  /// **'Policies'**
  String get policies;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
