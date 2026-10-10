import 'package:dalili/core/errors/exceptions.dart';
import 'package:dalili/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

Response<dynamic> _response(int status, Map<String, dynamic> body) =>
    Response<dynamic>(
      requestOptions: RequestOptions(path: '/books/by-accession/533'),
      statusCode: status,
      data: body,
    );

NotFoundException _thrownBy(Response<dynamic> response) {
  try {
    response.payload;
  } on NotFoundException catch (e) {
    return e;
  }
  fail('expected a NotFoundException');
}

/// "Not found" is two different answers, and treating them alike once showed
/// "this book is not in the database" for a book that was there — the server
/// simply had not been updated with the scan route yet.
void main() {
  test('a 404 carrying book_not_found means the book does not exist', () {
    final e = _thrownBy(
      _response(404, {
        'status': 'error',
        'message': 'Book not found',
        'code': 'book_not_found',
      }),
    );

    expect(e.isBookNotFound, isTrue);
  });

  test('a 404 for a missing route is not a missing book', () {
    final e = _thrownBy(
      _response(404, {
        'status': 'error',
        'message': 'Route not found: GET /api/books/by-accession/533',
        'code': 'route_not_found',
      }),
    );

    expect(e.isBookNotFound, isFalse);
  });

  test(
    'an older server that sends no code is not trusted to mean "no book"',
    () {
      // This is the server that answered the real 533 scan: a bare 404 with a
      // message and no code. It cannot tell the two apart, so neither can we.
      final e = _thrownBy(
        _response(404, {
          'status': 'error',
          'message': 'المسار غير موجود: GET /api/books/by-accession/533',
        }),
      );

      expect(e.isBookNotFound, isFalse);
      expect(e.code, isNull);
    },
  );

  test('a successful response still unwraps its data', () {
    final payload = _response(200, {
      'status': 'success',
      'data': {
        'book': {'id': '12554857'},
      },
    }).payload;

    expect((payload['book'] as Map)['id'], '12554857');
  });
}
