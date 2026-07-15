import 'package:dalili/features/library/data/models/navigation/navigation_correction_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_decision_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_position_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_session_model.dart';

class NavigationStateSnapshot {
  const NavigationStateSnapshot({
    required this.session,
    required this.position,
    required this.decision,
    required this.correction,
  });

  final NavigationSessionModel session;

  final NavigationPositionModel position;

  final NavigationDecisionModel decision;

  final NavigationCorrectionModel correction;
}
