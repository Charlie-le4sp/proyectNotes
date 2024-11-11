import 'package:flutter/material.dart';
import 'package:notes_app/cloudinary_service.dart';

class UploadPage extends StatelessWidget {
  final cloudinaryService = CloudinaryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subir Imagen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final imageUrl = await cloudinaryService.uploadImage();
            if (imageUrl != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Imagen subida con éxito! URL: $imageUrl')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al subir la imagen')));
            }
          },
          child: Text('Subir Imagen a Cloudinary'),
        ),
      ),
    );
  }
}
