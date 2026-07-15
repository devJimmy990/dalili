import 'package:dalili/core/services/graph_service.dart';
import 'package:dalili/features/library/data/models/navigation/node_model.dart';

class DijkstraService {
  const DijkstraService(this.graphService);

  final GraphService graphService;

  List<NodeModel> findShortestPath({
    required String startNodeId,
    required String endNodeId,
  }) {
    final distances = <String, double>{};
    final previous = <String, String?>{};
    final unvisited = <String>{};

    // Initialize
    for (final node in graphService.map.nodes) {
      distances[node.id] = double.infinity;
      previous[node.id] = null;
      unvisited.add(node.id);
    }

    distances[startNodeId] = 0;

    while (unvisited.isNotEmpty) {
      // Find node with minimum distance
      String? current;

      for (final nodeId in unvisited) {
        if (current == null || distances[nodeId]! < distances[current]!) {
          current = nodeId;
        }
      }

      if (current == null) {
        break;
      }

      if (current == endNodeId) {
        break;
      }

      unvisited.remove(current);

      final neighbors = graphService.neighborsOf(current);

      for (final neighbor in neighbors) {
        if (!unvisited.contains(neighbor.nodeId)) {
          continue;
        }

        final newDistance = distances[current]! + neighbor.distance;

        if (newDistance < distances[neighbor.nodeId]!) {
          distances[neighbor.nodeId] = newDistance;
          previous[neighbor.nodeId] = current;
        }
      }
    }

    // Build Path
    final path = <NodeModel>[];

    String? current = endNodeId;

    while (current != null) {
      final node = graphService.getNode(current);

      if (node != null) {
        path.insert(0, node);
      }

      current = previous[current];
    }

    return path;
  }
}
