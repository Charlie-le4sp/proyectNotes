import 'package:flutter/material.dart';
import 'package:notes_app/cloudinary_service.dart';

class UploadPage extends StatelessWidget {
  final cloudinaryService = CloudinaryService();

  UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subir Imagen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final imageUrl = await cloudinaryService.uploadImage();
            if (imageUrl != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Imagen subida con éxito! URL: $imageUrl')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al subir la imagen')));
            }
          },
          child: const Text('Subir Imagen a Cloudinary'),
        ),
      ),
    );
  }
}
