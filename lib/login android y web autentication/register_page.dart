import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/paginaInicio.dart';
import 'package:notes_app/paginaMiCuenta.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKeyRegister = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryPublic cloudinary =
      CloudinaryPublic('djm1bosvc', 'preset_users', cache: false);
  String errorMessage = '';
  Uint8List? profileImage;
  String? profileImageUrl;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        profileImage = imageBytes;
      });
      await _uploadImageToCloudinary(imageBytes);
    }
  }

  Future<void> _uploadImageToCloudinary(Uint8List imageBytes) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          imageBytes,
          identifier:
              'profile_image', // Corregir la falta de argumento "identifier"
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      setState(() {
        profileImageUrl = response.secureUrl;
      });
    } on CloudinaryException catch (e) {
      setState(() {
        errorMessage = 'Error uploading image: ${e.message}';
      });
    }
  }

  Future<void> register() async {
    if (_formKeyRegister.currentState?.validate() ?? false) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        final userData = {
          'username': emailController.text.split('@')[0],
          'uid': userCredential.user?.uid,
          'email': emailController.text,
          'profilePicture': profileImageUrl ?? '', // URL de imagen
        };

        final userDocRef =
            _firestore.collection('users').doc(userCredential.user?.uid);
        await userDocRef.set(userData);

        // Crear las subcolecciones 'notes' y 'lists' para el usuario
        await userDocRef.collection('notes').add({
          'noteImage': '',
          'title': 'Nota de ejemplo',
          'createdAt': FieldValue.serverTimestamp(),
          'description': 'Descripción de ejemplo',
          'reminderDate': null,
          'isDeleted': false,
          'importantNotes': false,
        });

        await userDocRef.collection('lists').add({
          'title': 'Lista de ejemplo',
          'isCompleted': false,
          'isDeleted': false,
          'importantTask': false,
          'description': 'Descripción de lista de ejemplo',
          'listImage': '',
          'createdAt': FieldValue.serverTimestamp(),
          'reminderDate': null,
        });

        // Guardar el estado de sesión en SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        // Navegar a la página de inicio de cuenta después de registro
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                paginaMiCuenta(user: userCredential.user!, userData: userData),
          ),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage = e.message ?? 'An error occurred';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKeyRegister,
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImage != null
                      ? MemoryImage(profileImage!)
                      : AssetImage('assets/default_profile.png')
                          as ImageProvider,
                  child: Icon(Icons.camera_alt, size: 30),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your email' : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your password'
                    : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: register,
                child: Text('Register'),
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child:
                      Text(errorMessage, style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
