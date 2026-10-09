import 'dart:convert';
import 'dart:io';

import 'package:dalili/features/library/data/models/book_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// A book has two identifiers that must never be confused: `id` is the
/// book's own (what a barcode carries, what articles link to) and `bibid`
/// is the catalogue number people search by. These tests pin that split.
Map<String, dynamic> _book(String fixture) {
  final root =
      jsonDecode(File('test/fixtures/$fixture.json').readAsStringSync())
          as Map<String, dynamic>;
  return (root['data'] as Map<String, dynamic>)['book'] as Map<String, dynamic>;
}

void main() {
  test('id and bibid are read as two separate values', () {
    final book = BookModel.fromJson(_book('book'));

    expect(book.id, isNotEmpty);
    expect(book.bibid, '12492294');
    expect(
      book.id,
      isNot(book.bibid),
      reason:
          'the book id must not be the BibID, or a barcode would '
          'resolve through the wrong identifier',
    );
  });

  test('a payload cached before bibid existed still loads', () {
    // Favorites are persisted on the device, so older ones have no bibid.
    final json = Map<String, dynamic>.of(_book('book'))..remove('bibid');
    final book = BookModel.fromJson(json);

    expect(book.bibid, isNull);
    expect(book.id, isNotEmpty);
    expect(book.title, isNotEmpty);
  });

  test('bibid survives the favorites round trip', () {
    final original = BookModel.fromJson(_book('book'));
    final restored = BookModel.fromJson(
      jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
    );

    expect(restored.bibid, original.bibid);
    expect(restored.id, original.id);
    expect(restored, equals(original));
  });

  test('a BibID search returns that one book, whole', () {
    final root =
        jsonDecode(File('test/fixtures/search_bibid.json').readAsStringSync())
            as Map<String, dynamic>;
    final data = root['data'] as Map<String, dynamic>;
    final books = (data['items'] as List)
        .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
        .toList();

    expect(data['total'], 1);
    expect(books, hasLength(1));
    expect(books.single.bibid, '12492294');
  });
}
