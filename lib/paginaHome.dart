import 'dart:convert';
import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:iconly/iconly.dart';
import 'package:notes_app/login%20android%20y%20web%20autentication/login_page.dart';

import 'package:notes_app/pruebas/prueba_conexion_firebase.dart';
import 'package:notes_app/pruebas/upload_page.dart';
import 'package:notes_app/themas/themeModeNotifier.dart';
import 'package:notes_app/themas/themes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class paginaHome extends StatefulWidget {
  const paginaHome({
    super.key,
    //required remoteConfigService
  });

  @override
  State<paginaHome> createState() => _paginaHomeState();
}

class _paginaHomeState extends State<paginaHome> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeModeNotifier>(context);
    final brightness = MediaQuery.of(context).platformBrightness;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Color.fromARGB(185, 0, 0, 0),
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness:
          brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      statusBarColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white12
          : const Color.fromARGB(255, 0, 5, 9),
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
      navigatorKey: navigatorKey, // Usa el GlobalKey para el Navigator
      themeMode: themeNotifier.getThemeMode(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final List<Widget> _paginas = [LoginPage(), UploadPage()];

  int currentIndex = 0;

  bool _isRailExtended(double width) {
    return width > 600;
  }

  final _formKeyOnboard = GlobalKey<FormState>();
  late String _userName;
  final controller = PageController();

  bool isLastPage = false;

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _checkDialogStatus();
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (_isRailExtended(constraints.maxWidth)) {
                return Row(
                  children: <Widget>[
                    NavigationRail(
                      indicatorColor: Color.fromARGB(255, 144, 79, 255),
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.transparent
                              : Colors.black,
                      selectedIndex: currentIndex,
                      onDestinationSelected: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        NavigationRailDestination(
                          selectedIcon: const Icon(
                            IconlyBold.home,
                            size: 25,
                            color: Colors.white,
                          ),
                          icon: const Icon(
                            IconlyLight.home,
                            size: 25,
                          ),
                          label: Text("Inicio"),
                        ),
                        NavigationRailDestination(
                          selectedIcon: const Icon(
                            IconlyBold.category,
                            size: 25,
                            color: Colors.white,
                          ),
                          icon: const Icon(
                            IconlyLight.category,
                            size: 25,
                          ),
                          label: Text('Categorías'),
                        ),
                        NavigationRailDestination(
                          selectedIcon: FadeIn(
                            child: const Icon(
                              IconlyBold.bookmark,
                              size: 25,
                              color: Colors.white,
                            ),
                          ),
                          icon: Icon(
                            IconlyLight.bookmark,
                            size: 25,
                          ),
                          label: Text('Guardados'),
                        ),
                        NavigationRailDestination(
                          icon: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? const Color.fromARGB(9, 0, 0, 0)
                                    : const Color.fromARGB(56, 255, 255, 255),
                              ),
                              width: 30,
                              child: FutureBuilder<SharedPreferences>(
                                future: SharedPreferences.getInstance(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<SharedPreferences> snapshot) {
                                  if (snapshot.hasData) {
                                    String selectedImageName = snapshot.data!
                                            .getString('selectedImageName') ??
                                        '';
                                    String selectedImageBytesString = snapshot
                                            .data!
                                            .getString('selectedImageBytes') ??
                                        '';
                                    if (selectedImageName.isNotEmpty &&
                                        selectedImageBytesString.isNotEmpty) {
                                      Uint8List selectedImageBytes =
                                          base64Decode(
                                              selectedImageBytesString);
                                      final image =
                                          MemoryImage(selectedImageBytes);
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: image,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return const FaIcon(
                                          FontAwesomeIcons.user);
                                    }
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                },
                              ),
                            ),
                          ),
                          label: Text('Mi cuenta'),
                        ),
                      ],
                    ),
                    Expanded(
                      child: _paginas[currentIndex],
                    ),
                  ],
                );
              } else {
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  extendBody: true,
                  backgroundColor: Colors.transparent,
                  body: _paginas[currentIndex],
                  bottomNavigationBar: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: NavigationBar(
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                                ? const Color.fromARGB(210, 255, 255, 255)
                                    .withOpacity(0.8)
                                : const Color.fromARGB(197, 0, 13, 24)
                                    .withOpacity(0.78),
                        animationDuration: const Duration(milliseconds: 800),
                        labelBehavior:
                            NavigationDestinationLabelBehavior.alwaysShow,
                        selectedIndex: currentIndex,
                        onDestinationSelected: (index) => {
                          setState(() => currentIndex = index),
                        },
                        destinations: [
                          NavigationDestination(
                            selectedIcon: FadeIn(
                              child: const Icon(
                                IconlyBold.home,
                                size: 25,
                                color: Colors.white,
                              ),
                            ),
                            icon: const Icon(
                              IconlyLight.home,
                              size: 25,
                            ),
                            label: "Inicio",
                          ),
                          NavigationDestination(
                            selectedIcon: FadeIn(
                              child: const Icon(
                                IconlyBold.category,
                                size: 25,
                                color: Colors.white,
                              ),
                            ),
                            icon: const Icon(
                              IconlyLight.category,
                              size: 25,
                            ),
                            label: "Categorias",
                          ),
                          NavigationDestination(
                            selectedIcon: FadeIn(
                              child: const Icon(
                                IconlyBold.bookmark,
                                size: 25,
                                color: Colors.white,
                              ),
                            ),
                            icon: Icon(
                              IconlyLight.bookmark,
                              size: 25,
                            ),
                            label: "Guardados",
                          ),
                          NavigationDestination(
                            icon: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? const Color.fromARGB(9, 0, 0, 0)
                                      : const Color.fromARGB(56, 255, 255, 255),
                                ),
                                width: 30,
                                child: FadeIn(
                                  delay: const Duration(milliseconds: 50),
                                  duration: const Duration(milliseconds: 400),
                                  child: FutureBuilder<SharedPreferences>(
                                    future: SharedPreferences.getInstance(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<SharedPreferences>
                                            snapshot) {
                                      if (snapshot.hasData) {
                                        String selectedImageName =
                                            snapshot.data!.getString(
                                                    'selectedImageName') ??
                                                '';
                                        String selectedImageBytesString =
                                            snapshot.data!.getString(
                                                    'selectedImageBytes') ??
                                                '';
                                        if (selectedImageName.isNotEmpty &&
                                            selectedImageBytesString
                                                .isNotEmpty) {
                                          Uint8List selectedImageBytes =
                                              base64Decode(
                                                  selectedImageBytesString);
                                          final image =
                                              MemoryImage(selectedImageBytes);
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 2),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: image,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          return Center(
                                            child: FaIcon(
                                                size: 16,
                                                FontAwesomeIcons.user),
                                          );
                                        }
                                      } else {
                                        return const CircularProgressIndicator();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            label: "Mi Cuenta",
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> saveUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', userName);
  }
}
