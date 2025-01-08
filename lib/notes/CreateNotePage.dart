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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color tempSelectedColor =
            Color(int.parse(_noteColor.replaceFirst('#', '0xff')));

        return AlertDialog(
          title: const Text('Selecciona un color para la nota'),
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
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
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
        'color': _noteColor, // Añadir el color al documento
      };

      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('notes')
            .add(noteData);

        Navigator.of(context).pop();
        final overlay = Overlay.of(context);
        OverlayEntry? overlayEntry;

        // Variable para controlar la visibilidad.
        bool isVisible = true;

        // Función para iniciar la animación de fadeOut y remover el Toast.
        void removeToast() {
          if (!isVisible) return; // Evita múltiples llamadas.
          isVisible = false;

          // Actualiza la animación a fadeOut.
          overlayEntry?.markNeedsBuild();

          // Remueve el overlayEntry después de la animación.
          Future.delayed(Duration(milliseconds: 500), () {
            overlayEntry?.remove();
            overlayEntry = null;
          });
        }

        // Crea el OverlayEntry.
        overlayEntry = OverlayEntry(
          builder: (context) => Positioned(
            bottom: 20,
            left: 20,
            child: AnimatedOpacity(
              opacity: isVisible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: FadeIn(
                duration: Duration(milliseconds: 120),
                child: Material(
                  color: Colors.transparent, // Fondo transparente.
                  child: Container(
                    width: 230,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            width: 230,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.transparent,
                            ),
                            height: 230,
                            child: Center(
                              child: Lottie.asset(
                                'assets/lottieAnimations/final.json',
                                fit: BoxFit.contain,
                                repeat: false,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 230,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Color.fromARGB(255, 29, 240, 99),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  "Guardado",
                                  style: TextStyle(
                                    fontFamily: "Roboto",
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: FaIcon(
                                  FontAwesomeIcons.circleCheck,
                                  size: 22,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        // Inserta el OverlayEntry.
        overlay.insert(overlayEntry!);

        // Activa el fadeOut después de 3 segundos.
        Future.delayed(Duration(milliseconds: 3000), removeToast);
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
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de Título y Descripción
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Título',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Ingresa un título'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 4,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Ingresa una descripción'
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
                      : const Text('Guardar Nota',
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
    );
  }
}
