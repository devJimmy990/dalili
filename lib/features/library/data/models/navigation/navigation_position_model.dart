class NavigationPositionModel {
  const NavigationPositionModel({required this.x, required this.y});

  /// Position in map coordinates (meters)
  final double x;
  final double y;

  NavigationPositionModel copyWith({double? x, double? y}) =>
      NavigationPositionModel(x: x ?? this.x, y: y ?? this.y);
}
