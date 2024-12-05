import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/login%20android%20y%20web%20autentication/register_page.dart';
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

  Future<User?> signInWithGoogle() async {
    User? user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
            await _auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await _auth.signInWithCredential(credential);

          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            print('The account already exists with a different credential.');
          } else if (e.code == 'invalid-credential') {
            print('Error occurred while accessing credentials. Try again.');
          }
        } catch (e) {
          print(e);
        }
      }
    }

    if (user != null) {
      // Verificar si el usuario ya existe en Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // Si el usuario no existe, crear su documento
        await _firestore.collection('users').doc(user.uid).set({
          'username': user.displayName ?? user.email?.split('@')[0],
          'email': user.email,
          'profilePicture': user.photoURL ?? '',
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
    }

    return user;
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeModeNotifier>(context);
    final brightness = MediaQuery.of(context).platformBrightness;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
      themeMode: themeNotifier.getThemeMode(),
      home: Scaffold(
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
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 1,
                      child: OutlinedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.white
                                  : Colors.black),
                          elevation: MaterialStateProperty.all<double>(0.0),
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Color.fromARGB(255, 190, 143, 255);
                              }
                              return null;
                            },
                          ),
                          side: MaterialStateProperty.all<BorderSide>(
                            BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                                width: 2),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
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
                                    builder: (context) => paginaInicio()),
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
                            ? CircularProgressIndicator(
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
                                    SizedBox(width: 5),
                                    FaIcon(
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
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
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
      ),
    );
  }
}
