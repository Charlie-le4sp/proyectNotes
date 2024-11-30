import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DisplayWallpaperPage extends StatelessWidget {
  const DisplayWallpaperPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Por favor, inicia sesión.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista de Fondo de Pantalla'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(
              child: Text(
                'No hay imagen disponible para mostrar.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final imageUrl = userData['wallpaper'] as String?;

          if (imageUrl == null || imageUrl.isEmpty) {
            return const Center(
              child: Text(
                'No hay imagen disponible para mostrar.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.error, color: Colors.red),
              );
            },
          );
        },
      ),
    );
  }
}
