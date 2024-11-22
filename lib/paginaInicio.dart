import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:notes_app/notes/alternativa/listaNotas.dart';
import 'package:notes_app/notes/modelCardNote.dart';
import 'package:notes_app/componentes/providers/list_provider.dart';
import 'package:notes_app/list/CreateTaskPage.dart';
import 'package:notes_app/list/TaskPage.dart';
import 'package:notes_app/list/modelCardTask.dart';
import 'package:notes_app/notes/CreateNotePage.dart';
import 'package:notes_app/login%20android%20y%20web%20autentication/login_page.dart';
import 'dart:html' as html;
import 'package:notes_app/notes/notesPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class paginaInicio extends StatefulWidget {
  @override
  _paginaInicioState createState() => _paginaInicioState();
}

class _paginaInicioState extends State<paginaInicio>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late SharedPreferences _prefsTodos;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initprefsTodos();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  Future<void> _initprefsTodos() async {
    _prefsTodos = await SharedPreferences.getInstance();
    setState(() {
      _currentIndex = _prefsTodos.getInt('tabIndex') ?? 0;
      _tabController.index = _currentIndex;
    });
  }

  void _handleTabSelection() {
    setState(() {
      _currentIndex = _tabController.index;
      _prefsTodos.setInt('tabIndex', _currentIndex);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    html.window.location.reload(); //

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text('Please login first.'));
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Cerrar sesión',
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Color.fromARGB(255, 0, 5, 9),
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.light
                  ? Brightness.dark
                  : Brightness.light,
          statusBarBrightness: Theme.of(context).brightness == Brightness.light
              ? Brightness.light
              : Brightness.dark,
        ),
        bottom: PreferredSize(
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
              tabs: [
                Tab(text: 'Notas'),
                Tab(text: 'Listas'),
                Tab(text: 'destacados'),
              ],
            ),
          ),
          preferredSize: const Size.fromHeight(80.0),
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
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? const Color.fromARGB(255, 255, 255, 255)
            : const Color.fromARGB(255, 0, 5, 9),
        elevation: 0,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ==================== Notas

          ListasNotas(),

          // ==================== Notas

          // Tab 2 - Listas (Repeat the same structure for centering content)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('lists') // Cambiar a la colección de tareas
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No tasks found.'));
              }

              final tasks = snapshot.data!.docs;
              final taskList = tasks.map((taskDoc) {
                final taskData = taskDoc.data() as Map<String, dynamic>;

                return Task(
                  taskId: taskDoc.id,
                  title: taskData['title'] ?? 'No Title',
                  description: taskData['description'] ?? 'No Description',
                  importantTask: taskData['importantTask'] ?? false,
                  isCompleted: taskData['isCompleted'] ?? false,
                  taskImage: taskData['taskImage'],
                  reminderDate: taskData['reminderDate'] != null
                      ? taskData['reminderDate'] as Timestamp
                      : null,
                  createdAt: taskData['createdAt'] != null
                      ? taskData['createdAt'] as Timestamp
                      : null,
                );
              }).toList();

              return TaskListScreen(
                  tasks: taskList.cast<
                      Task>()); // Renderiza con un widget de lista de tareas
            },
          ),

          // // Tab 3 - Destacados
          // Consumer<ListProvider>(
          //   builder: (context, listProvider, _) {
          //     return StreamBuilder<QuerySnapshot>(
          //       stream: FirebaseFirestore.instance
          //           .collection('users')
          //           .doc(user.uid)
          //           .collection('notes')
          //           .where('importantNotes',
          //               isEqualTo: true) // Filtrar notas importantes
          //           .snapshots(),
          //       builder: (context, snapshot) {
          //         if (snapshot.connectionState == ConnectionState.waiting) {
          //           return Center(child: CircularProgressIndicator());
          //         }

          //         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          //           return Center(
          //               child: Text('No se encontraron elementos destacados.'));
          //         }

          //         final importantNotes = snapshot.data!.docs;
          //         final importantTasks = listProvider.taskLists
          //             .where((task) =>
          //                 task['importantTask'] ==
          //                 true) // Filtrar tareas importantes
          //             .toList();

          //         return ListView.builder(
          //           itemCount: importantNotes.length + importantTasks.length,
          //           itemBuilder: (context, index) {
          //             if (index < importantNotes.length) {
          //               // Mostrar notas destacadas
          //               final note = importantNotes[index].data()
          //                   as Map<String, dynamic>;
          //               return ListTile(
          //                 leading: note['noteImage'] != null &&
          //                         note['noteImage'] != ''
          //                     ? Image.network(note['noteImage'],
          //                         width: 50, height: 50)
          //                     : Icon(Icons.note),
          //                 title: Text(note['title'] ?? 'Sin título'),
          //                 subtitle:
          //                     Text(note['description'] ?? 'Sin descripción'),
          //               );
          //             } else {
          //               // Mostrar tareas destacadas
          //               final task =
          //                   importantTasks[index - importantNotes.length];
          //               return ListTile(
          //                 leading: task['taskImage'] != null &&
          //                         task['taskImage'] != ''
          //                     ? Image.network(task['taskImage'],
          //                         width: 50, height: 50)
          //                     : Icon(Icons.list),
          //                 title: Text(task['title'] ?? 'Sin título'),
          //                 subtitle:
          //                     Text(task['description'] ?? 'Sin descripción'),
          //                 trailing: Icon(
          //                   task['isCompleted']
          //                       ? Icons.check_circle
          //                       : Icons.radio_button_unchecked,
          //                   color: task['isCompleted']
          //                       ? Colors.green
          //                       : Colors.grey,
          //                 ),
          //               );
          //             }
          //           },
          //         );
          //       },
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}
