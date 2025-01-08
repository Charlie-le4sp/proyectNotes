import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/componentes/providers/VisibilityProvider.dart';
import 'package:notes_app/firebase_options.dart';
import 'package:notes_app/languajeCode/languaje_provider.dart';
import 'package:notes_app/login%20android%20y%20web%20autentication/login_page.dart';
import 'package:notes_app/paginaInicio.dart';
import 'package:notes_app/pruebas/prueba.dart';
import 'package:notes_app/themas/themeModeNotifier.dart';
import 'package:notes_app/themas/themes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  var themeMode = prefs.getInt('themeMode') ?? 0;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeModeNotifier>(
          create: (_) => ThemeModeNotifier(ThemeMode.values[themeMode]),
        ),
        ChangeNotifierProvider<LanguageProvider>(
          create: (_) => LanguageProvider()..loadLanguage(), // Carga idioma
        ),
        ChangeNotifierProvider(
          create: (_) => VisibilityProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeNotifier>(
      builder: (context, themeNotifier, child) {
        ThemeData theme;
        ThemeData darkTheme;

        // Determinar el tema basado en el tema personalizado
        switch (themeNotifier.getCustomTheme()) {
          case 'notebook':
            theme = Themes.notebookTheme;
            darkTheme =
                Themes.notebookTheme; // Usar el mismo tema para modo oscuro
            break;
          case 'bluenight':
            theme = Themes.blueNightTheme;
            darkTheme =
                Themes.blueNightTheme; // Usar el mismo tema para modo oscuro
            break;
          default:
            theme = Themes.lightTheme;
            darkTheme = Themes.darkTheme;
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: darkTheme,
          themeMode: themeNotifier.getThemeMode(),
          home: const AuthCheck(),
        );
      },
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? loggedIn = prefs.getBool('isLoggedIn');
    setState(() {
      isLoggedIn = loggedIn ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn ? paginaInicio() : const LoginPage();
  }
}
