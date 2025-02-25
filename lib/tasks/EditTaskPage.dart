import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:notes_app/collections/collection_selector.dart';
import 'package:notes_app/languajeCode/languaje_provider.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bounce/bounce.dart' as bounce_pkg;
import 'package:notes_app/collections/collections_provider.dart';

class EditTaskPage extends StatefulWidget {
  final String taskId;

  const EditTaskPage({super.key, required this.taskId});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
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
  bool _showCollections = false;

  @override
  void initState() {
    super.initState();
    _loadTaskData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectionsProvider>().loadCollections();
    });
  }

  Future<void> _loadTaskData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('lists')
          .doc(widget.taskId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          titleController.text = data['title'] ?? '';
          descriptionController.text = data['description'] ?? '';
          _taskImageUrl = data['taskImage'];
          _reminderDate = (data['reminderDate'] as Timestamp?)?.toDate();
          _isImportantTask = data['importantTask'] ?? false;
          _taskColor = data['color'] ?? '#FFFFFF';
          _selectedCollections = List<String>.from(data['collections'] ?? []);
          setState(() {});
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
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      setState(() {
        _taskImageUrl = response.secureUrl;
      });
    } catch (e) {
      // Handle error
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

  void _pickTaskColor() {
    // Obtener el proveedor de idioma
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageProvider.translate('task color')),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor:
                  Color(int.parse(_taskColor.replaceFirst('#', '0xff'))),
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

  Future<void> _updateTask() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = _auth.currentUser;
      if (user == null) return;

      setState(() {
        isLoading = true;
      });

      if (_taskImage != null) {
        await _uploadImageToCloudinary(_taskImage!);
      }

      final taskData = {
        'title': titleController.text,
        'description': descriptionController.text,
        'taskImage': _taskImageUrl ?? '',
        'reminderDate':
            _reminderDate != null ? Timestamp.fromDate(_reminderDate!) : null,
        'importantTask': _isImportantTask,
        'color': _taskColor,
        'collections': _selectedCollections,
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('lists')
          .doc(widget.taskId)
          .update(taskData);

      Navigator.of(context).pop();
    }
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
            languageProvider.translate('edit task')),
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
                        child: _taskImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  _taskImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : (_taskImageUrl != null &&
                                    _taskImageUrl!.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _taskImageUrl!,
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
                        onTap: _pickTaskColor,
                        color: Color(
                            int.parse(_taskColor.replaceFirst('#', '0xff'))),
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
                        color: _isImportantTask
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
                            value: _isImportantTask,
                            onChanged: (value) {
                              setState(() {
                                _isImportantTask = value;
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
                                    key: ValueKey(
                                        _selectedCollections.toString()),
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
          onTap: isLoading ? null : _updateTask,
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
                              languageProvider.translate('update task'),
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
                                FontAwesomeIcons.listCheck,
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
