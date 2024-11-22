// import 'package:flutter/material.dart';

// class notesCardPrueba extends StatelessWidget {
//   const notesCardPrueba({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Material App',
//       home: Scaffold(
//           appBar: AppBar(
//             title: const Text('Material App Bar'),
//           ),
//           body: LayoutBuilder(
//             builder: (context, constraints) {
//               double screenWidth = constraints.maxWidth;

//               double widthCard;
//               double widthImageNotes;
//               double widthTextNotes;
//               double widthBotons;
//               double heightCard;
//               double heightCardElements;

//               // Ajusta los tamaños de los videos dependiendo del ancho de la pantalla
//               if (screenWidth > 1200) {
//                 // Pantallas grandes
//                 widthCard = MediaQuery.of(context).size.width * 0.6;
//                 widthImageNotes = MediaQuery.of(context).size.width * 0.18;
//                 widthTextNotes = MediaQuery.of(context).size.width * 0.38;
//                 widthBotons = MediaQuery.of(context).size.width * 1;
//                 heightCard = 385;
//                 heightCardElements = 220;
//               } else if (screenWidth > 800) {
//                 // Pantallas medianas
//                 widthCard = MediaQuery.of(context).size.width * 0.6;
//                 widthImageNotes = MediaQuery.of(context).size.width * 0.22;
//                 widthTextNotes = MediaQuery.of(context).size.width * 0.33;
//                 widthBotons = MediaQuery.of(context).size.width * 1;
//                 heightCard = 385;
//                 heightCardElements = 220;
//               } else {
//                 // Pantallas pequeñas
//                 widthCard = MediaQuery.of(context).size.width * 0.9;
//                 widthImageNotes = MediaQuery.of(context).size.width * 0.33;
//                 widthTextNotes = MediaQuery.of(context).size.width * 0.5;
//                 widthBotons = MediaQuery.of(context).size.width * 1;
//                 heightCard = 340;
//                 heightCardElements = 170;
//               }

//               return Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Container(
//                     width: widthCard,
//                     color: Colors.amber,
//                     child: Padding(
//                       padding: const EdgeInsets.all(15.0),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Column(
//                                 children: [
//                                   Container(
//                                     height: heightCardElements,
//                                     color: Color.fromARGB(255, 167, 120, 40),
//                                     width: widthTextNotes,
//                                     child: Column(
//                                       children: [
//                                         Container(
//                                           width: widthTextNotes,
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Text(
//                                              task.title,
//                                               style: TextStyle(fontSize: 24),
//                                             ),
//                                           ),
//                                         ),
//                                         Container(
//                                           width: widthTextNotes,
//                                           child: Padding(
//                                             padding: EdgeInsets.all(8.0),
//                                             child: Container(
//                                               height: heightCardElements - 110,
//                                               child: CustomScrollView(
//                                                 slivers: [
//                                                   SliverToBoxAdapter(
//                                                     child: Text(
//                                                                  task.description),
//                                                   )
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   )
//                                 ],
//                               ),
//                               Column(
//                                 children: [
//                                   Container(
//                                     height: heightCardElements,
//                                     color: Color.fromARGB(255, 129, 40, 167),
//                                     width: widthImageNotes,
//                                     child:
//                                     task.noteImage != null && task.noteImage!.isNotEmpty
//                   ? 
//                                      Image.network(
//                         task.noteImage!,
//                         fit: BoxFit.cover,
//                       )

//                      : Center(
//                       child: Icon(
//                         Icons.image_not_supported,
//                         size: 50,
//                         color: Colors.grey,
//                       ),
//                     ),
//                                   )
//                                 ],
//                               ),
//                             ],
//                           ),
//                           SizedBox(
//                             height: 15,
//                           ),
//                           Container(
//                             height: 100,
//                             color: Color.fromARGB(255, 40, 167, 101),
//                             width: widthBotons,
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Container(
//                                   height: 40,
//                                   width: widthImageNotes,
//                                   child: ElevatedButton(
//                                       onPressed: () {}, child: Text("data")),
//                                 ),
//                                 SizedBox(
//                                   height: 5,
//                                 ),
//                                 Container(
//                                   height: 40,
//                                   width: widthImageNotes,
//                                   child: ElevatedButton(
//                                       onPressed: () {}, child: Text("data")),
//                                 ),
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           )),
//     );
//   }
// }
