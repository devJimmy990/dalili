enum NavigationDecision {
  straight,
  slightLeft,
  left,
  slightRight,
  right,
  uTurn,
  arrived,
}

class NavigationDecisionModel {
  const NavigationDecisionModel({
    required this.decision,
    required this.angleDifference,
    required this.message,
  });

  final NavigationDecision decision;

  /// difference between current heading and segment heading
  final double angleDifference;

  final String message;
}
