import 'package:auto_size_text_plus/auto_size_text_plus.dart';
import 'package:bounce/bounce.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notes_app/componentes/AnimatedScaleWrapper.dart';
import 'package:notes_app/notes/EditNotePage.dart';
import 'package:provider/provider.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class modelCard extends StatelessWidget {
  final Note note;
  final bool isExpanded;
  final VoidCallback onTap;

  const modelCard({
    super.key,
    required this.note,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow =
            constraints.maxWidth < 400; // Cambia según sea necesario.
        return GestureDetector(
          onTap: onTap,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isExpanded
                  ? _buildExpandedContentNote(context, isNarrow)
                  : _buildCollapsedContent(context, isNarrow),
            ),
          ),
        );
      },
    );
  }

  // Contenido cuando la tarjeta está expandida
  Widget _buildExpandedContentNote(BuildContext context, bool isNarrow) {
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
        if (difference.inMinutes > 1) {
          return "En ${difference.inMinutes} minutos";
        }
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color(int.parse(note.color.replaceFirst('#', '0xff'))),
              ),
              width: widthCard,
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
                                  //  color:Colors.blue,
                                  width: widthTextNotes,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: widthTextNotes,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 8.0),
                                          child: AutoSizeText(
                                            note.title,
                                            style: TextStyle(
                                              color: ColorUtils.getTextColor(
                                                  note.color),
                                              fontSize:
                                                  27, // Tamaño máximo de fuente
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins",
                                            ),
                                            maxLines:
                                                2, // Número máximo de líneas permitidas
                                            overflow: TextOverflow.ellipsis,
                                            minFontSize:
                                                17, // Tamaño mínimo de fuente
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: widthTextNotes,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox(
                                            height: heightCardElements - 110,
                                            child: Scrollbar(
                                              child: CustomScrollView(
                                                slivers: [
                                                  SliverToBoxAdapter(
                                                    child: AutoSizeText(
                                                      note.description,
                                                      style: TextStyle(
                                                        color: ColorUtils
                                                            .getTextColor(
                                                                note.color),
                                                        fontSize:
                                                            19, // Tamaño máximo de fuente
                                                        fontWeight:
                                                            FontWeight.w200,
                                                        fontFamily: "Inter",
                                                      ),

                                                      minFontSize:
                                                          15, // Tamaño mínimo de fuente
                                                    ),
                                                  )
                                                ],
                                              ),
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
                                Bounce(
                                  cursor: SystemMouseCursors.click,
                                  duration: const Duration(milliseconds: 120),
                                  // Agregar GestureDetector para abrir el modal al hacer clic en la imagen
                                  onTap: () {
                                    Future.delayed(
                                        const Duration(milliseconds: 100), () {
                                      if (note.noteImage == null ||
                                          note.noteImage!.isEmpty) {
                                        // Mostrar Snackbar si no hay imagen
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'No hay imagen disponible')),
                                        );
                                      } else {
                                        WoltModalSheet.show<void>(
                                          context: context,
                                          pageListBuilder:
                                              (BuildContext context) {
                                            return [
                                              WoltModalSheetPage(
                                                isTopBarLayerAlwaysVisible:
                                                    true,
                                                backgroundColor: Theme.of(
                                                        context)
                                                    .scaffoldBackgroundColor,
                                                topBarTitle: Text(
                                                  'Imagen',
                                                  style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: InteractiveViewer(
                                                    child: Image.network(
                                                        note.noteImage!),
                                                  ),
                                                ),
                                              ),
                                            ];
                                          },
                                          modalTypeBuilder:
                                              (BuildContext context) {
                                            return WoltModalType.dialog();
                                          },
                                          barrierDismissible: true,
                                          useRootNavigator: true,
                                          useSafeArea: false,
                                        );
                                      }
                                    });
                                  },
                                  child: AnimatedScaleWrapper(
                                    child: Container(
                                      height: heightCardElements,
                                      width: widthImageNotes,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(17),
                                        color: const Color.fromARGB(
                                            255,
                                            129,
                                            40,
                                            167), // Color de fondo si no hay imagen
                                        image: note.noteImage != null &&
                                                note.noteImage!.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                    note.noteImage!),
                                                fit: BoxFit.cover,
                                              )
                                            : null, // No aplica imagen si está vacía o es nula
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          height: 100,
                          width: widthBotons,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color:
                                            Color.fromARGB(255, 31, 63, 223)),
                                    height: 40,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  color: Color.fromARGB(
                                                      255, 89, 113, 235)),
                                              height: 40,
                                              width: 40,
                                              child: Center(
                                                child: FaIcon(
                                                    FontAwesomeIcons.clock,
                                                    color: Colors.white,
                                                    size: 18),
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5.0, right: 10.0),
                                          child: Text(
                                            "${formatRelativeDate(note.reminderDate)}",
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    height: 40,
                                    child: Center(
                                      child: Text(
                                        "creado : ${note.createdAt != null ? formatRelativeDate(note.createdAt) : 'Unknown'}",
                                        style: TextStyle(
                                          color: ColorUtils.getTextColor(
                                              note.color),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: widthImageNotes,
                                    child: Bounce(
                                      cursor: SystemMouseCursors.click,
                                      duration:
                                          const Duration(milliseconds: 120),
                                      onTap: () {
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
                                          WoltModalSheet.show<void>(
                                            context: context,
                                            pageListBuilder:
                                                (BuildContext context) {
                                              return [
                                                WoltModalSheetPage(
                                                  isTopBarLayerAlwaysVisible:
                                                      true,
                                                  backgroundColor: Theme.of(
                                                          context)
                                                      .scaffoldBackgroundColor,
                                                  topBarTitle: Text(
                                                    'Editar Nota',
                                                    style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.8,
                                                    child: EditNotePage(
                                                      noteId: note.noteId,
                                                      noteData: {
                                                        'title': note.title,
                                                        'description':
                                                            note.description,
                                                        'noteImage':
                                                            note.noteImage,
                                                        'reminderDate':
                                                            note.reminderDate,
                                                        'importantNotes':
                                                            note.importantNotes,
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ];
                                            },
                                            modalTypeBuilder:
                                                (BuildContext context) {
                                              return WoltModalType.dialog();
                                            },
                                            barrierDismissible: true,
                                            useRootNavigator: true,
                                            useSafeArea: false,
                                          );
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        height: 40,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15),
                                              child: Text(
                                                "editar",
                                                style: TextStyle(
                                                    fontFamily: "Inter",
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15),
                                              child: FaIcon(
                                                FontAwesomeIcons.edit,
                                                size: 20,
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                    width: widthImageNotes,
                                    child: Bounce(
                                      cursor: SystemMouseCursors.click,
                                      duration:
                                          const Duration(milliseconds: 120),
                                      onTap: () {
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
                                          _toggleDeleteStatus(context);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 247, 96, 85),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        height: 40,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Text(
                                                "eliminar",
                                                style: TextStyle(
                                                    fontFamily: "Inter",
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: FaIcon(
                                                FontAwesomeIcons.trash,
                                                size: 20,
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
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
                        note.importantNotes ? Icons.star : Icons.star_border,
                        color: note.importantNotes ? Colors.amber : Colors.grey,
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

  // Contenido colapsado
  Widget _buildCollapsedContent(BuildContext context, bool isNarrow) {
    return LayoutBuilder(builder: (context, constraints) {
      double screenWidth = constraints.maxWidth;

      double widthCard;

      // Ajusta los tamaños de los videos dependiendo del ancho de la pantalla
      if (screenWidth > 1200) {
        // Pantallas grandes
        widthCard = MediaQuery.of(context).size.width * 0.6;
      } else if (screenWidth > 800) {
        // Pantallas medianas
        widthCard = MediaQuery.of(context).size.width * 0.6;
      } else {
        // Pantallas pequeñas
        widthCard = MediaQuery.of(context).size.width * 0.9;
      }

      return Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Color(int.parse(note.color.replaceFirst('#', '0xff'))),
          ),
          width: widthCard,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    note.noteImage != null && note.noteImage!.isNotEmpty
                        ? Image.network(
                            note.noteImage!,
                            width: isNarrow ? 40 : 50,
                            height: isNarrow ? 40 : 50,
                          )
                        : Icon(Icons.note, size: isNarrow ? 40 : 50),
                    SizedBox(width: isNarrow ? 5 : 10),
                    SizedBox(
                      width: 200,
                      child: Text(
                        note.title,
                        style: TextStyle(
                          color: ColorUtils.getTextColor(note.color),
                          fontSize: isNarrow ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      width: 120,
                      child: Bounce(
                        cursor: SystemMouseCursors.click,
                        duration: const Duration(milliseconds: 120),
                        onTap: () {
                          Future.delayed(const Duration(milliseconds: 100), () {
                            WoltModalSheet.show<void>(
                              context: context,
                              pageListBuilder: (BuildContext context) {
                                return [
                                  WoltModalSheetPage(
                                    isTopBarLayerAlwaysVisible: true,
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    topBarTitle: Text(
                                      'Crear Tarea',
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.8,
                                      child: EditNotePage(
                                        noteId: note.noteId,
                                        noteData: {
                                          'title': note.title,
                                          'description': note.description,
                                          'noteImage': note.noteImage,
                                          'reminderDate': note.reminderDate,
                                          'importantNotes': note.importantNotes,
                                        },
                                      ),
                                    ),
                                  ),
                                ];
                              },
                              modalTypeBuilder: (BuildContext context) {
                                return WoltModalType.dialog();
                              },
                              barrierDismissible: true,
                              useRootNavigator: true,
                              useSafeArea: false,
                            );
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          height: 40,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "editar",
                                  style: TextStyle(
                                      fontFamily: "Inter",
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: FaIcon(
                                  FontAwesomeIcons.edit,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isNarrow ? 4 : 8),
                    SizedBox(
                      width: 120,
                      child: Bounce(
                        cursor: SystemMouseCursors.click,
                        duration: const Duration(milliseconds: 120),
                        onTap: () {
                          Future.delayed(const Duration(milliseconds: 100), () {
                            _toggleDeleteStatus(context);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 247, 96, 85),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          height: 40,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  "eliminar",
                                  style: TextStyle(
                                      fontFamily: "Inter",
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: FaIcon(
                                  FontAwesomeIcons.trash,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _toggleDeleteStatus(BuildContext context) async {
    try {
      final noteDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(note.uid)
          .collection('notes')
          .doc(note.noteId);

      // Cambiar el campo isDeleted a true en Firestore
      await noteDocRef.update({'isDeleted': true});

      // Intenta actualizar el estado si está dentro de NoteListScreen
      final noteListState =
          context.findAncestorStateOfType<_NoteListScreenState>();
      if (noteListState != null) {
        noteListState.setState(() {
          noteListState.widget.notes
              .removeWhere((n) => n.noteId == note.noteId);
          noteListState.expandedNoteIndex = noteListState.expandedNoteIndex > 0
              ? noteListState.expandedNoteIndex - 1
              : 0;
        });
      }

      // Si no está dentro de NoteListScreen, actualiza el Provider
      final notesProvider = Provider.of<List<Note>>(context, listen: false);
      if (notesProvider is List<Note>) {
        final updatedNotes = List<Note>.from(notesProvider)
          ..removeWhere((n) => n.noteId == note.noteId);
        // Actualiza el provider (necesitarás implementar esto en tu NotesProvider)
      }
    } catch (e) {
      print('Error al actualizar la nota: $e');
    }
  }
}

// Modelo de datos de nota actualizado
class Note {
  final String noteId;
  final String uid;
  final String title;
  final String description;
  final bool importantNotes;
  final String? noteImage;
  final Timestamp? reminderDate;
  final Timestamp? createdAt;
  final bool isDeleted;
  final String color;

  Note({
    required this.noteId,
    required this.uid,
    required this.title,
    required this.description,
    required this.importantNotes,
    this.noteImage,
    this.reminderDate,
    this.createdAt,
    this.isDeleted = false,
    required this.color,
  });
}

// Pantalla de lista de notas
class NoteListScreen extends StatefulWidget {
  final List<Note> notes;

  const NoteListScreen({super.key, required this.notes});

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  int expandedNoteIndex = 0; // Inicializar con la primera nota expandida

  void moveToTop(int index) {
    setState(() {
      final note = widget.notes.removeAt(index);
      widget.notes.insert(0, note);
      expandedNoteIndex = 0; // Actualizar índice expandido al nuevo tope
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.notes.length,
      itemBuilder: (context, index) {
        final note = widget.notes[index];
        return SizedBox(
          width: 500,
          child: Center(
            child: modelCard(
              note: note,
              isExpanded: expandedNoteIndex == index,
              onTap: () {
                if (expandedNoteIndex == index) {
                  setState(() {
                    expandedNoteIndex = -1; // Cerrar si ya está expandido
                  });
                } else {
                  moveToTop(index); // Mover la tarjeta seleccionada al inicio
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class ColorUtils {
  static Color getTextColor(String colorHex) {
    final color = Color(int.parse(colorHex.replaceFirst('#', '0xff')));
    final brightness =
        (color.red * 299 + color.green * 587 + color.blue * 114) / 1000;
    return brightness > 128 ? Colors.black : Colors.white;
  }
}
