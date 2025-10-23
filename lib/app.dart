import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/localization/app_localizations.dart';
import 'core/navigation/route_transitions.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'features/home/home_page.dart';
import 'features/quiz/quiz_page.dart';
import 'features/chat/chat_page.dart';
import 'features/results/results_page.dart';
import 'features/settings/settings_page.dart';

class AiTutorApp extends ConsumerWidget {
  const AiTutorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'AI Tutor',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('te'),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case QuizPage.routeName:
            return buildFadeRoute(const QuizPage(), settings);
          case ChatPage.routeName:
            return buildFadeRoute(const ChatPage(), settings);
          case ResultsPage.routeName:
            return buildFadeRoute(const ResultsPage(), settings);
          case SettingsPage.routeName:
            return buildFadeRoute(const SettingsPage(), settings);
          case HomePage.routeName:
          default:
            return buildFadeRoute(const HomePage(), settings);
        }
      },
      initialRoute: HomePage.routeName,
    );
  }
}
