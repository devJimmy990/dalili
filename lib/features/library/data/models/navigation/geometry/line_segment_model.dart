import 'package:dalili/features/library/data/models/navigation/geometry/point_model.dart';

class LineSegmentModel {
  const LineSegmentModel({required this.start, required this.end});

  final PointModel start;
  final PointModel end;
}
