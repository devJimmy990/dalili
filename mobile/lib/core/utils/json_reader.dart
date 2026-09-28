/// Helpers for reading API payloads.
///
/// The API distinguishes "unknown" (null) from "empty", and every model
/// preserves that distinction — so these deliberately return null for a
/// blank string instead of quietly turning it into `''`.
extension JsonReader on Map<dynamic, dynamic> {
  /// A trimmed string, or null when the key is missing, null, or blank.
  String? optString(String key) {
    final value = this[key];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  /// A trimmed string, falling back to [orElse] when absent. Use only for
  /// fields the API guarantees.
  String requireString(String key, {String orElse = ''}) =>
      optString(key) ?? orElse;

  /// An int, tolerating a numeric string ("2003").
  int? optInt(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim());
  }

  /// A double, tolerating a numeric string ("0.96").
  double? optDouble(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim());
  }

  /// A nested object, or null when missing or not an object.
  Map<dynamic, dynamic>? optMap(String key) {
    final value = this[key];
    return value is Map<dynamic, dynamic> ? value : null;
  }

  /// A list, or an empty list when missing.
  List<dynamic> optList(String key) {
    final value = this[key];
    return value is List ? value : const [];
  }
}
