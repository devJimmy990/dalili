import 'package:dalili/core/utils/book_link.dart';
import 'package:flutter_test/flutter_test.dart';

/// These cases are the same ones web/src/bookLink.test.ts checks. If one side
/// changes the format, the other side's tests must fail.
void main() {
  group('parseBibid', () {
    String? read(String url) => parseBibid(Uri.parse(url));

    test('reads the id after the last hyphen', () {
      expect(
        read(
          'https://x.app/book/construction-detailing-for-landscape-12554857',
        ),
        '12554857',
      );
    });

    test('accepts a bare id', () {
      expect(read('https://x.app/book/12554857'), '12554857');
    });

    test('is not fooled by digits inside the name', () {
      expect(
        read('https://x.app/book/design-manual-2nd-edition-1990-267302'),
        '267302',
      );
    });

    test('reads an Arabic name, plain or percent-encoded', () {
      expect(
        read('https://x.app/book/العمارة-كتلة-وفراغ-12631333'),
        '12631333',
      );
      expect(
        read(
          'https://x.app/book/${Uri.encodeComponent('العمارة-كتلة-وفراغ-12631333')}',
        ),
        '12631333',
      );
    });

    test('tolerates a trailing slash', () {
      expect(read('https://x.app/book/x-12554857/'), '12554857');
    });

    test('rejects anything that is not a book link', () {
      expect(read('https://x.app/'), isNull);
      expect(read('https://x.app/book'), isNull);
      expect(read('https://x.app/book/'), isNull);
      expect(read('https://x.app/other/x-123'), isNull);
      expect(read('https://x.app/book/a/b-123'), isNull);
      expect(read('https://x.app/book/title-'), isNull);
    });
  });

  group('links shared before the prefix changed', () {
    test('still open — they were already sent to people', () {
      expect(
        parseBibid(
          Uri.parse('https://x.app/dalili/construction-detailing-12554857'),
        ),
        '12554857',
      );
      expect(
        parseBibid(Uri.parse('https://x.app/dalili/12554857')),
        '12554857',
      );
    });

    test('are no longer produced', () {
      expect(bookPath('Anything', '1'), startsWith('/book/'));
      expect(bookPath('Anything', '1'), isNot(contains('/dalili/')));
    });
  });

  group('slugify', () {
    test('lowercases and hyphenates', () {
      expect(
        slugify('Construction detailing for landscape and garden design'),
        'construction-detailing-for-landscape-and-garden-design',
      );
    });

    test('drops punctuation', () {
      expect(slugify('Electric machines :'), 'electric-machines');
      expect(
        slugify('GATE Electrical engineering : (2nd ed.)'),
        'gate-electrical-engineering-2nd-ed',
      );
    });

    test('keeps Arabic letters', () {
      expect(slugify('العمارة كتلة وفراغ ونظام'), 'العمارة-كتلة-وفراغ-ونظام');
    });

    test('never returns an empty slug', () {
      expect(slugify('::: ---'), 'book');
      expect(slugify(''), 'book');
    });

    test('cuts a long title on a word boundary', () {
      final slug = slugify(
        'Digital signal processing system analysis and design with applications',
      );
      expect(slug.length, lessThanOrEqualTo(60));
      expect(slug.endsWith('-'), isFalse);
      expect(
        'digital-signal-processing-system-analysis-and-design-with-applications',
        contains(slug),
      );
    });
  });

  group('bookLinkText', () {
    test('keeps an Arabic title readable instead of percent-encoding it', () {
      final text = bookLinkText(
        'https://x.app/',
        'العمارة كتلة وفراغ ونظام',
        '12631333',
      );

      expect(text, 'https://x.app/book/العمارة-كتلة-وفراغ-ونظام-12631333');
      expect(text, isNot(contains('%')));
    });

    test('is still a link the reader above understands', () {
      final text = bookLinkText('https://x.app', 'العمارة كتلة', '12631333');

      // Plain, and encoded by a browser or chat app — both give the same id.
      expect(parseBibid(Uri.parse(text)), '12631333');
      expect(parseBibid(Uri.parse(Uri.encodeFull(text))), '12631333');
    });

    test('only ever contains characters that are safe in a URL path', () {
      final text = bookLinkText(
        'https://x.app',
        'Title: with / odd ? chars # and % signs & more',
        '1',
      );

      final path = text.substring('https://x.app'.length);
      expect(path, matches(RegExp(r'^/book/[\p{L}\p{N}-]+$', unicode: true)));
    });
  });

  group('bookPath', () {
    test('builds the documented shape', () {
      expect(
        bookPath('Concrete technology: Theory and Practice', '40959'),
        '/book/concrete-technology-theory-and-practice-40959',
      );
    });

    test('round-trips through parseBibid', () {
      final uri = bookUri('https://x.app/', 'Calculus 2011', '13134446');

      expect(uri.toString(), 'https://x.app/book/calculus-2011-13134446');
      expect(parseBibid(uri), '13134446');
    });
  });
}
