import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/componentes/providers/VisibilityProvider.dart';
import 'package:notes_app/firebase_options.dart';
import 'package:notes_app/languajeCode/languaje_provider.dart';
import 'package:notes_app/login/login_page.dart';
import 'package:notes_app/modals/ModalProvider.dart';
import 'package:notes_app/notes/pruebaModal.dart';
import 'package:notes_app/paginaInicio.dart';
import 'package:notes_app/pruebas/CustomTastDemo.dart';
import 'package:notes_app/pruebas/pruebaTabbarAnimado.dart';
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
        ChangeNotifierProvider(
          create: (_) => ModalProvider(),
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

class TabBarPage extends StatefulWidget {
  const TabBarPage({super.key});

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<bool> _hoverStates = [false, false, false];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_resetHover);
  }

  /// Resetear hover al cambiar de tab
  void _resetHover() {
    setState(() {
      _hoverStates = [false, false, false];
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_resetHover);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          width: 500,
          height: 250,
          child: Column(
            children: [
              const Text(
                "Bienvenido Carlos",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              const SizedBox(height: 20),
              TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: List.generate(3, (index) {
                  return MouseRegion(
                    onEnter: (_) => setState(() => _hoverStates[index] = true),
                    onExit: (_) => setState(() => _hoverStates[index] = false),
                    child: Container(
                      height: 40, // Asegurar que el MouseRegion cubra el área
                      alignment: Alignment.center, // Centrar contenido
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color:
                            _hoverStates[index] && _tabController.index != index
                                ? Colors.grey.shade300
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                    opacity: animation, child: child),
                            child: Text(
                              ["notas", "tareas", "importantes"][index],
                              key: ValueKey(_tabController.index == index),
                              style: TextStyle(
                                color: _tabController.index == index
                                    ? Colors.white
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    Center(
                        child: Text("Contenido de Notas",
                            style: TextStyle(fontSize: 16))),
                    Center(
                        child: Text("Contenido de Tareas",
                            style: TextStyle(fontSize: 16))),
                    Center(
                        child: Text("Contenido de Importantes",
                            style: TextStyle(fontSize: 16))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
