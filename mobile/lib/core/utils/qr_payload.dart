import 'dart:convert';

/// What a location QR code carries: `{"id": "d_electrical", "name": "قسم كهربية"}`.
///
/// Only [id] is needed to place the visitor — it is a node id on the library
/// map. [name] is whatever label the printed code carries; it is kept so a
/// screen can show it, but nothing relies on it (the map's own node name is
/// the source of truth).
///
/// A bare string ("QR04", "d_electrical") is still accepted and read as the
/// id, so codes printed before the JSON format keep working.
class QrPayload {
  const QrPayload({required this.id, this.name});

  /// Never throws: anything that is not a JSON object with an `id` is
  /// treated as the id itself.
  factory QrPayload.parse(String raw) {
    final text = raw.trim();

    if (text.startsWith('{')) {
      try {
        final decoded = jsonDecode(text);
        if (decoded is Map) {
          final id = decoded['id']?.toString().trim();
          if (id != null && id.isNotEmpty) {
            final name = decoded['name']?.toString().trim();
            return QrPayload(
              id: id,
              name: name == null || name.isEmpty ? null : name,
            );
          }
        }
      } on FormatException {
        // Not JSON after all — fall through to the bare-string reading.
      }
    }

    return QrPayload(id: text);
  }

  final String id;
  final String? name;
}
