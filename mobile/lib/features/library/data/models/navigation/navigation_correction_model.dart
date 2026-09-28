class NavigationCorrectionModel {
  const NavigationCorrectionModel({
    required this.isOnRoute,
    this.nearestNodeId,
  });

  /// User is still walking on the expected route.
  final bool isOnRoute;

  /// Used later for rerouting.
  final String? nearestNodeId;
}
