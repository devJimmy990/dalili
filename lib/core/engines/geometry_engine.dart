import 'dart:math';

import 'package:dalili/features/library/data/models/navigation/geometry/line_segment_model.dart';
import 'package:dalili/features/library/data/models/navigation/geometry/point_model.dart';

class GeometryEngine {
  const GeometryEngine();

  //==========================================================
  // Distance between two points
  //==========================================================

  double distance({required PointModel a, required PointModel b}) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;

    return sqrt(dx * dx + dy * dy);
  }

  //==========================================================
  // Closest point on segment
  //==========================================================

  PointModel projectPointOnSegment({
    required PointModel point,
    required LineSegmentModel segment,
  }) {
    final ax = segment.start.x;
    final ay = segment.start.y;

    final bx = segment.end.x;
    final by = segment.end.y;

    final abx = bx - ax;
    final aby = by - ay;

    final apx = point.x - ax;
    final apy = point.y - ay;

    final abSquared = (abx * abx) + (aby * aby);

    if (abSquared == 0) {
      return segment.start;
    }

    var t = ((apx * abx) + (apy * aby)) / abSquared;

    t = t.clamp(0.0, 1.0);

    return PointModel(x: ax + (abx * t), y: ay + (aby * t));
  }

  //==========================================================
  // Distance from point to segment
  //==========================================================

  double distanceToSegment({
    required PointModel point,
    required LineSegmentModel segment,
  }) {
    final projected = projectPointOnSegment(point: point, segment: segment);

    return distance(a: point, b: projected);
  }
}
