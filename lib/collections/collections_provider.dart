import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/collections/collection_model.dart';
import 'package:notes_app/notes/modelCardNote.dart';
import 'package:notes_app/tasks/modelCardTask.dart';

class CollectionsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Collection> _collections = [];
  List<Note> _collectionNotes = [];
  List<Task> _collectionTasks = [];
  bool _isLoading = false;
  String? _selectedCollectionId;

  List<Collection> get collections => _collections;
  List<Note> get collectionNotes => _collectionNotes;
  List<Task> get collectionTasks => _collectionTasks;
  bool get isLoading => _isLoading;
  String? get selectedCollectionId => _selectedCollectionId;

  Future<void> loadCollections() async {
    _setLoading(true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('collections')
            .orderBy('createdAt', descending: true)
            .get();

        _collections =
            snapshot.docs.map((doc) => Collection.fromFirestore(doc)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading collections: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createCollection(String name, String color) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final collection = Collection(
          id: '',
          name: name,
          color: color,
          createdAt: Timestamp.now(),
          uid: user.uid,
        );

        final docRef = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('collections')
            .add(collection.toMap());

        _collections.insert(
          0,
          Collection(
            id: docRef.id,
            name: collection.name,
            color: collection.color,
            createdAt: collection.createdAt,
            uid: collection.uid,
          ),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error creating collection: $e');
    }
  }

  Future<void> selectCollection(String collectionId) async {
    _selectedCollectionId = collectionId;
    await loadCollectionItems(collectionId);
    notifyListeners();
  }

  Future<void> updateCollectionColor(
      String collectionId, String newColor) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Actualizar en Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('collections')
            .doc(collectionId)
            .update({'color': newColor});

        // Actualizar en la lista local
        final index = _collections.indexWhere((c) => c.id == collectionId);
        if (index != -1) {
          _collections[index] = Collection(
            id: _collections[index].id,
            name: _collections[index].name,
            color: newColor,
            createdAt: _collections[index].createdAt,
            uid: _collections[index].uid,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error updating collection color: $e');
    }
  }

  Future<void> updateCollectionName(String collectionId, String newName) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Actualizar en Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('collections')
            .doc(collectionId)
            .update({'name': newName});

        // Actualizar en la lista local
        final index = _collections.indexWhere((c) => c.id == collectionId);
        if (index != -1) {
          _collections[index] = Collection(
            id: _collections[index].id,
            name: newName,
            color: _collections[index].color,
            createdAt: _collections[index].createdAt,
            uid: _collections[index].uid,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error updating collection name: $e');
    }
  }

  Future<void> loadCollectionItems(String collectionId) async {
    _setLoading(true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Cargar notas de la colección
        final notesSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('notes')
            .where('collections', arrayContains: collectionId)
            .get();

        // Cargar tareas de la colección
        final tasksSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('lists')
            .where('collections', arrayContains: collectionId)
            .get();

        _collectionNotes = notesSnapshot.docs.map((doc) {
          final data = doc.data();
          return Note(
            noteId: doc.id,
            uid: user.uid,
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            importantNotes: data['importantNotes'] ?? false,
            noteImage: data['noteImage'],
            reminderDate: data['reminderDate'],
            createdAt: data['createdAt'],
            isDeleted: data['isDeleted'] ?? false,
            color: data['color'] ?? '#FFFFFF',
            collections: List<String>.from(data['collections'] ?? []),
          );
        }).toList();

        _collectionTasks = tasksSnapshot.docs.map((doc) {
          final data = doc.data();
          return Task(
            taskId: doc.id,
            uid: user.uid,
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            importantTask: data['importantTask'] ?? false,
            isCompleted: data['isCompleted'] ?? false,
            isDeleted: data['isDeleted'] ?? false,
            taskImage: data['taskImage'],
            reminderDate: data['reminderDate'],
            createdAt: data['createdAt'],
            color: data['color'] ?? '#FFFFFF',
            collections: List<String>.from(data['collections'] ?? []),
          );
        }).toList();

        notifyListeners();
      }
    } catch (e) {
      print('Error loading collection items: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCollection(String collectionId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('collections')
            .doc(collectionId)
            .delete();

        _collections.removeWhere((collection) => collection.id == collectionId);
        if (_selectedCollectionId == collectionId) {
          _selectedCollectionId = null;
          _collectionNotes = [];
          _collectionTasks = [];
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting collection: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Collection? getCollectionById(String collectionId) {
    return _collections.firstWhere(
      (collection) => collection.id == collectionId,
      orElse: () => Collection(
        id: '',
        name: '',
        color: '#FFFFFF',
        createdAt: Timestamp.now(),
        uid: '',
      ),
    );
  }
}
