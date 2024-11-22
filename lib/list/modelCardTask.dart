import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:notes_app/list/EditinTaskPage.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isExpanded;
  final VoidCallback onTap;

  TaskCard({
    required this.task,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 400;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isExpanded
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
        if (difference.inMinutes > 1)
          return "En ${difference.inMinutes} minutos";
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
              width: widthCard,
              color: Colors.amber,
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
                                  color: Color.fromARGB(255, 167, 120, 40),
                                  width: widthTextTasks,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: widthTextTasks,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            task.title,
                                            style: TextStyle(fontSize: 24),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: widthTextTasks,
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Container(
                                            height: heightCardElements - 80,
                                            child: CustomScrollView(
                                              slivers: [
                                                SliverToBoxAdapter(
                                                  child: Text(task.description),
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
                                    color: Color.fromARGB(255, 129, 40, 167),
                                    image: task.taskImage != null &&
                                            task.taskImage!.isNotEmpty
                                        ? DecorationImage(
                                            image:
                                                NetworkImage(task.taskImage!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          height: 100,
                          color: Color.fromARGB(255, 251, 172, 15),
                          width: widthButtons,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Chip(
                                    label: Text(
                                      "Recordatorio: ${formatRelativeDate(task.reminderDate)}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "creado : ${task.createdAt != null ? formatRelativeDate(task.createdAt) : 'Unknown'}",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    height: 40,
                                    width: widthImageTasks,
                                    child: ElevatedButton(
                                        onPressed: () {},
                                        child: Text("Completado")),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    height: 40,
                                    width: widthImageTasks,
                                    child: ElevatedButton(
                                        onPressed: () {},
                                        child: Text("Editar")),
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
                        task.importantTask ? Icons.star : Icons.star_border,
                        color: task.importantTask ? Colors.amber : Colors.grey,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            task.taskImage != null && task.taskImage!.isNotEmpty
                ? Image.network(
                    task.taskImage!,
                    width: isNarrow ? 40 : 50,
                    height: isNarrow ? 40 : 50,
                  )
                : Icon(Icons.task, size: isNarrow ? 40 : 50),
            SizedBox(width: isNarrow ? 5 : 10),
            SizedBox(
              width: 200,
              child: Text(
                task.title,
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
                        taskId:
                            task.taskId, // Se pasa el taskId al EditTaskPage
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
                child: Text('Editar'),
              ),
            ),
            SizedBox(height: isNarrow ? 4 : 8),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: () {
                  // Acción de eliminar
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[200],
                  minimumSize: Size(isNarrow ? 80 : 100, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Eliminar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class Task {
  final String taskId;
  final String title;
  final String description;
  final bool importantTask;
  final bool isCompleted;
  final String? taskImage;
  final Timestamp? reminderDate;
  final Timestamp? createdAt;

  Task({
    required this.taskId,
    required this.title,
    required this.description,
    required this.importantTask,
    required this.isCompleted,
    this.taskImage,
    this.reminderDate,
    this.createdAt,
  });
}

// Pantalla de lista de tareas
class TaskListScreen extends StatefulWidget {
  final List<Task> tasks;

  TaskListScreen({required this.tasks});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  int expandedTaskIndex = 0; // Inicializar con la primera tarea expandida

  void moveToTop(int index) {
    setState(() {
      final task = widget.tasks.removeAt(index);
      widget.tasks.insert(0, task);
      expandedTaskIndex = 0; // Actualizar índice expandido al nuevo tope
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.tasks.length,
      itemBuilder: (context, index) {
        final task = widget.tasks[index];
        return Container(
          width: 500,
          child: Center(
            child: TaskCard(
              task: task,
              isExpanded: expandedTaskIndex == index,
              onTap: () {
                if (expandedTaskIndex == index) {
                  setState(() {
                    expandedTaskIndex = -1; // Cerrar si ya está expandido
                  });
                } else {
                  moveToTop(index); // Mover la tarjeta seleccionada al inicio
                }
              },
            ),
          ),
        );
      },
    );
  }
}
