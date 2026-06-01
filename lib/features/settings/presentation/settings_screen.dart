import 'package:flutter/material.dart';
import '../theme_manager.dart';
import '../language_manager.dart';
import 'package:minecraft_seedwalker_mobile/main.dart'; // To access themeManager and languageManager
import 'privacy_policy_screen.dart';
import 'package:minecraft_seedwalker_mobile/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildAppearanceSection(context, l10n),
          const Divider(),
          _buildLegalSection(context, l10n),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsAppearance,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ListenableBuilder(
            listenable: themeManager,
            builder: (context, _) {
              return SwitchListTile(
                title: Text(l10n.settingsDarkMode),
                value: themeManager.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeManager.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                },
              );
            },
          ),
          const SizedBox(height: 8),
          ListenableBuilder(
            listenable: languageManager,
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: l10n.language,
                    border: const OutlineInputBorder(),
                  ),
                  value: languageManager.locale?.languageCode ?? 'en',
                  items: [
                    DropdownMenuItem(value: 'en', child: Text(l10n.languageEnglish)),
                    DropdownMenuItem(value: 'es', child: Text(l10n.languageSpanish)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      languageManager.setLocale(Locale(value));
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsLegal,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.settingsPrivacy),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildDisclaimerCard(context, l10n),
        ],
      ),
    );
  }

  Widget _buildDisclaimerCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  l10n.settingsUnofficial,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.settingsUnofficialDesc,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
