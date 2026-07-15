import 'package:dalili/features/library/data/models/navigation/navigation_location_update_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_progress_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_session_model.dart';

class NavigationProgressEngine {
  const NavigationProgressEngine();

  NavigationSessionModel calculate({
    required NavigationSessionModel session,
    required NavigationLocationUpdateModel update,
  }) {
    var progress = session.progress.copyWith(
      walkedDistanceInSegment:
          session.progress.walkedDistanceInSegment + update.walkedDistance,
      remainingDistance:
          (session.progress.remainingDistance - update.walkedDistance).clamp(
            0,
            double.infinity,
          ),
    );

    if (progress.isSegmentCompleted(session.currentSegment)) {
      if (session.hasNextSegment) {
        progress = NavigationProgressModel(
          currentSegmentIndex: progress.currentSegmentIndex + 1,
          walkedDistanceInSegment: 0,
          remainingDistance: progress.remainingDistance,
        );

        return session.copyWith(progress: progress);
      }

      return session.copyWith(
        progress: progress,
        status: NavigationStatus.arrived,
      );
    }

    return session.copyWith(progress: progress);
  }
}
