import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

class CustomToastDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Toast Demo')),
      body: Center(
          child: ElevatedButton(
              onPressed: () {
                // Obtiene el Overlay actual.
                final overlay = Overlay.of(context);

                // Crea un OverlayEntry para el Toast.
                final overlayEntry = OverlayEntry(
                  builder: (context) => Positioned(
                    bottom: 20, // Ajusta para colocarlo en la parte inferior.
                    left: 20, // Ajusta para colocarlo en la izquierda.
                    child: FadeIn(
                      duration: Duration(milliseconds: 120),
                      child: Material(
                        color: Colors
                            .transparent, // Fondo transparente para evitar bordes.
                        child: Container(
                          width: 250,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  width: 250,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color:
                                          Color.fromARGB(255, 229, 229, 229)),
                                  height: 250,
                                  child: Center(
                                    child: Lottie.asset(
                                      fit: BoxFit.contain,

                                      'assets/lottieAnimations/final.json', // Tu animación Lottie.
                                      repeat: false,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 250,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.redAccent),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: Text(
                                        "Eliminado",
                                        style: TextStyle(
                                          fontFamily: "Roboto",
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: FaIcon(FontAwesomeIcons.check),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );

                // Agrega el OverlayEntry al Overlay.
                overlay.insert(overlayEntry);

                // Remueve el Toast después de 2.7 segundos.
                Future.delayed(Duration(milliseconds: 3000), () {
                  overlayEntry.remove();
                });
              },
              child: Text("al fin"))),
    );
  }

  void showCustomToast(BuildContext context) {}
}
