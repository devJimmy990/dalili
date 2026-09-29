import 'dart:math';

import 'package:dalili/features/library/data/models/navigation/edge_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_route.dart';
import 'package:dalili/features/library/data/models/navigation/node_model.dart';

class NavigationRouteBuilder {
  const NavigationRouteBuilder._();

  static NavigationRouteModel build(
    List<NodeModel> nodes, {
    required List<EdgeModel> edges,
  }) {
    if (nodes.isEmpty) {
      throw Exception('Navigation route cannot be built from empty path.');
    }

    final segments = <PathSegment>[];
    double totalDistance = 0;

    for (int i = 0; i < nodes.length - 1; i++) {
      final from = nodes[i];
      final to = nodes[i + 1];

      final distance = _distance(from, to);
      final angle = _angle(from, to);

      totalDistance += distance;

      segments.add(
        PathSegment(
          index: i,
          from: from,
          to: to,
          distance: distance,
          angle: angle,
          width: _matchEdgeWidth(edges: edges, fromId: from.id, toId: to.id),
        ),
      );
    }

    return NavigationRouteModel(
      start: nodes.first,
      end: nodes.last,
      nodes: nodes,
      segments: segments,
      totalDistance: totalDistance,
    );
  }

  /// Finds the edge matching this from/to pair (in either direction, if
  /// the edge is bidirectional) and returns its calibrated width, if any.
  static double? _matchEdgeWidth({
    required List<EdgeModel> edges,
    required String fromId,
    required String toId,
  }) {
    for (final edge in edges) {
      final forward = edge.from == fromId && edge.to == toId;
      final backward =
          edge.bidirectional && edge.from == toId && edge.to == fromId;

      if (forward || backward) {
        return edge.width;
      }
    }

    return null;
  }

  /// المسافة بين نقطتين
  static double _distance(NodeModel a, NodeModel b) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;

    return sqrt(dx * dx + dy * dy);
  }

  /// زاوية الحركة من نقطة إلى أخرى
  static double _angle(NodeModel a, NodeModel b) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;

    return atan2(dy, dx) * 180 / pi;
  }
}
