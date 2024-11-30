import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
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
import 'package:notes_app/themas/themeModeNotifier.dart';
import 'package:notes_app/themas/themes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';

class paginaInicio extends StatefulWidget {
  const paginaInicio({super.key});

  @override
  _paginaInicioState createState() => _paginaInicioState();
}

class _paginaInicioState extends State<paginaInicio>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SharedPreferences _prefsTodos;

  int _currentIndex = 0;
  bool _isAlternateLayout = false;
  int _expandedNoteIndex = 0;
  bool _areItemsExpanded = true;
  String accentColor = '#FFFFFF'; // Color de énfasis por defecto
  String? wallpaperUrl; // Variable para almacenar la URL del wallpaper
  String?
      profileImageUrl; // Variable para almacenar la URL de la imagen de perfil

  @override
  void initState() {
    super.initState();

    _initprefsTodos();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadAccentColor(); // Cargar el color de énfasis al iniciar
    _loadWallpaperUrl(); // Cargar la URL del wallpaper al iniciar
    _loadProfileImageUrl(); // Cargar la URL de la imagen de perfil al iniciar
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
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        profileImageUrl = userDoc.data()?['profilePicture'];
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Themes.lightTheme,
        darkTheme: Themes.darkTheme,
        themeMode: themeNotifier.getThemeMode(),
        home: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _signOut,
                tooltip: 'Cerrar sesión',
              ),
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                onPressed: _toggleLayout,
                tooltip: 'Cambiar diseño',
              ),
              IconButton(
                icon: Icon(
                    _areItemsExpanded ? Icons.expand_less : Icons.expand_more),
                onPressed: _toggleItemsExpanded,
                tooltip: 'Alternar vista',
              ),
              IconButton(
                icon: const Icon(Icons.note_alt_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompletedTasksPage(),
                    ),
                  );
                },
                tooltip: 'Ver Tareas Completadas',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeletedItemsPage(),
                    ),
                  );
                },
                tooltip: 'elementos borrados ',
              ),
              IconButton(
                icon: const Icon(Icons.queue_play_next_sharp),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WallpaperSelectionPage(),
                    ),
                  );
                },
                tooltip: 'seleccionar imagen de fondo',
              ),
              IconButton(
                icon: const Icon(Icons.color_lens),
                onPressed: _pickAccentColor,
                tooltip: 'Seleccionar color de énfasis',
              ),
              IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () async {
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
                },
                tooltip: 'Mi Cuenta',
              ),
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DisplayWallpaperPage(),
                    ),
                  );
                },
                tooltip: 'Ver Fondo de Pantalla',
              ),
              PopupMenuButton<int>(
                iconColor: Colors.black,
                elevation: 2,
                padding: EdgeInsets.all(8),
                color: Colors.white,
                icon: profileImageUrl != null && profileImageUrl!.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(profileImageUrl!),
                      )
                    : const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                onSelected: (value) {
                  switch (value) {
                    case 0:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PopupMenuTestPage(),
                        ),
                      );
                      break;
                    case 1:
                      // Acción para la segunda opción
                      break;
                    case 2:
                      // Acción para la tercera opción
                      break;
                    // Agrega más casos según sea necesario
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 0,
                    child: Text(
                      'Opción 1',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 1,
                    child: Text(
                      'Opción 2',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: Text(
                      'Opción 3',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80.0),
              child: SizedBox(
                height: 60,
                child: TabBar(
                  isScrollable: true,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(
                      fontFamily: "Poppins",
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                  labelColor: Colors.black,
                  labelPadding: const EdgeInsets.all(8),
                  unselectedLabelStyle: const TextStyle(
                      fontFamily: "Poppins",
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.greenAccent,
                  ),
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
                "Inicio",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: "Poppins",
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28),
              ),
            ),
            elevation: 0,
            backgroundColor: Color(int.parse(accentColor.replaceFirst(
                '#', '0xff'))), // Aplicar el color de énfasis
          ),
          body: _isAlternateLayout
              ? _buildAlternateLayout()
              : _buildNormalLayout(),
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
                label: const Text("Agregar nota"),
              ),
              FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateTaskPage(),
                    ),
                  );
                },
                label: const Text("agregarlista"),
              ),
            ],
          ),
        ),
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

        // ==================== Listas
        Consumer<List<Task>>(
          builder: (context, tasks, _) {
            // Filtrar las tareas que no están eliminadas
            final activeTasks = tasks.where((task) => !task.isDeleted).toList();

            if (activeTasks.isEmpty) {
              return const Center(child: Text('No hay tareas disponibles.'));
            }
            return TaskListScreen(tasks: activeTasks);
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
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                // Lógica para eliminar la nota
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
                  );
                }
              },
            );
          },
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
