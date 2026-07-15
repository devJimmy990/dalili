import 'package:dalili/features/library/data/models/navigation/node_model.dart';

class NavigationRouteModel {
  const NavigationRouteModel({
    required this.start,
    required this.end,
    required this.nodes,
    required this.segments,
    required this.totalDistance,
  });

  /// أول Node
  final NodeModel start;

  /// آخر Node
  final NodeModel end;

  /// المسار الكامل
  ///
  /// N1 -> N2 -> N3 -> N5
  final List<NodeModel> nodes;

  /// كل جزء من المسار
  ///
  /// N1->N2
  /// N2->N3
  /// N3->N5
  final List<PathSegment> segments;

  /// إجمالى المسافة
  final double totalDistance;

  bool get isEmpty => nodes.isEmpty;

  bool get isNotEmpty => nodes.isNotEmpty;

  int get nodesCount => nodes.length;

  int get segmentsCount => segments.length;
}

class PathSegment {
  const PathSegment({
    required this.index,
    required this.from,
    required this.to,
    required this.distance,
    required this.angle,
  });

  final int index;

  final NodeModel from;
  final NodeModel to;

  /// بالمتر
  final double distance;

  /// اتجاه الحركة
  final double angle;

  /// فرق الإحداثيات
  double get deltaX => to.x - from.x;

  double get deltaY => to.y - from.y;

  bool get isHorizontal => deltaY.abs() < 0.001;

  bool get isVertical => deltaX.abs() < 0.001;
}
