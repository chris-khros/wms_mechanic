import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  static const String _localeKey = 'app_locale';
  
  Locale _locale = const Locale('en', 'US');
  
  Locale get locale => _locale;
  
  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('ms', 'MY'), // Malay
    Locale('zh', 'CN'), // Chinese (Simplified)
  ];
  
  // Language names for display
  static const Map<String, String> languageNames = {
    'en': 'English',
    'ms': 'Bahasa Melayu',
    'zh': '中文',
  };
  
  LocaleProvider() {
    _loadLocale();
  }
  
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey) ?? 'en';
      _locale = Locale(localeCode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading locale: $e');
    }
  }
  
  Future<void> setLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      _locale = locale;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }
  
  String get currentLanguageName => languageNames[_locale.languageCode] ?? 'English';
}
