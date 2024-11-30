import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/componentes/providers/VisibilityProvider.dart';
import 'package:notes_app/firebase_options.dart';
import 'package:notes_app/login%20android%20y%20web%20autentication/login_page.dart';

import 'package:notes_app/paginaInicio.dart';
import 'package:notes_app/themas/themeModeNotifier.dart';
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthCheck(),
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
