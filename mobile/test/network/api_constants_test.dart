import 'package:dalili/core/constants/api_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bookByAccession', () {
    test('a plain label number goes straight into the path', () {
      expect(ApiConstants.bookByAccession('1415'), '/books/by-accession/1415');
    });

    test('a barcode with path characters cannot change the route', () {
      // A barcode can carry any text. "/" must not turn this into
      // /books/by-accession/a/b, and "?" must not start a query string.
      final path = ApiConstants.bookByAccession('a/b?c=d e');

      expect(path, startsWith('/books/by-accession/'));
      expect(
        path.substring('/books/by-accession/'.length),
        isNot(contains('/')),
      );
      expect(path, isNot(contains('?')));
      expect(path, isNot(contains(' ')));
      expect(
        Uri.decodeComponent(path.substring('/books/by-accession/'.length)),
        'a/b?c=d e',
      );
    });
  });
}
