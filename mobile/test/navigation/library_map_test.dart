import 'dart:convert';
import 'dart:io';

import 'package:dalili/core/services/dijkstra_service.dart';
import 'package:dalili/core/services/graph_service.dart';
import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// The map is hand-edited JSON, and a broken edit fails *silently*:
/// `GraphService` drops an edge whose endpoint is missing, so a destination
/// simply stops being reachable with no error anywhere. These tests make
/// that loud instead.
void main() {
  final map = LibraryMapModel.fromJson(
    jsonDecode(File('assets/map/library_map.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  final nodeIds = map.nodes.map((n) => n.id).toList();
  final destinations = map.nodes.where((n) => n.type == 'destination');

  test('no node id appears twice', () {
    final seen = <String>{};
    final duplicates = nodeIds.where((id) => !seen.add(id)).toSet();

    expect(
      duplicates,
      isEmpty,
      reason:
          'a duplicated id shows the same place twice in the destination '
          'list and makes lookups ambiguous',
    );
  });

  test('every edge connects two nodes that exist', () {
    final known = nodeIds.toSet();

    for (final edge in map.edges) {
      expect(
        known,
        contains(edge.from),
        reason:
            'edge "${edge.from}" -> "${edge.to}" starts at a node the map '
            'does not define, so it is silently dropped from the graph',
      );
      expect(
        known,
        contains(edge.to),
        reason:
            'edge "${edge.from}" -> "${edge.to}" ends at a node the map '
            'does not define, so it is silently dropped from the graph',
      );
    }
  });

  test('every destination is reachable on foot from the entrance', () {
    final graph = GraphService(map);
    final dijkstra = DijkstraService(graph);

    for (final destination in destinations) {
      final path = dijkstra.findShortestPath(
        startNodeId: 'entrance',
        endNodeId: destination.id,
      );

      expect(
        path.length,
        greaterThan(1),
        reason:
            'no walking route from the entrance to "${destination.id}" '
            '(${destination.name}) — navigation to it would fail',
      );
      expect(path.first.id, 'entrance');
      expect(path.last.id, destination.id);
    }
  });

  test('every node carries an English label', () {
    for (final node in map.nodes) {
      expect(
        node.nameEn,
        isNotNull,
        reason:
            '"${node.id}" has no nameEn, so the English UI would show its '
            'Arabic name',
      );
      expect(node.displayName('en'), node.nameEn);
      expect(node.displayName('ar'), node.name);
    }
  });

  test('a QR code identifies exactly one node', () {
    final byQr = <String, List<String>>{};
    for (final node in map.nodes) {
      final qr = node.qr;
      if (qr != null) byQr.putIfAbsent(qr, () => []).add(node.id);
    }

    byQr.forEach((qr, owners) {
      expect(
        owners,
        hasLength(1),
        reason:
            '$qr is claimed by ${owners.join(", ")} — scanning it could '
            'place the visitor at either one',
      );
    });
  });

  test('Basic Sciences shares the Mechanical section’s spot', () {
    // The two sections sit together in the library. They stay separate
    // nodes so each book routes to its own section's name, but they must
    // describe the same physical place.
    final mechanical = map.nodes.firstWhere((n) => n.id == 'd_mechanical');
    final basic = map.nodes.firstWhere((n) => n.id == 'd_basic_sciences');

    expect(basic.x, mechanical.x);
    expect(basic.y, mechanical.y);
  });
}
