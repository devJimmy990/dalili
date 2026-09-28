import 'package:dalili/core/engines/navigation_correction_engine.dart';
import 'package:dalili/core/engines/navigation_decision_engine.dart';
import 'package:dalili/core/engines/navigation_position_engine.dart';
import 'package:dalili/core/engines/navigation_progress_engine.dart';
import 'package:dalili/core/engines/navigation_projection_engine.dart';
import 'package:dalili/core/utils/angle_utils.dart';
import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_location_update_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_session_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_state_snapshot.dart';

class NavigationEngine {
  const NavigationEngine({
    this.progressEngine = const NavigationProgressEngine(),
    this.positionEngine = const NavigationPositionEngine(),
    this.projectionEngine = const NavigationProjectionEngine(),
    this.correctionEngine = const NavigationCorrectionEngine(),
    this.decisionEngine = const NavigationDecisionEngine(),
    this.headingSmoothingFactor = 0.35,
  });

  final NavigationProgressEngine progressEngine;
  final NavigationPositionEngine positionEngine;
  final NavigationProjectionEngine projectionEngine;
  final NavigationCorrectionEngine correctionEngine;
  final NavigationDecisionEngine decisionEngine;

  /// How much of each new raw compass reading gets blended into the
  /// *displayed* heading (the turn-by-turn text/arrow), between 0 and 1.
  /// This is the "sensitivity" knob:
  ///   - Higher (closer to 1.0) = reacts faster to real turns, but also
  ///     shows more of the compass's natural jitter (e.g. near metal
  ///     shelving) as false "you're turning" flickers.
  ///   - Lower (closer to 0.0) = steadier text during a real 90°/180°
  ///     turn (takes a bit longer to catch up), but small hand jitter
  ///     while walking straight gets smoothed away almost completely.
  /// Only affects what's displayed — dead reckoning (actual distance
  /// walked) always uses the raw, unsmoothed heading, so smoothing this
  /// doesn't affect position accuracy, only how "twitchy" the guidance
  /// text/arrow looks.
  final double headingSmoothingFactor;

  //==========================================================
  // Initialize
  //==========================================================

  NavigationStateSnapshot initialize({
    required NavigationSessionModel session,
    required LibraryMapModel map,
  }) {
    final projectedPosition = projectionEngine.calculate(
      session: session,
      position: session.currentPosition,
    );

    final updatedSession = session.copyWith(currentPosition: projectedPosition);

    final correction = correctionEngine.calculate(
      session: updatedSession,
      position: projectedPosition,
      map: map,
    );

    final decision = decisionEngine.calculate(session: updatedSession);

    return NavigationStateSnapshot(
      session: updatedSession,
      position: projectedPosition,
      correction: correction,
      decision: decision,
    );
  }

  //==========================================================
  // Update
  //==========================================================

  NavigationStateSnapshot update({
    required NavigationSessionModel session,
    required NavigationLocationUpdateModel update,
    required LibraryMapModel map,
  }) {
    //---------------------------------------
    // Position (Dead Reckoning)
    //---------------------------------------

    final estimatedPosition = positionEngine.calculate(
      previousPosition: session.currentPosition,
      update: update,
    );

    //---------------------------------------
    // Project onto current segment
    //---------------------------------------

    final projectedPosition = projectionEngine.calculate(
      session: session,
      position: estimatedPosition,
    );

    //---------------------------------------
    // Progress
    //---------------------------------------
    // The heading used for the *displayed* turn-by-turn guidance is
    // smoothed (see headingSmoothingFactor) — raw compass readings jitter
    // a few degrees even when walking perfectly straight, which would
    // otherwise flicker the instruction text/arrow between "straight" and
    // "slight turn" on every tick. Dead reckoning above already used the
    // raw update.heading, so this only affects what's shown, not distance
    // accuracy.

    final smoothedHeading = AngleUtils.normalizeDegrees(
      session.heading +
          headingSmoothingFactor *
              AngleUtils.normalizeDegrees(update.heading - session.heading),
    );

    final updatedSession = progressEngine
        .calculate(
          session: session,
          update: update,
          estimatedPosition: estimatedPosition,
        )
        .copyWith(heading: smoothedHeading, currentPosition: projectedPosition);

    //---------------------------------------
    // Correction
    //---------------------------------------
    // NOTE: intentionally checks the raw (pre-projection) estimated
    // position, not the projected one. Checking the projected position
    // here would always read ~0 distance-from-segment, since it was
    // already clamped onto that exact segment a few lines above — making
    // drift undetectable.

    final correction = correctionEngine.calculate(
      session: updatedSession,
      position: estimatedPosition,
      map: map,
    );

    //---------------------------------------
    // Decision
    //---------------------------------------

    final decision = decisionEngine.calculate(session: updatedSession);

    //---------------------------------------
    // Snapshot
    //---------------------------------------

    return NavigationStateSnapshot(
      session: updatedSession,
      position: projectedPosition,
      correction: correction,
      decision: decision,
    );
  }
}
