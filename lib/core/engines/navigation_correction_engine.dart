import 'package:dalili/core/engines/geometry_engine.dart';
import 'package:dalili/features/library/data/models/navigation/geometry/line_segment_model.dart';
import 'package:dalili/features/library/data/models/navigation/geometry/point_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_correction_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_position_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_session_model.dart';

class NavigationCorrectionEngine {
  const NavigationCorrectionEngine({this.geometry = const GeometryEngine()});

  final GeometryEngine geometry;

  static const double _maxAllowedDistance = 1.5;

  NavigationCorrectionModel calculate({
    required NavigationSessionModel session,
    required NavigationPositionModel position,
  }) {
    final segment = session.currentSegment;

    final distance = geometry.distanceToSegment(
      point: PointModel(x: position.x, y: position.y),
      segment: LineSegmentModel(
        start: PointModel(x: segment.from.x, y: segment.from.y),
        end: PointModel(x: segment.to.x, y: segment.to.y),
      ),
    );

    return NavigationCorrectionModel(
      isOnRoute: distance <= _maxAllowedDistance,
    );
  }
}
