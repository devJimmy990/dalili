/// The link that gets shared for a book, and the reading of it when it comes
/// back. The web landing page (web/src/bookLink.ts) implements the same rules;
/// both are tested against the same examples so a link made by one is always
/// understood by the other.
///
///   `https://HOST/dalili/BOOK-NAME-BIBID`
///
/// The name only makes the link readable in a chat. The BibID after the last
/// hyphen is the key: titles repeat and get corrected, a BibID does not.
library;

const String bookLinkPrefix = 'dalili';

/// A readable, URL-safe form of [title]; letters of any script are kept, so an
/// Arabic title stays Arabic rather than collapsing to nothing.
String slugify(String title, {int maxLength = 60}) {
  final slug = title
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  if (slug.isEmpty) return 'book';
  if (slug.length <= maxLength) return slug;

  // Cut on a word boundary, so the link never ends mid-word.
  final cut = slug.substring(0, maxLength);
  final lastHyphen = cut.lastIndexOf('-');
  return (lastHyphen > 10 ? cut.substring(0, lastHyphen) : cut).replaceAll(
    RegExp(r'-+$'),
    '',
  );
}

/// `/dalili/construction-detailing-12554857`.
String bookPath(String title, String bibid) =>
    '/$bookLinkPrefix/${slugify(title)}-$bibid';

/// The full shareable URL on [origin] (`https://dalili.example.com`).
Uri bookUri(String origin, String title, String bibid) =>
    Uri.parse(origin.replaceAll(RegExp(r'/+$'), '') + bookPath(title, bibid));

/// The BibID in [uri], or null when it is not a book link.
String? parseBibid(Uri uri) {
  final parts = uri.pathSegments.where((p) => p.isNotEmpty).toList();
  if (parts.length != 2 || parts[0] != bookLinkPrefix) return null;

  // `pathSegments` is already percent-decoded.
  final segment = parts[1];
  final id = segment.substring(segment.lastIndexOf('-') + 1).trim();
  return id.isEmpty ? null : id;
}
