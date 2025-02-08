import 'dart:async';
import 'dart:ui';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:notes_app/paginaInicio.dart';
import 'package:notes_app/themas/themeModeNotifier.dart';
import 'package:notes_app/themas/themes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class paginaPuenteMisCursos extends StatefulWidget {
  const paginaPuenteMisCursos({super.key});

  @override
  _paginaPuenteMisCursosState createState() => _paginaPuenteMisCursosState();
}

class _paginaPuenteMisCursosState extends State<paginaPuenteMisCursos> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeModeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
      themeMode: themeNotifier.getThemeMode(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool isLoadingMisCursos = true;
  late Timer _timerMisCursos;

  @override
  void initState() {
    super.initState();
    // Simular tiempo de carga y reiniciar el estado
    _timerMisCursos = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          isLoadingMisCursos = false;
        });

        // Reiniciar la página web completa después de 400ms
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            FocusManager.instance.primaryFocus?.unfocus();
            // Utilizar js para recargar la página web
            html.window.location.reload();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timerMisCursos.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: 50, width: 50, child: CircularProgressIndicator()),
                SizedBox(
                  height: 30,
                ),
                Text("Cargando...")
              ],
            ),
          ),
        ],
      ),
    );
  }
}
