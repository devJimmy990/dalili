import 'package:dalili/core/errors/navigation_exception.dart';
import 'package:dalili/core/services/dijkstra_service.dart';
import 'package:dalili/features/library/data/models/navigation/node_model.dart';
import 'package:dalili/core/services/graph_service.dart';
import 'package:dalili/core/services/navigation_route_builder.dart';
import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_position_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_progress_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_session_model.dart';

class NavigationSessionBuilder {
  const NavigationSessionBuilder();

  NavigationSessionModel build({
    required LibraryMapModel map,
    required String startNodeId,
    required String endNodeId,
    double heading = 0,
  }) {
    final graph = GraphService.of(map);

    final path = DijkstraService(
      graph,
    ).findShortestPath(startNodeId: startNodeId, endNodeId: endNodeId);

    // Dijkstra returns the destination alone when it is also the start, and
    // nothing at all when the two are not connected. Both would otherwise
    // surface much later as a RangeError on the first segment read, so they
    // are named here instead.
    //
    // "Already there" is a question of position, not of id: two sections can
    // share one spot (Basic Sciences stands with Mechanical Engineering), so
    // someone who scans the QR there and asks for a book in the twin section
    // is standing on their destination. Comparing ids alone would hand them
    // a route out to the corridor junction and back to where they started.
    if (startNodeId == endNodeId ||
        path.length == 1 ||
        _samePlace(graph.getNode(startNodeId), graph.getNode(endNodeId))) {
      throw const NavigationException(
        NavigationFailureReason.alreadyAtDestination,
      );
    }

    if (path.length < 2) {
      throw const NavigationException(NavigationFailureReason.noRouteFound);
    }

    final route = NavigationRouteBuilder.build(path, edges: map.edges);

    return NavigationSessionModel(
      heading: heading,
      route: route,
      status: NavigationStatus.navigating,
      progress: NavigationProgressModel(
        currentSegmentIndex: 0,
        walkedDistanceInSegment: 0,
        remainingDistance: route.totalDistance,
      ),
      currentPosition: NavigationPositionModel(
        x: route.start.x,
        y: route.start.y,
      ),
    );
  }
}

/// Whether two nodes describe the same tile of floor. The tolerance is a
/// centimetre — these coordinates are surveyed by hand, so exact equality
/// would be brittle.
bool _samePlace(NodeModel? a, NodeModel? b) {
  if (a == null || b == null) return false;
  return (a.x - b.x).abs() < 0.01 && (a.y - b.y).abs() < 0.01;
}
