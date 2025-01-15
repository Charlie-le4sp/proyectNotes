import 'dart:typed_data';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/collections/collection_selector.dart';
import 'package:notes_app/languajeCode/languaje_provider.dart';
import 'package:provider/provider.dart';

class EditNotePage extends StatefulWidget {
  final String noteId;
  final Map<String, dynamic> noteData;

  const EditNotePage({super.key, required this.noteId, required this.noteData});

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime? _reminderDate;
  Uint8List? _noteImage;
  String? _noteImageUrl;
  bool isLoading = false;
  bool _isImportantNotes = false;
  String _noteColor = '#FFC107';
  List<String> _selectedCollections = [];

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
    _loadNoteData();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadNoteData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(widget.noteId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          setState(() {
            titleController.text = data['title'] ?? '';
            descriptionController.text = data['description'] ?? '';
            _noteImageUrl = data['noteImage'];
            _reminderDate = (data['reminderDate'] as Timestamp?)?.toDate();
            _isImportantNotes = data['importantNotes'] ?? false;
            _noteColor = data['color'] ?? '#FFC107';
            _selectedCollections = List<String>.from(data['collections'] ?? []);
          });
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

      try {
        if (_noteImage != null) {
          await _uploadImageToCloudinary(_noteImage!);
        }

        final noteData = {
          'title': titleController.text,
          'description': descriptionController.text,
          'noteImage': _noteImageUrl ?? '',
          'reminderDate':
              _reminderDate != null ? Timestamp.fromDate(_reminderDate!) : null,
          'importantNotes': _isImportantNotes,
          'color': _noteColor,
          'updatedAt': Timestamp.now(),
          'collections': _selectedCollections,
        };

        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('notes')
            .doc(widget.noteId)
            .update(noteData);

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating note: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
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
    // Obtener el proveedor de idioma
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageProvider.translate('selectAccentColor')),
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
              child: Text(languageProvider.translate('accept')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TextFormField(
                          autofocus: true,
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: languageProvider.translate('title'),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? languageProvider.translate('enter a title')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText:
                                languageProvider.translate('description'),
                            border: const OutlineInputBorder(),
                          ),
                          maxLines: 4,
                          validator: (value) => value == null || value.isEmpty
                              ? languageProvider
                                  .translate('enter a description')
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _noteImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                _noteImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : (_noteImageUrl != null && _noteImageUrl!.isNotEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _noteImageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.camera_alt,
                                      size: 50, color: Colors.grey),
                                ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectReminderDate,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _getFormattedReminderText(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickNoteColor,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Color(
                              int.parse(_noteColor.replaceFirst('#', '0xff'))),
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.palette, size: 20),
                            SizedBox(width: 8),
                            Text('Color', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      Text(_isImportantNotes ? 'Sí' : 'No'),
                      Switch(
                        value: _isImportantNotes,
                        onChanged: (value) {
                          setState(() {
                            _isImportantNotes = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.translate('collections'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CollectionSelector(
                      selectedCollections: _selectedCollections,
                      onCollectionsChanged: (newCollections) {
                        setState(() {
                          _selectedCollections = newCollections;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _updateNote,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(languageProvider.translate('update task'),
                          style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
