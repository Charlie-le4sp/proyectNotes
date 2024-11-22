import 'dart:typed_data';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/notes/EditNotePage.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text('Please login first.'));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Your Notes')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notes')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No notes found.'));
          }

          final notes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final noteDoc = notes[index];
              final note = noteDoc.data() as Map<String, dynamic>;

              return ListTile(
                leading: note['noteImage'] != null && note['noteImage'] != ''
                    ? Image.network(note['noteImage'], width: 50, height: 50)
                    : Icon(Icons.note),
                title: Text(note['title'] ?? 'No Title'),
                subtitle: Text(note['description'] ?? 'No Description'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (note['reminderDate'] != null)
                      Chip(
                        label: Text('Reminder'),
                        backgroundColor: Colors.blueAccent,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditNotePage(
                              noteId: noteDoc.id,
                              noteData: note,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
