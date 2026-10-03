import 'package:dalili/core/utils/qr_payload.dart';
import 'package:dalili/features/library/data/models/navigation/node_model.dart';

/// Finds the map node a scanned QR refers to.
///
/// The payload's id is a node id (`d_electrical`, `N8`). A node's legacy
/// `qr` field ("QR04") is accepted too, so codes printed from the old scheme
/// still resolve. Matching ignores case and spaces; null means the code is
/// not on this map.
NodeModel? resolveQrNode(Iterable<NodeModel> nodes, QrPayload payload) {
  String normalize(String s) => s.trim().toUpperCase().replaceAll(' ', '');

  final wanted = normalize(payload.id);
  if (wanted.isEmpty) return null;

  for (final node in nodes) {
    if (normalize(node.id) == wanted) return node;
  }
  for (final node in nodes) {
    final qr = node.qr;
    if (qr != null && normalize(qr) == wanted) return node;
  }
  return null;
}
