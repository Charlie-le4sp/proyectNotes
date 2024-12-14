import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notes_app/DeletedItemsPage.dart';
import 'package:notes_app/DisplayWallpaperPage.dart';
import 'package:notes_app/WallpaperSelectionPage.dart';
import 'package:notes_app/componentes/AnimatedFloatingMenu.dart';
import 'package:notes_app/list/CompletedTaskPage.dart';
import 'package:notes_app/list/CreateTaskPage.dart';
import 'package:notes_app/list/EditTaskPage.dart';
import 'package:notes_app/list/modelCardTask.dart';
import 'package:notes_app/notes/EditNotePage.dart';

import 'package:notes_app/notes/modelCardNote.dart';

import 'package:notes_app/notes/CreateNotePage.dart';
import 'package:notes_app/login%20android%20y%20web%20autentication/login_page.dart';
import 'package:notes_app/paginaMiCuenta.dart';
import 'package:notes_app/pruebas/popUpMenuPrueba.dart';
import 'package:notes_app/pruebas/pruebaIdioma.dart';
import 'package:notes_app/pruebas/pruebaThema.dart';
import 'package:notes_app/themas/themeChoice.dart';
import 'package:notes_app/themas/themeModeNotifier.dart';
import 'package:notes_app/themas/themes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

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
  int _expandedNoteIndex = 0;
  bool _areItemsExpanded = true;

  String? wallpaperUrl; // Variable para almacenar la URL del wallpaper
  String?
      profileImageUrl; // Variable para almacenar la URL de la imagen de perfil

  String? username;

  double wallpaperOpacity = 0.8;
  double backdropBlur = 0.0;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();

    _initprefsTodos();
    _tabController = TabController(length: 3, vsync: this);
    _listTabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadAccentColor(); // Cargar el color de énfasis al iniciar
    _loadWallpaperUrl(); // Cargar la URL del wallpaper al iniciar
    _loadProfileImageUrl(); // Cargar la URL de la imagen de perfil al iniciar
    _loadUsername();
    _initPrefs();
    _loadWallpaperSettings();
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
      _prefsTodos.setBool('isAlternateLayout', _isAlternateLayout);
    });
  }

  Future<void> _toggleItemsExpanded() async {
    setState(() {
      _areItemsExpanded = !_areItemsExpanded;
      _prefsTodos.setBool('areItemsExpanded', _areItemsExpanded);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _listTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

  Widget _buildScaffold(BuildContext context) {
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
              return Container(
                width: constraints.maxWidth * 0.85,
                child: AppBar(
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: _toggleLayout,
                      tooltip: 'Cambiar diseño',
                    ),
                    IconButton(
                      icon: Icon(_areItemsExpanded
                          ? Icons.expand_less
                          : Icons.expand_more),
                      onPressed: _toggleItemsExpanded,
                      tooltip: 'Alternar vista',
                    ),
                    InkWell(
                      onTap: () {
                        // Mostrar el menú emergente debajo de la foto de perfil
                        showDialog(
                          context: context,
                          barrierColor:
                              Colors.transparent, // Fondo transparente
                          builder: (BuildContext context) {
                            return ProfileMenu(accentColor: accentColor);
                          },
                        );
                      },
                      child: Container(
                        height: 43,
                        width: 43,
                        margin: EdgeInsets.symmetric(horizontal: 8),
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
                                  errorBuilder: (context, error, stackTrace) {
                                    print("Error loading image: $error");
                                    return Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Colors.grey[500],
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
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
                                ),
                        ),
                      ),
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(80.0),
                    child: SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: TabBar(
                        labelPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                        indicatorPadding:
                            EdgeInsets.symmetric(horizontal: 1, vertical: 8),
                        tabAlignment: TabAlignment.start,
                        isScrollable: true,
                        physics: const BouncingScrollPhysics(),
                        labelColor: ThemeData.estimateBrightnessForColor(Color(
                                    int.parse(accentColor.replaceFirst(
                                        '#', '0xff')))) ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        labelStyle: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Color(int.parse(
                                accentColor.replaceFirst('#', '0xff')))),
                        controller: _tabController,
                        tabs: [
                          Tab(
                            child: Row(
                              children: [
                                Text(
                                  "notes",
                                  style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  height: 28,
                                  width: 28,
                                  child: Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Center(
                                      child: FaIcon(
                                        FontAwesomeIcons.stickyNote,
                                        size: 20,
                                        color: (ThemeData.estimateBrightnessForColor(
                                                        Color(int.parse(
                                                            accentColor
                                                                .replaceFirst(
                                                                    '#',
                                                                    '0xff')))) ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black)
                                            .withOpacity(
                                                _tabController.index == 0
                                                    ? 1.0
                                                    : 0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              children: [
                                Text(
                                  'tareas',
                                  style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 10),
                                FaIcon(
                                  FontAwesomeIcons.check,
                                  size: 20,
                                  color: (ThemeData.estimateBrightnessForColor(
                                                  Color(int.parse(
                                                      accentColor.replaceFirst(
                                                          '#', '0xff')))) ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black)
                                      .withOpacity(_tabController.index == 1
                                          ? 1.0
                                          : 0.3),
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              children: [
                                Text(
                                  'destacados',
                                  style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 10),
                                FaIcon(
                                  FontAwesomeIcons.star,
                                  size: 20,
                                  color: (ThemeData.estimateBrightnessForColor(
                                                  Color(int.parse(
                                                      accentColor.replaceFirst(
                                                          '#', '0xff')))) ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black)
                                      .withOpacity(_tabController.index == 2
                                          ? 1.0
                                          : 0.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  centerTitle: false,
                  title: Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text(
                      "Holiii 😆, ${username ?? ''}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  elevation: 0,
                ),
              );
            },
          ),
        ),
      ),
      body: _isAlternateLayout ? _buildAlternateLayout() : _buildNormalLayout(),
      floatingActionButton: AnimatedFloatingMenu(
        accentColor: accentColor,
        onNoteTap: () {
          WoltModalSheet.show<void>(
            context: context,
            pageListBuilder: (BuildContext context) {
              return [
                WoltModalSheetPage(
                  isTopBarLayerAlwaysVisible: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  topBarTitle: Text(
                    'Crear Nota',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: CreateNotePage(),
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
        onTaskTap: () {
          WoltModalSheet.show<void>(
            context: context,
            pageListBuilder: (BuildContext context) {
              return [
                WoltModalSheetPage(
                  isTopBarLayerAlwaysVisible: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  topBarTitle: Text(
                    'Crear Tarea',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: CreateTaskPage(),
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
      ),
    );
  }

  Widget _buildNormalLayout() {
    return TabBarView(
      controller: _tabController,
      children: [
        // ==================== Notas
        Consumer<List<Note>>(
          builder: (context, notes, _) {
            // Filtrar las notas que no están eliminadas
            final activeNotes = notes.where((note) => !note.isDeleted).toList();

            if (activeNotes.isEmpty) {
              return const Center(child: Text('No hay notas disponibles.'));
            }
            return NoteListScreen(notes: activeNotes);
          },
        ),

        // ==================== tareas
        _buildListsTab(),

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

            return NoteListScreen(
              notes: importantNotes,
            );
          },
        ),
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
            return Row(
              children: [
                Flexible(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: activeNotes.length,
                    itemBuilder: (context, index) {
                      final note = activeNotes[index];
                      return ListTile(
                        title: Text(note.title),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (note.noteImage != null)
                              Image.network(
                                note.noteImage!,
                                width: 50,
                                height: 50,
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditNotePage(
                                      noteId: note.noteId,
                                      noteData: {
                                        'title': note.title,
                                        'description': note.description,
                                        'noteImage': note.noteImage,
                                        'reminderDate': note.reminderDate,
                                        'importantNotes': note.importantNotes,
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _expandedNoteIndex = index;
                          });
                        },
                      );
                    },
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: _expandedNoteIndex != -1 &&
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
        // Listas
        Consumer<List<Task>>(
          builder: (context, tasks, _) {
            final activeTasks = tasks.where((task) => !task.isDeleted).toList();

            if (activeTasks.isEmpty) {
              return const Center(child: Text('No hay tareas disponibles.'));
            }
            return Row(
              children: [
                Flexible(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: activeTasks.length,
                    itemBuilder: (context, index) {
                      final task = activeTasks[index];
                      return ListTile(
                        title: Text(task.title),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (task.taskImage != null)
                              Image.network(
                                task.taskImage!,
                                width: 50,
                                height: 50,
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTaskPage(
                                      taskId: task.taskId,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                // Lógica para eliminar la tarea
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _expandedNoteIndex = index;
                          });
                        },
                      );
                    },
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: _expandedNoteIndex != -1 &&
                          _expandedNoteIndex < activeTasks.length
                      ? TaskCard(
                          task: activeTasks[_expandedNoteIndex],
                          isExpanded: true,
                          onTap: () {},
                        )
                      : const Center(child: Text('Selecciona una tarea')),
                ),
              ],
            );
          },
        ),
        // Destacados
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

            return NoteListScreen(
              notes: importantNotes,
            );
          },
        ),
      ],
    );
  }

  Widget _buildListsTab() {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth * 0.85,
            child: TabBar(
              controller: _listTabController,
              indicatorPadding:
                  EdgeInsets.symmetric(horizontal: 15, vertical: 8),
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
        // Contenido de las subtabs
        Expanded(
          child: TabBarView(
            controller: _listTabController,
            children: [
              // Tab de todas las tareass
              Consumer<List<Task>>(
                builder: (context, tasks, _) {
                  final activeTasks = tasks
                      .where((task) => !task.isDeleted && !task.isCompleted)
                      .toList();
                  if (activeTasks.isEmpty) {
                    return const Center(
                        child: Text('No hay tareas disponibles.'));
                  }
                  return TaskListScreen(tasks: activeTasks);
                },
              ),
              // Tab de tareass completadas
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('lists')
                    .where('isCompleted', isEqualTo: true)
                    .where('isDeleted', isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No hay tareas completadas.'));
                  }

                  final completedTasks = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Task(
                      taskId: doc.id,
                      uid: user!.uid,
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

  ProfileMenu({Key? key, required this.accentColor}) : super(key: key);

  @override
  State<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  String accentColor = '#FFFFFF';

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
    // Lista personalizada de colores pasteles
    final List<Color> pastelColors = [
      Color(0xFFFF5722), // Naranja intenso
      Color(0xFF4CAF50), // Verde
      Color(0xFF3F51B5), // Azul oscuro
      Color(0xFF03A9F4), // Azul claro
      Color(0xFFFFEB3B), // Amarillo
      Color(0xFFFF9800), // Naranja
      Color(0xFF2196F3), // Azul
      Color(0xFF00BCD4), // Cian
      Color(0xFFCDDC39), // Lima
      Color(0xFF009688), // Verde azulado
      Color.fromARGB(255, 141, 228, 41), // Verde claro
      Color(0xFFA7A7A7), // Gris claro
      Color(0xFF9E9E9E), // Gris
      Color(0xFF795548), // Café
      Color(0xFF607D8B), // Azul grisáceo
      Color(0xFFFFC207), // Amarillo intenso
      Color(0xFFFFC107), // Amarillo anaranjado
      Color(0xFF2E2E2E), // Gris oscuro
      Color(0xFFFF9D00), // Naranja saturado
      Color(0xFFF64336), // Rojo
    ];

    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (BuildContext context) {
        return [
          WoltModalSheetPage(
            isTopBarLayerAlwaysVisible: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            topBarTitle: const Text(
              'Selecciona un color de énfasis',
              style: TextStyle(
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
                        child: const Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Aceptar'),
                        onPressed: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .update({'accentColor': accentColor});
                          }
                          Navigator.of(context).pop();
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
  void initState() {
    super.initState();

    menuOptions = [
      MenuOption(
        text: "color de énfasis",
        icon: Icons.palette,
        onTap: () {
          _pickAccentColor();
        },
      ),
      MenuOption(
        text: "mi cuenta",
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
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    topBarTitle: Text(
                      "mi cuenta",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.8,
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
      ),
      MenuOption(
        text: "Idioma / Language",
        icon: FontAwesomeIcons.trash,
        onTap: () {
          WoltModalSheet.show<void>(
            context: context,
            pageListBuilder: (BuildContext context) {
              return [
                WoltModalSheetPage(
                  isTopBarLayerAlwaysVisible: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  topBarTitle: Text(
                    'Idioma / Language',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
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
      ),
      MenuOption(
        text: "papelera",
        icon: FontAwesomeIcons.trash,
        onTap: () {
          WoltModalSheet.show<void>(
            context: context,
            pageListBuilder: (BuildContext context) {
              return [
                WoltModalSheetPage(
                  isTopBarLayerAlwaysVisible: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  topBarTitle: Text(
                    'papelera',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: DeletedItemsPage(),
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
      ),
      MenuOption(
        text: "imagen de fondo",
        icon: Icons.check_circle,
        onTap: () {
          WoltModalSheet.show<void>(
            context: context,
            pageListBuilder: (BuildContext context) {
              return [
                WoltModalSheetPage(
                  isTopBarLayerAlwaysVisible: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  topBarTitle: Text(
                    'Seleccionar fondo de pantalla',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: WallpaperSelectionPage(),
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
      ),
      MenuOption(
        text: "seleccionar tema",
        icon: Icons.folder,
        onTap: () {
          WoltModalSheet.show<void>(
            context: context,
            pageListBuilder: (BuildContext context) {
              return [
                WoltModalSheetPage(
                  isTopBarLayerAlwaysVisible: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  topBarTitle: Text(
                    'Seleccionar tema',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: ThemeChoice(),
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
      ),
      MenuOption(
        text: "cerrar sesion",
        icon: Icons.logout, // Cambiado a un ícono más apropiado
        onTap: () async {
          await _signOut();
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
                  children: menuOptions.map((option) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 8.0), // Espaciado vertical
                      child: HoverMenuOption(
                        text: option.text,
                        icon: option.icon,
                        onTap: option.onTap, // Usar la función onTap específica
                        accentColor: widget.accentColor,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuOption {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const MenuOption({
    required this.text,
    required this.icon,
    required this.onTap,
  });
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
    Key? key,
  }) : super(key: key);

  @override
  State<HoverMenuOption> createState() => _HoverMenuOptionState();
}

class _HoverMenuOptionState extends State<HoverMenuOption> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
