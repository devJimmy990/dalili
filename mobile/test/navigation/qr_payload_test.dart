import 'dart:convert';
import 'dart:io';

import 'package:dalili/core/utils/qr_payload.dart';
import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:dalili/features/library/presentation/screens/navigation/qr_node_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final map = LibraryMapModel.fromJson(
    jsonDecode(File('assets/map/library_map.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  group('QrPayload.parse', () {
    test('reads {id, name}', () {
      final p = QrPayload.parse('{"id":"d_electrical","name":"قسم كهربية"}');
      expect(p.id, 'd_electrical');
      expect(p.name, 'قسم كهربية');
    });

    test('name is optional, extra keys are ignored', () {
      final p = QrPayload.parse(' {"id": "N8", "floor": 1} ');
      expect(p.id, 'N8');
      expect(p.name, isNull);
    });

    test('a bare string is the id (codes printed before the JSON format)', () {
      expect(QrPayload.parse('QR04').id, 'QR04');
      expect(QrPayload.parse('  d_civil\n').id, 'd_civil');
    });

    test('broken or id-less JSON never throws', () {
      expect(QrPayload.parse('{"id": ').id, '{"id":');
      expect(QrPayload.parse('{"name":"x"}').name, isNull);
    });
  });

  group('resolveQrNode', () {
    test('every node resolves by its id, from a JSON code', () {
      for (final node in map.nodes) {
        final payload = QrPayload.parse(
          jsonEncode({'id': node.id, 'name': node.name}),
        );
        expect(resolveQrNode(map.nodes, payload)?.id, node.id);
      }
    });

    test('the legacy qr field still resolves', () {
      final node = resolveQrNode(map.nodes, QrPayload.parse('qr 04'));
      expect(node?.id, 'd_electrical');
    });

    test('an unknown id is null, not a guess', () {
      expect(
        resolveQrNode(map.nodes, QrPayload.parse('{"id":"nope"}')),
        isNull,
      );
      expect(resolveQrNode(map.nodes, const QrPayload(id: '')), isNull);
    });
  });
}
