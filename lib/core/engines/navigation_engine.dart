import 'package:dalili/core/engines/navigation_correction_engine.dart';
import 'package:dalili/core/engines/navigation_decision_engine.dart';
import 'package:dalili/core/engines/navigation_position_engine.dart';
import 'package:dalili/core/engines/navigation_progress_engine.dart';
import 'package:dalili/core/engines/navigation_projection_engine.dart';
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
  });

  final NavigationProgressEngine progressEngine;
  final NavigationPositionEngine positionEngine;
  final NavigationProjectionEngine projectionEngine;
  final NavigationCorrectionEngine correctionEngine;
  final NavigationDecisionEngine decisionEngine;

  //==========================================================
  // Initialize
  //==========================================================

  NavigationStateSnapshot initialize({
    required NavigationSessionModel session,
  }) {
    final projectedPosition = projectionEngine.calculate(
      session: session,
      position: session.currentPosition,
    );

    final updatedSession = session.copyWith(currentPosition: projectedPosition);

    final correction = correctionEngine.calculate(
      session: updatedSession,
      position: projectedPosition,
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

    final updatedSession = progressEngine
        .calculate(session: session, update: update)
        .copyWith(heading: update.heading, currentPosition: projectedPosition);

    //---------------------------------------
    // Correction
    //---------------------------------------

    final correction = correctionEngine.calculate(
      session: updatedSession,
      position: projectedPosition,
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
