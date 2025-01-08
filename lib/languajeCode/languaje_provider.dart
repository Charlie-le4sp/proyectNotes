import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'es';

  // Traducciones
  final Map<String, Map<String, String>> _localizedStrings = {
    'es': {
      'hello': 'Hola',
      'welcome': 'Bienvenido',
      'language': 'Idioma',
      'notes': 'notas',
      'tasks': 'tareas',
      'importants': 'importantes',
      'create': 'crear',
      'accent color': 'color de enfasis',
      'my account': 'mi cuenta',
      'background image': 'imagen de fondo',
      'select theme': 'seleccionar tema',
      'log out': 'cerrar sesión',
      'accept': 'aceptar',
      'cancel': 'cancelar',
      'recycle bin': 'papelera',
      'change language': 'cambiar idioma',
    },
    'en': {
      'hello': 'Hello',
      'welcome': 'Welcome',
      'language': 'Language',
      'notes': 'Notes',
      'tareas': 'tasks',
      'importants': 'Importants',
      'create': 'Create',
      'accent color': 'Accent color',
      'my account': 'My account',
      'background image': 'Background image',
      'select theme': 'Select theme',
      'log out': 'Log out',
      'accept': 'accept',
      'cancel': 'cancel',
      'recycle bin': 'recycle bin',
      'change language': ' change language',
    },
  };

  String get currentLanguage => _currentLanguage;

  // Método para obtener la traducción
  String translate(String key) {
    return _localizedStrings[_currentLanguage]?[key] ?? key;
  }

  Future<void> changeLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _currentLanguage);
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'es';
    notifyListeners();
  }
}
