class NavigationPositionModel {
  const NavigationPositionModel({
    required this.x,
    required this.y,
    required this.progress,
  });

  /// Position in map coordinates (meters)
  final double x;
  final double y;

  /// Segment progress (0 -> 1)
  final double progress;

  NavigationPositionModel copyWith({double? x, double? y, double? progress}) =>
      NavigationPositionModel(
        x: x ?? this.x,
        y: y ?? this.y,
        progress: progress ?? this.progress,
      );
}
