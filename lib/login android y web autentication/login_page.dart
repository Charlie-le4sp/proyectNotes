import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:notes_app/login%20android%20y%20web%20autentication/register_page.dart';
import 'package:notes_app/paginaMiCuenta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../paginaInicio.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKeyLoginDefault = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String errorMessage = '';
  Uint8List? profileImage;
  String? profileImageUrl;

  String getTranslatedErrorMessage(String errorMessage) {
    switch (errorMessage) {
      case 'The email address is badly formatted.':
        return 'La dirección de correo electrónico tiene un formato incorrecto.';
      case 'The password is invalid or the user does not have a password.':
        return 'La contraseña es inválida o el usuario no tiene una contraseña.';
      case 'There is no user record corresponding to this identifier. The user may have been deleted.':
        return 'No hay ningún usuario registrado con este correo electrónico.';
      case 'The email address is already in use by another account.':
        return 'La dirección de correo electrónico ya está en uso por otra cuenta.';
      case 'The password must be 6 characters long or more.':
        return 'La contraseña debe tener al menos 6 caracteres.';
      default:
        return 'Ocurrió un error. Por favor, inténtelo de nuevo.';
    }
  }

  Future<void> signIn() async {
    if (_formKeyLoginDefault.currentState?.validate() ?? false) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user?.uid)
            .get();

        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        if (userData != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => paginaInicio()),
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage =
              getTranslatedErrorMessage(e.message ?? 'An error occurred');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKeyLoginDefault,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: signIn,
                    child: Text('Login'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text('Register'),
                  ),
                ],
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
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
