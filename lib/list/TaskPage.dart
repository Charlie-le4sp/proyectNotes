// import 'dart:typed_data';

// import 'package:cloudinary_public/cloudinary_public.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:notes_app/list/EditinTaskPage.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class TaskPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       return Center(child: Text('Please login first.'));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Your Tasks'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.delete),
//             onPressed: () async {
//               final confirm = await showDialog<bool>(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: Text('Delete All Tasks'),
//                   content: Text('Are you sure you want to delete all tasks?'),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context, false),
//                       child: Text('Cancel'),
//                     ),
//                     TextButton(
//                       onPressed: () => Navigator.pop(context, true),
//                       child: Text('Delete All'),
//                     ),
//                   ],
//                 ),
//               );
//               if (confirm ?? false) {
//                 FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(user.uid)
//                     .collection('lists')
//                     .get()
//                     .then((snapshot) {
//                   for (var doc in snapshot.docs) {
//                     doc.reference.delete();
//                   }
//                 });
//               }
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .collection('lists')
//             .orderBy('createdAt', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('No tasks found.'));
//           }

//           final tasks = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: tasks.length,
//             itemBuilder: (context, index) {
//               final task = tasks[index];
//               final taskData = task.data() as Map<String, dynamic>;

//               return ListTile(
//                 leading:
//                     taskData['listImage'] != null && taskData['listImage'] != ''
//                         ? Image.network(taskData['listImage'],
//                             width: 50, height: 50)
//                         : Icon(Icons.list),
//                 title: Text(taskData['title'] ?? 'No Title'),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(taskData['description'] ?? 'No Description'),
//                     if (taskData['reminderDate'] != null)
//                       Chip(
//                         label: Text(
//                           'Reminder: ${timeago.format(taskData['reminderDate'].toDate())}',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         backgroundColor: Colors.blue,
//                       ),
//                   ],
//                 ),
//                 trailing: Wrap(
//                   spacing: 8.0,
//                   children: [
//                     IconButton(
//                       icon: Icon(
//                         taskData['isCompleted'] == true
//                             ? Icons.check_circle
//                             : Icons.radio_button_unchecked,
//                         color: taskData['isCompleted'] == true
//                             ? Colors.green
//                             : Colors.grey,
//                       ),
//                       onPressed: () {
//                         task.reference
//                             .update({'isCompleted': !taskData['isCompleted']});
//                       },
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.edit),
//                       onPressed: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => EditTaskPage(
                              
//                               taskId: task.id),
//                           ),
//                         );
//                       },
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.delete),
//                       onPressed: () async {
//                         final confirm = await showDialog<bool>(
//                           context: context,
//                           builder: (context) => AlertDialog(
//                             title: Text('Delete Task'),
//                             content: Text(
//                                 'Are you sure you want to delete this task?'),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context, false),
//                                 child: Text('Cancel'),
//                               ),
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context, true),
//                                 child: Text('Delete'),
//                               ),
//                             ],
//                           ),
//                         );
//                         if (confirm ?? false) {
//                           task.reference.delete();
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
