import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/notes/CreateNotePage.dart';
import 'package:notes_app/cloudinary_service.dart';
import 'package:notes_app/login/login_page.dart';

class paginaMiCuenta extends StatefulWidget {
  final User user;
  final Map<String, dynamic> userData;

  const paginaMiCuenta({super.key, required this.user, required this.userData});

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
          builder: (context) => const LoginPage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
                            : const AssetImage('assets/default_profile.png')
                                as ImageProvider,
                    child: profileImageUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _updateProfileImage,
                    child: const Text('Subir nueva imagen'),
                  ),
                  ElevatedButton(
                    onPressed: _removeProfileImage,
                    child: const Text('Eliminar imagen'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateNotePage(),
                          ));
                    },
                    child: const Text('agregar nota'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Bienvenido, ${username ?? 'Usuario'}',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Email: ${widget.user.email}',
                    style: const TextStyle(fontSize: 16),
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
