import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'AI Tutor',
      'startQuiz': 'Start Quiz',
      'aiTutorChat': 'AI Tutor Chat',
      'results': 'Results',
      'settings': 'Settings',
      'next': 'Next',
      'previous': 'Previous',
      'yourScore': 'Your Score',
      'resetProgress': 'Reset Quiz Progress',
      'theme': 'Theme',
      'dark': 'Dark',
      'light': 'Light',
      'language': 'Language',
      'english': 'English',
      'hindi': 'Hindi',
      'telugu': 'Telugu',
      'askAnything': 'Ask anything...'
    },
    'hi': {
      'appName': 'एआई ट्यूटर',
      'startQuiz': 'क्विज़ शुरू करें',
      'aiTutorChat': 'एआई ट्यूटर चैट',
      'results': 'परिणाम',
      'settings': 'सेटिंग्स',
      'next': 'आगे',
      'previous': 'पीछे',
      'yourScore': 'आपका स्कोर',
      'resetProgress': 'क्विज़ प्रगति रीसेट करें',
      'theme': 'थीम',
      'dark': 'डार्क',
      'light': 'लाइट',
      'language': 'भाषा',
      'english': 'अंग्रेज़ी',
      'hindi': 'हिंदी',
      'telugu': 'तेलुगु',
      'askAnything': 'कुछ भी पूछें...'
    },
    'te': {
      'appName': 'ఏఐ ట్యూటర్',
      'startQuiz': 'క్విజ్ ప్రారంభించండి',
      'aiTutorChat': 'ఏఐ ట్యూటర్ చాట్',
      'results': 'ఫలితాలు',
      'settings': 'సెట్టింగ్స్',
      'next': 'తర్వాత',
      'previous': 'మునుపటి',
      'yourScore': 'మీ స్కోర్',
      'resetProgress': 'క్విజ్ పురోగతిని రీసెట్ చేయండి',
      'theme': 'థీమ్',
      'dark': 'డార్క్',
      'light': 'లైట్',
      'language': 'భాష',
      'english': 'ఇంగ్లీష్',
      'hindi': 'హింది',
      'telugu': 'తెలుగు',
      'askAnything': 'ఏదైనా అడగండి...'
    }
  };

  String t(String key) {
    final lang = locale.languageCode;
    return _localizedValues[lang]?[key] ?? _localizedValues['en']![key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
