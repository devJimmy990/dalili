/// The link that gets shared for a book, and the reading of it when it comes
/// back. The web landing page (web/src/bookLink.ts) implements the same rules;
/// both are tested against the same examples so a link made by one is always
/// understood by the other.
///
///   `https://HOST/book/BOOK-NAME-BIBID`
///
/// The name only makes the link readable in a chat. The BibID after the last
/// hyphen is the key: titles repeat and get corrected, a BibID does not.
library;

/// What new links are built with.
const String bookLinkPrefix = 'book';

/// Prefixes still understood when reading a link. `dalili` is what links were
/// built with at first — `HOST/dalili/NAME-ID` repeated the app's name right
/// after a domain that already carries it — and some were already shared, so
/// they must keep opening.
const List<String> bookLinkReadPrefixes = [bookLinkPrefix, 'dalili'];

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

/// `/book/construction-detailing-12554857`.
String bookPath(String title, String bibid) =>
    '/$bookLinkPrefix/${slugify(title)}-$bibid';

/// The full shareable URL on [origin] (`https://dalili.example.com`), as
/// text *as people should read it*: an Arabic title stays Arabic.
///
/// Going through [Uri] would percent-encode it — `%D8%A7%D9%84%D8%B9…` — which
/// is correct for a browser but unreadable in a chat, the opposite of why the
/// name is in the link at all. Nothing is lost by leaving it plain: a slug is
/// only letters, digits and hyphens, none of which are reserved in a URL, and
/// WhatsApp, Telegram and browsers all accept it and encode it themselves.
String bookLinkText(String origin, String title, String bibid) =>
    origin.replaceAll(RegExp(r'/+$'), '') + bookPath(title, bibid);

/// The same link as a [Uri] (percent-encoded), for code rather than people.
Uri bookUri(String origin, String title, String bibid) =>
    Uri.parse(bookLinkText(origin, title, bibid));

/// The BibID in [uri], or null when it is not a book link.
String? parseBibid(Uri uri) {
  final parts = uri.pathSegments.where((p) => p.isNotEmpty).toList();
  if (parts.length != 2 || !bookLinkReadPrefixes.contains(parts[0])) {
    return null;
  }

  // `pathSegments` is already percent-decoded.
  final segment = parts[1];
  final id = segment.substring(segment.lastIndexOf('-') + 1).trim();
  return id.isEmpty ? null : id;
}
