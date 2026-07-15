import 'package:dalili/core/builders/navigation_session_builder.dart';
import 'package:dalili/core/services/map_loader_service.dart';
import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_session_model.dart';

class NavigationStartService {
  const NavigationStartService({this.mapLoader = const MapLoaderService()});

  final MapLoaderService mapLoader;

  Future<NavigationStartResult> start({
    required String startNodeId,
    required String endNodeId,
  }) async {
    final map = await mapLoader.load();

    final session = const NavigationSessionBuilder().build(
      map: map,
      startNodeId: startNodeId,
      endNodeId: endNodeId,
    );

    return NavigationStartResult(map: map, session: session);
  }
}

class NavigationStartResult {
  const NavigationStartResult({required this.map, required this.session});

  final LibraryMapModel map;

  final NavigationSessionModel session;
}
