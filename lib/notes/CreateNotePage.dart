import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:intl/intl.dart';

class CreateNotePage extends StatefulWidget {
  @override
  _CreateNotePageState createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryPublic cloudinary = CloudinaryPublic(
    'djm1bosvc',
    'notesImages',
    cache: false,
  );

  Uint8List? _noteImage;
  String? _noteImageUrl;
  String errorMessage = '';
  bool isLoading = false;
  DateTime? _reminderDate;
  bool _isImportantNotes = false; // Nuevo estado para el botón de estrella

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
      setState(() {
        errorMessage = 'Error uploading image: ${e.toString()}';
      });
    }
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = 'User not logged in';
        });
        return;
      }

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
        'createdAt': FieldValue.serverTimestamp(),
        'reminderDate':
            _reminderDate != null ? Timestamp.fromDate(_reminderDate!) : null,
        'isDeleted': false,
        'importantNotes': _isImportantNotes, // Nuevo campo important
      };

      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('notes')
            .add(noteData);

        Navigator.of(context).pop();
      } catch (e) {
        setState(() {
          errorMessage = 'Error saving note: ${e.toString()}';
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create note'),
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
                onPressed: isLoading ? null : _saveNote,
                child: isLoading
                    ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text('Save Note'),
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
