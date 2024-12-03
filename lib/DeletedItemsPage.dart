import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/notes/modelCardNote.dart';
import 'package:notes_app/list/modelCardTask.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeletedItemsPage extends StatefulWidget {
  const DeletedItemsPage({super.key});

  @override
  _DeletedItemsPageState createState() => _DeletedItemsPageState();
}

class _DeletedItemsPageState extends State<DeletedItemsPage> {
  bool _areItemsExpanded = false;
  Set<String> _selectedItems = {};
  bool _selectAll = false;

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

  void _toggleItemSelection(String id) {
    setState(() {
      if (_selectedItems.contains(id)) {
        _selectedItems.remove(id);
      } else {
        _selectedItems.add(id);
      }
    });
  }

  void _toggleSelectAll(List<String> allIds) {
    setState(() {
      if (_selectedItems.length == allIds.length) {
        _selectedItems.clear();
        _selectAll = false;
      } else {
        _selectedItems = Set.from(allIds);
        _selectAll = true;
      }
    });
  }

  Future<void> _deleteSelectedItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay elementos seleccionados'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
              '¿Estás seguro de que deseas eliminar permanentemente ${_selectedItems.length} elemento(s)? Esta acción no se puede deshacer.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Eliminar'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      for (String id in _selectedItems) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notes')
            .doc(id)
            .delete()
            .catchError((e) => print('Error al eliminar nota: $e'));

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('lists')
            .doc(id)
            .delete()
            .catchError((e) => print('Error al eliminar tarea: $e'));
      }

      setState(() {
        _selectedItems.clear();
        _selectAll = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Elementos eliminados permanentemente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar elementos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Método para restaurar los elementos seleccionados
  Future<void> _restoreSelectedItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay elementos seleccionados'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar restauración'),
          content: Text('¿Estás seguro de que deseas restaurar ${_selectedItems.length} elemento(s)?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Restaurar'),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      for (String id in _selectedItems) {
        // Intentar restaurar en la colección de notas
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notes')
            .doc(id)
            .update({'isDeleted': false})
            .catchError((e) => print('No es una nota: $e'));

        // Intentar restaurar en la colección de tareas
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('lists')
            .doc(id)
            .update({'isDeleted': false})
            .catchError((e) => print('No es una tarea: $e'));
      }

      setState(() {
        _selectedItems.clear();
        _selectAll = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Elementos restaurados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al restaurar elementos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please login first.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elementos Eliminados'),
        actions: [
          if (_selectedItems.isNotEmpty)
            Text('${_selectedItems.length} seleccionados'),
          IconButton(
            icon: Icon(_selectAll ? Icons.deselect : Icons.select_all),
            onPressed: () {
              _toggleSelectAll([/* lista de IDs */]);
            },
            tooltip: _selectAll ? 'Deseleccionar todo' : 'Seleccionar todo',
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _restoreSelectedItems,
            tooltip: 'Restaurar seleccionados',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _deleteSelectedItems,
            tooltip: 'Eliminar seleccionados',
          ),
          IconButton(
            icon:
                Icon(_areItemsExpanded ? Icons.expand_less : Icons.expand_more),
            onPressed: _toggleExpansionState,
            tooltip: 'Alternar vista',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notes')
            .snapshots(),
        builder: (context, noteSnapshot) {
          if (noteSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final deletedNotes = noteSnapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['isDeleted'] == true;
          }).map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Note(
              noteId: doc.id,
              uid: user.uid,
              title: data['title'] ?? 'No Title',
              description: data['description'] ?? 'No Description',
              importantNotes: data['importantNotes'] ?? false,
              isDeleted: data['isDeleted'] ?? false,
              noteImage: data['noteImage'],
              reminderDate: data['reminderDate'] != null
                  ? data['reminderDate'] as Timestamp
                  : null,
              createdAt: data['createdAt'] != null
                  ? data['createdAt'] as Timestamp
                  : null,
              color: data['color'] ?? '#FFFFFF',
            );
          }).toList();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('lists')
                .snapshots(),
            builder: (context, taskSnapshot) {
              if (taskSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final deletedTasks = taskSnapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['isDeleted'] == true;
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

              final allIds = [
                ...deletedNotes.map((n) => n.noteId),
                ...deletedTasks.map((t) => t.taskId)
              ];

              if (_selectAll && _selectedItems.length != allIds.length) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _toggleSelectAll(allIds);
                });
              }

              return ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Notas Eliminadas',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...deletedNotes.map((note) => Stack(
                        children: [
                          modelCard(
                            note: note,
                            isExpanded: _areItemsExpanded,
                            onTap: () => _toggleItemSelection(note.noteId),
                          ),
                          if (_selectedItems.contains(note.noteId))
                            const Positioned(
                              right: 10,
                              top: 10,
                              child: CircleAvatar(
                                backgroundColor: Colors.green,
                                child: Icon(Icons.check, color: Colors.white),
                              ),
                            ),
                        ],
                      )),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Tareas Eliminadas',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...deletedTasks.map((task) => Stack(
                        children: [
                          TaskCard(
                            task: task,
                            isExpanded: _areItemsExpanded,
                            onTap: () => _toggleItemSelection(task.taskId),
                          ),
                          if (_selectedItems.contains(task.taskId))
                            const Positioned(
                              right: 10,
                              top: 10,
                              child: CircleAvatar(
                                backgroundColor: Colors.green,
                                child: Icon(Icons.check, color: Colors.white),
                              ),
                            ),
                        ],
                      )),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
