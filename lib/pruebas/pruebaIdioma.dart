import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class pruebaIdioma extends StatefulWidget {
  const pruebaIdioma({super.key});

  @override
  _pruebaIdiomaState createState() => _pruebaIdiomaState();
}

class _pruebaIdiomaState extends State<pruebaIdioma> {
  Map<String, dynamic> translations = {};
  String currentLanguage = 'es'; // Idioma por defecto

  @override
  void initState() {
    super.initState();
    _loadTranslations();
    _loadSavedLanguage();
  }

  Future<void> _loadTranslations() async {
    final String jsonString =
        await rootBundle.loadString('assets/languages/translations.json');
    setState(() {
      translations = json.decode(jsonString);
    });
  }

  Future<void> _loadSavedLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentLanguage =
          prefs.getString('selectedLanguage') ?? 'es'; // Español por defecto
    });
  }

  Future<void> _saveLanguage(String language) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
  }

  void _toggleLanguage() {
    setState(() {
      currentLanguage = currentLanguage == 'es' ? 'en' : 'es';
    });
    _saveLanguage(currentLanguage); // Guardar el idioma seleccionado
  }

  @override
  Widget build(BuildContext context) {
    if (translations.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambio de Idioma'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              translations[currentLanguage]['notes'] ?? '',
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleLanguage,
              child: Text(currentLanguage == 'es'
                  ? 'Cambiar a Inglés'
                  : 'Switch to Spanish'),
            ),
          ],
        ),
      ),
    );
  }
}
