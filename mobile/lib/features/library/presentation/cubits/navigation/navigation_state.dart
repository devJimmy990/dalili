import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_decision_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_position_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_session_model.dart';

class NavigationState {
  const NavigationState({
    this.map,
    this.error,
    this.session,
    this.decision,
    this.position,
    this.loading = false,
    this.arrived = false,
    this.navigating = false,
  });

  final String? error;

  final LibraryMapModel? map;

  final NavigationSessionModel? session;

  final NavigationPositionModel? position;

  final NavigationDecisionModel? decision;

  final bool navigating, arrived, loading;

  NavigationState copyWith({
    bool? loading,
    String? error,
    bool clearError = false,
    bool? arrived,
    bool? navigating,
    LibraryMapModel? map,
    bool clearMap = false,
    NavigationSessionModel? session,
    bool clearSession = false,
    NavigationDecisionModel? decision,
    bool clearDecision = false,
    NavigationPositionModel? position,
    bool clearPosition = false,
  }) => NavigationState(
    map: clearMap ? null : (map ?? this.map),
    error: clearError ? null : (error ?? this.error),
    loading: loading ?? this.loading,
    session: clearSession ? null : (session ?? this.session),
    arrived: arrived ?? this.arrived,
    decision: clearDecision ? null : (decision ?? this.decision),
    position: clearPosition ? null : (position ?? this.position),
    navigating: navigating ?? this.navigating,
  );
}
