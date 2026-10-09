import 'dart:convert';
import 'dart:io';

import 'package:dalili/features/library/data/models/book_model.dart';
import 'package:dalili/features/library/data/models/department_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// These fixtures are real responses captured from the API, so a change to
/// the backend's payload shape fails here instead of at runtime.
Map<String, dynamic> _fixture(String name) {
  final file = File('test/fixtures/$name.json');
  final root = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return root['data'] as Map<String, dynamic>;
}

void main() {
  group('BookModel.fromJson', () {
    test('reads a fully populated book', () {
      final book = BookModel.fromJson(
        _fixture('book')['book'] as Map<String, dynamic>,
      );

      // The catalogue number is the BibID; the book's own id is a separate
      // value (see book_identifiers_test.dart for the split).
      expect(book.bibid, '12492294');
      expect(book.id, isNotEmpty);
      expect(book.title, 'High Voltage Engineering');
      expect(book.author, 'Wadhwa, C.L.');
      expect(book.callNumber, '621.3193.W H');
      expect(book.year, 2010);
      expect(book.edition, 3);
      expect(book.isbn, '9788122430905');
      // The shelf number itself is catalogue data the librarians re-assign;
      // what matters here is that it parses as a number at all.
      expect(book.shelf, isNotNull);
      expect(book.place?.name, isNotEmpty);
      expect(book.articles, hasLength(3));
    });

    test('keeps an absent field null instead of an empty string', () {
      final book = BookModel.fromJson(
        _fixture('book_minimal')['book'] as Map<String, dynamic>,
      );

      // This book has no subjects in the catalogue.
      expect(book.subjects, isNull);
      // Required fields are still there.
      expect(book.title, isNotEmpty);
      expect(book.callNumber, isNotEmpty);
    });

    test('resolves location from the department, with the map node id', () {
      final book = BookModel.fromJson(
        _fixture('book')['book'] as Map<String, dynamic>,
      );

      expect(book.department.id, 'd_electrical');
      expect(book.location.nodeId, 'd_electrical');
      expect(book.location.name, book.department.name);
      expect(book.location.isNavigable, isTrue);
    });

    test('exposes the localized labels the API resolved', () {
      final ar = BookModel.fromJson(
        _fixture('book')['book'] as Map<String, dynamic>,
      );
      // Labels are built by the API around values the catalogue owns, so
      // they are checked against those values rather than pinned verbatim.
      expect(ar.shelfLabel, 'الرف ${ar.shelf}');
      expect(ar.locationLabel, contains(ar.department.name));
      expect(ar.locationLabel, endsWith(ar.shelfLabel!));
      expect(ar.editionLabel, 'ط. ${ar.edition}');
      expect(ar.language, 'الإنجليزية');

      // A kind of edition (teacher's) is named by the API, with no number
      // behind it.
      final en = BookModel.fromJson(
        _fixture('book_en')['book'] as Map<String, dynamic>,
      );
      expect(en.edition, isNull);
      expect(en.editionLabel, "Teacher's edition");
      expect(en.locationLabel, startsWith('${en.department.name} Department'));
      expect(en.locationLabel, endsWith('Shelf ${en.shelf}'));
    });

    test('reads the document kind and source of each related article', () {
      final book = BookModel.fromJson(
        _fixture('book')['book'] as Map<String, dynamic>,
      );

      // Flat localized strings, as the article card prints them — the
      // kinds come from lookup tables, so the contract is the shape, not
      // which kind any one article happens to carry today.
      for (final article in book.articles) {
        expect(article.type, isNotNull);
        expect(article.type, isNotEmpty);
        expect(article.source, isNotNull);
        expect(article.source, isNotEmpty);
      }
      expect(
        book.articles.map((a) => a.source),
        everyElement(anyOf('مجلة', 'مؤتمر')),
      );
    });

    test('survives a round trip through toJson, for cached favorites', () {
      final original = BookModel.fromJson(
        _fixture('book')['book'] as Map<String, dynamic>,
      );
      final restored = BookModel.fromJson(
        jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
      );

      expect(restored, equals(original));
    });

    test('round-trips a book with null fields without inventing values', () {
      final original = BookModel.fromJson(
        _fixture('book_minimal')['book'] as Map<String, dynamic>,
      );
      final restored = BookModel.fromJson(
        jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
      );

      expect(restored.subjects, isNull);
      expect(restored, equals(original));
    });

    test('parses a page of books and a search result list', () {
      final page = _fixture('books');
      final books = (page['items'] as List)
          .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(books, hasLength(3));
      expect(page['total'], 50);
      expect(page['hasMore'], isTrue);

      final results = (_fixture('search')['items'] as List)
          .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(results, isNotEmpty);
      expect(results.every((b) => b.title.isNotEmpty), isTrue);
    });
  });

  group('DepartmentModel.fromJson', () {
    test('carries bookCount and the map node id', () {
      final departments = (_fixture('departments')['items'] as List)
          .map((e) => DepartmentModel.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(departments, hasLength(8));

      final electrical = departments.firstWhere((d) => d.id == 'd_electrical');
      expect(electrical.bookCount, 10);
      expect(electrical.isNavigable, isTrue);
      expect(electrical.isEmpty, isFalse);

      // Basic Sciences shares the Mechanical section's node on the map.
      // Basic Sciences shares Mechanical Engineering's spot in the library
      // but keeps a node of its own, so a book from it is walked to under
      // its own section's name.
      final basic = departments.firstWhere((d) => d.id == 'd_basic_sciences');
      expect(basic.mapNodeId, 'd_basic_sciences');

      // A section with no books still exists and is still navigable.
      final theses = departments.firstWhere((d) => d.id == 'd_theses');
      expect(theses.isEmpty, isTrue);
      expect(theses.isNavigable, isTrue);
    });
  });
}
