import 'dart:typed_data';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bounce/bounce.dart' as bounce_pkg; // Prefijo para bounce
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
  bool _showCollections = false;

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

  void collections() {
    // Obtener el proveedor de idioma
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LayoutBuilder(builder: (context, constraints) {
          double dialogWidth;
          if (constraints.maxWidth > 1200) {
            dialogWidth = 400.0;
          } else if (constraints.maxWidth > 800) {
            dialogWidth = 300.0;
          } else {
            dialogWidth = constraints.maxWidth * 1;
          }

          return Center(
            child: ZoomIn(
              curve: Curves.easeInOutCubicEmphasized,
              duration: const Duration(milliseconds: 350),
              child: AlertDialog(
                insetPadding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                contentPadding: EdgeInsets.all(16),
                content: Container(
                  width: dialogWidth,
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Card(
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
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _saveNote() async {
    // Obtener el proveedor de idioma
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
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

  Widget buildButton(String text,
      {IconData? icon, Color? color, Widget? trailing, Function()? onTap}) {
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
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Colors.black,
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
                color: Theme.of(context).brightness == Brightness.light
                    ? const Color.fromARGB(255, 244, 69, 57) // Modo claro
                    : const Color(0xFFE9E9E9)),
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
            languageProvider.translate(
              'create note',
            )),
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
                            decoration: InputDecoration(
                              hoverColor: Colors.transparent,
                              filled: true,
                              fillColor: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.white
                                  : Color.fromARGB(255, 12, 12, 12),
                              errorStyle: TextStyle(
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
                                  : Color.fromARGB(255, 12, 12, 12),
                              errorStyle: TextStyle(
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
                    // Imagen
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
                                  : Color.fromARGB(255, 12, 12, 12),
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
                Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.spaceAround,
                    children: [
                      buildButton(
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
                        icon: FontAwesomeIcons.palette,
                        "color",
                        onTap: _pickNoteColor,
                        color: _selectedColor ?? const Color(0xFFFFC107),
                      ),
                      buildButton(
                        "recordatorio",
                        icon: FontAwesomeIcons.calendar,
                        onTap: _selectReminderDate,
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFF2F2F34)
                            : const Color(0xFFE9E9E9),
                      ),
                      buildButton(
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
                            trackOutlineColor:
                                MaterialStateProperty.all(Colors.white),
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
      floatingActionButton: // Botón Guardar
          SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: bounce_pkg.Bounce(
          scaleFactor: 0.98,
          duration: const Duration(milliseconds: 250),
          tiltAngle: 0,
          cursor: SystemMouseCursors.click,
          onTap: isLoading
              ? null
              : () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _saveNote();
                  }
                },
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
                              languageProvider.translate('save note'),
                              style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 5),
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
}
