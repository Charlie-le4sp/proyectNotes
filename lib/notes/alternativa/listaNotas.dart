import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/notes/alternativa/crearNota.dart';
import 'package:notes_app/notes/alternativa/editarNota.dart';
import 'package:notes_app/notes/alternativa/notesProvider.dart';
import 'package:provider/provider.dart';

class ListasNotas extends StatefulWidget {
  @override
  _ListasNotasState createState() => _ListasNotasState();
}

class _ListasNotasState extends State<ListasNotas> {
  bool _isLoading = true;
  int expandedNoteIndex = 0; // -1 significa que ninguna está expandida

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    await notesProvider.fetchNotes();
    setState(() {
      _isLoading = false;
    });
  }

  void moveToTop(int index, List<Map<String, dynamic>> notes) {
    if (index == 0) return; // La primera nota ya está arriba
    setState(() {
      final note = notes.removeAt(index);
      notes.insert(0, note);
      expandedNoteIndex = 0; // Mantener la primera expandida
    });
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    final notes = notesProvider.notes;

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? Center(child: Text('No notes available. Add some!'))
              : ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 400;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: GestureDetector(
                            onTap: index == 0
                                ? null // No hacer nada para la primera nota
                                : () {
                                    if (expandedNoteIndex == index) {
                                      setState(() {
                                        expandedNoteIndex =
                                            -1; // Colapsar la nota
                                      });
                                    } else {
                                      moveToTop(index,
                                          notes); // Mover al tope y expandir
                                    }
                                  },
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: expandedNoteIndex == index
                                    ? _buildExpandedContent(
                                        context, note, isNarrow, constraints)
                                    : _buildCollapsedContent(
                                        context, note, isNarrow),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => crearNota()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // Contenido cuando la tarjeta está expandida
  Widget _buildExpandedContent(BuildContext context, Map<String, dynamic> note,
      bool isNarrow, BoxConstraints constraints) {
    String formatRelativeDate(Timestamp? timestamp) {
      if (timestamp == null) return 'Sin fecha';
      final now = DateTime.now();
      final date = timestamp.toDate();
      final difference = date.difference(now);

      if (difference.isNegative) {
        final past = now.difference(date);
        if (past.inDays > 1) return "Hace ${past.inDays} días";
        if (past.inDays == 1) return "Hace 1 día";
        if (past.inHours > 1) return "Hace ${past.inHours} horas";
        if (past.inHours == 1) return "Hace 1 hora";
        if (past.inMinutes > 1) return "Hace ${past.inMinutes} minutos";
        return "Hace menos de 1 minuto";
      } else {
        if (difference.inDays > 1) return "En ${difference.inDays} días";
        if (difference.inDays == 1) return "En 1 día";
        if (difference.inHours > 1) return "En ${difference.inHours} horas";
        if (difference.inHours == 1) return "En 1 hora";
        if (difference.inMinutes > 1)
          return "En ${difference.inMinutes} minutos";
        return "En menos de 1 minuto";
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;

        double widthCard;
        double widthImageNotes;
        double widthTextNotes;
        double widthBotons;
        double heightCard;
        double heightCardElements;

        // Ajusta los tamaños de los videos dependiendo del ancho de la pantalla
        if (screenWidth > 1200) {
          // Pantallas grandes
          widthCard = MediaQuery.of(context).size.width * 0.6;
          widthImageNotes = MediaQuery.of(context).size.width * 0.18;
          widthTextNotes = MediaQuery.of(context).size.width * 0.38;
          widthBotons = MediaQuery.of(context).size.width * 1;
          heightCard = 385;
          heightCardElements = 220;
        } else if (screenWidth > 800) {
          // Pantallas medianas
          widthCard = MediaQuery.of(context).size.width * 0.6;
          widthImageNotes = MediaQuery.of(context).size.width * 0.22;
          widthTextNotes = MediaQuery.of(context).size.width * 0.33;
          widthBotons = MediaQuery.of(context).size.width * 1;
          heightCard = 385;
          heightCardElements = 220;
        } else {
          // Pantallas pequeñas
          widthCard = MediaQuery.of(context).size.width * 0.9;
          widthImageNotes = MediaQuery.of(context).size.width * 0.33;
          widthTextNotes = MediaQuery.of(context).size.width * 0.5;
          widthBotons = MediaQuery.of(context).size.width * 1;
          heightCard = 340;
          heightCardElements = 170;
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: widthCard,
              color: Colors.amber,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Container(
                                  height: heightCardElements,
                                  color: Color.fromARGB(255, 167, 120, 40),
                                  width: widthTextNotes,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: widthTextNotes,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            note['title'] ?? 'No Title',
                                            style: TextStyle(fontSize: 24),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: widthTextNotes,
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Container(
                                            height: heightCardElements - 80,
                                            child: CustomScrollView(
                                              slivers: [
                                                SliverToBoxAdapter(
                                                  child: Text(
                                                    note['description'] ??
                                                        'No description',
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  height: heightCardElements,
                                  width: widthImageNotes,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 129, 40,
                                        167), // Color de fondo si no hay imagen
                                    image: note['noteImage'] != null &&
                                            note['noteImage']!.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(
                                                note['noteImage']!),
                                            fit: BoxFit.cover,
                                          )
                                        : null, // No aplica imagen si está vacía o es nula
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          height: 100,
                          color: Color.fromARGB(255, 251, 172, 15),
                          width: widthBotons,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Chip(
                                    label: Text(
                                      'Reminder: ${formatRelativeDate(note['reminderDate'])}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "creado : ${note['createdAt'] != null ? formatRelativeDate(note['createdAt']) : 'Unknown'}",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    height: 40,
                                    width: widthImageNotes,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => editarNota(
                                                  noteId: note['id']),
                                            ),
                                          );
                                        },
                                        child: Text("editar")),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    height: 40,
                                    width: widthImageNotes,
                                    child: ElevatedButton(
                                        onPressed: () {}, child: Text("data")),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(
                        note['importantNotes'] ? Icons.star : Icons.star_border,
                        color:
                            note['importantNotes'] ? Colors.amber : Colors.grey,
                        size: 30,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCollapsedContent(
      BuildContext context, Map<String, dynamic> note, bool isNarrow) {
    return Row(
      children: [
        if (note['noteImage'] != null && note['noteImage'].isNotEmpty)
          Image.network(
            note['noteImage'],
            width: isNarrow ? 50 : 70,
            height: isNarrow ? 50 : 70,
            fit: BoxFit.cover,
          )
        else
          Icon(Icons.note, size: isNarrow ? 50 : 70),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            note['title'] ?? 'No Title',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
