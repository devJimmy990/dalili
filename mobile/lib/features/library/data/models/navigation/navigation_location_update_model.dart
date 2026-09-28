class NavigationLocationUpdateModel {
  const NavigationLocationUpdateModel({
    required this.heading,
    required this.walkedDistance,
    this.currentNodeId,
    this.timestamp,
  });

  final double heading;

  final double walkedDistance;

  /// QR Result
  final String? currentNodeId;

  final DateTime? timestamp;
}
