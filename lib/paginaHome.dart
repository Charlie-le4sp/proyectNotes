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

  void _setDialogShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dialogShown', true);
  }

  void _checkDialogStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? dialogShown = prefs.getBool('dialogShown') ?? false;

    if (!dialogShown) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _showAlertDialog(context));
    }
  }

  bool _showDialog = true;

  void _showAlertDialog(BuildContext context) {
    showDialog(
      barrierColor: const Color.fromARGB(101, 0, 0, 0),
      context: navigatorKey.currentContext!,
      barrierDismissible:
          false, // Permite cerrar el diálogo al hacer tap fuera de él
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return LayoutBuilder(
            builder: (context, constraints) {
              double dialogLogin;
              if (constraints.maxWidth > 1200) {
                dialogLogin = 600.0;
              } else if (constraints.maxWidth > 800) {
                dialogLogin = 600.0;
              } else {
                dialogLogin = MediaQuery.of(context).size.width * 1;
              }
              return Center(
                child: ZoomIn(
                  duration: Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap:
                        () {}, // Este evita que el tap dentro del diálogo lo cierre
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.9,
                          color: Colors.black,
                          width: dialogLogin,
                          child: Stack(
                            children: [
                              Container(
                                color: Color.fromARGB(255, 124, 57, 240),
                                child: Scaffold(
                                  extendBody: true,
                                  resizeToAvoidBottomInset: false,
                                  backgroundColor:
                                      Color.fromARGB(255, 144, 79, 255),
                                  body: Stack(
                                    children: [
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(200),
                                                child: Container(
                                                    color: Colors.white,
                                                    height: 90,
                                                    width: 90,
                                                    child: Center(
                                                        child: Image.asset(
                                                            "assets/images/logo/logo_oficial.png"))),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                "HolaiTv",
                                                style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                          LayoutBuilder(
                                              builder: (context, constraints) {
                                            double dialogWidth;
                                            if (constraints.maxWidth > 1200) {
                                              dialogWidth = 800.0;
                                            } else if (constraints.maxWidth >
                                                800) {
                                              dialogWidth = 600.0;
                                            } else {
                                              dialogWidth =
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      1;
                                            }
                                            return Container(
                                              width: dialogWidth,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.68,
                                              child: PageView(
                                                controller: controller,
                                                onPageChanged: (index) {
                                                  setState(() {
                                                    isLastPage = index == 1;
                                                    // _progressValue = (index + 1) / 5;
                                                  });
                                                },
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 15),
                                                    child: SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.4,
                                                      child: ListView(
                                                        children: [
                                                          SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.07,
                                                          ),
                                                          SizedBox(
                                                            height: 120,
                                                            width: constraints
                                                                    .maxWidth *
                                                                0.8,
                                                            child: AnimatedTextKit(
                                                                pause:
                                                                    const Duration(
                                                                        seconds:
                                                                            1),
                                                                repeatForever:
                                                                    false,
                                                                totalRepeatCount:
                                                                    1,
                                                                animatedTexts: [
                                                                  TyperAnimatedText(
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      textStyle:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontFamily:
                                                                            "Poppins",
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            27.5,
                                                                      ),
                                                                      speed: const Duration(
                                                                          milliseconds:
                                                                              50),
                                                                      curve: Curves
                                                                          .ease,
                                                                      "HolaiTv , peliculas , series y mucho mas"),
                                                                ]),
                                                          ),
                                                          SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.2,
                                                            child: Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              children: [
                                                                ZoomIn(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            180),
                                                                    child: Transform
                                                                        .rotate(
                                                                      angle:
                                                                          -0.2, // ángulo de rotación en radianes
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(20),
                                                                          color:
                                                                              Colors.white12,
                                                                          image:
                                                                              DecorationImage(
                                                                            image:
                                                                                AssetImage("assets/images/onboard/onboard_3.png"), // URL de la imagen
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                        width:
                                                                            200,
                                                                        height:
                                                                            150,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                ZoomIn(
                                                                  delay: Duration(
                                                                      milliseconds:
                                                                          150),
                                                                  child: Transform
                                                                      .rotate(
                                                                    angle:
                                                                        -0.2, // ángulo de rotación en radianes
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          200,
                                                                      height:
                                                                          150,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(20),
                                                                        color: Colors
                                                                            .white12,
                                                                        image:
                                                                            DecorationImage(
                                                                          image:
                                                                              AssetImage("assets/images/onboard/onboard.png"), // URL de la imagen
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                ZoomIn(
                                                                  delay: Duration(
                                                                      milliseconds:
                                                                          400),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            180),
                                                                    child: Transform
                                                                        .rotate(
                                                                      angle:
                                                                          -0.2, // ángulo de rotación en radianes (sin rotación)
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            200,
                                                                        height:
                                                                            150,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(20),
                                                                          color:
                                                                              Colors.white12,
                                                                          image:
                                                                              DecorationImage(
                                                                            image:
                                                                                AssetImage("assets/images/onboard/onboard_2.png"), // URL de la imagen
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 20,
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(15.0),
                                                          child: SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.8,
                                                            child: Center(
                                                              child: Text(
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                "Ingresa un nombre de usuario , que mas te guste",
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        "Poppins",
                                                                    fontSize:
                                                                        23,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          height: 80,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              1,
                                                          child: Form(
                                                            key:
                                                                _formKeyOnboard,
                                                            child:
                                                                TextFormField(
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText:
                                                                    'Nombre de Usuario',
                                                                hintStyle:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      "Poppins",
                                                                  fontSize:
                                                                      16.0,
                                                                  color: Colors
                                                                      .white54,
                                                                ),
                                                                labelStyle:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      "Poppins",
                                                                  fontSize:
                                                                      16.0,
                                                                  color: Colors
                                                                      .white54,
                                                                ),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15.0),
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .white, // Color del borde por defecto
                                                                    width: 1.0,
                                                                  ),
                                                                ),
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15.0),
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .white, // Color del borde cuando el campo no está enfocado
                                                                    width: 1.0,
                                                                  ),
                                                                ),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15.0),
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .white, // Color del borde cuando el campo está enfocado
                                                                    width: 3.0,
                                                                  ),
                                                                ),
                                                                errorBorder:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15.0),
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .red, // Color del borde cuando hay un error
                                                                    width: 2.0,
                                                                  ),
                                                                ),
                                                                focusedErrorBorder:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15.0),
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .red, // Color del borde cuando el campo está enfocado y hay un error
                                                                    width: 2.0,
                                                                  ),
                                                                ),
                                                              ),
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "Poppins",
                                                                fontSize: 16.0,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              maxLength: 15,
                                                              validator:
                                                                  (value) {
                                                                if (value!
                                                                    .isEmpty) {
                                                                  return 'Introduce un nombre';
                                                                }
                                                                return null;
                                                              },
                                                              onSaved: (value) =>
                                                                  _userName =
                                                                      value!,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          FadeIn(
                                            child: Padding(
                                              padding: const EdgeInsets.all(15),
                                              child: LayoutBuilder(
                                                builder:
                                                    (context, constraints) {
                                                  double dialogWidth;
                                                  if (constraints.maxWidth >
                                                      1200) {
                                                    dialogWidth = 800.0;
                                                  } else if (constraints
                                                          .maxWidth >
                                                      800) {
                                                    dialogWidth = 600.0;
                                                  } else {
                                                    dialogWidth =
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            1;
                                                  }

                                                  return Center(
                                                    child: SizedBox(
                                                      width:
                                                          dialogWidth, // Asegúrate de que el ancho del contenedor sea el ancho de la pantalla
                                                      child: Container(
                                                        height: 80,
                                                        child: ElevatedButton(
                                                          style: ButtonStyle(
                                                            backgroundColor:
                                                                WidgetStateProperty.all<
                                                                        Color?>(
                                                                    Colors
                                                                        .white),
                                                            elevation:
                                                                WidgetStateProperty
                                                                    .all<double>(
                                                                        0.8),
                                                            overlayColor:
                                                                WidgetStateProperty
                                                                    .resolveWith<
                                                                        Color?>(
                                                              (Set<WidgetState>
                                                                  states) {
                                                                if (states.contains(
                                                                    WidgetState
                                                                        .pressed)) {
                                                                  return Color
                                                                      .fromARGB(
                                                                          138,
                                                                          0,
                                                                          0,
                                                                          0);
                                                                }
                                                                return null;
                                                              },
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            if (isLastPage) {
                                                              if (_formKeyOnboard
                                                                  .currentState!
                                                                  .validate()) {
                                                                _formKeyOnboard
                                                                    .currentState!
                                                                    .save();
                                                                saveUserName(
                                                                    _userName);
                                                                Navigator.pop(
                                                                    context);
                                                                _setDialogShown();
                                                              }
                                                            } else {
                                                              controller
                                                                  .nextPage(
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        700),
                                                                curve: Curves
                                                                    .fastLinearToSlowEaseIn,
                                                              );
                                                            }
                                                          },
                                                          child: Center(
                                                            child: Text(
                                                              'Vamos!',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "Poppins",
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    23, // Ajusta el tamaño del texto según el ancho de la pantalla
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
      },
    );
  }

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
