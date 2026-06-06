import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Seed Map'**
  String get appTitle;

  /// No description provided for @worldsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Worlds'**
  String get worldsScreenTitle;

  /// No description provided for @worldsScreenNewWorld.
  ///
  /// In en, this message translates to:
  /// **'NEW WORLD'**
  String get worldsScreenNewWorld;

  /// No description provided for @worldsScreenToggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle Theme'**
  String get worldsScreenToggleTheme;

  /// No description provided for @worldsScreenViewTutorial.
  ///
  /// In en, this message translates to:
  /// **'View Tutorial'**
  String get worldsScreenViewTutorial;

  /// No description provided for @worldsScreenSeedCopied.
  ///
  /// In en, this message translates to:
  /// **'Seed copied to clipboard'**
  String get worldsScreenSeedCopied;

  /// No description provided for @worldsScreenEditSettings.
  ///
  /// In en, this message translates to:
  /// **'Edit settings'**
  String get worldsScreenEditSettings;

  /// No description provided for @worldSettingsTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New World'**
  String get worldSettingsTitleNew;

  /// No description provided for @worldSettingsTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'World Settings'**
  String get worldSettingsTitleEdit;

  /// No description provided for @selectDimension.
  ///
  /// In en, this message translates to:
  /// **'Select Dimension'**
  String get selectDimension;

  /// No description provided for @dimensionOverworld.
  ///
  /// In en, this message translates to:
  /// **'Overworld'**
  String get dimensionOverworld;

  /// No description provided for @dimensionNether.
  ///
  /// In en, this message translates to:
  /// **'Nether'**
  String get dimensionNether;

  /// No description provided for @dimensionEnd.
  ///
  /// In en, this message translates to:
  /// **'The End'**
  String get dimensionEnd;

  /// No description provided for @worldSettingsName.
  ///
  /// In en, this message translates to:
  /// **'World Name'**
  String get worldSettingsName;

  /// No description provided for @worldSettingsSeed.
  ///
  /// In en, this message translates to:
  /// **'Seed (leave empty for random)'**
  String get worldSettingsSeed;

  /// No description provided for @worldSettingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Generation Version'**
  String get worldSettingsVersion;

  /// No description provided for @worldSettingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get worldSettingsCancel;

  /// No description provided for @worldSettingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get worldSettingsSave;

  /// No description provided for @worldSettingsCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get worldSettingsCreate;

  /// No description provided for @mapScreenWaypointList.
  ///
  /// In en, this message translates to:
  /// **'Waypoints List'**
  String get mapScreenWaypointList;

  /// No description provided for @mapScreenWorldSettings.
  ///
  /// In en, this message translates to:
  /// **'World Settings'**
  String get mapScreenWorldSettings;

  /// No description provided for @mapScreenCenterSpawn.
  ///
  /// In en, this message translates to:
  /// **'Center on Spawn'**
  String get mapScreenCenterSpawn;

  /// No description provided for @mapScreenAddWaypoint.
  ///
  /// In en, this message translates to:
  /// **'Add Waypoint'**
  String get mapScreenAddWaypoint;

  /// No description provided for @mapScreenSeedCopied.
  ///
  /// In en, this message translates to:
  /// **'Seed copied to clipboard'**
  String get mapScreenSeedCopied;

  /// No description provided for @mapScreenNoWaypoints.
  ///
  /// In en, this message translates to:
  /// **'You have no waypoints in this world. Use the green map button to add one.'**
  String get mapScreenNoWaypoints;

  /// No description provided for @mapScreenCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get mapScreenCancel;

  /// No description provided for @mapScreenSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get mapScreenSave;

  /// No description provided for @mapScreenWaypointName.
  ///
  /// In en, this message translates to:
  /// **'Waypoint Name'**
  String get mapScreenWaypointName;

  /// No description provided for @mapScreenDeleteWaypoint.
  ///
  /// In en, this message translates to:
  /// **'Delete Waypoint'**
  String get mapScreenDeleteWaypoint;

  /// No description provided for @mapScreenFilterWaypoints.
  ///
  /// In en, this message translates to:
  /// **'Waypoints'**
  String get mapScreenFilterWaypoints;

  /// No description provided for @mapScreenFilterSpawn.
  ///
  /// In en, this message translates to:
  /// **'Spawn'**
  String get mapScreenFilterSpawn;

  /// No description provided for @tutorialWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get tutorialWelcome;

  /// No description provided for @tutorialWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Seed Map lets you preview your world, biomes and structures in real time.'**
  String get tutorialWelcomeDesc;

  /// No description provided for @tutorialDimensions.
  ///
  /// In en, this message translates to:
  /// **'Three Dimensions'**
  String get tutorialDimensions;

  /// No description provided for @tutorialDimensionsDesc.
  ///
  /// In en, this message translates to:
  /// **'From the main menu you can choose to explore the Overworld, the Nether or the End with a single tap.'**
  String get tutorialDimensionsDesc;

  /// No description provided for @tutorialNavigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get tutorialNavigation;

  /// No description provided for @tutorialNavigationDesc.
  ///
  /// In en, this message translates to:
  /// **'Drag to move the map and use two fingers to zoom. Tap on structures to see what they are.'**
  String get tutorialNavigationDesc;

  /// No description provided for @tutorialVersions.
  ///
  /// In en, this message translates to:
  /// **'Infinite Versions'**
  String get tutorialVersions;

  /// No description provided for @tutorialVersionsDesc.
  ///
  /// In en, this message translates to:
  /// **'You can change the generation version in the world settings at any time.'**
  String get tutorialVersionsDesc;

  /// No description provided for @tutorialSkip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get tutorialSkip;

  /// No description provided for @tutorialNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get tutorialNext;

  /// No description provided for @tutorialStart.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get tutorialStart;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @mapScreenStructure.
  ///
  /// In en, this message translates to:
  /// **'Structure'**
  String get mapScreenStructure;

  /// No description provided for @mapScreenWaypoint.
  ///
  /// In en, this message translates to:
  /// **'Waypoint'**
  String get mapScreenWaypoint;

  /// No description provided for @mapScreenSpawn.
  ///
  /// In en, this message translates to:
  /// **'Spawn Point'**
  String get mapScreenSpawn;

  /// No description provided for @mapSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Map Settings'**
  String get mapSettingsTitle;

  /// No description provided for @mapSettingsDimension.
  ///
  /// In en, this message translates to:
  /// **'Dimension'**
  String get mapSettingsDimension;

  /// No description provided for @mapSettingsBiomeHeight.
  ///
  /// In en, this message translates to:
  /// **'Biome Height'**
  String get mapSettingsBiomeHeight;

  /// No description provided for @mapSettingsSurface.
  ///
  /// In en, this message translates to:
  /// **'Surface (Y=320)'**
  String get mapSettingsSurface;

  /// No description provided for @mapSettingsUnderground.
  ///
  /// In en, this message translates to:
  /// **'Underground (Y=0)'**
  String get mapSettingsUnderground;

  /// No description provided for @mapSettingsBottom.
  ///
  /// In en, this message translates to:
  /// **'Bottom (Y=-51)'**
  String get mapSettingsBottom;

  /// No description provided for @mapSettingsStructures.
  ///
  /// In en, this message translates to:
  /// **'Structures'**
  String get mapSettingsStructures;

  /// No description provided for @mapSettingsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get mapSettingsAll;

  /// No description provided for @mapSettingsNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get mapSettingsNone;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance & Localization'**
  String get settingsAppearance;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal & Information'**
  String get settingsLegal;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsUnofficial.
  ///
  /// In en, this message translates to:
  /// **'COMPATIBLE UTILITY'**
  String get settingsUnofficial;

  /// No description provided for @settingsUnofficialDesc.
  ///
  /// In en, this message translates to:
  /// **'This is an independent utility compatible with block-building sandbox games. It is not affiliated with or endorsed by the developers of any official game.'**
  String get settingsUnofficialDesc;

  /// No description provided for @mapScreenWaypointFrom.
  ///
  /// In en, this message translates to:
  /// **'From: '**
  String get mapScreenWaypointFrom;
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
      <String>['en', 'es'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
