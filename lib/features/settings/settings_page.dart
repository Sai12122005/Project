import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  static const routeName = '/settings';

  Future<void> _resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('answers');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.t('settings'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.t('theme'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
              ],
              selected: {themeMode == ThemeMode.dark ? ThemeMode.dark : ThemeMode.light},
              onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).setThemeMode(s.first),
            ),
            const SizedBox(height: 24),
            Text(t.t('language'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButton<Locale>(
              value: locale,
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('hi'), child: Text('हिंदी')),
                DropdownMenuItem(value: Locale('te'), child: Text('తెలుగు')),
              ],
              onChanged: (loc) {
                if (loc != null) ref.read(localeProvider.notifier).setLocale(loc);
              },
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: _resetProgress,
                icon: const Icon(Icons.refresh),
                label: Text(t.t('resetProgress')),
              ),
            )
          ],
        ),
      ),
    );
  }
}
