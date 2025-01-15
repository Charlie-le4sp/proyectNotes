import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/componentes/providers/VisibilityProvider.dart';
import 'package:notes_app/firebase_options.dart';
import 'package:notes_app/languajeCode/languaje_provider.dart';
import 'package:notes_app/login%20android%20y%20web%20autentication/login_page.dart';
import 'package:notes_app/notes/pruebaTeclado.dart';
import 'package:notes_app/paginaInicio.dart';
import 'package:notes_app/pruebas/CustomTastDemo.dart';
import 'package:notes_app/themas/themeModeNotifier.dart';
import 'package:notes_app/themas/themes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notes_app/collections/collections_provider.dart';

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
        ChangeNotifierProvider(
          create: (_) => CollectionsProvider(),
        ),
      ],
      child: MyApp(),
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
          home: AuthCheck(),
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
    return isLoggedIn ? const paginaInicio() : const LoginPage();
  }
}

class TestInputPage extends StatefulWidget {
  @override
  _TestInputPageState createState() => _TestInputPageState();
}

class _TestInputPageState extends State<TestInputPage> {
  final FocusNode _focus1 = FocusNode();
  final FocusNode _focus2 = FocusNode();
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  @override
  void dispose() {
    _focus1.dispose();
    _focus2.dispose();
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                focusNode: _focus1,
                controller: _controller1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Campo 1',
                ),
                onEditingComplete: () {
                  FocusScope.of(context).requestFocus(_focus2);
                },
              ),
              SizedBox(height: 20),
              TextField(
                focusNode: _focus2,
                controller: _controller2,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Campo 2',
                ),
              ),
              SizedBox(height: 20),
              FocusScope(
                canRequestFocus: false,
                child: ElevatedButton(
                  onPressed: () {
                    print('Campo 1: ${_controller1.text}');
                    print('Campo 2: ${_controller2.text}');
                  },
                  child: Text('Enviar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/*

intenta esto :

dale clik al primer campo , escribe algo , 
luego con tabulador avanza al otro campo y escribe algo 
luego dale al boton con de enviar , y ahora dale algun campo he intenta escribir  , luego intercambia entre los campos con tab y mouse al mismo tiempo 
ahora si reinicias  la pestaña completa e inicias con tab no te dejara escribir 

si lo conseguiste tendras los siguientes resultados:
no te dejas escribir,
te deja escribir pero el texto sale asi "textodeejemplo" y no "texto normal"
ademas si le das al boton miesntras haces la combinacion de los campos de textoe entre mouse y tab , no te dejara escribir 

no te deja escribir 


*/