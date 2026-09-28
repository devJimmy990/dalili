import 'package:dalili/core/services/dijkstra_service.dart';
import 'package:dalili/core/services/graph_service.dart';
import 'package:dalili/core/services/navigation_instruction_service.dart';
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
    final graph = GraphService(map);

    final path = DijkstraService(
      graph,
    ).findShortestPath(startNodeId: startNodeId, endNodeId: endNodeId);

    final route = NavigationRouteBuilder.build(path, edges: map.edges);

    final instructions = NavigationInstructionService.build(route);

    return NavigationSessionModel(
      heading: heading,
      route: route,
      instructions: instructions,
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
