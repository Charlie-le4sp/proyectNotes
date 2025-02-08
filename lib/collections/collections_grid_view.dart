import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:notes_app/collections/collections_details_page.dart';
import 'package:notes_app/collections/collections_provider.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

class CollectionsGridView extends StatefulWidget {
  const CollectionsGridView({super.key});

  @override
  State<CollectionsGridView> createState() => _CollectionsGridViewState();
}

class _CollectionsGridViewState extends State<CollectionsGridView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectionsProvider>().loadCollections();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.collections.isEmpty) {
          return Center(
            child: FadeIn(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay colecciones',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: provider.collections.length,
          itemBuilder: (context, index) {
            final collection = provider.collections[index];
            return FadeInUp(
              delay: Duration(milliseconds: index * 100),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CollectionDetailsPage(
                        collection: collection,
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(int.parse(
                            collection.color.replaceFirst('#', '0xff'))),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder,
                            size: 48,
                            color: ThemeData.estimateBrightnessForColor(
                                      Color(int.parse(collection.color
                                          .replaceFirst('#', '0xff'))),
                                    ) ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            collection.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ThemeData.estimateBrightnessForColor(
                                        Color(int.parse(collection.color
                                            .replaceFirst('#', '0xff'))),
                                      ) ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: ListTile(
                              leading: const Icon(Icons.color_lens),
                              title: const Text('Cambiar color'),
                              onTap: () {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Seleccionar color'),
                                    content: SingleChildScrollView(
                                      child: BlockPicker(
                                        pickerColor: Color(int.parse(collection
                                            .color
                                            .replaceFirst('#', '0xff'))),
                                        onColorChanged: (color) {
                                          provider.updateCollectionColor(
                                            collection.id,
                                            '#${color.value.toRadixString(16).substring(2)}',
                                          );
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading: const Icon(Icons.edit),
                              title: const Text('Cambiar nombre'),
                              onTap: () {
                                Navigator.pop(context);
                                final controller = TextEditingController(
                                    text: collection.name);
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Cambiar nombre'),
                                    content: TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(
                                        labelText: 'Nuevo nombre',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (controller.text
                                              .trim()
                                              .isNotEmpty) {
                                            provider.updateCollectionName(
                                              collection.id,
                                              controller.text.trim(),
                                            );
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: const Text('Guardar'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading:
                                  const Icon(Icons.delete, color: Colors.red),
                              title: const Text('Eliminar',
                                  style: TextStyle(color: Colors.red)),
                              onTap: () {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmar eliminación'),
                                    content: Text(
                                        '¿Estás seguro de eliminar "${collection.name}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          provider
                                              .deleteCollection(collection.id);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Eliminar',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
