import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';

class NotesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryPublic _cloudinary;
  final String userId;

  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> get notes => _notes;

  NotesProvider({
    required this.userId,
    required String cloudinaryCloudName,
    required String cloudinaryUploadPreset,
  }) : _cloudinary = CloudinaryPublic(
            cloudinaryCloudName, cloudinaryUploadPreset,
            cache: false) {
    fetchNotes();
  }

  Future<String?> uploadImageToCloudinary(Uint8List imageData) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          imageData,
          identifier: 'note_${DateTime.now().millisecondsSinceEpoch}.jpg',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> addNote(String title, String description, Uint8List? imageData,
      DateTime? reminderDate, bool isImportant) async {
    String? imageUrl;
    if (imageData != null) {
      imageUrl = await uploadImageToCloudinary(imageData);
    }

    final noteData = {
      'noteImage': imageUrl ?? '',
      'title': title,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'reminderDate':
          reminderDate != null ? Timestamp.fromDate(reminderDate) : null,
      'isDeleted': false,
      'importantNotes': isImportant,
    };

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .add(noteData);
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .get();
    _notes = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'title': data['title'] ?? '',
        'description': data['description'] ?? '',
        'noteImage': data['noteImage'] ?? '',
        'createdAt': data['createdAt'],
        'reminderDate': data['reminderDate'],
        'isDeleted': data['isDeleted'] ?? false,
        'importantNotes': data['importantNotes'] ?? false,
      };
    }).toList();
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getNoteById(String noteId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(noteId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data?['title'] ?? '',
          'description': data?['description'] ?? '',
          'noteImage': data?['noteImage'] ?? '',
          'createdAt': data?['createdAt'],
          'reminderDate': data?['reminderDate']?.toDate(),
          'isDeleted': data?['isDeleted'] ?? false,
          'importantNotes': data?['importantNotes'] ?? false,
        };
      }
      return null;
    } catch (e) {
      print('Error fetching note by ID: $e');
      return null;
    }
  }

  Future<String?> uploadNoteImage(Uint8List imageData) async {
    return await uploadImageToCloudinary(
        imageData); // Reutilizando el método existente.
  }

  Future<void> updateNote(
      String noteId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(noteId)
          .update(updatedData);
      fetchNotes(); // Opcional: para actualizar la lista local después de editar.
    } catch (e) {
      print('Error updating note: $e');
      throw Exception('Failed to update note');
    }
  }
}
