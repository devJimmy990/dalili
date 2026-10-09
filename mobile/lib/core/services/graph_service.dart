import 'package:dalili/core/utils/distance_calculator.dart';
import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:dalili/features/library/data/models/navigation/neighbor_model.dart';
import 'package:dalili/features/library/data/models/navigation/node_model.dart';

class GraphService {
  GraphService(this.map);

  /// One graph per map object, reused for the life of that map.
  ///
  /// Building the adjacency list walks every node and edge. Route
  /// correction asks for the nearest routable node on *every* sensor
  /// update, and used to construct a throwaway GraphService each time —
  /// rebuilding the whole graph several times a second while the camera
  /// was running. An Expando keys the cache on the map instance itself, so
  /// it is collected with the map and never goes stale.
  static final Expando<GraphService> _cache = Expando<GraphService>();

  /// The graph for [map], built on first use and reused afterwards.
  static GraphService of(LibraryMapModel map) =>
      _cache[map] ??= GraphService(map);

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
