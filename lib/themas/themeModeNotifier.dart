// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeNotifier with ChangeNotifier {
  ThemeMode _themeMode;
  String _customTheme;

  ThemeModeNotifier(this._themeMode) : _customTheme = 'default' {
    _loadThemePreference();
  }

  // Cargar preferencias guardadas
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode');
    final customTheme = prefs.getString('customTheme');

    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    }
    if (customTheme != null) {
      _customTheme = customTheme;
    }
    notifyListeners();
  }

  ThemeMode getThemeMode() => _themeMode;
  String getCustomTheme() => _customTheme;

  Future<void> setThemeMode(ThemeMode themeMode,
      [String customTheme = 'default']) async {
    _themeMode = themeMode;
    _customTheme = customTheme;

    // Guardar en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', themeMode.index);
    await prefs.setString('customTheme', customTheme);

    notifyListeners();
  }
}
