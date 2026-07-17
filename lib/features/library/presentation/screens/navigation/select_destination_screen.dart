import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:dalili/features/library/data/models/navigation/node_model.dart';
import 'package:flutter/material.dart';

/// Lets the user pick where they want to go, from every node marked as a
/// destination in the map — replaces the previously hardcoded end node.
class SelectDestinationScreen extends StatelessWidget {
  const SelectDestinationScreen({super.key, required this.map});

  final LibraryMapModel map;

  @override
  Widget build(BuildContext context) {
    final destinations = map.nodes
        .where((node) => node.type == 'destination')
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Destination')),
      body: destinations.isEmpty
          ? const Center(child: Text('No destinations found in this map.'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: destinations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final node = destinations[index];
                return _DestinationTile(
                  node: node,
                  onTap: () => Navigator.pop(context, node.id),
                );
              },
            ),
    );
  }
}

class _DestinationTile extends StatelessWidget {
  const _DestinationTile({required this.node, required this.onTap});

  final NodeModel node;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: ListTile(
      leading: const CircleAvatar(child: Icon(Icons.place_outlined)),
      title: Text(node.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: node.qr != null ? Text(node.qr!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
