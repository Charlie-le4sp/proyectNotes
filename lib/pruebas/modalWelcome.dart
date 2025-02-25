import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// App principal
class modalWelcome extends StatelessWidget {
  const modalWelcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ejemplo Modal con múltiples fondos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

/// Pantalla principal con botón para mostrar el modal
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  // Aquí definimos la lista de "páginas" que se mostrarán en el PageView.
  // Cada página tiene su propio fondo y texto.
  final List<ModalPageData> pages = [
    ModalPageData(
      title: 'Unlimited Multi-Scenes',
      description: '  build multiverses & alternatives.',
      backgroundAsset: 'assets/images/recursos/perro1.jpg',
    ),
    ModalPageData(
      title: 'Más funciones',
      description: 'Descubre más opciones avanzadas en tus proyectos.',
      backgroundAsset: 'assets/images/recursos/perro2.jpg',
    ),
    ModalPageData(
      title: 'Diseño creativo',
      description: 'Explora nuevos estilos y potencia tu creatividad.',
      backgroundAsset: 'assets/images/recursos/perro3.jpg',
    ),
  ];

  // Ejemplo de info adicional para el modal
  final ModalInfo _exampleModal = ModalInfo(
    id: 'modal_1',
    link: 'https://flutter.dev',
  );

  final ModalProvider _provider = ModalProvider();

  /// Muestra el modal usando Stack para que cada página tenga su propio fondo
  void _showModal(
      BuildContext context, ModalInfo modal, ModalProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final pageController = PageController();

        return ZoomIn(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Definimos el ancho del diálogo según el ancho disponible
              double dialogWidth;
              if (constraints.maxWidth > 1200) {
                dialogWidth = 650.0;
              } else if (constraints.maxWidth > 800) {
                dialogWidth = 600.0;
              } else {
                dialogWidth = constraints.maxWidth;
              }

              return Center(
                // Animación de escala (puedes cambiarla por FadeInUp si gustas)
                child: AlertDialog(
                  insetPadding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 24,
                  ),
                  backgroundColor: Colors.black,

                  contentPadding: EdgeInsets.zero, // Quitamos padding
                  content: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: dialogWidth,
                      height: 400, // Ajusta la altura del modal
                      child: Stack(
                        children: [
                          // PageView que muestra cada "página" con su propio fondo
                          Positioned.fill(
                            child: PageView.builder(
                              physics: const BouncingScrollPhysics(),
                              controller: pageController,
                              itemCount: pages.length,
                              itemBuilder: (context, index) {
                                final pageData = pages[index];
                                return FadeIn(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            pageData.backgroundAsset),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    // Aquí va el contenido textual de la página
                                    child: Center(
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [
                                                  Colors.black,
                                                  Colors.transparent
                                                ],
                                                stops: [0.0, 1.0],
                                              ),
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    pageData.title,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    pageData.description,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 100),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Botón de cierre en la esquina superior derecha
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                provider.markModalAsShown(modal.id);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),

                          // Indicador de página y botones (flechas + botón central) al fondo
                          // Los posicionamos en la parte inferior
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
                                // Indicador de páginas
                                SmoothPageIndicator(
                                  controller: pageController,
                                  count: pages.length,
                                  effect: ExpandingDotsEffect(
                                    dotColor: Colors.white,
                                    activeDotColor: Colors.purple,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Fila con flechas y botón central
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Flecha izquierda
                                    IconButton(
                                      icon: const Icon(
                                        Icons.arrow_left,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        pageController.previousPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeIn,
                                        );
                                      },
                                    ),
                                    // Botón central "See all plans"
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.purple,
                                      ),
                                      onPressed: () {
                                        if (modal.link.isNotEmpty) {
                                          _openLink(modal.link);
                                        }
                                      },
                                      child: const Text('See all plans'),
                                    ),
                                    // Flecha derecha
                                    IconButton(
                                      icon: const Icon(
                                        Icons.arrow_right,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        pageController.nextPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve:
                                              Curves.easeInOutCubicEmphasized,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Lógica para "abrir enlace"
  void _openLink(String link) {
    debugPrint('Abrir enlace: $link');
    // Aquí podrías usar url_launcher u otra lógica
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejemplo Modal con múltiples fondos'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _showModal(context, _exampleModal, _provider);
          },
          child: const Text('Mostrar Modal'),
        ),
      ),
    );
  }
}

/// Datos de cada página del PageView (fondo, título, descripción)
class ModalPageData {
  final String title;
  final String description;
  final String backgroundAsset;

  ModalPageData({
    required this.title,
    required this.description,
    required this.backgroundAsset,
  });
}

/// Info adicional para el modal (ID, link, etc.)
class ModalInfo {
  final String id;
  final String link;

  ModalInfo({
    required this.id,
    required this.link,
  });
}

/// Proveedor de ejemplo
class ModalProvider {
  void markModalAsShown(String id) {
    debugPrint('Modal con id "$id" marcado como visto.');
  }
}
