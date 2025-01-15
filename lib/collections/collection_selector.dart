import 'package:flutter/material.dart';
import 'package:notes_app/collections/collections_provider.dart';
import 'package:provider/provider.dart';

class CollectionSelector extends StatelessWidget {
  final List<String> selectedCollections;
  final Function(List<String>) onCollectionsChanged;

  const CollectionSelector({
    Key? key,
    required this.selectedCollections,
    required this.onCollectionsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionsProvider>(
      builder: (context, collectionsProvider, child) {
        if (collectionsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNewCollectionInput(context, collectionsProvider),
            const SizedBox(height: 8),
            _buildCollectionChips(collectionsProvider),
          ],
        );
      },
    );
  }

  Widget _buildNewCollectionInput(
      BuildContext context, CollectionsProvider provider) {
    final TextEditingController controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Nueva colección',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final color =
                    '#${Colors.primaries[provider.collections.length % Colors.primaries.length].value.toRadixString(16).substring(2)}';
                provider.createCollection(name, color);
                controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionChips(CollectionsProvider provider) {
    return Wrap(
      spacing: 8.0,
      children: provider.collections.map((collection) {
        final isSelected = selectedCollections.contains(collection.id);
        return FilterChip(
          label: Text(collection.name),
          selected: isSelected,
          onSelected: (selected) {
            final newSelections = List<String>.from(selectedCollections);
            if (selected) {
              newSelections.add(collection.id);
            } else {
              newSelections.remove(collection.id);
            }
            onCollectionsChanged(newSelections);
          },
          backgroundColor:
              Color(int.parse(collection.color.replaceFirst('#', '0xff'))),
        );
      }).toList(),
    );
  }
}
