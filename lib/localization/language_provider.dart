import 'package:flutter/material.dart';
import '../../services/user_settings_service.dart';

class LanguageProvider extends ChangeNotifier {
  LanguageProvider() {
    _locale = null;
  }

  Locale? _locale;

  Locale? get locale => _locale;

  bool get isSystem => _locale == null;
  bool get isEnglish => _locale?.languageCode == 'en';
  bool get isFrench => _locale?.languageCode == 'fr';
  bool get isArabic => _locale?.languageCode == 'ar';

  // Load language from Firestore
  Future<void> loadUserLanguage(String? language) async {
    switch (language) {
      case 'en':
        _locale = const Locale('en');
        break;

      case 'fr':
        _locale = const Locale('fr');
        break;

      case 'ar':
        _locale = const Locale('ar');
        break;

      case 'system':
      default:
        _locale = null;
        break;
    }

    notifyListeners();
  }

  // Save language to Firestore + update app
  Future<void> setLanguage(String languageCode) async {
    switch (languageCode) {
      case 'en':
        _locale = const Locale('en');
        break;

      case 'fr':
        _locale = const Locale('fr');
        break;

      case 'ar':
        _locale = const Locale('ar');
        break;

      case 'system':
      default:
        _locale = null;
        languageCode = 'system';
        break;
    }

    await UserSettingsService.saveLanguage(languageCode);

    notifyListeners();
  }

  Future<void> setSystemLanguage() async {
    await setLanguage('system');
  }

  Future<void> setEnglish() async {
    await setLanguage('en');
  }

  Future<void> setFrench() async {
    await setLanguage('fr');
  }

  Future<void> setArabic() async {
    await setLanguage('ar');
  }
}
