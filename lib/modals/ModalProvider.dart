import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ModalType { welcome, update }

class WelcomePageData {
  final String title;
  final String description;
  final String backgroundAsset;

  WelcomePageData({
    required this.title,
    required this.description,
    required this.backgroundAsset,
  });
}

class ModalInfo {
  final String id;
  final String title;
  final String description;
  final String imageAsset;
  final String link;
  final bool dismissible;
  final ModalType type;
  final List<WelcomePageData>? welcomePages;

  ModalInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.imageAsset,
    this.link = '',
    this.dismissible = true,
    required this.type,
    this.welcomePages,
  });
}

class ModalProvider with ChangeNotifier {
  final List<ModalInfo> _modals = []; // Lista de todos los modales disponibles
  final List<ModalInfo> _activeModals = []; // Modales actualmente visibles

  List<ModalInfo> get activeModals => _activeModals;

  ModalProvider() {
    _loadModals();
  }

  Future<void> _loadModals() async {
    // Cargar estado de modales vistos desde SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final shownModals = prefs.getStringList('shownModals') ?? [];

    // Filtrar los modales que aún no se han mostrado
    _modals.addAll([
      //control de versiones de modales , para anunciar noticias y funcionalidades
      //y tener comunicacion con la comunidad de la app
      // siempre que vaya a agregar un modal , se debe de agregar el id del modal diferente a los ya existentes
      // ademas se debe eliminar el modal antiguo , de tal forma que queden 2 no mas
      //es decir el de bienvenida y el de funcionalidades , o el que necesite
      ModalInfo(
        id: 'welcome',
        title: '¡Bienvenido!',
        description: 'Explora las nuevas funcionalidades de la aplicación.',
        imageAsset: 'assets/images/onboard/onboard_2.png',
        link: 'https://www.youtube.com/watch?v=KAjJtMynOes',
        type: ModalType.welcome,
        welcomePages: [
          WelcomePageData(
            title: 'Unlimited Multi-Scenes',
            description: 'build multiverses & alternatives.',
            backgroundAsset: 'assets/images/recursos/perro1.jpg',
          ),
          WelcomePageData(
            title: 'Más funciones',
            description: 'Descubre más opciones avanzadas en tus proyectos.',
            backgroundAsset: 'assets/images/recursos/perro2.jpg',
          ),
          WelcomePageData(
            title: 'Diseño creativo',
            description: 'Explora nuevos estilos y potencia tu creatividad.',
            backgroundAsset: 'assets/images/recursos/perro3.jpg',
          ),
        ],
      ),

      ModalInfo(
        id: 'funcionalidades',
        title: 'Nuevas funcionalidades - 19 de enero',
        description: 'Se han agregado nuevas características y mejoras...',
        imageAsset: 'assets/images/onboard/onboard_5.png',
        link: 'https://www.youtube.com/watch?v=KAjJtMynOes',
        type: ModalType.update,
      ),
    ]);

    _activeModals.addAll(
      _modals.where((modal) => !shownModals.contains(modal.id)).take(2),

      // poner en .take(2) para que se muestren el numero de modales que se quieren
    );

    notifyListeners();
  }

  Future<void> markModalAsShown(String id) async {
    // Marcar un modal como visto
    final prefs = await SharedPreferences.getInstance();
    final shownModals = prefs.getStringList('shownModals') ?? [];
    if (!shownModals.contains(id)) {
      shownModals.add(id);
      await prefs.setStringList('shownModals', shownModals);
    }

    _activeModals.removeWhere((modal) => modal.id == id);
    notifyListeners();
  }
}
