import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*

Permite mostrar x o y elementos en pantalla dependiendo de lo que se quiera 
ejemplo , actualmente se usa para ocultar elementos y funcionalidades que se tiene que 
mostrar unicamente cuando se loguea el usuario

*/

class VisibilityProvider with ChangeNotifier {
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  VisibilityProvider() {
    _loadVisibility();
  }

  void _loadVisibility() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isVisible = prefs.getBool('isVisible') ?? true;
    notifyListeners();
  }

  void toggleVisibility() async {
    _isVisible = !_isVisible;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isVisible', _isVisible);
    notifyListeners();
  }
}
