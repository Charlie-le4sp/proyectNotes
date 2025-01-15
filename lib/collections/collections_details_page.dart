import 'package:flutter/material.dart';
import 'package:notes_app/collections/collection_model.dart';
import 'package:notes_app/collections/collections_provider.dart';
import 'package:provider/provider.dart';
import 'package:notes_app/notes/modelCardNote.dart';
import 'package:notes_app/tasks/modelCardTask.dart';

class CollectionDetailsPage extends StatefulWidget {
  final Collection collection;

  const CollectionDetailsPage({
    Key? key,
    required this.collection,
  }) : super(key: key);

  @override
  State<CollectionDetailsPage> createState() => _CollectionDetailsPageState();
}

class _CollectionDetailsPageState extends State<CollectionDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<CollectionsProvider>()
          .selectCollection(widget.collection.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.collection.name),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Notas'),
                Tab(text: 'Tareas'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildNotesList(provider),
              _buildTasksList(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotesList(CollectionsProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.collectionNotes.isEmpty) {
      return const Center(child: Text('No hay notas en esta colección'));
    }

    return ListView.builder(
      itemCount: provider.collectionNotes.length,
      itemBuilder: (context, index) {
        final note = provider.collectionNotes[index];
        // Aquí puedes usar tu widget modelCard existente
        return modelCard(
          note: note,
          isExpanded: false,
          onTap: () {
            // Implementar la navegación a la edición de la nota
          },
        );
      },
    );
  }

  Widget _buildTasksList(CollectionsProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.collectionTasks.isEmpty) {
      return const Center(child: Text('No hay tareas en esta colección'));
    }

    return ListView.builder(
      itemCount: provider.collectionTasks.length,
      itemBuilder: (context, index) {
        final task = provider.collectionTasks[index];
        // Aquí puedes usar tu widget TaskCard existente
        return TaskCard(
          task: task,
          isExpanded: false,
          onTap: () {
            // Implementar la navegación a la edición de la tarea
          },
        );
      },
    );
  }
}
