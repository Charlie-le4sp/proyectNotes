import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/list/modelCardTask.dart';
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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please login first.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas Completadas'),
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
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay tareas.'));
          }

          final completedTasks = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['isCompleted'] == true;
          }).map((doc) {
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

          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Tareas Completadas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...completedTasks.map((task) => TaskCard(
                    task: task,
                    isExpanded: _areItemsExpanded,
                    onTap: () {},
                  )),
            ],
          );
        },
      ),
    );
  }
}
