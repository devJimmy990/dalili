import 'dart:convert';
import 'dart:io';

import 'package:dalili/features/library/data/models/book_model.dart';
import 'package:dalili/features/library/data/models/department_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// "Take me to the book" hands `book.location.nodeId` to the navigation
/// engine, which looks it up in the map asset. If the API ever reports a
/// node the map does not have, the button would open a dead end — so the
/// two sources are checked against each other here.
void main() {
  final map =
      jsonDecode(File('assets/map/library_map.json').readAsStringSync())
          as Map<String, dynamic>;

  final nodes = (map['nodes'] as List).cast<Map<String, dynamic>>();
  final nodeIds = nodes.map((n) => n['id'] as String).toSet();
  final destinationIds = nodes
      .where((n) => n['type'] == 'destination')
      .map((n) => n['id'] as String)
      .toSet();

  Map<String, dynamic> fixture(String name) =>
      (jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
          as Map<String, dynamic>)['data'] as Map<String, dynamic>;

  test('every department node id exists on the map as a destination', () {
    final departments = (fixture('departments')['items'] as List)
        .map((e) => DepartmentModel.fromJson(e as Map<String, dynamic>))
        .toList();

    for (final department in departments) {
      final nodeId = department.mapNodeId;
      if (nodeId == null) continue; // Legitimately not on the map.

      expect(
        nodeIds,
        contains(nodeId),
        reason: '${department.id} points at map node "$nodeId", which the '
            'map asset does not define',
      );
      expect(
        destinationIds,
        contains(nodeId),
        reason: '${department.id} points at "$nodeId", which is on the map '
            'but is not a destination the navigation UI can route to',
      );
    }
  });

  test('a book resolves to a destination the navigation engine accepts', () {
    final book = BookModel.fromJson(
      fixture('book')['book'] as Map<String, dynamic>,
    );

    expect(book.location.isNavigable, isTrue);
    expect(destinationIds, contains(book.location.nodeId));
  });

  test('every book in a page carries a usable destination', () {
    final books = (fixture('books')['items'] as List)
        .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
        .toList();

    for (final book in books) {
      expect(
        book.location.isNavigable,
        isTrue,
        reason: '"${book.title}" has no map node, so the navigate button '
            'would be disabled for it',
      );
      expect(destinationIds, contains(book.location.nodeId));
    }
  });
}
