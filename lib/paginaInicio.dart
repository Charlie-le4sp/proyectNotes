import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:lottie/lottie.dart';
import 'package:notes_app/DeletedItemsPage.dart';
import 'package:notes_app/DisplayWallpaperPage.dart';
import 'package:notes_app/WallpaperSelectionPage.dart';
import 'package:notes_app/collections/collection_selector.dart';
import 'package:notes_app/collections/collections_provider.dart';
import 'package:notes_app/componentes/AnimatedFloatingMenu.dart';
import 'package:notes_app/componentes/AnimatedScaleWrapper.dart';
import 'package:notes_app/componentes/providers/bounceButton.dart';
import 'package:notes_app/languajeCode/languaje_provider.dart';
import 'package:notes_app/languajeCode/HomePage.dart';
import 'package:notes_app/modals/ModalProvider.dart';
import 'package:notes_app/tasks/CompletedTaskPage.dart';
import 'package:notes_app/tasks/CreateTaskPage.dart';
import 'package:animate_do/animate_do.dart'
    as animate_do; // Prefijo para animate_do
import 'package:bounce/bounce.dart' as bounce_pkg; // Prefijo para bounce
import 'package:notes_app/tasks/EditTaskPage.dart';
import 'package:notes_app/tasks/modelCardTask.dart';
import 'package:notes_app/notes/EditNotePage.dart';

import 'package:notes_app/notes/modelCardNote.dart';

import 'package:notes_app/notes/CreateNotePage.dart';
import 'package:notes_app/login/login_page.dart';
import 'package:notes_app/paginaMiCuenta.dart';
import 'package:notes_app/pruebas/popUpMenuPrueba.dart';

import 'package:notes_app/pruebas/pruebaThema.dart';
import 'package:notes_app/themas/themeChoice.dart';
import 'package:notes_app/themas/themeModeNotifier.dart';
import 'package:notes_app/themas/themes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'dart:html' as html;
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:notes_app/collections/collections_grid_view.dart';

// se implemento que tanto buildnormal , como buildalternate  funcionen bien
//lo unico que falta es que cuando se cambie de una a otro layout mantenga el orden
//y que tambien se actualce cuando se elimine o modifique una nota o tarea, ademas
//cabe resaltar que tareas si funciona bien pero notas no

class paginaInicio extends StatefulWidget {
  const paginaInicio({super.key});

  @override
  _paginaInicioState createState() => _paginaInicioState();
}

