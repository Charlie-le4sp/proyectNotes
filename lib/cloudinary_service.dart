import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  final cloudinary =
      CloudinaryPublic('djm1bosvc', 'preset_users', cache: false);

  Future<String?> uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(pickedFile.path,
              resourceType: CloudinaryResourceType.Image),
        );
        return response.secureUrl;
      } on CloudinaryException catch (e) {
        print('Error al subir imagen: ${e.message}');
        return null;
      }
    }
    return null;
  }
}
