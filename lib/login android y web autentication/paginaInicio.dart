import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:notes_app/componentes/providers/list_provider.dart';
import 'package:notes_app/list/CreateTaskPage.dart';
import 'package:notes_app/list/TaskPage.dart';
import 'package:notes_app/notes/CreateNotePage.dart';
import 'package:notes_app/login%20android%20y%20web%20autentication/login_page.dart';

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
    _tabController = TabController(length: 2, vsync: this);
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

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text('Please login first.'));
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
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
                statusBarBrightness:
                    Theme.of(context).brightness == Brightness.light
                        ? Brightness.light
                        : Brightness.dark,
              ),
              floating: true,
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
                    labelPadding: const EdgeInsets.all(15),
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
                      FadeInLeft(
                        from: 10,
                        duration: Duration(milliseconds: 180),
                        delay: Duration(milliseconds: 150),
                        child: Tab(text: 'Notas'),
                      ),
                      FadeInLeft(
                        from: 10,
                        duration: Duration(milliseconds: 200),
                        delay: Duration(milliseconds: 310),
                        child: Tab(text: 'Listas'),
                      ),
                    ],
                  ),
                ),
                preferredSize: const Size.fromHeight(80.0),
              ),
              toolbarHeight: 65,
              collapsedHeight: 65,
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
              pinned: true,
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? const Color.fromARGB(255, 255, 255, 255)
                  : const Color.fromARGB(255, 0, 5, 9),
              elevation: 0,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            //============================TAB 1 - Notas=================================
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('notes')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No notes found.'));
                  }

                  final notes = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final noteDoc = notes[index];
                      final note = noteDoc.data() as Map<String, dynamic>;

                      return ListTile(
                        leading:
                            note['noteImage'] != null && note['noteImage'] != ''
                                ? Image.network(note['noteImage'],
                                    width: 50, height: 50)
                                : Icon(Icons.note),
                        title: Text(note['title'] ?? 'No Title'),
                        subtitle: Text(note['description'] ?? 'No Description'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (note['reminderDate'] != null)
                              Chip(
                                label: Text('Reminder'),
                                backgroundColor: Colors.blueAccent,
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EditNotePage(
                                      noteId: noteDoc.id,
                                      noteData: note,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            //============================ TAB 2 - Listas =================================
            Consumer<ListProvider>(
              builder: (context, listProvider, _) {
                if (listProvider.taskLists.isEmpty) {
                  listProvider.fetchTaskLists();
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: listProvider.taskLists.length,
                  itemBuilder: (context, index) {
                    final task = listProvider.taskLists[index];

                    return ListTile(
                      onTap: () {
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (context) =>
                                EditTaskPage(taskId: task['id']),
                          ),
                        )
                            .then((_) {
                          Provider.of<ListProvider>(context, listen: false)
                              .fetchTaskLists();
                        });
                      },
                      leading:
                          task['taskImage'] != null && task['taskImage'] != ''
                              ? Image.network(task['taskImage'],
                                  width: 50, height: 50)
                              : Icon(Icons.list),
                      title: Text(task['title'] ?? 'No Title'),
                      subtitle: Text(task['description'] ?? 'No Description'),
                      trailing: IconButton(
                        icon: Icon(
                          task['isCompleted']
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color:
                              task['isCompleted'] ? Colors.green : Colors.grey,
                        ),
                        onPressed: () {
                          listProvider.toggleCompletion(
                              task['id'], task['isCompleted']);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateNotePage(),
                ),
              );
            },
            label: Text("Agregar nota"),
          ),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CreateTaskPage(
                    onTaskSaved: () {
                      Provider.of<ListProvider>(context, listen: false)
                          .fetchTaskLists();
                    },
                  ),
                ),
              );
            },
            label: Text("agregarlista"),
          ),
        ],
      ),
    );
  }
}
