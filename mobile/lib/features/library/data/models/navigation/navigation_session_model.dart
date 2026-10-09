import 'package:dalili/features/library/data/models/navigation/navigation_position_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_progress_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_route.dart';

enum NavigationStatus { idle, navigating, arrived }

class NavigationSessionModel {
  const NavigationSessionModel({
    required this.route,
    required this.status,
    required this.heading,
    required this.progress,
    required this.currentPosition,
  });
  final double heading;
  final NavigationRouteModel route;

  final NavigationProgressModel progress;

  final NavigationStatus status;

  final NavigationPositionModel currentPosition;

  PathSegment get currentSegment =>
      route.segments[progress.currentSegmentIndex];

  bool get hasNextSegment =>
      progress.currentSegmentIndex < route.segments.length - 1;

  NavigationSessionModel copyWith({
    double? heading,
    NavigationStatus? status,
    NavigationProgressModel? progress,
    NavigationPositionModel? currentPosition,
  }) => NavigationSessionModel(
    route: route,
    status: status ?? this.status,
    heading: heading ?? this.heading,
    progress: progress ?? this.progress,
    currentPosition: currentPosition ?? this.currentPosition,
  );
}
