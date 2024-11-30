import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notes_app/componentes/providers/VisibilityProvider.dart';
import 'package:notes_app/pruebas/prueba_conexion_firebase.dart';
import 'package:notes_app/themas/themeChoice.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UI for displayed all content in Drawer with small screens
class Drawers extends StatefulWidget {
  const Drawers({
    super.key,
  });

  @override
  _DrawersState createState() => _DrawersState();
}

class _DrawersState extends State<Drawers> {
  //CONTROLADOR DE TEXTO
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    super.initState();
  }

  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  // acceder al nombre del usuario desde SharedPreferences
  Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? '';
  }

  Future<void> saveUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', userName);
  }

  @override
  void dispose() {
    _textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VisibilityProvider>(
        builder: (context, visibilityProvider, child) {
      return LayoutBuilder(builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double videoWidth;

        // Ajusta los tamaños de los videos dependiendo del ancho de la pantalla
        if (screenWidth > 1200) {
          // Pantallas grandes
          videoWidth = screenWidth * 0.2;
        } else if (screenWidth > 800) {
          // Pantallas medianas
          videoWidth = screenWidth * 0.3;
        } else {
          // Pantallas pequeñas
          videoWidth = screenWidth * 0.7;
        }
        return Drawer(
          width: videoWidth,
          child: Container(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DrawerHeader(
                      child: SizedBox(
                        height: 150,
                        child: Center(
                          child: FutureBuilder<SharedPreferences>(
                            future: SharedPreferences.getInstance(),
                            builder: (BuildContext context,
                                AsyncSnapshot<SharedPreferences> snapshot) {
                              if (snapshot.hasData) {
                                String selectedImageName = snapshot.data!
                                        .getString('selectedImageName') ??
                                    '';
                                String selectedImageBytesString = snapshot.data!
                                        .getString('selectedImageBytes') ??
                                    '';
                                if (selectedImageName.isNotEmpty &&
                                    selectedImageBytesString.isNotEmpty) {
                                  Uint8List selectedImageBytes =
                                      base64Decode(selectedImageBytesString);
                                  final image = MemoryImage(selectedImageBytes);
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Container(
                                      height: 130,
                                      width: 130,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? const Color.fromARGB(9, 0, 0, 0)
                                            : const Color.fromARGB(
                                                56, 255, 255, 255),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: image,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return const Text('No image selected');
                                }
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 70,
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                            onPressed: () async {
                              Future.delayed(const Duration(milliseconds: 330),
                                  () async {
                                Navigator.of(context, rootNavigator: true).push(
                                  PageRouteBuilder(
                                    transitionDuration:
                                        const Duration(milliseconds: 500),
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const pagina_conexion(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      var begin = const Offset(0.0, 1.0);
                                      var end = Offset.zero;
                                      var curve =
                                          Curves.easeInOutCubicEmphasized;

                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));

                                      return SlideTransition(
                                        position: animation.drive(tween),
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color?>(
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? const Color.fromARGB(255, 246, 246, 246)
                                      : const Color.fromARGB(255, 15, 25, 34)),
                              elevation: WidgetStateProperty.all<double>(0.0),
                              overlayColor:
                                  WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.pressed)) {
                                    return const Color.fromARGB(
                                        255, 190, 143, 255);
                                  }
                                  return null;
                                },
                              ),
                            ),
                            child: Row(
                              children: [
                                FaIcon(FontAwesomeIcons.clock,
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.black
                                        : Colors.white),
                                const SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'Historial',
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                            height: 70,
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: () {
                                Future.delayed(
                                    const Duration(milliseconds: 330), () {
                                  Navigator.pop(context);
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    isDismissible: true,
                                    barrierColor: Colors.black12,
                                    backgroundColor: Colors.transparent,
                                    useRootNavigator: true,
                                    builder: (context) => BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 10, sigmaY: 10),
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 20),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                    sigmaX: 8, sigmaY: 8),
                                                child: Container(
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? const Color.fromARGB(
                                                          255, 255, 255, 255)
                                                      : const Color.fromARGB(
                                                          255, 21, 35, 47),
                                                  child:
                                                      DraggableScrollableSheet(
                                                    initialChildSize: 0.58,
                                                    minChildSize: 0.58,
                                                    maxChildSize: 0.58,
                                                    expand: false,
                                                    builder: (_, controller) =>
                                                        ListView(
                                                      physics:
                                                          const BouncingScrollPhysics(),
                                                      children: [
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                "Tema ",
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      "Poppins",
                                                                  fontSize: 24,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Theme.of(context)
                                                                              .brightness ==
                                                                          Brightness
                                                                              .light
                                                                      ? Colors
                                                                          .black
                                                                      : Colors
                                                                          .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 30,
                                                        ),
                                                        const ThemeChoice(),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            child: SizedBox(
                                                height: 110,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    1,
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 20),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      child: SizedBox(
                                                        height: 65,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.8,
                                                        child: ElevatedButton(
                                                          style: ButtonStyle(
                                                            backgroundColor:
                                                                WidgetStateProperty.all<
                                                                        Color?>(
                                                                    const Color.fromARGB(
                                                                        255,
                                                                        118,
                                                                        19,
                                                                        255)), // Cambia el color del botón aquí
                                                            elevation:
                                                                WidgetStateProperty.all<
                                                                        double>(
                                                                    0.0), // Cambia la elevación del botón aquí
                                                            overlayColor:
                                                                WidgetStateProperty
                                                                    .resolveWith<
                                                                        Color?>(
                                                              (Set<WidgetState>
                                                                  states) {
                                                                if (states.contains(
                                                                    WidgetState
                                                                        .pressed)) {
                                                                  return const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      190,
                                                                      143,
                                                                      255); //<-- SEE HERE
                                                                }
                                                                return null; // Defer to the widget's default.
                                                              },
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .popUntil((route) =>
                                                                    route
                                                                        .isFirst);
                                                          },
                                                          child: const Text(
                                                            'Regresar',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "Poppins",
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<
                                    Color?>(Theme.of(context).brightness ==
                                        Brightness.light
                                    ? const Color.fromARGB(255, 246, 246, 246)
                                    : const Color.fromARGB(255, 15, 25,
                                        34)), // Cambia el color del botón aquí
                                elevation: WidgetStateProperty.all<double>(
                                    0.0), // Cambia la elevación del botón aquí

                                overlayColor:
                                    WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.pressed)) {
                                      return const Color.fromARGB(
                                          255, 190, 143, 255); //<-- SEE HERE
                                    }
                                    return null; // Defer to the widget's default.
                                  },
                                ),
                              ),
                              child: Row(
                                children: [
                                  FaIcon(FontAwesomeIcons.moon,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black
                                          : Colors.white),
                                  const SizedBox(width: 10),
                                  Text("Tema",
                                      style: TextStyle(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Colors.black
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Poppins",
                                          fontSize: 16))
                                ],
                              ),
                            )),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "version 1.0.0",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                )),
          ),
        );
      });
    });
  }
}
