import 'package:dalili/features/library/data/models/navigation/navigation_location_update_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_position_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_progress_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_route.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_session_model.dart';

class NavigationProgressEngine {
  const NavigationProgressEngine();

  NavigationSessionModel calculate({
    required NavigationSessionModel session,
    required NavigationLocationUpdateModel update,
    required NavigationPositionModel estimatedPosition,
  }) {
    final segment = session.currentSegment;

    final walkedDistanceInSegment =
        session.progress.walkedDistanceInSegment + update.walkedDistance;

    // A destination/intersection with a calibrated footprint counts as
    // "reached" the moment the raw estimated position enters it,
    // regardless of accumulated walked distance — this is what lets
    // arrival trigger correctly even when dead-reckoning distance is a
    // bit off. Nodes without a footprint fall back to the walked-distance
    // threshold.
    final reachedFootprint = segment.to.containsPoint(
      estimatedPosition.x,
      estimatedPosition.y,
    );

    final segmentCompleted =
        reachedFootprint || walkedDistanceInSegment >= segment.distance;

    if (segmentCompleted) {
      if (session.hasNextSegment) {
        final nextIndex = session.progress.currentSegmentIndex + 1;

        return session.copyWith(
          progress: NavigationProgressModel(
            currentSegmentIndex: nextIndex,
            walkedDistanceInSegment: 0,
            remainingDistance: _remainingDistance(
              route: session.route,
              currentSegmentIndex: nextIndex,
              walkedInSegment: 0,
            ),
          ),
        );
      }

      return session.copyWith(
        progress: session.progress.copyWith(
          walkedDistanceInSegment: walkedDistanceInSegment,
          remainingDistance: 0,
        ),
        status: NavigationStatus.arrived,
      );
    }

    return session.copyWith(
      progress: session.progress.copyWith(
        walkedDistanceInSegment: walkedDistanceInSegment,
        remainingDistance: _remainingDistance(
          route: session.route,
          currentSegmentIndex: session.progress.currentSegmentIndex,
          walkedInSegment: walkedDistanceInSegment,
        ),
      ),
    );
  }

  /// Recomputed from route structure every tick (sum of what's left in the
  /// current segment plus the full length of every segment after it) —
  /// not a running counter that's decremented in place, which would drift
  /// out of sync with [currentSegmentIndex] jumps (footprint-triggered
  /// completion, relocation, etc).
  double _remainingDistance({
    required NavigationRouteModel route,
    required int currentSegmentIndex,
    required double walkedInSegment,
  }) {
    var remaining = (route.segments[currentSegmentIndex].distance -
            walkedInSegment)
        .clamp(0.0, double.infinity);

    for (var i = currentSegmentIndex + 1; i < route.segments.length; i++) {
      remaining += route.segments[i].distance;
    }

    return remaining;
  }
}
