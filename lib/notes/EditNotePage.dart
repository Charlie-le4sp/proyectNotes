import 'dart:typed_data';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';

class EditNotePage extends StatefulWidget {
  final String noteId;
  final Map<String, dynamic> noteData;

  const EditNotePage({super.key, required this.noteId, required this.noteData});

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  DateTime? _reminderDate;
  Uint8List? _noteImage;
  String? _noteImageUrl;
  bool isLoading = false;
  bool _isImportantNotes = false;
  String _noteColor = '#FFC107';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryPublic cloudinary = CloudinaryPublic(
    'djm1bosvc',
    'notesImages',
    cache: false,
  );

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.noteData['title']);
    descriptionController =
        TextEditingController(text: widget.noteData['description']);
    _noteImageUrl = widget.noteData['noteImage'];
    _reminderDate = (widget.noteData['reminderDate'] as Timestamp?)?.toDate();
    _isImportantNotes = widget.noteData['importantNotes'] ?? false;
    _noteColor = widget.noteData['color'] ?? '#FFFFFF';
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _noteImage = imageBytes;
      });
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

  void _clearReminderDate() {
    setState(() {
      _reminderDate = null;
    });
  }

  Future<void> _uploadImageToCloudinary(Uint8List imageBytes) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          imageBytes,
          identifier: 'note_${DateTime.now().millisecondsSinceEpoch}.jpg',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      setState(() {
        _noteImageUrl = response.secureUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateNote() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      if (_noteImage != null) {
        await _uploadImageToCloudinary(_noteImage!);
      }

      final noteData = {
        'noteImage': _noteImageUrl ?? '',
        'title': titleController.text,
        'description': descriptionController.text,
        'reminderDate':
            _reminderDate != null ? Timestamp.fromDate(_reminderDate!) : null,
        'isDeleted': false,
        'importantNotes': _isImportantNotes,
        'color': _noteColor,
      };

      try {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('notes')
            .doc(widget.noteId)
            .update(noteData);

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating note: ${e.toString()}')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _getFormattedReminderText() {
    if (_reminderDate == null) return 'No reminder date set';

    final difference = _reminderDate!.difference(DateTime.now());
    if (difference.inDays > 1) {
      return 'In ${difference.inDays} days';
    } else if (difference.inHours >= 24) {
      return 'In 1 day';
    } else if (difference.inHours > 1) {
      return 'In ${difference.inHours} hours';
    } else if (difference.inMinutes >= 60) {
      return 'In 1 hour';
    } else {
      return 'In ${difference.inMinutes} minutes';
    }
  }

  void _pickNoteColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecciona un color para la nota'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor:
                  Color(int.parse(_noteColor.replaceFirst('#', '0xff'))),
              onColorChanged: (Color color) {
                setState(() {
                  _noteColor = '#${color.value.toRadixString(16).substring(2)}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: Icon(
              _isImportantNotes ? Icons.star : Icons.star_border,
              color: _isImportantNotes ? Colors.yellow : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isImportantNotes = !_isImportantNotes;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isImportantNotes
                      ? 'Marked as important'
                      : 'Unmarked as important'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: _pickNoteColor,
            tooltip: 'Seleccionar color de nota',
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
                child: _noteImage != null
                    ? Image.memory(_noteImage!, height: 150)
                    : (_noteImageUrl != null && _noteImageUrl!.isNotEmpty)
                        ? Image.network(_noteImageUrl!, height: 150)
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
                  Text(_getFormattedReminderText()),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectReminderDate,
                  ),
                  if (_reminderDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearReminderDate,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _updateNote,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Update Note'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
