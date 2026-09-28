import 'dart:math';

import 'package:dalili/features/library/data/models/navigation/node_model.dart';

/// Utility class for distance calculations.
class DistanceCalculator {
  const DistanceCalculator._();

  /// Returns the Euclidean distance between two nodes.
  static double between(NodeModel from, NodeModel to) {
    final dx = to.x - from.x;
    final dy = to.y - from.y;

    return sqrt(dx * dx + dy * dy);
  }

  /// Returns the squared distance.
  /// Useful later with A* if you don't need the actual distance.
  static double squared(NodeModel from, NodeModel to) {
    final dx = to.x - from.x;
    final dy = to.y - from.y;

    return dx * dx + dy * dy;
  }
}
