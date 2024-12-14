import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
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
        ),
      );
      setState(() {
        _taskImageUrl = response.secureUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  void _pickTaskColor() {
    // Lista personalizada de colores pasteles

    final List<Color> pastelColors = [
      Color(0xFFFF5722), // Naranja intenso
      Color(0xFF4CAF50), // Verde
      Color(0xFF3F51B5), // Azul oscuro
      Color(0xFF03A9F4), // Azul claro
      Color(0xFFFFEB3B), // Amarillo
      Color(0xFFFF9800), // Naranja
      Color(0xFF2196F3), // Azul
      Color(0xFF00BCD4), // Cian
      Color(0xFFCDDC39), // Lima
      Color(0xFF009688), // Verde azulado
      Color(0xFF8BC34A), // Verde claro
      Color(0xFFA7A7A7), // Gris claro
      Color(0xFF9E9E9E), // Gris
      Color(0xFF795548), // Café
      Color(0xFF607D8B), // Azul grisáceo
      Color(0xFFFFC207), // Amarillo intenso
      Color(0xFFFFC107), // Amarillo anaranjado
      Color(0xFF2E2E2E), // Gris oscuro
      Color(0xFFFF9D00), // Naranja saturado
      Color(0xFFF64336), // Rojo
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecciona un color para la tarea'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor:
                  Color(int.parse(_taskColor.replaceFirst('#', '0xff'))),
              availableColors: pastelColors, // Usar nuestra lista personalizada
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

  Future<void> _saveTask() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      if (_taskImage != null) {
        await _uploadImageToCloudinary(_taskImage!);
      }

      final taskData = {
        'taskImage': _taskImageUrl ?? '',
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'reminderDate':
            _reminderDate != null ? Timestamp.fromDate(_reminderDate!) : null,
        'isCompleted': false,
        'isDeleted': false,
        'importantTask': _isImportantTask,
        'color': _taskColor,
      };

      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('lists')
            .add(taskData);

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving task: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _selectReminderDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (selectedDate != null) {
      setState(() {
        _reminderDate = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
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
                    : Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.camera_alt),
                      ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 20),
              IconButton(
                icon: const Icon(Icons.color_lens),
                onPressed: _pickTaskColor,
                tooltip: 'Seleccionar color de tarea',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _saveTask,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


