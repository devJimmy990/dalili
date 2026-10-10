import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:dalili/core/localization/generated/l10n.dart';
import 'package:dalili/core/services/book_link_service.dart';
import 'package:dalili/features/library/data/models/book_model.dart';
import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:dalili/features/library/domain/entities/book_page.dart';
import 'package:dalili/features/library/domain/entities/department.dart';
import 'package:dalili/features/library/domain/repositories/library_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements LibraryRepository {
  _Repo(this.books);

  final Map<String, Book> books;
  final List<String> asked = [];
  Object? failWith;

  @override
  Future<Book?> getBookById(String bibid) async {
    asked.add(bibid);
    if (failWith != null) throw failWith!;
    return books[bibid];
  }

  @override
  Future<Book?> getBookByAccessionNumber(String number) =>
      throw UnimplementedError();
  @override
  Future<BookPage> getAllBooks({int page = 1}) => throw UnimplementedError();
  @override
  Future<List<Department>> getDepartments() => throw UnimplementedError();
  @override
  Future<List<Book>> searchBooks(String query) => throw UnimplementedError();
  @override
  Future<BookPage> getBooksByDepartment(String id, {int page = 1}) =>
      throw UnimplementedError();
  @override
  Future<BookPage> getBooksByAuthor(String author, {int page = 1}) =>
      throw UnimplementedError();
  @override
  Future<List<Book>> getBooksByIds(List<String> ids) =>
      throw UnimplementedError();
}

Book _book(String id, String title) => BookModel.fromJson({
  'id': id,
  'callNumber': '1',
  'title': title,
  'author': 'A',
  'department': {'id': 'd', 'name': 'D'},
  'location': {'nodeId': null, 'name': 'D'},
});

void main() {
  late GlobalKey<NavigatorState> navigatorKey;
  late _Repo repo;
  late BookLinkService service;

  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      // The service's messages come from the app's own strings, so the test
      // app has to load them like the real one does.
      locale: const Locale('en'),
      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates: const [
        S.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      home: const Scaffold(body: Text('home')),
    ),
  );

  setUp(() {
    navigatorKey = GlobalKey<NavigatorState>();
    repo = _Repo({'12554857': _book('12554857', 'Construction detailing')});
    service = BookLinkService(
      navigatorKey: navigatorKey,
      repository: repo,
      bookPage: (book) => Scaffold(body: Text('BOOK ${book.title}')),
      appLinks: AppLinks(),
    );
  });

  testWidgets('a book link opens that book on top of the current screen', (
    tester,
  ) async {
    await pumpApp(tester);

    unawaited(
      service.handle(
        Uri.parse('https://x.app/dalili/construction-detailing-12554857'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.asked, ['12554857']);
    expect(find.text('BOOK Construction detailing'), findsOneWidget);

    // Back returns to where the reader was.
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('the name in the link is ignored — only the BibID counts', (
    tester,
  ) async {
    await pumpApp(tester);

    unawaited(
      service.handle(
        Uri.parse('https://x.app/dalili/an-old-wrong-title-12554857'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BOOK Construction detailing'), findsOneWidget);
  });

  testWidgets('a link that is not a book link does nothing', (tester) async {
    await pumpApp(tester);

    await service.handle(Uri.parse('https://x.app/somewhere/else'));
    await service.handle(Uri.parse('https://x.app/dalili'));
    await tester.pumpAndSettle();

    expect(repo.asked, isEmpty);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('an unknown BibID says so instead of opening anything', (
    tester,
  ) async {
    await pumpApp(tester);

    await service.handle(Uri.parse('https://x.app/dalili/ghost-99999'));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('a network failure is reported, and the link can be retried', (
    tester,
  ) async {
    await pumpApp(tester);
    repo.failWith = Exception('offline');
    final uri = Uri.parse(
      'https://x.app/dalili/construction-detailing-12554857',
    );

    await service.handle(uri);
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('home'), findsOneWidget);

    // Back online: the very same link now works.
    repo.failWith = null;
    unawaited(service.handle(uri));
    await tester.pumpAndSettle();
    expect(find.text('BOOK Construction detailing'), findsOneWidget);
  });
}
