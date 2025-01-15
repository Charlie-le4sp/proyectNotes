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
      'title': 'titulo',
      'enter a title': 'ingresa un titulo',
      'description': 'descripcion',
      'enter a description': 'ingresa una descripcion',
      'save note': 'guardar nota',
      'saved': 'guardado',
      'save task': 'guardar tarea',
      'update task': 'actualizar tarea',
      'no image available': 'no hay imagen disponible',
      "image": 'imagen',
      "created": 'creado',
      "edit note": 'editar nota',
      "edit": 'editar',
      "eliminate": 'eliminar',
      "removed": 'eliminado',
      "task image": 'imagen de tarea',
      "completed": 'completado',
      "task color": 'color de tarea',
      "completed tasks": 'tareas completadas',
      "reminder": 'recordatorio',
      "create task": 'crear tarea',
      "create note": 'crear nota',
      "new collection": 'nueva coleccion',
      "collection name": 'nombre coleccion',
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
      'title': 'title',
      'enter a title': 'enter a title',
      'description': 'description',
      'enter a description': 'enter a description',
      'save note': 'save note',
      'saved': 'saved',
      'save task': 'save task',
      'update task': 'update task',
      'no image available': 'no image available',
      "image": 'image',
      "created": 'created',
      "edit note": 'edit note',
      "edit": 'edit',
      "eliminate": 'eliminate',
      "removed": 'removed',
      "task image": 'task image',
      "completed": 'completed',
      "task color": 'task color',
      "completed tasks": 'completed tasks',
      "reminder": 'reminder',
      "create task": 'create task',
      "create note": 'create note',
      "new collection": 'new collection',
      "collection name": 'collection name',
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
