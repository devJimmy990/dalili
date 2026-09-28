class DistanceEstimatorService {
  const DistanceEstimatorService({this.stepLength = 0.75});

  /// Average step length in meters.
  final double stepLength;

  /// Convert steps to walked distance in meters.
  double estimate(int steps) {
    if (steps <= 0) {
      return 0;
    }

    return steps * stepLength;
  }
}
