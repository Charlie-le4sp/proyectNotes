import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/notes/alternativa/notesProvider.dart';

import 'package:provider/provider.dart';

class crearNota extends StatefulWidget {
  @override
  _crearNotaState createState() => _crearNotaState();
}

class _crearNotaState extends State<crearNota> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  Uint8List? _noteImage;
  DateTime? _reminderDate;
  bool _isImportant = false;
  bool isLoading = false;

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
    final notesProvider = Provider.of<NotesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Note'),
        actions: [
          IconButton(
            icon: Icon(
              _isImportant ? Icons.star : Icons.star_border,
              color: _isImportant ? Colors.yellow : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isImportant = !_isImportant;
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
                child: _noteImage != null
                    ? Image.memory(_noteImage!, height: 150)
                    : Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: Icon(Icons.camera_alt),
                      ),
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
                maxLines: 5,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(_reminderDate == null
                      ? 'No reminder set'
                      : 'Reminder: ${_reminderDate!.toLocal()}'),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: _selectReminderDate,
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          setState(() {
                            isLoading = true;
                          });
                          await notesProvider.addNote(
                            titleController.text,
                            descriptionController.text,
                            _noteImage,
                            _reminderDate,
                            _isImportant,
                          );
                          Navigator.pop(context);
                        }
                      },
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Save Note'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
