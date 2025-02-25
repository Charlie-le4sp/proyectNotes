import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/login/register_page.dart';
import 'package:notes_app/themas/themeModeNotifier.dart';
import 'package:notes_app/themas/themes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../paginaInicio.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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

  bool _isProcessing = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool _obscureText = true;
  bool _showLatestCharacter = false;
  String _latestCharacter = '';

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
            MaterialPageRoute(builder: (context) => const paginaInicio()),
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

  Future<User?> signInWithGoogle() async {
    User? user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
            await _auth.signInWithPopup(authProvider);
        user = userCredential.user;
      } catch (e) {
        print('Error en autenticación de Google: $e');
        return null;
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      try {
        final GoogleSignInAccount? googleSignInAccount =
            await googleSignIn.signIn();

        if (googleSignInAccount != null) {
          final GoogleSignInAuthentication googleSignInAuthentication =
              await googleSignInAccount.authentication;

          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );

          final UserCredential userCredential =
              await _auth.signInWithCredential(credential);
          user = userCredential.user;
        }
      } catch (e) {
        print('Error en autenticación de Google: $e');
        return null;
      }
    }

    if (user != null) {
      try {
        // Verificar si el usuario ya existe en Firestore
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Si el usuario no existe, crear su documento con manejo de errores para la foto
          String photoURL = '';
          try {
            // Intentar obtener la URL de la foto
            photoURL = user.photoURL ?? '';
          } catch (e) {
            print('Error al obtener foto de perfil: $e');
            // Si hay error, usar una URL de imagen por defecto o dejar vacío
            photoURL = '';
          }

          await _firestore.collection('users').doc(user.uid).set({
            'username': user.displayName ?? user.email?.split('@')[0],
            'email': user.email,
            'profilePicture': photoURL,
            'uid': user.uid,
            'wallpaper': '',
            'accentColor': '#FFFFFF',
          });

          // Crear nota de ejemplo
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('notes')
              .add({
            'noteImage': '',
            'title': 'Nota de ejemplo',
            'createdAt': FieldValue.serverTimestamp(),
            'description': 'Descripción de ejemplo',
            'reminderDate': null,
            'isDeleted': false,
            'importantNotes': false,
            'color': '#FFFFFF',
          });

          // Crear lista de ejemplo
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('lists')
              .add({
            'title': 'Lista de ejemplo',
            'isCompleted': false,
            'isDeleted': false,
            'importantTask': false,
            'description': 'Descripción de lista de ejemplo',
            'listImage': '',
            'createdAt': FieldValue.serverTimestamp(),
            'reminderDate': null,
            'color': '#FFFFFF',
          });
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      } catch (e) {
        print('Error al crear documento de usuario: $e');
        // Considerar si quieres manejar este error de alguna manera específica
      }
    }

    return user;
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeModeNotifier>(context);
    final brightness = MediaQuery.of(context).platformBrightness;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKeyLoginDefault,
          child: Column(
            children: <Widget>[
              if (kIsWeb)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 1,
                    child: OutlinedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : Colors.black),
                        elevation: WidgetStateProperty.all<double>(0.0),
                        overlayColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return const Color.fromARGB(255, 190, 143, 255);
                            }
                            return null;
                          },
                        ),
                        side: WidgetStateProperty.all<BorderSide>(
                          BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                              width: 2),
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          _isProcessing = true;
                        });
                        await signInWithGoogle().then((result) {
                          if (result != null) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const paginaInicio()),
                            );
                          }
                        }).catchError((error) {
                          print('Login Error: $error');
                        });
                        setState(() {
                          _isProcessing = false;
                        });
                      },
                      child: _isProcessing
                          ? const CircularProgressIndicator(
                              strokeWidth: 5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Iniciar sesión con Google ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: "Poppins",
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const FaIcon(
                                    FontAwesomeIcons.google,
                                    size: 20,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hoverColor: Colors.transparent,
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : const Color.fromARGB(255, 12, 12, 12),
                  errorStyle: const TextStyle(
                      fontSize: 14,
                      fontFamily: "Poppins",
                      color: Color.fromARGB(255, 255, 125, 116),
                      fontWeight: FontWeight.bold),
                  labelText: "Email",
                  labelStyle: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.light
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
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                      width: 2.0,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  hoverColor: Colors.transparent,
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : const Color.fromARGB(255, 12, 12, 12),
                  errorStyle: const TextStyle(
                      fontSize: 14,
                      fontFamily: "Poppins",
                      color: Color.fromARGB(255, 255, 125, 116),
                      fontWeight: FontWeight.bold),
                  labelText: "password",
                  labelStyle: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white38,
                      width: 1,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                      width: 2.0,
                    ),
                  ),
                ),
                obscureText: _obscureText && !_showLatestCharacter,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _showLatestCharacter = true;
                      _latestCharacter = value.substring(value.length - 1);
                    });
                    Future.delayed(const Duration(milliseconds: 1500), () {
                      setState(() {
                        _showLatestCharacter = false;
                      });
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: signIn,
                    child: const Text('Login'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage()),
                      );
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
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
