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
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bounce/bounce.dart' as bounce_pkg;
import 'package:notes_app/collections/collections_provider.dart';

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
  bool _showCollections = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectionsProvider>().loadCollections();
    });
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
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildButton("Esc", onTap: () {
              Navigator.pop(context);
            },
                icon: FontAwesomeIcons.times,
                colorText: Colors.white,
                color: const Color.fromARGB(255, 244, 69, 57)),
          ),
        ],
        title: Text(
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            languageProvider.translate('edit note')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              hoverColor: Colors.transparent,
                              filled: true,
                              fillColor: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.white
                                  : const Color.fromARGB(255, 12, 12, 12),
                              errorStyle: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Poppins",
                                  color: Color.fromARGB(255, 255, 125, 116),
                                  fontWeight: FontWeight.bold),
                              labelText: languageProvider.translate('title'),
                              labelStyle: TextStyle(
                                fontSize: 16.0,
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.black
                                      : Colors.white38,
                                  width: 1,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.black
                                      : Colors.white,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            autofocus: true,
                            controller: titleController,
                            validator: (value) => value == null || value.isEmpty
                                ? languageProvider.translate('enter a title')
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: descriptionController,
                            decoration: InputDecoration(
                              hoverColor: Colors.transparent,
                              filled: true,
                              fillColor: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.white
                                  : const Color.fromARGB(255, 12, 12, 12),
                              errorStyle: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Poppins",
                                  color: Color.fromARGB(255, 255, 125, 116),
                                  fontWeight: FontWeight.bold),
                              labelText:
                                  languageProvider.translate('description'),
                              labelStyle: TextStyle(
                                fontSize: 16.0,
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.black
                                      : Colors.white38,
                                  width: 1,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.black
                                      : Colors.white,
                                  width: 2.0,
                                ),
                              ),
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
                        height: 185,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white38,
                            width: 1,
                          ),
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.white
                                  : const Color.fromARGB(255, 12, 12, 12),
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
                            : (_noteImageUrl != null &&
                                    _noteImageUrl!.isNotEmpty)
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
                Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.spaceAround,
                    children: [
                      buildButton(
                        colorText:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : Colors.black,
                        "colecciones",
                        icon: FontAwesomeIcons.folder,
                        onTap: () {
                          setState(() {
                            _showCollections = !_showCollections;
                          });
                        },
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFF2F2F34)
                            : const Color(0xFFE9E9E9),
                      ),
                      buildButton(
                        colorText:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : Colors.black,
                        icon: FontAwesomeIcons.palette,
                        "color",
                        onTap: _pickNoteColor,
                        color: Color(
                            int.parse(_noteColor.replaceFirst('#', '0xff'))),
                      ),
                      buildButton(
                        colorText:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : Colors.black,
                        "recordatorio",
                        icon: FontAwesomeIcons.calendar,
                        onTap: _selectReminderDate,
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFF2F2F34)
                            : const Color(0xFFE9E9E9),
                      ),
                      buildButton(
                        colorText:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : Colors.black,
                        onTap: null,
                        "important?",
                        color: _isImportantNotes
                            ? const Color.fromARGB(255, 74, 0, 255)
                            : Theme.of(context).brightness == Brightness.light
                                ? const Color(0xFF2F2F34)
                                : const Color(0xFFE9E9E9),
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            activeTrackColor: Colors.white,
                            trackOutlineColor: WidgetStateProperty.all(
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.white
                                    : Colors.black),
                            padding: const EdgeInsets.all(0),
                            value: _isImportantNotes,
                            onChanged: (value) {
                              setState(() {
                                _isImportantNotes = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Collections section
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _showCollections ? null : 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _showCollections ? 1.0 : 0.0,
                    child: _showCollections
                        ? Card(
                            margin: const EdgeInsets.only(top: 16),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                    onCollectionsChanged: (collections) {
                                      setState(() {
                                        _selectedCollections = collections;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: bounce_pkg.Bounce(
          scaleFactor: 0.98,
          duration: const Duration(milliseconds: 250),
          tiltAngle: 0,
          cursor: SystemMouseCursors.click,
          onTap: isLoading ? null : _updateNote,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? const Color.fromARGB(255, 47, 47, 52)
                  : const Color.fromARGB(255, 233, 233, 233),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
              child: Row(
                children: [
                  isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Row(
                          children: [
                            Text(
                              languageProvider.translate('update note'),
                              style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 5),
                            FaIcon(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.black,
                                FontAwesomeIcons.folder,
                                size: 16),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButton(String text,
      {IconData? icon,
      Color? color,
      Color? colorText,
      Widget? trailing,
      Function()? onTap}) {
    return bounce_pkg.Bounce(
      scaleFactor: 0.98,
      duration: const Duration(milliseconds: 250),
      tiltAngle: 0,
      cursor: SystemMouseCursors.click,
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: colorText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 5),
              FaIcon(
                icon,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Colors.black,
                size: 16,
              ),
            ],
            if (trailing != null) ...[
              const SizedBox(width: 10),
              trailing,
            ]
          ],
        ),
      ),
    );
  }
}
