import 'package:flutter/material.dart';
import 'package:notes_app/languajeCode/languaje_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('language')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              languageProvider.translate('hello'),
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              languageProvider.translate('welcome'),
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                String newLanguage =
                    languageProvider.currentLanguage == 'es' ? 'en' : 'es';
                languageProvider.changeLanguage(newLanguage);
              },
              child: Text(languageProvider.currentLanguage == 'es'
                  ? 'Switch to English'
                  : 'Cambiar a Español'),
            ),
          ],
        ),
      ),
    );
  }
}
