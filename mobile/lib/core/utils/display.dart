/// Formatting helpers for optional catalogue fields.
///
/// Most book and article fields can be null, and a naive
/// `'$publisher • $year'` would render "null • null". These build the
/// string from the parts that actually exist, and return null when none
/// do — so the caller can drop the row entirely.
library;

/// Joins the non-empty parts with [separator], or returns null if nothing
/// is left. `join(['Springer', null])` → `'Springer'`.
String? joinParts(List<Object?> parts, {String separator = ' • '}) {
  final kept = parts
      .map((p) => p?.toString().trim())
      .where((p) => p != null && p.isNotEmpty)
      .cast<String>();
  return kept.isEmpty ? null : kept.join(separator);
}

/// True when the value is worth rendering at all.
bool hasText(String? value) => value != null && value.trim().isNotEmpty;

extension OptionalText on String? {
  /// The value, or null when it is blank — lets `??` supply a fallback.
  String? get orNull {
    final value = this;
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
