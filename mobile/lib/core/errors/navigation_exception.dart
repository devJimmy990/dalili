/// Why a trip could not be started.
///
/// The reason is an enum rather than a message so the cubit can localize it;
/// a raw `Exception.toString()` used to reach the screen verbatim.
enum NavigationFailureReason {
  /// The scanned starting point is the destination itself — someone asked
  /// to be taken to the section they are already standing in.
  alreadyAtDestination,

  /// The graph has no walking path between the two nodes. Normally this
  /// means the map is missing an edge.
  noRouteFound,
}

class NavigationException implements Exception {
  const NavigationException(this.reason);

  final NavigationFailureReason reason;

  @override
  String toString() => 'NavigationException: ${reason.name}';
}
