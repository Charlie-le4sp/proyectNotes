import 'package:animate_do/animate_do.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notes_app/DeletedItemsPage.dart';
import 'package:notes_app/DisplayWallpaperPage.dart';
import 'package:notes_app/WallpaperSelectionPage.dart';
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
import 'package:notes_app/pruebas/pruebaThema.dart';
import 'package:notes_app/themas/themeChoice.dart';
import 'package:notes_app/themas/themeModeNotifier.dart';
import 'package:notes_app/themas/themes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';

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

  String accentColor = '#FFFFFF';

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
        // Verificar si el usuario se registró con Google
        final isGoogleUser = user.providerData
            .any((provider) => provider.providerId == 'google.com');

        if (isGoogleUser) {
          // Usuario de Google
          if (user.photoURL != null) {
            print("Usuario de Google con foto: ${user.photoURL}"); // Debug
            setState(() {
              profileImageUrl = user.photoURL;
            });
          } else {
            print("Usuario de Google sin foto de perfil."); // Debug
          }
        } else {
          // Usuario normal
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          final photoUrl = userDoc.data()?['profilePicture'];
          print("Foto de Firestore: $photoUrl"); // Debug

          setState(() {
            profileImageUrl = photoUrl;
          });
        }
      }
    } catch (e) {
      print("Error cargando imagen de perfil: $e");
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
              .map((snapshot) => snapshot.docs.map((doc) {
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
                  }).toList()),
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
                width: constraints.maxWidth *
                    0.85, // Ajargentina bofetadas xxxusta este valor según necesites (80% del ancho)
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
                      child:
                          profileImageUrl != null && profileImageUrl!.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    height: 65,
                                    width: 65,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(profileImageUrl!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: profileImageUrl != null &&
                                          profileImageUrl!.isNotEmpty
                                      ? NetworkImage(profileImageUrl!)
                                      : null,
                                  child: profileImageUrl == null ||
                                          profileImageUrl!.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          size: 20,
                                          color: Colors.grey[500],
                                        )
                                      : null,
                                ),
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(80.0),
                    child: SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: TabBar(
                        tabAlignment: TabAlignment.start,
                        isScrollable: true,
                        physics: const BouncingScrollPhysics(),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        labelStyle: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        labelColor: Color(
                            int.parse(accentColor.replaceFirst('#', '0xff'))),
                        labelPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        unselectedLabelStyle: const TextStyle(
                          fontFamily: "Poppins",
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
                        ),
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.transparent,
                        ),
                        dividerColor: Colors.transparent,
                        unselectedLabelColor:
                            Theme.of(context).brightness == Brightness.light
                                ? const Color.fromARGB(252, 140, 140, 140)
                                : const Color.fromARGB(255, 170, 170, 170),
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Notas'),
                          Tab(text: 'Listas'),
                          Tab(text: 'destacados'),
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
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateNotePage(),
                ),
              );
            },
            label: const Text("nota"),
          ),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateTaskPage(),
                ),
              );
            },
            label: const Text("tarea"),
          ),
        ],
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

            return ListView.builder(
              itemCount: importantNotes.length + importantTasks.length,
              itemBuilder: (context, index) {
                if (index < importantNotes.length) {
                  final note = importantNotes[index];
                  return modelCard(
                    note: note,
                    isExpanded: _areItemsExpanded,
                    onTap: () {
                      // Acción al tocar la nota
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
                  );
                } else {
                  final task = importantTasks[index - importantNotes.length];
                  return TaskCard(
                    task: task,
                    isExpanded: _areItemsExpanded,
                    onTap: () {
                      // Acción al tocar la tarea
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTaskPage(
                            taskId: task.taskId,
                          ),
                        ),
                      );
                    },
                  );
                }
              },
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

            return ListView.builder(
              itemCount: importantNotes.length + importantTasks.length,
              itemBuilder: (context, index) {
                if (index < importantNotes.length) {
                  final note = importantNotes[index];
                  return modelCard(
                    note: note,
                    isExpanded: _areItemsExpanded,
                    onTap: () {
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
                  );
                } else {
                  final task = importantTasks[index - importantNotes.length];
                  return TaskCard(
                    task: task,
                    isExpanded: _areItemsExpanded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTaskPage(
                            taskId: task.taskId,
                          ),
                        ),
                      );
                    },
                    onDeleted: () {
                      setState(() {
                        importantTasks
                            .removeWhere((t) => t.taskId == task.taskId);
                      });
                    },
                  );
                }
              },
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
        TabBar(
          controller: _listTabController,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(
              fontFamily: "Poppins", fontSize: 12, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Completadas'),
          ],
        ),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color pickerColor =
            Color(int.parse(accentColor.replaceFirst('#', '0xff')));
        return AlertDialog(
          title: const Text('Selecciona un color de énfasis'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                setState(() {
                  accentColor =
                      '#${color.value.toRadixString(16).substring(2)}';
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
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
        );
      },
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
    _loadAccentColor();
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => paginaMiCuenta(
                  user: user,
                  userData: userData,
                ),
              ),
            );
          }
        },
      ),
      MenuOption(
        text: "papelera",
        icon: FontAwesomeIcons.trash,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeletedItemsPage(),
            ),
          );
        },
      ),
      MenuOption(
        text: "imagen de fondo",
        icon: Icons.check_circle,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WallpaperSelectionPage(),
            ),
          );
        },
      ),
      MenuOption(
        text: "seleccionar tema",
        icon: Icons.folder,
        onTap: () {
          showDialog(
            context: context,
            barrierColor: Colors.transparent, // Fondo transparente
            builder: (BuildContext context) {
              return AlertDialog(content: Container(child: ThemeChoice()));
            },
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
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              Icon(
                widget.icon,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
