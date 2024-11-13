import 'dart:typed_data';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'package:timeago/timeago.dart' as timeago;

class TaskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text('Please login first.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete All Tasks'),
                  content: Text('Are you sure you want to delete all tasks?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Delete All'),
                    ),
                  ],
                ),
              );
              if (confirm ?? false) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('lists')
                    .get()
                    .then((snapshot) {
                  for (var doc in snapshot.docs) {
                    doc.reference.delete();
                  }
                });
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('lists')
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

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final taskData = task.data() as Map<String, dynamic>;

              return ListTile(
                leading:
                    taskData['listImage'] != null && taskData['listImage'] != ''
                        ? Image.network(taskData['listImage'],
                            width: 50, height: 50)
                        : Icon(Icons.list),
                title: Text(taskData['title'] ?? 'No Title'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(taskData['description'] ?? 'No Description'),
                    if (taskData['reminderDate'] != null)
                      Chip(
                        label: Text(
                          'Reminder: ${timeago.format(taskData['reminderDate'].toDate())}',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                  ],
                ),
                trailing: Wrap(
                  spacing: 8.0,
                  children: [
                    IconButton(
                      icon: Icon(
                        taskData['isCompleted'] == true
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: taskData['isCompleted'] == true
                            ? Colors.green
                            : Colors.grey,
                      ),
                      onPressed: () {
                        task.reference
                            .update({'isCompleted': !taskData['isCompleted']});
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditTaskPage(taskId: task.id),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Task'),
                            content: Text(
                                'Are you sure you want to delete this task?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm ?? false) {
                          task.reference.delete();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EditTaskPage extends StatefulWidget {
  final String taskId;

  EditTaskPage({required this.taskId});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryPublic cloudinary = CloudinaryPublic(
    'djm1bosvc',
    'taksImages',
    cache: false,
  );

  Uint8List? _taskImage;
  String? _taskImageUrl;
  bool isLoading = false;
  DateTime? _reminderDate;
  bool _isImportantTaks = false; // Estado para el botón de estrella

  @override
  void initState() {
    super.initState();
    _loadTaskData();
  }

  Future<void> _loadTaskData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('lists')
          .doc(widget.taskId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          titleController.text = data['title'] ?? '';
          descriptionController.text = data['description'] ?? '';
          _taskImageUrl = data['taskImage'];
          _reminderDate = (data['reminderDate'] as Timestamp?)?.toDate();
          _isImportantTaks = data['importantTask'] ?? false; // Carga el estado
          setState(() {}); // Refresca la UI con los datos cargados
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _taskImage = imageBytes;
      });
    }
  }

  Future<void> _uploadImageToCloudinary(Uint8List imageBytes) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          imageBytes,
          identifier: 'task_${DateTime.now().millisecondsSinceEpoch}.jpg',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      setState(() {
        _taskImageUrl = response.secureUrl;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _updateTask() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = _auth.currentUser;
      if (user == null) return;

      setState(() {
        isLoading = true;
      });

      if (_taskImage != null) {
        await _uploadImageToCloudinary(_taskImage!);
      }

      final taskData = {
        'title': titleController.text,
        'description': descriptionController.text,
        'taskImage': _taskImageUrl ?? '',
        'reminderDate':
            _reminderDate != null ? Timestamp.fromDate(_reminderDate!) : null,
        'importantTask': _isImportantTaks, // Actualiza importantTask
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('lists')
          .doc(widget.taskId)
          .update(taskData);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
        actions: [
          IconButton(
            icon: Icon(
              _isImportantTaks ? Icons.star : Icons.star_border,
              color: _isImportantTaks ? Colors.yellow : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isImportantTaks = !_isImportantTaks;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _taskImage != null
                    ? Image.memory(_taskImage!, height: 150)
                    : (_taskImageUrl != null
                        ? Image.network(_taskImageUrl!, height: 150)
                        : Container(
                            height: 150,
                            color: Colors.grey[300],
                            child: Icon(Icons.camera_alt),
                          )),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a title' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter a description'
                    : null,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: isLoading ? null : _updateTask,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
