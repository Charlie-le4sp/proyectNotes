import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class EditTaskPage extends StatefulWidget {
  final String taskId;

  const EditTaskPage({super.key, required this.taskId});

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
  bool _isImportantTask = false;
  String _taskColor = '#FFC107';

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
          _isImportantTask = data['importantTask'] ?? false;
          _taskColor = data['color'] ?? '#FFFFFF';
          setState(() {});
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

  Future<void> _selectReminderDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _reminderDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (selectedDate != null) {
      setState(() {
        _reminderDate = selectedDate;
      });
    }
  }

  void _pickTaskColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecciona un color para la tarea'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor:
                  Color(int.parse(_taskColor.replaceFirst('#', '0xff'))),
              onColorChanged: (Color color) {
                setState(() {
                  _taskColor = '#${color.value.toRadixString(16).substring(2)}';
                });
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Aceptar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
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
        'importantTask': _isImportantTask,
        'color': _taskColor,
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
        title: const Text('Edit Task'),
        actions: [
          IconButton(
            icon: Icon(
              _isImportantTask ? Icons.star : Icons.star_border,
              color: _isImportantTask ? Colors.yellow : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isImportantTask = !_isImportantTask;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: _pickTaskColor,
            tooltip: 'Seleccionar color de tarea',
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
                            child: const Icon(Icons.camera_alt),
                          )),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a title' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter a description'
                    : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    _reminderDate == null
                        ? 'No reminder set'
                        : DateFormat.yMMMd().format(_reminderDate!),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectReminderDate,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: isLoading ? null : _updateTask,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
