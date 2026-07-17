import 'package:dalili/core/engines/geometry_engine.dart';
import 'package:dalili/features/library/data/models/navigation/geometry/line_segment_model.dart';
import 'package:dalili/features/library/data/models/navigation/geometry/point_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_position_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_session_model.dart';

class NavigationProjectionEngine {
  const NavigationProjectionEngine({this.geometry = const GeometryEngine()});

  final GeometryEngine geometry;

  NavigationPositionModel calculate({
    required NavigationSessionModel session,
    required NavigationPositionModel position,
  }) {
    final segment = session.currentSegment;

    final projected = geometry.projectPointOnSegment(
      point: PointModel(x: position.x, y: position.y),
      segment: LineSegmentModel(
        start: PointModel(x: segment.from.x, y: segment.from.y),
        end: PointModel(x: segment.to.x, y: segment.to.y),
      ),
    );

    return NavigationPositionModel(x: projected.x, y: projected.y);
  }
}
