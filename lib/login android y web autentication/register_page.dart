import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/paginaInicio.dart';
import 'package:notes_app/paginaMiCuenta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

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
  bool _isProcessing = false;
  String errorMessage = '';
  Uint8List? profileImage;
  String? profileImageUrl;
  String? wallpaperUrl;
  String accentColor = '#FFBF00';
  final GoogleSignIn googleSignIn = GoogleSignIn();

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

        // Crear el documento del usuario con todos los campos necesarios
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'username': emailController.text.split('@')[0],
          'email': emailController.text,
          'profilePicture': profileImageUrl ?? '',
          'uid': userCredential.user?.uid,
          'wallpaper': '',
          'accentColor': '#FFBF00',
          'wallpaperOpacity': 0.0, // Valor por defecto
          'backdropBlur': 0.0, // Valor por defecto
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => paginaInicio()),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage = e.message ?? 'An error occurred';
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
        print("Error en autenticación de Google: $e");
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
        print("Error en autenticación de Google: $e");
        return null;
      }
    }

    if (user != null) {
      try {
        // Asegurarse de que la URL de la foto use HTTPS
        String? photoURL = user.photoURL;
        if (photoURL != null && !photoURL.startsWith('https:')) {
          photoURL = photoURL.replaceFirst('http:', 'https:');
        }

        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'username': user.displayName ?? user.email?.split('@')[0],
            'email': user.email,
            'profilePicture': photoURL ?? '',
            'uid': user.uid,
            'wallpaper': '',
            'accentColor': '#FFBF00',
            'wallpaperOpacity': 0.0,
            'backdropBlur': 0.0,
          });
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      } catch (e) {
        print("Error guardando datos de usuario: $e");
      }
    }

    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKeyRegister,
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
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
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
                          print(result);
                          if (result != null) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => paginaInicio()),
                            );
                          }
                        }).catchError((error) {
                          print('Registration Error: $error');
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
                                    'Registrarse con Google ',
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
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child: profileImage != null
                        ? Image.memory(
                            profileImage!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey[500],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your email' : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your password'
                    : null,
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: register,
                child: const Text('Register'),
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(errorMessage,
                      style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
