import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:notes_app/list/EditTaskPage.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback? onDeleted;

  const TaskCard({
    super.key,
    required this.task,
    required this.isExpanded,
    required this.onTap,
    this.onDeleted,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  void _toggleDeleteStatus(BuildContext context) async {
    try {
      final taskDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.task.uid)
          .collection('lists')
          .doc(widget.task.taskId);

      // Cambiar el campo isDeleted a true en Firestoreew
      await taskDocRef.update({'isDeleted': true});

      // Actualiza el estado de la lista de tareas
      if (context.findAncestorStateOfType<_TaskListScreenState>() != null) {
        final taskListState =
            context.findAncestorStateOfType<_TaskListScreenState>();
        taskListState?.setState(() {
          taskListState.widget.tasks
              .removeWhere((t) => t.taskId == widget.task.taskId);
          taskListState.expandedTaskIndex = taskListState.expandedTaskIndex > 0
              ? taskListState.expandedTaskIndex - 1
              : 0;
        });
      }
    } catch (e) {
      print('Error al actualizar la tarea: $e');
    }
  }

  void _toggleCompletionStatus(BuildContext context) async {
    try {
      final taskDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.task.uid)
          .collection('lists')
          .doc(widget.task.taskId);

      // Cambiar el campo isCompleted en Firestore
      await taskDocRef.update({'isCompleted': !widget.task.isCompleted});

      // Actualiza el estado de la lista de tareas
      if (context.findAncestorStateOfType<_TaskListScreenState>() != null) {
        final taskListState =
            context.findAncestorStateOfType<_TaskListScreenState>();
        taskListState?.setState(() {
          taskListState.widget.tasks
              .removeWhere((t) => t.taskId == widget.task.taskId);
          taskListState.expandedTaskIndex = taskListState.expandedTaskIndex > 0
              ? taskListState.expandedTaskIndex - 1
              : 0;
        });
      }
    } catch (e) {
      print('Error al actualizar el estado de la tarea: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 400;
        return InkWell(
          onTap: widget.onTap,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: widget.isExpanded
                  ? _buildExpandedContent(context, isNarrow)
                  : _buildCollapsedContent(context, isNarrow),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedContent(BuildContext context, bool isNarrow) {
    String formatRelativeDate(Timestamp? timestamp) {
      if (timestamp == null) return 'Sin fecha';
      final now = DateTime.now();
      final date = timestamp.toDate();
      final difference = date.difference(now);

      if (difference.isNegative) {
        final past = now.difference(date);
        if (past.inDays > 1) return "Hace ${past.inDays} días";
        if (past.inDays == 1) return "Hace 1 día";
        if (past.inHours > 1) return "Hace ${past.inHours} horas";
        if (past.inHours == 1) return "Hace 1 hora";
        if (past.inMinutes > 1) return "Hace ${past.inMinutes} minutos";
        return "Hace menos de 1 minuto";
      } else {
        if (difference.inDays > 1) return "En ${difference.inDays} días";
        if (difference.inDays == 1) return "En 1 día";
        if (difference.inHours > 1) return "En ${difference.inHours} horas";
        if (difference.inHours == 1) return "En 1 hora";
        if (difference.inMinutes > 1) {
          return "En ${difference.inMinutes} minutos";
        }
        return "En menos de 1 minuto";
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;

        double widthCard;
        double widthImageTasks;
        double widthTextTasks;
        double widthButtons;
        double heightCard;
        double heightCardElements;

        if (screenWidth > 1200) {
          widthCard = MediaQuery.of(context).size.width * 0.6;
          widthImageTasks = MediaQuery.of(context).size.width * 0.18;
          widthTextTasks = MediaQuery.of(context).size.width * 0.38;
          widthButtons = MediaQuery.of(context).size.width * 1;
          heightCard = 385;
          heightCardElements = 220;
        } else if (screenWidth > 800) {
          widthCard = MediaQuery.of(context).size.width * 0.6;
          widthImageTasks = MediaQuery.of(context).size.width * 0.22;
          widthTextTasks = MediaQuery.of(context).size.width * 0.33;
          widthButtons = MediaQuery.of(context).size.width * 1;
          heightCard = 385;
          heightCardElements = 220;
        } else {
          widthCard = MediaQuery.of(context).size.width * 0.9;
          widthImageTasks = MediaQuery.of(context).size.width * 0.33;
          widthTextTasks = MediaQuery.of(context).size.width * 0.5;
          widthButtons = MediaQuery.of(context).size.width * 1;
          heightCard = 340;
          heightCardElements = 170;
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Color(
                    int.parse(widget.task.color.replaceFirst('#', '0xff'))),
                borderRadius: BorderRadius.circular(20),
              ),
              width: widthCard,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Container(
                                  height: heightCardElements,
                                  width: widthTextTasks,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: widthTextTasks,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            widget.task.title,
                                            style:
                                                const TextStyle(fontSize: 24),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: widthTextTasks,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox(
                                            height: heightCardElements - 80,
                                            child: CustomScrollView(
                                              slivers: [
                                                SliverToBoxAdapter(
                                                  child: Text(
                                                      widget.task.description),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  height: heightCardElements,
                                  width: widthImageTasks,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(17),
                                    color:
                                        const Color.fromARGB(255, 129, 40, 167),
                                    image: widget.task.taskImage != null &&
                                            widget.task.taskImage!.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(
                                                widget.task.taskImage!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          height: 100,
                          width: widthButtons,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Chip(
                                    label: Text(
                                      "Recordatorio: ${formatRelativeDate(widget.task.reminderDate)}",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "creado : ${widget.task.createdAt != null ? formatRelativeDate(widget.task.createdAt) : 'Unknown'}",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditTaskPage(
                                                  taskId: widget.task
                                                      .taskId, // Se pasa el taskId al EditTaskPage
                                                ),
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.edit)),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    height: 40,
                                    width: widthImageTasks,
                                    child: ElevatedButton(
                                        onPressed: () =>
                                            _toggleCompletionStatus(context),
                                        child: const Text("completado")),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                    height: 40,
                                    width: widthImageTasks,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          _toggleDeleteStatus(context);
                                        },
                                        child: const Text("eliminar")),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(
                        widget.task.importantTask
                            ? Icons.star
                            : Icons.star_border,
                        color: widget.task.importantTask
                            ? Colors.amber
                            : Colors.grey,
                        size: 30,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Contenido colapsado
  Widget _buildCollapsedContent(BuildContext context, bool isNarrow) {
    return LayoutBuilder(builder: (context, constraints) {
      double screenWidth = constraints.maxWidth;
      double widthCard;

      if (screenWidth > 1200) {
        widthCard = MediaQuery.of(context).size.width * 0.6;
      } else if (screenWidth > 800) {
        widthCard = MediaQuery.of(context).size.width * 0.6;
      } else {
        widthCard = MediaQuery.of(context).size.width * 0.9;
      }

      return Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color:
                Color(int.parse(widget.task.color.replaceFirst('#', '0xff'))),
          ),
          width: widthCard,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    widget.task.taskImage != null &&
                            widget.task.taskImage!.isNotEmpty
                        ? Image.network(
                            widget.task.taskImage!,
                            width: isNarrow ? 40 : 50,
                            height: isNarrow ? 40 : 50,
                          )
                        : Icon(Icons.task, size: isNarrow ? 40 : 50),
                    SizedBox(width: isNarrow ? 5 : 10),
                    SizedBox(
                      width: 200,
                      child: Text(
                        widget.task.title,
                        style: TextStyle(
                          fontSize: isNarrow ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTaskPage(
                                taskId: widget.task.taskId,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: Size(isNarrow ? 80 : 100, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Editar'),
                      ),
                    ),
                    SizedBox(height: isNarrow ? 4 : 8),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () => _toggleDeleteStatus(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[200],
                          minimumSize: Size(isNarrow ? 80 : 100, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Eliminar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class Task {
  final String taskId;
  final String title;
  final String description;
  final bool importantTask;
  final bool isCompleted;
  final bool isDeleted;
  final String? taskImage;
  final Timestamp? reminderDate;
  final Timestamp? createdAt;
  final String uid;
  final String color;

  Task({
    required this.taskId,
    required this.title,
    required this.description,
    required this.importantTask,
    required this.isCompleted,
    required this.isDeleted,
    this.taskImage,
    this.reminderDate,
    this.createdAt,
    required this.uid,
    required this.color,
  });
}

// Pantalla de lista de tareas
class TaskListScreen extends StatefulWidget {
  final List<Task> tasks;
  final VoidCallback? onTaskDeleted;

  const TaskListScreen({
    super.key,
    required this.tasks,
    this.onTaskDeleted,
  });

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  int expandedTaskIndex = 0;

  void moveToTop(int index) {
    setState(() {
      final task = widget.tasks.removeAt(index);
      widget.tasks.insert(0, task);
      expandedTaskIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.tasks.length,
      itemBuilder: (context, index) {
        final task = widget.tasks[index];
        return SizedBox(
          width: 500,
          child: Center(
            child: TaskCard(
              task: task,
              isExpanded: expandedTaskIndex == index,
              onTap: () {
                if (expandedTaskIndex == index) {
                  setState(() {
                    expandedTaskIndex = -1;
                  });
                } else {
                  moveToTop(index);
                }
              },
              onDeleted: widget.onTaskDeleted,
            ),
          ),
        );
      },
    );
  }
}
