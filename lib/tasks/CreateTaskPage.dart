import 'dart:typed_data';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:lottie/lottie.dart';
import 'package:notes_app/collections/collection_selector.dart';
import 'package:notes_app/collections/collections_provider.dart';
import 'package:notes_app/languajeCode/languaje_provider.dart';
import 'package:provider/provider.dart';

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
  List<String> _selectedCollections = [];

  @override
  void initState() {
    super.initState();
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
    // Obtener el proveedor de idioma
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    // Lista personalizada de colores pasteles

    final List<Color> pastelColors = [
      const Color(0xFFFF5722), // Naranja intenso
      const Color(0xFF4CAF50), // Verde
      const Color(0xFF3F51B5), // Azul oscuro
      const Color(0xFF03A9F4), // Azul claro
      const Color(0xFFFFEB3B), // Amarillo
      const Color(0xFFFF9800), // Naranja
      const Color(0xFF2196F3), // Azul
      const Color(0xFF00BCD4), // Cian
      const Color(0xFFCDDC39), // Lima
      const Color(0xFF009688), // Verde azulado
      const Color(0xFF8BC34A), // Verde claro
      const Color(0xFFA7A7A7), // Gris claro
      const Color(0xFF9E9E9E), // Gris
      const Color(0xFF795548), // Café
      const Color(0xFF607D8B), // Azul grisáceo
      const Color(0xFFFFC207), // Amarillo intenso
      const Color(0xFFFFC107), // Amarillo anaranjado
      const Color(0xFF2E2E2E), // Gris oscuro
      const Color(0xFFFF9D00), // Naranja saturado
      const Color(0xFFF64336), // Rojo
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageProvider.translate('task color')),
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
              child: Text(languageProvider.translate('accept')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveTask() async {
    // Obtener el proveedor de idioma
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      try {
        final user = _auth.currentUser;
        if (user != null) {
          if (_taskImage != null) {
            await _uploadImageToCloudinary(_taskImage!);
          }

          // Crear el documento de la tarea con las colecciones seleccionadas
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('lists')
              .add({
            'title': titleController.text,
            'description': descriptionController.text,
            'taskImage': _taskImageUrl,
            'createdAt': Timestamp.now(),
            'reminderDate': _reminderDate,
            'importantTask': _isImportantTask,
            'isCompleted': false,
            'isDeleted': false,
            'color': _taskColor,
            'collections':
                _selectedCollections, // Agregar las colecciones seleccionadas
          });

          if (!mounted) return;
          Navigator.pop(context);

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
            Future.delayed(const Duration(milliseconds: 500), () {
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
                duration: const Duration(milliseconds: 300),
                child: FadeIn(
                  duration: const Duration(milliseconds: 120),
                  child: Material(
                    color: Colors.transparent, // Fondo transparente.
                    child: SizedBox(
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
                              color: const Color.fromARGB(255, 29, 240, 99),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Text(
                                    languageProvider.translate('saved'),
                                    style: const TextStyle(
                                      fontFamily: "Roboto",
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
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
          Future.delayed(const Duration(milliseconds: 3000), removeToast);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FocusTraversalGroup(
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
                            controller: titleController,
                            autofocus: true,
                            textInputAction: TextInputAction.next,
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
                            textInputAction: TextInputAction.newline,
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
                    FocusTraversalGroup(
                      descendantsAreFocusable: false,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 190,
                          height: 190,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _taskImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _taskImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.camera_alt,
                                      size: 50, color: Colors.grey),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FocusTraversalGroup(
                  descendantsAreFocusable: false,
                  child: Row(
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
                                  _reminderDate == null
                                      ? 'No reminder set'
                                      : DateFormat.yMMMd()
                                          .format(_reminderDate!),
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
                          onTap: _pickTaskColor,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Color(int.parse(
                                  _taskColor.replaceFirst('#', '0xff'))),
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
                          Text(_isImportantTask ? 'Sí' : 'No'),
                          Switch(
                            value: _isImportantTask,
                            onChanged: (value) {
                              setState(() {
                                _isImportantTask = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveTask,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(languageProvider.translate('save task'),
                            style: const TextStyle(fontSize: 16)),
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
