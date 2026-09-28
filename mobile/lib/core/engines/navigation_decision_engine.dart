import 'dart:math';

import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/utils/angle_utils.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_decision_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_session_model.dart';

class NavigationDecisionEngine {
  const NavigationDecisionEngine();

  NavigationDecisionModel calculate({required NavigationSessionModel session}) {
    if (session.status == NavigationStatus.arrived) {
      return NavigationDecisionModel(
        decision: NavigationDecision.arrived,
        angleDifference: 0,
        message: AppLocalizations.navArrivedMessage,
      );
    }

    final segment = session.currentSegment;

    final dx = segment.to.x - segment.from.x;
    final dy = segment.to.y - segment.from.y;

    //-----------------------------
    // Segment Heading
    //-----------------------------

    double segmentHeading = atan2(dx, -dy) * 180 / pi;

    if (segmentHeading < 0) {
      segmentHeading += 360;
    }

    //-----------------------------
    // Difference
    //-----------------------------

    final diff = AngleUtils.normalizeDegrees(segmentHeading - session.heading);

    final absDiff = diff.abs();

    //-----------------------------
    // Decision
    //-----------------------------

    if (absDiff <= 15) {
      return NavigationDecisionModel(
        decision: NavigationDecision.straight,
        angleDifference: diff,
        message: AppLocalizations.navGoStraight,
      );
    }

    if (absDiff <= 45) {
      return NavigationDecisionModel(
        decision: diff > 0
            ? NavigationDecision.slightRight
            : NavigationDecision.slightLeft,
        angleDifference: diff,
        message: diff > 0
            ? AppLocalizations.navSlightRight
            : AppLocalizations.navSlightLeft,
      );
    }

    if (absDiff <= 120) {
      return NavigationDecisionModel(
        decision: diff > 0 ? NavigationDecision.right : NavigationDecision.left,
        angleDifference: diff,
        message: diff > 0
            ? AppLocalizations.navTurnRight
            : AppLocalizations.navTurnLeft,
      );
    }

    return NavigationDecisionModel(
      decision: NavigationDecision.uTurn,
      angleDifference: diff,
      message: AppLocalizations.navUTurn,
    );
  }
}
