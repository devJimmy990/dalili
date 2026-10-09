import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:dalili/core/builders/navigation_session_builder.dart';
import 'package:dalili/core/errors/navigation_exception.dart';
import 'package:dalili/core/services/dijkstra_service.dart';
import 'package:dalili/core/services/graph_service.dart';
import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Basic Sciences and Mechanical Engineering are two destinations standing on
/// one spot. That is deliberate — each book is announced under its own
/// section's name — but it puts two nodes at identical coordinates, which the
/// routing code has to handle without sending anyone on a detour.
void main() {
  final map = LibraryMapModel.fromJson(
    jsonDecode(File('assets/map/library_map.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  final mechanical = map.nodes.firstWhere((n) => n.id == 'd_mechanical');
  final basic = map.nodes.firstWhere((n) => n.id == 'd_basic_sciences');

  test('the twins really do share a position', () {
    expect(basic.x, mechanical.x);
    expect(basic.y, mechanical.y);
    expect(basic.id, isNot(mechanical.id));
  });

  test('each twin is reached by its own route, of the same length', () {
    final dijkstra = DijkstraService(GraphService.of(map));

    double lengthOf(String destination) {
      final path = dijkstra.findShortestPath(
        startNodeId: 'entrance',
        endNodeId: destination,
      );
      var total = 0.0;
      for (var i = 0; i < path.length - 1; i++) {
        total += _distance(path[i].x, path[i].y, path[i + 1].x, path[i + 1].y);
      }
      return total;
    }

    // Same spot on the floor, so the same walk — a visitor heading to
    // either section covers identical ground.
    expect(
      lengthOf('d_basic_sciences'),
      closeTo(lengthOf('d_mechanical'), 0.01),
    );
  });

  test('walking from one twin to the other is treated as already there', () {
    // Both sit on the same tile, so there is nothing to walk. Without this
    // the graph would happily plot a route out to the corridor junction and
    // straight back, telling the visitor to walk several metres in a circle.
    expect(
      () => const NavigationSessionBuilder().build(
        map: map,
        startNodeId: 'd_basic_sciences',
        endNodeId: 'd_mechanical',
      ),
      throwsA(
        isA<NavigationException>().having(
          (e) => e.reason,
          'reason',
          NavigationFailureReason.alreadyAtDestination,
        ),
      ),
    );
  });

  test('standing on the destination is reported, not routed', () {
    expect(
      () => const NavigationSessionBuilder().build(
        map: map,
        startNodeId: 'd_electrical',
        endNodeId: 'd_electrical',
      ),
      throwsA(
        isA<NavigationException>().having(
          (e) => e.reason,
          'reason',
          NavigationFailureReason.alreadyAtDestination,
        ),
      ),
    );
  });

  test('a normal trip still builds a route with segments to walk', () {
    final session = const NavigationSessionBuilder().build(
      map: map,
      startNodeId: 'entrance',
      endNodeId: 'd_electrical',
    );

    expect(session.route.segments, isNotEmpty);
    expect(session.route.start.id, 'entrance');
    expect(session.route.end.id, 'd_electrical');
    expect(session.progress.remainingDistance, session.route.totalDistance);
  });
}

double _distance(double x1, double y1, double x2, double y2) =>
    sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2)).toDouble();
