import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:notes_app/notes/alternativa/notesProvider.dart';

import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class editarNota extends StatefulWidget {
  final String noteId; // ID de la nota que se va a editar

  editarNota({required this.noteId});

  @override
  _editarNotaState createState() => _editarNotaState();
}

class _editarNotaState extends State<editarNota> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  Uint8List? _updatedImage;
  String? _noteImageUrl;
  DateTime? _reminderDate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNoteDetails();
  }

  Future<void> _loadNoteDetails() async {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    final note = await notesProvider.getNoteById(widget.noteId);

    if (note != null) {
      setState(() {
        titleController.text = note['title'] ?? '';
        descriptionController.text = note['description'] ?? '';
        _noteImageUrl = note['noteImage'] ?? '';
        _reminderDate = (note['reminderDate'] as DateTime?);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _updatedImage = imageBytes;
      });
    }
  }

  Future<void> _updateNote() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      final notesProvider = Provider.of<NotesProvider>(context, listen: false);

      // Subir la imagen actualizada (si hay)
      if (_updatedImage != null) {
        _noteImageUrl = await notesProvider.uploadNoteImage(_updatedImage!);
      }

      final updatedData = {
        'title': titleController.text,
        'description': descriptionController.text,
        'noteImage': _noteImageUrl,
        'reminderDate': _reminderDate,
      };

      try {
        await notesProvider.updateNote(widget.noteId, updatedData);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Note'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: _updatedImage != null
                          ? Image.memory(_updatedImage!, height: 150)
                          : (_noteImageUrl != null && _noteImageUrl!.isNotEmpty
                              ? Image.network(_noteImageUrl!, height: 150)
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
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter a title'
                          : null,
                    ),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter a description'
                          : null,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(_getFormattedReminderText()),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: _selectReminderDate,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isLoading ? null : _updateNote,
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Update Note'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
