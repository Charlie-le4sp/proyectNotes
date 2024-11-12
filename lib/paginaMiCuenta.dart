import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/notes/CreateNotePage.dart';
import 'package:notes_app/cloudinary_service.dart';
import 'package:notes_app/login%20android%20y%20web%20autentication/login_page.dart';
import 'package:notes_app/notes/notesPage.dart';

class paginaMiCuenta extends StatefulWidget {
  final User user;
  final Map<String, dynamic> userData;

  paginaMiCuenta({required this.user, required this.userData});

  @override
  _paginaMiCuentaState createState() => _paginaMiCuentaState();
}

class _paginaMiCuentaState extends State<paginaMiCuenta> {
  String? profileImageUrl;
  String? username;

  @override
  void initState() {
    super.initState();
    profileImageUrl = widget.userData['profilePicture'];
    username = widget.userData['username']; // Obtén el nombre de usuario
  }

  Future<void> _updateProfileImage() async {
    final cloudinaryService = CloudinaryService();
    final newImageUrl = await cloudinaryService.uploadImage();

    if (newImageUrl != null) {
      setState(() {
        profileImageUrl = newImageUrl;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({'profilePicture': newImageUrl});
    }
  }

  Future<void> _removeProfileImage() async {
    setState(() {
      profileImageUrl = null;
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .update({'profilePicture': ''});
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        profileImageUrl != null && profileImageUrl!.isNotEmpty
                            ? NetworkImage(profileImageUrl!)
                            : AssetImage('assets/default_profile.png')
                                as ImageProvider,
                    child: profileImageUrl == null
                        ? Icon(Icons.person, size: 50)
                        : null,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _updateProfileImage,
                    child: Text('Subir nueva imagen'),
                  ),
                  ElevatedButton(
                    onPressed: _removeProfileImage,
                    child: Text('Eliminar imagen'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateNotePage(),
                          ));
                    },
                    child: Text('agregar nota'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotesPage(),
                          ));
                    },
                    child: Text('ver notas'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Bienvenido, ${username ?? 'Usuario'}',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Email: ${widget.user.email}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
