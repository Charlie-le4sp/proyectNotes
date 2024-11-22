import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:notes_app/AuthCheckPage.dart';
import 'package:notes_app/componentes/providers/VisibilityProvider.dart';
import 'package:notes_app/componentes/providers/list_provider.dart';

import 'package:notes_app/firebase_options.dart';
import 'package:notes_app/login%20android%20y%20web%20autentication/login_page.dart';
import 'package:notes_app/notes/alternativa/listaNotas.dart';
import 'package:notes_app/notes/alternativa/notesProvider.dart';
import 'package:notes_app/paginaInicio.dart';
import 'package:notes_app/paginaHome.dart';
import 'package:notes_app/pruebas/pruebaDise%C3%B1oCardNotes.dart';
import 'package:notes_app/themas/themeModeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

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
        ChangeNotifierProvider<NotesProvider>(
          create: (_) {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              throw Exception('User not logged in!');
            }
            return NotesProvider(
              userId: user.uid,
              cloudinaryCloudName: 'djm1bosvc', // Tu cloudName de Cloudinary
              cloudinaryUploadPreset: 'notesImages', // Tu uploadPreset
            );
          },
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthCheck(),
    );
  }
}

class AuthCheck extends StatefulWidget {
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
    return isLoggedIn ? paginaInicio() : LoginPage();
  }
}