class _paginaInicioState extends State<paginaInicio>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _listTabController;
  late SharedPreferences _prefsTodos;

  String accentColor = '#FFBF00';

  int _currentIndex = 0;
  bool _isAlternateLayout = false;
  int _expandedNoteIndex = -1;
  int _expandedTaskIndex = -1;
  bool _areItemsExpanded = true;

  String? wallpaperUrl; // Variable para almacenar la URL del wallpaper
  String?
      profileImageUrl; // Variable para almacenar la URL de la imagen de perfil

  String? username;

  double wallpaperOpacity = 0.8;
  double backdropBlur = 0.0;
  late SharedPreferences prefs;

  List<bool> _hoverStates = List.generate(4, (_) => false);

  @override
  void initState() {
    super.initState();

    _initprefsTodos();
    _tabController = TabController(length: 4, vsync: this);
    _listTabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      _handleTabSelection();
      _resetHover();
    });
    _loadAccentColor(); // Cargar el color de énfasis al iniciar
    _loadWallpaperUrl(); // Cargar la URL del wallpaper al iniciar
    _loadProfileImageUrl(); // Cargar la URL de la imagen de perfil al iniciar
    _loadUsername();
    _initPrefs();
    _loadWallpaperSettings();
  }

  void _resetHover() {
    setState(() {
      _hoverStates = List.generate(4, (_) => false);
    });
  }

  Future<void> _initprefsTodos() async {
    _prefsTodos = await SharedPreferences.getInstance();
    setState(() {
      _currentIndex = _prefsTodos.getInt('tabIndex') ?? 0;
      _isAlternateLayout = _prefsTodos.getBool('isAlternateLayout') ?? false;
      _areItemsExpanded = _prefsTodos.getBool('areItemsExpanded') ?? true;
      _tabController.index = _currentIndex;
    });
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      wallpaperOpacity = prefs.getDouble('wallpaperOpacity') ?? 0.8;
      backdropBlur = prefs.getDouble('backdropBlur') ?? 0.0;
    });
  }

  Future<void> _loadAccentColor() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        accentColor = userDoc.data()?['accentColor'] ?? '#FFFFFF';
      });
    }
  }

  Future<void> _loadWallpaperUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        wallpaperUrl = userDoc.data()?['wallpaper'];
      });
    }
  }

  Future<void> _loadProfileImageUrl() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final isGoogleUser = user.providerData
            .any((provider) => provider.providerId == 'google.com');

        if (isGoogleUser && user.photoURL != null) {
          String photoUrl = user.photoURL!;
          if (photoUrl.isNotEmpty) {
            if (!photoUrl.startsWith('https:')) {
              photoUrl = photoUrl.replaceFirst('http:', 'https:');
            }

            setState(() {
              profileImageUrl = photoUrl;
            });
            print("URL de imagen cargada: $photoUrl");
          } else {
            setState(() {
              profileImageUrl = null;
            });
          }
        } else {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          final photoUrl = userDoc.data()?['profilePicture'];
          if (photoUrl != null && photoUrl.isNotEmpty) {
            setState(() {
              profileImageUrl = photoUrl;
            });
          } else {
            setState(() {
              profileImageUrl = null;
            });
          }
        }
      }
    } catch (e) {
      print("Error cargando imagen de perfil: $e");
      setState(() {
        profileImageUrl = null;
      });
    }
  }

  Future<void> _loadUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Primero intentamos obtener el nombre de Google
      if (user.displayName != null) {
        setState(() {
          username = user.displayName;
        });
      } else {
        // Si no hay nombre de Google, buscamos en Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          username = userDoc.data()?['username'] ?? user.email?.split('@')[0];
        });
      }
    }
  }

  Future<void> _loadWallpaperSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        wallpaperUrl = userDoc.data()?['wallpaper'];
        wallpaperOpacity = userDoc.data()?['wallpaperOpacity'] ?? 0.8;
        backdropBlur = userDoc.data()?['backdropBlur'] ?? 0.0;
      });
    }
  }

  void _handleTabSelection() {
    setState(() {
      _currentIndex = _tabController.index;
      _prefsTodos.setInt('tabIndex', _currentIndex);
    });
  }

  Future<void> _toggleLayout() async {
    setState(() {
      _isAlternateLayout = !_isAlternateLayout;
      // Si cambiamos al layout alternativo, seleccionamos el primer elemento
      if (_isAlternateLayout) {
        _expandedNoteIndex = 0;
        _expandedTaskIndex = 0;
      } else {
        // Si volvemos al layout normal, reseteamos los índices
        _expandedNoteIndex = -1;
        _expandedTaskIndex = -1;
      }
      _prefsTodos.setBool('isAlternateLayout', _isAlternateLayout);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _listTabController.dispose();
    super.dispose();
  }

  void _showModal(
      BuildContext context, ModalInfo modal, ModalProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LayoutBuilder(builder: (context, constraints) {
          double dialogWidth;
          if (constraints.maxWidth > 1200) {
            dialogWidth = 650.0;
          } else if (constraints.maxWidth > 800) {
            dialogWidth = 600.0;
          } else {
            dialogWidth = constraints.maxWidth * 1;
          }

          return Center(
            child: FadeInUp(
              from: 50,
              curve: Curves.easeInOutCubicEmphasized,
              duration: const Duration(milliseconds: 800),
              child: AlertDialog(
                icon: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FButton.icon(
                      style: FButtonStyle.secondary,
                      child: FIcon(FAssets.icons.x),
                      onPress: () {
                        provider.markModalAsShown(modal.id);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                insetPadding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                contentPadding: EdgeInsets.all(16),
                content: Container(
                  width: dialogWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          modal.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (modal.imageAsset.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            modal
                                .imageAsset, // Reemplázalo con la imagen adecuada
                            width: 200,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          modal.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (modal.link.isNotEmpty)
                        FButton(
                          label: Text('saber mas'),
                          onPress: () => _openLink(modal.link),
                        ),
                      FButton(
                        label: const Text('cerrar'),
                        style: FButtonStyle.destructive,
                        onPress: () {
                          provider.markModalAsShown(modal.id);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('No se pudo abrir el enlace: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final modalProvider = Provider.of<ModalProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (modalProvider.activeModals.isNotEmpty) {
        if (ModalRoute.of(context)?.isCurrent ?? true) {
          // Prevenir superposiciones
          _showModal(context, modalProvider.activeModals.first, modalProvider);
        }
      }
    });
    final themeNotifier = Provider.of<ThemeModeNotifier>(context);

    super.build(context);

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please login first.'));
    }

    return MultiProvider(
      providers: [
        StreamProvider<List<Note>>(
          create: (_) => FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('notes')
              .orderBy('createdAt', descending: true)
              .snapshots()
              .map((snapshot) => snapshot.docs
                  .map((doc) {
                    final data = doc.data();
                    return Note(
                      noteId: doc.id,
                      uid: user.uid,
                      title: data['title'] ?? 'No Title',
                      description: data['description'] ?? 'No Description',
                      importantNotes: data['importantNotes'] ?? false,
                      noteImage: data['noteImage'],
                      reminderDate: data['reminderDate'] != null
                          ? data['reminderDate'] as Timestamp
                          : null,
                      createdAt: data['createdAt'] != null
                          ? data['createdAt'] as Timestamp
                          : null,
                      isDeleted: data['isDeleted'] ?? false,
                      color: data['color'] ?? '#FFC107',
                    );
                  })
                  .where((note) => !note.isDeleted)
                  .toList()),
          initialData: const [],
        ),
        StreamProvider<List<Task>>(
          create: (_) => FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('lists')
              .orderBy('createdAt', descending: true)
              .snapshots()
              .map((snapshot) => snapshot.docs
                  .map((doc) {
                    final data = doc.data();
                    return Task(
                      taskId: doc.id,
                      uid: user.uid,
                      title: data['title'] ?? 'No Title',
                      description: data['description'] ?? 'No Description',
                      importantTask: data['importantTask'] ?? false,
                      isCompleted: data['isCompleted'] ?? false,
                      isDeleted: data['isDeleted'] ?? false,
                      taskImage: data['taskImage'],
                      reminderDate: data['reminderDate'] != null
                          ? data['reminderDate'] as Timestamp
                          : null,
                      createdAt: data['createdAt'] != null
                          ? data['createdAt'] as Timestamp
                          : null,
                      color: data['color'] ?? '#FFC107',
                    );
                  })
                  .where((task) => !task.isCompleted && !task.isDeleted)
                  .toList()),
          initialData: const [],
        ),
      ],
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: wallpaperUrl != null
              ? DecorationImage(
                  image: NetworkImage(wallpaperUrl!),
                  fit: BoxFit.cover,
                  opacity: 1.0 - wallpaperOpacity,
                )
              : null,
        ),
        child: backdropBlur > 0
            ? BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: backdropBlur,
                  sigmaY: backdropBlur,
                ),
                child: _buildScaffold(context),
              )
            : _buildScaffold(context),
      ),
    );
  }

  Widget buildButton(String text,
      {IconData? icon, Color? color, Widget? trailing, Function()? onTap}) {
    return bounce_pkg.Bounce(
      scaleFactor: 0.95,
      duration: const Duration(milliseconds: 250),
      tiltAngle: 0,
      cursor: SystemMouseCursors.click,
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(51, 0, 0, 0),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 5),
              FaIcon(
                icon,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Colors.black,
                size: 16,
              ),
            ],
            if (trailing != null) ...[
              const SizedBox(width: 10),
              trailing,
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
        backgroundColor: Theme.of(context)
            .scaffoldBackgroundColor
            .withOpacity(wallpaperUrl != null ? 1.0 - wallpaperOpacity : 1.0),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(
              kToolbarHeight + 80), // Altura del AppBar + TabBar
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: constraints.maxWidth * 0.85,
                  child: AppBar(
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.create_new_folder),
                        onPressed: () {
                          // Mostrar diálogo para crear colección
                          showDialog(
                            context: context,
                            builder: (context) {
                              final TextEditingController controller =
                                  TextEditingController();
                              String selectedColor =
                                  '#${Colors.blue.value.toRadixString(16).substring(2)}'; // Color inicial

                              return StatefulBuilder(
                                  // Usar StatefulBuilder para actualizar el estado del diálogo
                                  builder: (context, setState) {
                                return AlertDialog(
                                  title: Text(languageProvider
                                      .translate('new collection')),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: controller,
                                        decoration: InputDecoration(
                                          hintText: languageProvider
                                              .translate('collection name'),
                                          border: const OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Text(languageProvider
                                              .translate('select color')),
                                          const SizedBox(width: 16),
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: Text(languageProvider
                                                      .translate(
                                                          'select color')),
                                                  content:
                                                      SingleChildScrollView(
                                                    child: BlockPicker(
                                                      pickerColor: Color(
                                                          int.parse(
                                                              selectedColor
                                                                  .replaceFirst(
                                                                      '#',
                                                                      '0xff'))),
                                                      onColorChanged: (color) {
                                                        setState(() {
                                                          selectedColor =
                                                              '#${color.value.toRadixString(16).substring(2)}';
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Color(int.parse(
                                                    selectedColor.replaceFirst(
                                                        '#', '0xff'))),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                          languageProvider.translate('cancel')),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        final name = controller.text.trim();
                                        if (name.isNotEmpty) {
                                          final provider =
                                              Provider.of<CollectionsProvider>(
                                                  context,
                                                  listen: false);
                                          provider.createCollection(
                                              name, selectedColor);
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Text(
                                          languageProvider.translate('create')),
                                    ),
                                  ],
                                );
                              });
                            },
                          );
                        },
                        tooltip: languageProvider.translate('new collection'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.swap_horiz),
                        onPressed: _toggleLayout,
                        tooltip: 'Cambiar diseño',
                      ),
                      IconButton(
                        icon: Icon(_areItemsExpanded
                            ? Icons.expand_less
                            : Icons.expand_more),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return LayoutBuilder(
                                  builder: (context, constraints) {
                                double dialogWidth;
                                if (constraints.maxWidth > 1200) {
                                  dialogWidth = 650.0;
                                } else if (constraints.maxWidth > 800) {
                                  dialogWidth = 600.0;
                                } else {
                                  dialogWidth = constraints.maxWidth * 1;
                                }

                                return Center(
                                  child: FadeInUp(
                                    from: 50,
                                    curve: Curves.easeInOutCubicEmphasized,
                                    duration: const Duration(milliseconds: 800),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: dialogWidth,
                                          child: AlertDialog(
                                            insetPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 50,
                                                    horizontal: 24),
                                            icon: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                FButton.icon(
                                                  style: FButtonStyle.secondary,
                                                  child: FIcon(FAssets.icons.x),
                                                  onPress: () {},
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            contentPadding: EdgeInsets.all(16),
                                            content: Container(
                                              width: double.maxFinite,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  const Text(
                                                    "Prueba Gemini 2.0 Flash,\nnuestro modelo experimental",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.asset(
                                                      "assets/images/recursos/noConexion.png", // Reemplázalo con la imagen adecuada
                                                      width: 200,
                                                      height: 150,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  const Text(
                                                    "Ya puedes obtener una vista previa de uno de",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  FButton(
                                                    label:
                                                        const Text('saber mas'),
                                                    onPress: () {},
                                                  ),
                                                  FButton(
                                                    label: const Text('cerrar'),
                                                    style: FButtonStyle
                                                        .destructive,
                                                    onPress: () {},
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                            },
                          );
                        },
                        tooltip: 'Alternar vista',
                      ),
                      bounce_pkg.Bounce(
                        cursor: SystemMouseCursors.click,
                        duration: const Duration(milliseconds: 120),
                        onTap: () {
                          Future.delayed(const Duration(milliseconds: 50), () {
                            showDialog(
                              context: context,
                              barrierColor:
                                  Colors.transparent, // Fondo transparente
                              builder: (BuildContext context) {
                                return ProfileMenu(accentColor: accentColor);
                              },
                            );
                          });
                          // Mostrar el menú emergente debajo de la foto de perfil
                        },
                        child: Container(
                          height: 43,
                          width: 43,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                          ),
                          child: ClipOval(
                              child: profileImageUrl != null &&
                                      profileImageUrl!.isNotEmpty
                                  ? Image.network(
                                      profileImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        // Manejo mejorado del error
                                        if (error.toString().contains('429')) {
                                          // Implementar reintento con delay
                                          Future.delayed(Duration(seconds: 2),
                                              () {
                                            setState(() {
                                              // Forzar recarga de la imagen
                                              profileImageUrl = profileImageUrl;
                                            });
                                          });
                                        }

                                        // Mientras tanto mostrar un placeholder
                                        return Icon(
                                          Icons.person,
                                          size: 30,
                                          color: Colors.grey[500],
                                        );
                                      },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Colors.grey[500],
                                    )),
                        ),
                      ),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(80.0),
                      child: SizedBox(
                        height: 60,
                        width: double.infinity,
                        child: TabBar(
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                          tabAlignment: TabAlignment.start,
                          isScrollable: true,
                          physics: const BouncingScrollPhysics(),
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Color(int.parse(
                                accentColor.replaceFirst('#', '0xff'))),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          controller: _tabController,
                          tabs: List.generate(4, (index) {
                            return MouseRegion(
                              onEnter: (_) =>
                                  setState(() => _hoverStates[index] = true),
                              onExit: (_) =>
                                  setState(() => _hoverStates[index] = false),
                              child: Container(
                                height: 40,
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  color: _hoverStates[index] &&
                                          _tabController.index != index
                                      ? Theme.of(context).brightness ==
                                              Brightness.light
                                          ? const Color.fromARGB(24, 0, 0, 0)
                                          : const Color.fromARGB(
                                              33, 255, 255, 255)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      transitionBuilder: (child, animation) =>
                                          FadeTransition(
                                              opacity: animation, child: child),
                                      child: Text(
                                        [
                                          languageProvider.translate('notes'),
                                          languageProvider.translate('tasks'),
                                          languageProvider
                                              .translate('importants'),
                                          languageProvider
                                              .translate('collections'),
                                        ][index],
                                        key: ValueKey(
                                            _tabController.index == index),
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: _tabController.index == index
                                              ? ThemeData.estimateBrightnessForColor(
                                                          Color(int.parse(
                                                              accentColor
                                                                  .replaceFirst(
                                                                      '#',
                                                                      '0xff')))) ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black
                                              : null,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(
                                      [
                                        FontAwesomeIcons.stickyNote,
                                        FontAwesomeIcons.check,
                                        FontAwesomeIcons.star,
                                        FontAwesomeIcons.folder,
                                      ][index],
                                      size: 20,
                                      color: _tabController.index == index
                                          ? ThemeData.estimateBrightnessForColor(
                                                      Color(int.parse(
                                                          accentColor
                                                              .replaceFirst('#',
                                                                  '0xff')))) ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    centerTitle: false,
                    title: Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: languageProvider.translate('welcome'),
                          ),
                          TextSpan(
                            text: username ?? '',
                          ),
                        ]),
                      ),
                    ),
                    elevation: 0,
                  ),
                );
              },
            ),
          ),
        ),
        body:
            _isAlternateLayout ? _buildAlternateLayout() : _buildNormalLayout(),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildButton(
                color: Color(int.parse(accentColor.replaceFirst('#', '0xff'))),
                languageProvider.translate('notes'),
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return RawKeyboardListener(
                        focusNode: FocusNode(),
                        autofocus: true,
                        onKey: (RawKeyEvent event) {
                          if (event.logicalKey == LogicalKeyboardKey.escape) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: LayoutBuilder(builder: (context, constraints) {
                          double dialogWidth;
                          if (constraints.maxWidth > 1200) {
                            dialogWidth = 650.0;
                          } else if (constraints.maxWidth > 800) {
                            dialogWidth = 600.0;
                          } else {
                            dialogWidth = constraints.maxWidth * 1;
                          }

                          return Center(
                            child: FadeInUp(
                              from: 50,
                              curve: Curves.easeInOutCubicEmphasized,
                              duration: const Duration(milliseconds: 350),
                              child: AlertDialog(
                                insetPadding: const EdgeInsets.symmetric(
                                    vertical: 30, horizontal: 24),
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                contentPadding: EdgeInsets.all(16),
                                content: Container(
                                  width: dialogWidth,
                                  height:
                                      MediaQuery.of(context).size.height * 0.75,
                                  child: CreateNotePage(),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  );
                },
                icon: FontAwesomeIcons.noteSticky,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildButton(
                color: Color(int.parse(accentColor.replaceFirst('#', '0xff'))),
                languageProvider.translate('tasks'),
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return RawKeyboardListener(
                        focusNode: FocusNode(),
                        autofocus: true,
                        onKey: (RawKeyEvent event) {
                          if (event.logicalKey == LogicalKeyboardKey.escape) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: LayoutBuilder(builder: (context, constraints) {
                          double dialogWidth;
                          if (constraints.maxWidth > 1200) {
                            dialogWidth = 650.0;
                          } else if (constraints.maxWidth > 800) {
                            dialogWidth = 600.0;
                          } else {
                            dialogWidth = constraints.maxWidth * 1;
                          }

                          return Center(
                            child: FadeInUp(
                              from: 50,
                              curve: Curves.easeInOutCubicEmphasized,
                              duration: const Duration(milliseconds: 350),
                              child: AlertDialog(
                                insetPadding: const EdgeInsets.symmetric(
                                    vertical: 30, horizontal: 24),
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                contentPadding: EdgeInsets.all(16),
                                content: Container(
                                  width: dialogWidth,
                                  height:
                                      MediaQuery.of(context).size.height * 0.75,
                                  child: CreateTaskPage(),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  );
                },
                icon: FontAwesomeIcons.times,
              ),
            ),
          ],
        ));
  }

  Widget _buildNormalLayout() {
    return TabBarView(
      controller: _tabController,
      children: [
        // ==================== Notas
        Consumer<List<Note>>(
          builder: (context, notes, _) {
            if (notes.isEmpty) {
              return ShimmerLoading(
                child: NotesShimmer(),
              );
            }
            // Filtrar las notas que no están eliminadas
            final activeNotes = notes.where((note) => !note.isDeleted).toList();

            if (activeNotes.isEmpty) {
              return const Center(child: Text('No hay notas disponibles.'));
            }
            return NoteListScreen(notes: activeNotes);
          },
        ),

        // ==================== tareas
        Consumer<List<Task>>(
          builder: (context, tasks, _) {
            if (tasks.isEmpty) {
              return ShimmerLoading(
                child: TasksShimmer(),
              );
            }
            // ... existing code ...
            final activeTasks = tasks
                .where((task) => !task.isDeleted && !task.isCompleted)
                .toList();

            if (activeTasks.isEmpty) {
              return const Center(child: Text('No hay tareas disponibles.'));
            }
            return _isAlternateLayout
                ? _buildTasksAlternateLayout(activeTasks)
                : TaskListScreen(tasks: activeTasks);
          },
        ),

        // Destacados
        Consumer2<List<Note>, List<Task>>(
          builder: (context, notes, tasks, _) {
            final importantNotes =
                notes.where((note) => note.importantNotes).toList();
            final importantTasks =
                tasks.where((task) => task.importantTask).toList();

            if (importantNotes.isEmpty && importantTasks.isEmpty) {
              return const Center(child: Text('No hay elementos destacados.'));
            }

            return Column(
              children: [
                LayoutBuilder(builder: (context, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth * 0.85,
                    child: TabBar(
                      controller: _listTabController,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      indicatorPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(text: 'Notas Importantes'),
                        Tab(text: 'Tareas Importantes'),
                      ],
                    ),
                  );
                }),
                Expanded(
                  child: TabBarView(
                    controller: _listTabController,
                    children: [
                      // Tab de notas importantes
                      importantNotes.isEmpty
                          ? const Center(
                              child: Text('No hay notas importantes'))
                          : NoteListScreen(notes: importantNotes),

                      // Tab de tareas importantes
                      importantTasks.isEmpty
                          ? const Center(
                              child: Text('No hay tareas importantes'))
                          : TaskListScreen(tasks: importantTasks),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const CollectionsGridView(),
      ],
    );
  }

  Widget _buildAlternateLayout() {
    return TabBarView(
      controller: _tabController,
      children: [
        // Notas
        Consumer<List<Note>>(
          builder: (context, notes, _) {
            final activeNotes = notes.where((note) => !note.isDeleted).toList();

            if (activeNotes.isEmpty) {
              return const Center(child: Text('No hay notas disponibles.'));
            }

            if (_expandedNoteIndex == -1 && activeNotes.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _expandedNoteIndex = 0;
                });
              });
            }

            return Row(
              children: [
                Flexible(
                  flex: 2,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: ListView.builder(
                      itemCount: activeNotes.length,
                      itemBuilder: (context, index) {
                        final note = activeNotes[index];
                        return bounce_pkg.Bounce(
                          duration: const Duration(milliseconds: 120),
                          onTap: () {
                            setState(() {
                              _expandedNoteIndex = index;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: AnimatedScaleWrapper(
                                initialColor: Color(int.parse(
                                    note.color.replaceFirst('#', '0xff'))),
                                hoverColor: Color(int.parse(
                                        note.color.replaceFirst('#', '0xff')))
                                    .withOpacity(0.8),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              note.title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (note
                                                .description.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                note.description,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (note.noteImage != null &&
                                          note.noteImage!.isNotEmpty) ...[
                                        const SizedBox(width: 12),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            note.noteImage!,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  color: Colors.grey[400],
                                                  size: 30,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ] else ...[
                                        const SizedBox(width: 12),
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.description_outlined,
                                            color: Colors.grey[400],
                                            size: 30,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Flexible(
                  flex: 5,
                  child: _expandedNoteIndex >= 0 &&
                          _expandedNoteIndex < activeNotes.length
                      ? modelCard(
                          note: activeNotes[_expandedNoteIndex],
                          isExpanded: true,
                          onTap: () {},
                        )
                      : const Center(child: Text('Selecciona una nota')),
                ),
              ],
            );
          },
        ),

        // Tareas
        Column(
          children: [
            LayoutBuilder(builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth * 0.85,
                child: TabBar(
                  controller: _listTabController,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  indicatorPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Todas'),
                    Tab(text: 'Completadas'),
                  ],
                ),
              );
            }),
            Expanded(
              child: TabBarView(
                controller: _listTabController,
                children: [
                  // Tab de todas las tareas
                  Consumer<List<Task>>(
                    builder: (context, tasks, _) {
                      final activeTasks = tasks
                          .where((task) => !task.isDeleted && !task.isCompleted)
                          .toList();

                      if (activeTasks.isEmpty) {
                        return const Center(
                            child: Text('No hay tareas disponibles.'));
                      }

                      return _isAlternateLayout
                          ? _buildTasksAlternateLayout(activeTasks)
                          : TaskListScreen(tasks: activeTasks);
                    },
                  ),
                  // Tab de tareas completadas
                  _isAlternateLayout
                      ? const CompletedTasksView()
                      : StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser?.uid)
                              .collection('lists')
                              .where('isCompleted', isEqualTo: true)
                              .where('isDeleted', isEqualTo: false)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                  child: Text('No hay tareas completadas.'));
                            }

                            final completedTasks =
                                snapshot.data!.docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return Task(
                                taskId: doc.id,
                                uid: FirebaseAuth.instance.currentUser!.uid,
                                title: data['title'] ?? 'No Title',
                                description:
                                    data['description'] ?? 'No Description',
                                importantTask: data['importantTask'] ?? false,
                                isCompleted: data['isCompleted'] ?? false,
                                isDeleted: data['isDeleted'] ?? false,
                                taskImage: data['taskImage'],
                                reminderDate: data['reminderDate'] != null
                                    ? data['reminderDate'] as Timestamp
                                    : null,
                                createdAt: data['createdAt'] != null
                                    ? data['createdAt'] as Timestamp
                                    : null,
                                color: data['color'] ?? '#FFFFFF',
                              );
                            }).toList();

                            return TaskListScreen(tasks: completedTasks);
                          },
                        ),
                ],
              ),
            ),
          ],
        ),

        // importantes
        Consumer2<List<Note>, List<Task>>(
          builder: (context, notes, tasks, _) {
            final importantNotes = notes
                .where((note) => note.importantNotes && !note.isDeleted)
                .toList();
            final importantTasks = tasks
                .where((task) =>
                    task.importantTask && !task.isDeleted && !task.isCompleted)
                .toList();

            if (importantNotes.isEmpty && importantTasks.isEmpty) {
              return const Center(child: Text('No hay elementos destacados.'));
            }

            // Inicializar automáticamente los índices si hay elementos
            if (importantNotes.isNotEmpty && _expandedNoteIndex == -1) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _expandedNoteIndex = 0;
                });
              });
            }
            if (importantTasks.isNotEmpty && _expandedTaskIndex == -1) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _expandedTaskIndex = 0;
                });
              });
            }

            return Column(
              children: [
                LayoutBuilder(builder: (context, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth * 0.85,
                    child: TabBar(
                      controller: _listTabController,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      indicatorPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(text: 'Notas Importantes'),
                        Tab(text: 'Tareas Importantes'),
                      ],
                    ),
                  );
                }),
                Expanded(
                  child: TabBarView(
                    controller: _listTabController,
                    children: [
                      // Tab de notas importantes
                      importantNotes.isEmpty
                          ? const Center(
                              child: Text('No hay notas importantes'))
                          : Row(
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: ListView.builder(
                                      itemCount: importantNotes.length,
                                      itemBuilder: (context, index) {
                                        final note = importantNotes[index];
                                        return bounce_pkg.Bounce(
                                          duration:
                                              const Duration(milliseconds: 120),
                                          onTap: () {
                                            setState(() {
                                              _expandedNoteIndex = index;
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4, horizontal: 8),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: AnimatedScaleWrapper(
                                                initialColor: Color(int.parse(
                                                    note.color.replaceFirst(
                                                        '#', '0xff'))),
                                                hoverColor: Color(int.parse(
                                                        note.color.replaceFirst(
                                                            '#', '0xff')))
                                                    .withOpacity(0.8),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              note.title,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            if (note.description
                                                                .isNotEmpty) ...[
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                note.description,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600],
                                                                  fontSize: 14,
                                                                ),
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                      if (note.noteImage !=
                                                              null &&
                                                          note.noteImage!
                                                              .isNotEmpty) ...[
                                                        const SizedBox(
                                                            width: 12),
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          child: Image.network(
                                                            note.noteImage!,
                                                            width: 60,
                                                            height: 60,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Container(
                                                                width: 60,
                                                                height: 60,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                          .grey[
                                                                      200],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: Icon(
                                                                  Icons
                                                                      .image_not_supported_outlined,
                                                                  color: Colors
                                                                          .grey[
                                                                      400],
                                                                  size: 30,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ] else ...[
                                                        const SizedBox(
                                                            width: 12),
                                                        Container(
                                                          width: 60,
                                                          height: 60,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey[200],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Icon(
                                                            Icons
                                                                .description_outlined,
                                                            color: Colors
                                                                .grey[400],
                                                            size: 30,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 5,
                                  child: _expandedNoteIndex >= 0 &&
                                          _expandedNoteIndex <
                                              importantNotes.length
                                      ? modelCard(
                                          note: importantNotes[
                                              _expandedNoteIndex],
                                          isExpanded: true,
                                          onTap: () {},
                                        )
                                      : const Center(
                                          child: Text('Selecciona una nota')),
                                ),
                              ],
                            ),

                      // Tab de tareas importantes
                      importantTasks.isEmpty
                          ? const Center(
                              child: Text('No hay tareas importantes'))
                          : Row(
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: ListView.builder(
                                      itemCount: importantTasks.length,
                                      itemBuilder: (context, index) {
                                        final task = importantTasks[index];
                                        return bounce_pkg.Bounce(
                                          duration:
                                              const Duration(milliseconds: 120),
                                          onTap: () {
                                            setState(() {
                                              _expandedTaskIndex = index;
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4, horizontal: 8),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: AnimatedScaleWrapper(
                                                initialColor: Color(int.parse(
                                                    task.color.replaceFirst(
                                                        '#', '0xff'))),
                                                hoverColor: Color(int.parse(
                                                        task.color.replaceFirst(
                                                            '#', '0xff')))
                                                    .withOpacity(0.8),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              task.title,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            const SizedBox(
                                                                height: 4),
                                                            if (task.description
                                                                .isNotEmpty)
                                                              Text(
                                                                task.description,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600],
                                                                  fontSize: 14,
                                                                ),
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      if (task.taskImage !=
                                                              null &&
                                                          task.taskImage!
                                                              .isNotEmpty) ...[
                                                        const SizedBox(
                                                            width: 12),
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          child: Image.network(
                                                            task.taskImage!,
                                                            width: 60,
                                                            height: 60,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Container(
                                                                width: 60,
                                                                height: 60,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                          .grey[
                                                                      200],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: Icon(
                                                                  Icons
                                                                      .image_not_supported_outlined,
                                                                  color: Colors
                                                                          .grey[
                                                                      400],
                                                                  size: 30,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ] else ...[
                                                        const SizedBox(
                                                            width: 12),
                                                        Container(
                                                          width: 60,
                                                          height: 60,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey[200],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Icon(
                                                            Icons
                                                                .description_outlined,
                                                            color: Colors
                                                                .grey[400],
                                                            size: 30,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 5,
                                  child: _expandedTaskIndex >= 0 &&
                                          _expandedTaskIndex <
                                              importantTasks.length
                                      ? TaskCard(
                                          task: importantTasks[
                                              _expandedTaskIndex],
                                          isExpanded: true,
                                          onTap: () {},
                                        )
                                      : const Center(
                                          child: Text('Selecciona una tarea')),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const CollectionsGridView(),
      ],
    );
  }

  Widget _buildTasksAlternateLayout(List<Task> tasks) {
    // Inicializar automáticamente el primer elemento si no hay ninguno seleccionado
    if (_expandedTaskIndex == -1 && tasks.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _expandedTaskIndex = 0;
        });
      });
    }

    return Row(
      children: [
        Flexible(
          flex: 2,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return bounce_pkg.Bounce(
                  duration: const Duration(milliseconds: 120),
                  onTap: () {
                    setState(() {
                      _expandedTaskIndex = index;
                    });
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedScaleWrapper(
                        initialColor: Color(
                            int.parse(task.color.replaceFirst('#', '0xff'))),
                        hoverColor: Color(
                                int.parse(task.color.replaceFirst('#', '0xff')))
                            .withOpacity(0.8),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    if (task.description.isNotEmpty)
                                      Text(
                                        task.description,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              if (task.taskImage != null &&
                                  task.taskImage!.isNotEmpty) ...[
                                const SizedBox(width: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    task.taskImage!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          color: Colors.grey[400],
                                          size: 30,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(width: 12),
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.description_outlined,
                                    color: Colors.grey[400],
                                    size: 30,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Flexible(
          flex: 5,
          child: _expandedTaskIndex >= 0 && _expandedTaskIndex < tasks.length
              ? TaskCard(
                  task: tasks[_expandedTaskIndex],
                  isExpanded: true,
                  onTap: () {},
                )
              : const Center(child: Text('Selecciona una tarea')),
        ),
      ],
    );
  }

  Widget _buildListsTab() {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth * 0.85,
            child: TabBar(
              controller: _listTabController,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              indicatorPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Todas'),
                Tab(text: 'Completadas'),
              ],
            ),
          );
        }),
        Expanded(
          child: TabBarView(
            controller: _listTabController,
            children: [
              // Tab de todas las tareas
              Consumer<List<Task>>(
                builder: (context, tasks, _) {
                  final activeTasks = tasks
                      .where((task) => !task.isDeleted && !task.isCompleted)
                      .toList();
                  if (activeTasks.isEmpty) {
                    return const Center(
                        child: Text('No hay tareas disponibles.'));
                  }
                  return _isAlternateLayout
                      ? _buildTasksAlternateLayout(activeTasks)
                      : TaskListScreen(tasks: activeTasks);
                },
              ),
              // Tab de tareas completadas
              _isAlternateLayout
                  ? const CompletedTasksView()
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .collection('lists')
                          .where('isCompleted', isEqualTo: true)
                          .where('isDeleted', isEqualTo: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text('No hay tareas completadas.'));
                        }

                        final completedTasks = snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return Task(
                            taskId: doc.id,
                            uid: FirebaseAuth.instance.currentUser!.uid,
                            title: data['title'] ?? 'No Title',
                            description:
                                data['description'] ?? 'No Description',
                            importantTask: data['importantTask'] ?? false,
                            isCompleted: data['isCompleted'] ?? false,
                            isDeleted: data['isDeleted'] ?? false,
                            taskImage: data['taskImage'],
                            reminderDate: data['reminderDate'] != null
                                ? data['reminderDate'] as Timestamp
                                : null,
                            createdAt: data['createdAt'] != null
                                ? data['createdAt'] as Timestamp
                                : null,
                            color: data['color'] ?? '#FFFFFF',
                          );
                        }).toList();

                        return TaskListScreen(tasks: completedTasks);
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// Widget para mantener el estado de los hijos
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({super.key, required this.child});

  @override
  _KeepAliveWrapperState createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}

// Implementación del ProfileMenu y sus componentes
class ProfileMenu extends StatefulWidget {
  final String accentColor;

  const ProfileMenu({super.key, required this.accentColor});

  @override
  State<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  String accentColor = '#FFFFFF';
  @override
  void initState() {
    super.initState();
    accentColor = widget.accentColor;
    _loadAccentColor();
  }

  Future<void> _loadAccentColor() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        accentColor = userDoc.data()?['accentColor'] ?? '#FFFFFF';
      });
    }
  }

  void _pickAccentColor() {
    // Obtener el proveedor de idioma
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    // Lista personalizada de colores pasteles
    final List<Color> pastelColors = [
      const Color(0xFFFF5722), // Naranja intenso
      const Color(0xFF4CAF50), // Verde
      const Color(0xFF3F51B5), // Azul oscuro
      const Color(0xFF03A9F4), // Azul claro
      const Color(0xFFFFEB3B), // Amarillo
      const Color(0xFFFF9800), // Naranja
      const Color(0xFF2196F3), // Azul
      const Color(0xFF00BCD4), // Cian
      const Color(0xFFCDDC39), // Lima
      const Color(0xFF009688), // Verde azulado
      const Color.fromARGB(255, 141, 228, 41), // Verde claro
      const Color(0xFFA7A7A7), // Gris claro
      const Color(0xFF9E9E9E), // Gris
      const Color(0xFF795548), // Café
      const Color(0xFF607D8B), // Azul grisáceo
      const Color(0xFFFFC207), // Amarillo intenso
      const Color(0xFFFFC107), // Amarillo anaranjado
      const Color(0xFF2E2E2E), // Gris oscuro
      const Color(0xFFFF9D00), // Naranja saturado
      const Color(0xFFF64336), // Rojo
    ];

    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (BuildContext context) {
        return [
          WoltModalSheetPage(
            isTopBarLayerAlwaysVisible: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            topBarTitle: Text(
              languageProvider
                  .translate('selectAccentColor'), // Traducción dinámica
              style: const TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SingleChildScrollView(
                    child: BlockPicker(
                      pickerColor: Color(
                          int.parse(accentColor.replaceFirst('#', '0xff'))),
                      availableColors: pastelColors,
                      onColorChanged: (Color color) {
                        setState(() {
                          accentColor =
                              '#${color.value.toRadixString(16).substring(2)}';
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        child: Text(languageProvider
                            .translate('cancel')), // Traducción dinámica
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text(languageProvider
                            .translate('accept')), // Traducción dinámica
                        onPressed: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .update({'accentColor': accentColor});
                          }
                          Navigator.of(context).pop();

                          // Remueve el overlayEntry después de la animación.
                          Future.delayed(const Duration(milliseconds: 2000),
                              () {
                            html.window.location.reload();
                          });

                          final overlay = Overlay.of(context);
                          OverlayEntry? overlayEntry;

                          // Variable para controlar la visibilidad.
                          bool isVisible = true;

                          // Función para iniciar la animación de fadeOut y remover el Toast.
                          void removeToast() {
                            if (!isVisible) return; // Evita múltiples llamadas.
                            isVisible = false;

                            // Actualiza la animación a fadeOut.
                            overlayEntry?.markNeedsBuild();

                            // Remueve el overlayEntry después de la animación.
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              overlayEntry?.remove();
                              overlayEntry = null;
                            });
                          }

                          // Crea el OverlayEntry.
                          overlayEntry = OverlayEntry(
                            builder: (context) => Positioned(
                              bottom: 20,
                              left: 20,
                              child: AnimatedOpacity(
                                opacity: isVisible ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: FadeIn(
                                  duration: const Duration(milliseconds: 120),
                                  child: Material(
                                    color: Colors
                                        .transparent, // Fondo transparente.
                                    child: SizedBox(
                                      width: 230,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: Container(
                                              width: 230,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.transparent,
                                              ),
                                              height: 230,
                                              child: Center(
                                                child: Lottie.asset(
                                                  renderCache:
                                                      RenderCache.raster,
                                                  'assets/lottieAnimations/animacionReload.json',
                                                  fit: BoxFit.contain,
                                                  repeat: false,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 230,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              color: const Color.fromARGB(
                                                  255, 29, 240, 99),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 15),
                                                  child: Text(
                                                    languageProvider
                                                        .translate('saved'),
                                                    style: const TextStyle(
                                                      fontFamily: "Roboto",
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 15),
                                                  child: FaIcon(
                                                    FontAwesomeIcons
                                                        .circleCheck,
                                                    size: 22,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
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

                          // Inserta el OverlayEntry.
                          overlay.insert(overlayEntry!);

                          // Activa el fadeOut después de 3 segundos.
                          Future.delayed(
                              const Duration(milliseconds: 3000), removeToast);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ];
      },
      modalTypeBuilder: (BuildContext context) {
        return WoltModalType.dialog();
      },
      barrierDismissible: true,
      useRootNavigator: true,
      useSafeArea: false,
    );
  }

  Future<void> _signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await FirebaseAuth.instance
        .signOut(); // Asegúrate de cerrar sesión en Firebase también

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  late final List<MenuOption> menuOptions;

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    double paddingHoverMenuOption = 5.0;

    return FadeInUp(
      curve: Curves.easeInOutCubicEmphasized,
      from: 20,
      duration: const Duration(milliseconds: 250),
      child: Stack(
        children: [
          Positioned(
            top: 50, // Ajusta según el tamaño del AppBar
            right: 80, // Posicionamiento similar al ejemplo
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(paddingHoverMenuOption),
                      child: HoverMenuOption(
                        text: languageProvider.translate('accent color'),
                        icon: Icons.color_lens,
                        onTap: _pickAccentColor,
                        accentColor: accentColor,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(paddingHoverMenuOption),
                      child: HoverMenuOption(
                        text: languageProvider.translate('select theme'),
                        icon: Icons.palette,
                        onTap: () {
                          WoltModalSheet.show<void>(
                            context: context,
                            pageListBuilder: (BuildContext context) {
                              return [
                                WoltModalSheetPage(
                                  isTopBarLayerAlwaysVisible: true,
                                  backgroundColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  topBarTitle: const Text(
                                    'Seleccionar tema',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.8,
                                    child: const ThemeChoice(),
                                  ),
                                ),
                              ];
                            },
                            modalTypeBuilder: (BuildContext context) {
                              return WoltModalType.dialog();
                            },
                            barrierDismissible: true,
                            useRootNavigator: true,
                            useSafeArea: false,
                          );
                        },
                        accentColor: accentColor,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(paddingHoverMenuOption),
                      child: HoverMenuOption(
                        text: languageProvider.translate('recycle bin'),
                        icon: Icons.delete_forever_rounded,
                        onTap: () {
                          WoltModalSheet.show<void>(
                            context: context,
                            pageListBuilder: (BuildContext context) {
                              return [
                                WoltModalSheetPage(
                                  isTopBarLayerAlwaysVisible: true,
                                  backgroundColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  topBarTitle: const Text(
                                    'papelera',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.8,
                                    child: const DeletedItemsPage(),
                                  ),
                                ),
                              ];
                            },
                            modalTypeBuilder: (BuildContext context) {
                              return WoltModalType.dialog();
                            },
                            barrierDismissible: true,
                            useRootNavigator: true,
                            useSafeArea: false,
                          );
                        },
                        accentColor: accentColor,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(paddingHoverMenuOption),
                      child: HoverMenuOption(
                        text: languageProvider.translate('change language'),
                        icon: FontAwesomeIcons.language,
                        onTap: () {
                          String newLanguage =
                              languageProvider.currentLanguage == 'es'
                                  ? 'en'
                                  : 'es';
                          languageProvider.changeLanguage(newLanguage);
                        },
                        accentColor: accentColor,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(paddingHoverMenuOption),
                      child: HoverMenuOption(
                        text: languageProvider.translate('background image'),
                        icon: Icons.image,
                        onTap: () {
                          WoltModalSheet.show<void>(
                            context: context,
                            pageListBuilder: (BuildContext context) {
                              return [
                                WoltModalSheetPage(
                                  isTopBarLayerAlwaysVisible: true,
                                  backgroundColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  topBarTitle: const Text(
                                    'Seleccionar fondo de pantalla',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.8,
                                    child: const WallpaperSelectionPage(),
                                  ),
                                ),
                              ];
                            },
                            modalTypeBuilder: (BuildContext context) {
                              return WoltModalType.dialog();
                            },
                            barrierDismissible: true,
                            useRootNavigator: true,
                            useSafeArea: false,
                          );
                        },
                        accentColor: accentColor,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(paddingHoverMenuOption),
                      child: HoverMenuOption(
                        text: languageProvider.translate('my account'),
                        icon: Icons.account_circle,
                        onTap: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            final userDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .get();
                            final userData = userDoc.data() ?? {};

                            WoltModalSheet.show<void>(
                              context: context,
                              pageListBuilder: (BuildContext context) {
                                return [
                                  WoltModalSheetPage(
                                    isTopBarLayerAlwaysVisible: true,
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    topBarTitle: const Text(
                                      "mi cuenta",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.8,
                                      child: paginaMiCuenta(
                                        user: user,
                                        userData: userData,
                                      ),
                                    ),
                                  ),
                                ];
                              },
                              modalTypeBuilder: (BuildContext context) {
                                return WoltModalType.dialog();
                              },
                              barrierDismissible: true,
                              useRootNavigator: true,
                              useSafeArea: false,
                            );
                          }
                        },
                        accentColor: accentColor,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(paddingHoverMenuOption),
                      child: HoverMenuOption(
                        text: languageProvider.translate('log out'),
                        icon: Icons.logout,
                        onTap: _signOut,
                        accentColor: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HoverMenuOption extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final String accentColor;

  const HoverMenuOption({
    required this.text,
    required this.icon,
    required this.onTap,
    required this.accentColor,
    super.key,
  });

  @override
  State<HoverMenuOption> createState() => _HoverMenuOptionState();
}

class _HoverMenuOptionState extends State<HoverMenuOption> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return bounce_pkg.Bounce(
      tiltAngle: 0.0,
      scaleFactor: 0.97,
      duration: const Duration(milliseconds: 80),
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() {
            isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            isHovered = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 0),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: isHovered
                ? Color(int.parse(widget.accentColor.replaceFirst('#', '0xff')))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.text,
                style: TextStyle(
                  color: isHovered
                      ? (ThemeData.estimateBrightnessForColor(Color(int.parse(
                                  widget.accentColor
                                      .replaceFirst('#', '0xff')))) ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      : Colors.black,
                  fontSize: 16,
                ),
              ),
              Icon(
                widget.icon,
                color: isHovered
                    ? (ThemeData.estimateBrightnessForColor(Color(int.parse(
                                widget.accentColor
                                    .replaceFirst('#', '0xff')))) ==
                            Brightness.dark
                        ? Colors.white
                        : Colors.black)
                    : Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modificar CompletedTasksView para usar TaskListScreen en layout normal
class CompletedTasksView extends StatefulWidget {
  const CompletedTasksView({super.key});

  @override
  State<CompletedTasksView> createState() => _CompletedTasksViewState();
}

class _CompletedTasksViewState extends State<CompletedTasksView> {
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(-1);
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _selectedIndexNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('lists')
          .where('isCompleted', isEqualTo: true)
          .where('isDeleted', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay tareas completadas.'));
        }

        final completedTasks = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Task(
            taskId: doc.id,
            uid: FirebaseAuth.instance.currentUser!.uid,
            title: data['title'] ?? 'No Title',
            description: data['description'] ?? 'No Description',
            importantTask: data['importantTask'] ?? false,
            isCompleted: data['isCompleted'] ?? false,
            isDeleted: data['isDeleted'] ?? false,
            taskImage: data['taskImage'],
            reminderDate: data['reminderDate'] != null
                ? data['reminderDate'] as Timestamp
                : null,
            createdAt: data['createdAt'] != null
                ? data['createdAt'] as Timestamp
                : null,
            color: data['color'] ?? '#FFFFFF',
          );
        }).toList();

        // Inicializar automáticamente el primer elemento si no hay ninguno seleccionado
        if (_selectedIndexNotifier.value == -1 && completedTasks.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _selectedIndexNotifier.value = 0;
          });
        }

        return Row(
          children: [
            Flexible(
              flex: 2,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: completedTasks.length,
                  itemBuilder: (context, index) {
                    final task = completedTasks[index];
                    return ValueListenableBuilder<int>(
                      valueListenable: _selectedIndexNotifier,
                      builder: (context, selectedIndex, _) {
                        return bounce_pkg.Bounce(
                          duration: const Duration(milliseconds: 120),
                          onTap: () {
                            _selectedIndexNotifier.value = index;
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: AnimatedScaleWrapper(
                                initialColor: Color(int.parse(
                                    task.color.replaceFirst('#', '0xff'))),
                                hoverColor: Color(int.parse(
                                        task.color.replaceFirst('#', '0xff')))
                                    .withOpacity(0.8),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task.title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (task
                                                .description.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                task.description,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (task.taskImage != null &&
                                          task.taskImage!.isNotEmpty) ...[
                                        const SizedBox(width: 12),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            task.taskImage!,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  color: Colors.grey[400],
                                                  size: 30,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ] else ...[
                                        const SizedBox(width: 12),
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.description_outlined,
                                            color: Colors.grey[400],
                                            size: 30,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Flexible(
              flex: 5,
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedIndexNotifier,
                builder: (context, selectedIndex, _) {
                  return selectedIndex >= 0 &&
                          selectedIndex < completedTasks.length
                      ? TaskCard(
                          task: completedTasks[selectedIndex],
                          isExpanded: true,
                          onTap: () {},
                        )
                      : const Center(child: Text('Selecciona una tarea'));
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  final Widget child;

  const ShimmerLoading({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      color: Colors.grey[300]!,
      direction: const ShimmerDirection.fromLTRB(),
      interval: const Duration(milliseconds: 500),
      enabled: true,
      colorOpacity: 0.2,
      child: child,
    );
  }
}

class NotesShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 24,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TasksShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 20,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 200,
                        height: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
