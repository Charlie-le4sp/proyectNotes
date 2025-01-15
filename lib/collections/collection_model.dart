import 'package:cloud_firestore/cloud_firestore.dart';

class Collection {
  final String id;
  final String name;
  final String color;
  final Timestamp createdAt;
  final String uid;

  Collection({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.uid,
  });

  factory Collection.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Collection(
      id: doc.id,
      name: data['name'] ?? '',
      color: data['color'] ?? '#FFFFFF',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      uid: data['uid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color,
      'createdAt': createdAt,
      'uid': uid,
    };
  }
}
