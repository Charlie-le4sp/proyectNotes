// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ListProvider with ChangeNotifier {
//   List<Map<String, dynamic>> _taskLists = [];

//   List<Map<String, dynamic>> get taskLists => _taskLists;

//   Future<void> fetchTaskLists() async {
//     // Obtener todas las listas de tareas del Firestore
//     final querySnapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(FirebaseAuth.instance.currentUser!.uid)
//         .collection('lists')
//         .orderBy('createdAt', descending: true)
//         .get();

//     _taskLists = querySnapshot.docs.map((doc) {
//       final data = doc.data();
//       data['id'] = doc.id; // Agregar el ID del documento a los datos
//       return data;
//     }).toList();

//     notifyListeners();
//   }

//   Future<void> toggleCompletion(String taskId, bool isCompleted) async {
//     // Cambiar el estado de completado
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(FirebaseAuth.instance.currentUser!.uid)
//         .collection('lists')
//         .doc(taskId)
//         .update({'isCompleted': !isCompleted});

//     fetchTaskLists(); // Volver a obtener las listas para reflejar el cambio
//   }

//   Future<void> updateTaskList(
//       String taskId, Map<String, dynamic> updatedData) async {
//     // Actualizar la lista de tareas en Firestore
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(FirebaseAuth.instance.currentUser!.uid)
//         .collection('lists')
//         .doc(taskId)
//         .update(updatedData);

//     fetchTaskLists(); // Refrescar la lista después de la actualización
//   }
// }
