import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:notes_app/componentes/providers/VisibilityProvider.dart';
import 'package:notes_app/componentes/providers/list_provider.dart';
import 'package:notes_app/componentes/providers/notes_provider.dart';
import 'package:notes_app/login%20android%20y%20web%20autentication/login_page.dart';
import 'package:notes_app/login%20android%20y%20web%20autentication/paginaInicio.dart';
import 'package:notes_app/paginaHome.dart';
import 'package:notes_app/themas/themeModeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importa Firebase Firestore

bool show = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // if (!kIsWeb) {
  //   MobileAds.instance.initialize();
  // }

  await Firebase.initializeApp(
    name: kIsWeb ? null : "flutterproyectnotes",
    options: FirebaseOptions(
        apiKey: "AIzaSyA3dcmgspdJurKLxoymNTt_c-fmF08rRjM",
        authDomain: "flutterproyectnotes.firebaseapp.com",
        projectId: "flutterproyectnotes",
        storageBucket: "flutterproyectnotes.appspot.com",
        messagingSenderId: "457835806108",
        appId: "1:457835806108:web:6635e63166e964cbefdc59",
        measurementId: "G-68VK13QRTC"),
  );

  final prefsMain = await SharedPreferences.getInstance();
  show = prefsMain.getBool('ON_BOARDING') ?? true;
  var themeMode = prefsMain.getInt('themeMode') ?? 0;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeModeNotifier>(
          create: (_) => ThemeModeNotifier(ThemeMode.values[themeMode]),
        ),
        ChangeNotifierProvider(
          create: (_) => VisibilityProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotesProvider(),
        ),
        ChangeNotifierProvider(create: (_) => ListProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home:
            paginaHome() //_getHomePage() // mas() // show ? IntroScreen() : paginaHome()
        );
  }

  // Widget _getHomePage() {
  //   if (kIsWeb) {
  //     return paginaHome();
  //   } else {
  //     return show ? IntroScreen() : paginaHome();
  //   }
  // }
}
