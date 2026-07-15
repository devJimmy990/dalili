import 'package:dalili/features/library/data/models/navigation/navigation_route.dart';

class NavigationProgressModel {
  const NavigationProgressModel({
    required this.currentSegmentIndex,
    required this.walkedDistanceInSegment,
    required this.remainingDistance,
  });

  final int currentSegmentIndex;

  /// كام متر مشى داخل الـ Segment الحالى
  final double walkedDistanceInSegment;

  /// المسافة المتبقية للوجهة
  final double remainingDistance;

  NavigationProgressModel copyWith({
    int? currentSegmentIndex,
    double? walkedDistanceInSegment,
    double? remainingDistance,
  }) => NavigationProgressModel(
    currentSegmentIndex: currentSegmentIndex ?? this.currentSegmentIndex,
    walkedDistanceInSegment:
        walkedDistanceInSegment ?? this.walkedDistanceInSegment,
    remainingDistance: remainingDistance ?? this.remainingDistance,
  );

  double progress(PathSegment segment) {
    if (segment.distance == 0) {
      return 1;
    }

    return (walkedDistanceInSegment / segment.distance).clamp(0.0, 1.0);
  }

  bool isSegmentCompleted(PathSegment segment) =>
      walkedDistanceInSegment >= segment.distance;
}
