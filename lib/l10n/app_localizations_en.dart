// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Minecraft Waypoints';

  @override
  String get worldsScreenTitle => 'Your Worlds';

  @override
  String get worldsScreenNewWorld => 'NEW WORLD';

  @override
  String get worldsScreenToggleTheme => 'Toggle Theme';

  @override
  String get worldsScreenViewTutorial => 'View Tutorial';

  @override
  String get worldsScreenSeedCopied => 'Seed copied to clipboard';

  @override
  String get worldsScreenEditSettings => 'Edit settings';

  @override
  String get worldSettingsTitleNew => 'New World';

  @override
  String get worldSettingsTitleEdit => 'World Settings';

  @override
  String get selectDimension => 'Select Dimension';

  @override
  String get dimensionOverworld => 'Overworld';

  @override
  String get dimensionNether => 'Nether';

  @override
  String get dimensionEnd => 'The End';

  @override
  String get worldSettingsName => 'World Name';

  @override
  String get worldSettingsSeed => 'Seed (leave empty for random)';

  @override
  String get worldSettingsVersion => 'Minecraft Version';

  @override
  String get worldSettingsCancel => 'Cancel';

  @override
  String get worldSettingsSave => 'Save';

  @override
  String get worldSettingsCreate => 'Create';

  @override
  String get mapScreenWaypointList => 'Waypoints List';

  @override
  String get mapScreenWorldSettings => 'World Settings';

  @override
  String get mapScreenCenterSpawn => 'Center on Spawn';

  @override
  String get mapScreenAddWaypoint => 'Add Waypoint';

  @override
  String get mapScreenSeedCopied => 'Seed copied to clipboard';

  @override
  String get mapScreenNoWaypoints =>
      'You have no waypoints in this world. Use the green map button to add one.';

  @override
  String get mapScreenCancel => 'Cancel';

  @override
  String get mapScreenSave => 'Save';

  @override
  String get mapScreenWaypointName => 'Waypoint Name';

  @override
  String get mapScreenDeleteWaypoint => 'Delete Waypoint';

  @override
  String get mapScreenFilterWaypoints => 'Waypoints';

  @override
  String get mapScreenFilterSpawn => 'Spawn';

  @override
  String get tutorialWelcome => 'Welcome!';

  @override
  String get tutorialWelcomeDesc =>
      'Minecraft Waypoints lets you preview your world, biomes and structures in real time.';

  @override
  String get tutorialDimensions => 'Three Dimensions';

  @override
  String get tutorialDimensionsDesc =>
      'From the main menu you can choose to explore the Overworld, the Nether or the End with a single tap.';

  @override
  String get tutorialNavigation => 'Navigation';

  @override
  String get tutorialNavigationDesc =>
      'Drag to move the map and use two fingers to zoom. Tap on structures to see what they are.';

  @override
  String get tutorialVersions => 'Infinite Versions';

  @override
  String get tutorialVersionsDesc =>
      'You can change the generation version in the world settings at any time.';

  @override
  String get tutorialSkip => 'SKIP';

  @override
  String get tutorialNext => 'NEXT';

  @override
  String get tutorialStart => 'START';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System Default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get mapScreenStructure => 'Structure';

  @override
  String get mapScreenWaypoint => 'Waypoint';

  @override
  String get mapScreenSpawn => 'Spawn Point';

  @override
  String get mapSettingsTitle => 'Map Settings';

  @override
  String get mapSettingsDimension => 'Dimension';

  @override
  String get mapSettingsBiomeHeight => 'Biome Height';

  @override
  String get mapSettingsSurface => 'Surface (Y=320)';

  @override
  String get mapSettingsUnderground => 'Underground (Y=0)';

  @override
  String get mapSettingsBottom => 'Bottom (Y=-51)';

  @override
  String get mapSettingsStructures => 'Structures';

  @override
  String get mapSettingsAll => 'All';

  @override
  String get mapSettingsNone => 'None';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance & Localization';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsLegal => 'Legal & Information';

  @override
  String get settingsPrivacy => 'Privacy Policy';

  @override
  String get settingsUnofficial => 'UNOFFICIAL APPLICATION';

  @override
  String get settingsUnofficialDesc =>
      'This is an unofficial application for Minecraft. This application is not affiliated in any way with Mojang AB. The Minecraft Name, the Minecraft Brand and the Minecraft Assets are all property of Mojang AB or their respectful owner.';

  @override
  String get mapScreenWaypointFrom => 'From: ';
}
