import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/DisplayWallpaperPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';

class WallpaperSelectionPage extends StatefulWidget {
  @override
  _WallpaperSelectionPageState createState() => _WallpaperSelectionPageState();
}

class _WallpaperSelectionPageState extends State<WallpaperSelectionPage> {
  List<Map<String, String>> wallpapers = [];
  String? selectedWallpaperUrl;
  double wallpaperOpacity = 0.8;
  double backdropBlur = 0.0;

  Future<void> _fetchWallpapers() async {
    try {
      final QuerySnapshot wallpaperSnapshot =
          await FirebaseFirestore.instance.collection('wallpapersApp').get();

      setState(() {
        wallpapers = wallpaperSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'link': data['link'] as String,
            'title': data['title'] as String,
          };
        }).toList();
      });

      print('Wallpapers cargados: ${wallpapers.length}');
      wallpapers.forEach((wallpaper) {
        print('URL: ${wallpaper['link']}, Título: ${wallpaper['title']}');
      });
    } catch (e) {
      print('Error al cargar los fondos de pantalla: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
    _fetchWallpapers();
  }

  Future<void> _loadCurrentSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        selectedWallpaperUrl = userDoc.data()?['wallpaper'];
        wallpaperOpacity = selectedWallpaperUrl == null
            ? 1.0
            : (userDoc.data()?['wallpaperOpacity'] ?? 0.8);
        backdropBlur = userDoc.data()?['backdropBlur'] ?? 0.0;
      });
    }
  }

  Future<void> _updateSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Map<String, dynamic> updateData = {
        'wallpaperOpacity': wallpaperOpacity,
        'backdropBlur': backdropBlur,
      };

      if (selectedWallpaperUrl != null) {
        updateData['wallpaper'] = selectedWallpaperUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updateData);
      Navigator.pop(context);
    }
  }

  Future<void> _removeWallpaper() async {
    // Mostrar diálogo de confirmación
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
              '¿Estás seguro que deseas eliminar el fondo de pantalla?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );

    // Si el usuario confirma la eliminación
    if (confirmDelete == true) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'wallpaper': null,
          'wallpaperOpacity': 0.8,
          'backdropBlur': 0.0,
        });

        setState(() {
          selectedWallpaperUrl = null;
          wallpaperOpacity = 0.8;
          backdropBlur = 0.0;
        });

        // Mostrar SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fondo de pantalla eliminado correctamente'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _removeWallpaper,
            tooltip: 'Eliminar fondo',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Opacidad: '),
                    Expanded(
                      child: Slider(
                        value: 1.0 - wallpaperOpacity,
                        min: 0.0,
                        max: 1.0,
                        divisions: 100,
                        label: wallpaperOpacity.toStringAsFixed(2),
                        onChanged: (value) {
                          setState(() {
                            wallpaperOpacity = 1.0 - value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Desenfoque: '),
                    Expanded(
                      child: Slider(
                        value: backdropBlur,
                        min: 0.0,
                        max: 20.0,
                        divisions: 20,
                        label: backdropBlur.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            backdropBlur = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: wallpapers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: wallpapers.length,
                    itemBuilder: (context, index) {
                      final wallpaper = wallpapers[index];
                      final isSelected =
                          wallpaper['link'] == selectedWallpaperUrl;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedWallpaperUrl = wallpaper['link'];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: isSelected
                                ? Border.all(
                                    color: Colors.green,
                                    width: 3,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Imagen con efectos
                                ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                    sigmaX: isSelected ? backdropBlur : 0,
                                    sigmaY: isSelected ? backdropBlur : 0,
                                  ),
                                  child: Opacity(
                                    opacity: wallpaperOpacity,
                                    child: Image.network(
                                      wallpaper['link']!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(Icons.error,
                                              color: Colors.red),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                // Indicador de selección
                                if (isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                // Título
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      wallpaper['title']!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateSettings,
        child: const Icon(Icons.check),
        tooltip: 'Guardar configuración',
      ),
    );
  }
}
