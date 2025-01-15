import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/languajeCode/languaje_provider.dart';
import 'package:notes_app/tasks/modelCardTask.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompletedTasksPage extends StatefulWidget {
  const CompletedTasksPage({super.key});

  @override
  _CompletedTasksPageState createState() => _CompletedTasksPageState();
}

class _CompletedTasksPageState extends State<CompletedTasksPage> {
  bool _areItemsExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadExpansionState();
  }

  Future<void> _loadExpansionState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _areItemsExpanded = prefs.getBool('areItemsExpanded') ?? false;
    });
  }

  Future<void> _toggleExpansionState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _areItemsExpanded = !_areItemsExpanded;
      prefs.setBool('areItemsExpanded', _areItemsExpanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el proveedor de idioma
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please login first.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('completed tasks')),
        actions: [
          IconButton(
            icon: Icon(
              _areItemsExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onPressed: _toggleExpansionState,
            tooltip: 'Alternar vista',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
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
              color: data['color'] ?? '#FFFFFF',
            );
          }).toList();

          return TaskListScreen(
            tasks: completedTasks,
            onTaskDeleted: () {
              // Actualizar la vista si es necesario
              setState(() {});
            },
          );
        },
      ),
    );
  }
}
