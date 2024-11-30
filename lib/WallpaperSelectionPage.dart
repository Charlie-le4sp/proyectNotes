import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/DisplayWallpaperPage.dart';

class WallpaperSelectionPage extends StatefulWidget {
  @override
  _WallpaperSelectionPageState createState() => _WallpaperSelectionPageState();
}

class _WallpaperSelectionPageState extends State<WallpaperSelectionPage> {
  List<Map<String, String>> wallpapers = [];
  String? selectedWallpaperUrl;

  @override
  void initState() {
    super.initState();
    _fetchWallpapers();
  }

  void _fetchWallpapers() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('wallpapersApp').get();

      setState(() {
        wallpapers = querySnapshot.docs.map((doc) {
          return {
            'link': doc['link'] as String,
            'title': doc['title'] as String,
          };
        }).toList();
      });
    } catch (e) {
      print('Error al cargar fondos: $e');
    }
  }

  Future<void> _updateUserWallpaper() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && selectedWallpaperUrl != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'wallpaper': selectedWallpaperUrl});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Fondo de Pantalla'),
      ),
      body: wallpapers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: wallpapers.length,
              itemBuilder: (context, index) {
                final wallpaper = wallpapers[index];
                final isSelected = wallpaper['link'] == selectedWallpaperUrl;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedWallpaperUrl = wallpaper['link'];
                    });
                  },
                  child: GridTile(
                    child: Stack(
                      children: [
                        Image.network(
                          wallpaper['link']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.error, color: Colors.red),
                            );
                          },
                        ),
                        if (isSelected)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 30,
                            ),
                          ),
                      ],
                    ),
                    footer: GridTileBar(
                      backgroundColor: Colors.black54,
                      title: Text(wallpaper['title']!),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (selectedWallpaperUrl != null) {
            await _updateUserWallpaper();
          }
        },
        child: const Icon(Icons.check),
        tooltip: 'Confirmar selección',
      ),
    );
  }
}
