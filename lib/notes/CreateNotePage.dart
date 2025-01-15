import 'dart:typed_data';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:lottie/lottie.dart';
import 'package:notes_app/collections/collection_selector.dart';
import 'package:notes_app/collections/collections_provider.dart';
import 'package:notes_app/languajeCode/languaje_provider.dart';
import 'package:provider/provider.dart';

class CreateNotePage extends StatefulWidget {
  const CreateNotePage({super.key});

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
  Color? _selectedColor; // Para almacenar el color seleccionado
  Uint8List? _noteImage;
  String? _noteImageUrl;
  String errorMessage = '';
  bool isLoading = false;
  DateTime? _reminderDate;
  bool _isImportantNotes = false; // Nuevo estado para el botón de estrella
  String _noteColor = '#FFC107'; // Cambiar el color por defecto a ámbar
  List<String> _selectedCollections =
      []; // Nueva variable para las colecciones seleccionadas

  @override
  void initState() {
    super.initState();
    // Cargar las colecciones cuando se inicia la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectionsProvider>().loadCollections();
    });
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

  void _pickNoteColor() {
    // Obtener el proveedor de idioma
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color tempSelectedColor =
            Color(int.parse(_noteColor.replaceFirst('#', '0xff')));

        return AlertDialog(
          title: Text(languageProvider.translate('selectAccentColor')),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: tempSelectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  _noteColor = '#${color.value.toRadixString(16).substring(2)}';
                });
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  // Aseguramos que el contenedor se actualice con el nuevo color seleccionado
                  _selectedColor =
                      Color(int.parse(_noteColor.replaceFirst('#', '0xff')));
                });
                Navigator.of(context).pop();
              },
              child: Text(languageProvider.translate('accept')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      try {
        final user = _auth.currentUser;
        if (user != null) {
          if (_noteImage != null) {
            await _uploadImageToCloudinary(_noteImage!);
          }

          // Crear el documento de la nota con las colecciones seleccionadas
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('notes')
              .add({
            'title': titleController.text,
            'description': descriptionController.text,
            'noteImage': _noteImageUrl,
            'createdAt': Timestamp.now(),
            'reminderDate': _reminderDate,
            'importantNotes': _isImportantNotes,
            'color': _noteColor,
            'isDeleted': false,
            'collections':
                _selectedCollections, // Agregar las colecciones seleccionadas
          });

          if (!mounted) return;
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _getFormattedReminderText() {
    if (_reminderDate == null) return 'recordatorio';

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
    // Obtener el proveedor de idioma
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('create note')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Sección de Título y Descripción
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
                              border: OutlineInputBorder(),
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
                              border: OutlineInputBorder(),
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
                    // Imagen
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
                            : const Center(
                                child: Icon(Icons.camera_alt,
                                    size: 50, color: Colors.grey),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Opciones Adicionales: Recordatorio, Color e Importancia
                Row(
                  children: [
                    // Recordatorio
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
                    // Color
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickNoteColor,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: _selectedColor ??
                                Color(
                                    0xFFFFC107), // Mostrar el color seleccionado
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
                    // Importancia
                    Column(
                      children: [
                        Text(_isImportantNotes ? 'Sí' : 'No'), // Texto dinámico
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
                Card(
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
                ),
                const SizedBox(height: 24),
                // Botón Guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _saveNote();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(languageProvider.translate('save note'),
                            style: TextStyle(fontSize: 16)),
                  ),
                ),
                // Mensajes de Error
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
