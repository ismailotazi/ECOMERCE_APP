import 'package:flutter/material.dart';
import '../../services/user_settings_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _themeMode = ThemeMode.system;
  }

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isLight => _themeMode == ThemeMode.light;
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get isSystem => _themeMode == ThemeMode.system;

  // Load theme from Firestore
  Future<void> loadUserTheme(String? theme) async {
    switch (theme) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;

      case 'dark':
        _themeMode = ThemeMode.dark;
        break;

      case 'system':
      default:
        _themeMode = ThemeMode.system;
        break;
    }

    notifyListeners();
  }

  // Save theme to Firestore + update app
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;

    String theme;

    switch (mode) {
      case ThemeMode.light:
        theme = 'light';
        break;

      case ThemeMode.dark:
        theme = 'dark';
        break;

      case ThemeMode.system:
        theme = 'system';
        break;
    }

    await UserSettingsService.saveTheme(theme);

    notifyListeners();
  }

  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setLightTheme();
    } else {
      await setDarkTheme();
    }
  }
}
