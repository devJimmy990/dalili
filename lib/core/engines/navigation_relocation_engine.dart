import 'package:dalili/core/builders/navigation_session_builder.dart';
import 'package:dalili/core/engines/navigation_engine.dart';
import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_session_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_state_snapshot.dart';

class NavigationRelocationEngine {
  const NavigationRelocationEngine({
    this.navigationEngine = const NavigationEngine(),
    this.sessionBuilder = const NavigationSessionBuilder(),
  });

  final NavigationEngine navigationEngine;
  final NavigationSessionBuilder sessionBuilder;

  NavigationStateSnapshot relocate({
    required LibraryMapModel map,
    required NavigationSessionModel session,
    required String currentNodeId,
  }) {
    //--------------------------------------
    // Build new navigation session
    //--------------------------------------

    final relocatedSession = sessionBuilder.build(
      map: map,
      startNodeId: currentNodeId,
      endNodeId: session.route.end.id,
      heading: session.heading,
    );

    //--------------------------------------
    // Build snapshot
    //--------------------------------------

    return navigationEngine.initialize(session: relocatedSession);
  }
}
