import 'package:dalili/core/utils/distance_calculator.dart';
import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:dalili/features/library/data/models/navigation/neighbor_model.dart';
import 'package:dalili/features/library/data/models/navigation/node_model.dart';

class GraphService {
  GraphService(this.map);

  final LibraryMapModel map;

  /// Graph
  ///
  /// N1 -> [Neighbor(N2,5)]
  /// N2 -> [Neighbor(N1,5), Neighbor(N3,4)]
  late final Map<String, List<NeighborModel>> graph = _buildGraph();

  Map<String, List<NeighborModel>> _buildGraph() {
    final result = <String, List<NeighborModel>>{};

    /// initialize all nodes
    for (final node in map.nodes) {
      result[node.id] = [];
    }

    /// build graph from edges
    for (final edge in map.edges) {
      final fromNode = _findNode(edge.from);
      final toNode = _findNode(edge.to);

      if (fromNode == null || toNode == null) {
        continue;
      }

      final distance = DistanceCalculator.between(fromNode, toNode);

      result[fromNode.id]!.add(
        NeighborModel(nodeId: toNode.id, distance: distance),
      );
      result[toNode.id]!.add(
        NeighborModel(nodeId: fromNode.id, distance: distance),
      );
    }

    return result;
  }

  NodeModel? _findNode(String id) {
    try {
      return map.nodes.firstWhere((node) => node.id == id);
    } catch (_) {
      return null;
    }
  }

  List<NeighborModel> neighborsOf(String nodeId) => graph[nodeId] ?? [];

  NodeModel? getNode(String id) => _findNode(id);
}
