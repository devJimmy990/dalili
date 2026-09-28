import 'package:dalili/core/engines/geometry_engine.dart';
import 'package:dalili/core/services/graph_service.dart';
import 'package:dalili/features/library/data/models/navigation/geometry/line_segment_model.dart';
import 'package:dalili/features/library/data/models/navigation/geometry/point_model.dart';
import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_correction_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_position_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_session_model.dart';
import 'package:dalili/features/library/data/models/navigation/node_model.dart';

class NavigationCorrectionEngine {
  const NavigationCorrectionEngine({this.geometry = const GeometryEngine()});

  final GeometryEngine geometry;

  /// Fallback on-route tolerance (meters either side of the segment's
  /// centerline) for edges without a calibrated width.
  static const double _defaultTolerance = 1.5;

  NavigationCorrectionModel calculate({
    required NavigationSessionModel session,
    required NavigationPositionModel position,
    required LibraryMapModel map,
  }) {
    final segment = session.currentSegment;

    final distance = geometry.distanceToSegment(
      point: PointModel(x: position.x, y: position.y),
      segment: LineSegmentModel(
        start: PointModel(x: segment.from.x, y: segment.from.y),
        end: PointModel(x: segment.to.x, y: segment.to.y),
      ),
    );

    final segmentWidth = segment.width;
    final tolerance = segmentWidth != null
        ? segmentWidth / 2
        : _defaultTolerance;

    final isOnRoute = distance <= tolerance;

    // Off-route: locate the closest node that's actually part of the
    // routable graph (has at least one edge) so the cubit can recalculate
    // a shortest path from there back to the destination, instead of
    // freezing guidance until the user manually rescans a QR code.
    final nearestNodeId = isOnRoute
        ? null
        : _nearestRoutableNode(map: map, position: position)?.id;

    return NavigationCorrectionModel(
      isOnRoute: isOnRoute,
      nearestNodeId: nearestNodeId,
    );
  }

  NodeModel? _nearestRoutableNode({
    required LibraryMapModel map,
    required NavigationPositionModel position,
  }) {
    final graph = GraphService(map);

    NodeModel? nearest;
    var bestDistanceSquared = double.infinity;

    for (final node in map.nodes) {
      if (graph.neighborsOf(node.id).isEmpty) {
        continue;
      }

      final dx = node.x - position.x;
      final dy = node.y - position.y;
      final distanceSquared = dx * dx + dy * dy;

      if (distanceSquared < bestDistanceSquared) {
        bestDistanceSquared = distanceSquared;
        nearest = node;
      }
    }

    return nearest;
  }
}
