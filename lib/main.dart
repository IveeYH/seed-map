import 'package:flutter/material.dart';
import 'features/worlds/presentation/worlds_screen.dart';
import 'features/settings/theme_manager.dart';
import 'features/settings/language_manager.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:minecraft_seedwalker_mobile/l10n/app_localizations.dart';

late final ThemeManager themeManager;
late final LanguageManager languageManager;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  themeManager = ThemeManager();
  languageManager = LanguageManager();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('packages/cubiomes_ffi/LICENSE');
    yield LicenseEntryWithLineBreaks(['cubiomes'], license);
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeManager, languageManager]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Seed Map',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
          ],
          locale: languageManager.locale,
          theme: themeManager.lightTheme,
          darkTheme: themeManager.darkTheme,
          themeMode: themeManager.themeMode,
          home: const WorldsScreen(),
        );
      },
    );
  }
}
