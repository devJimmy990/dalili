import 'package:dalili/features/library/data/models/book_model.dart';
import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:dalili/features/library/domain/entities/book_page.dart';
import 'package:dalili/features/library/domain/entities/department.dart';
import 'package:dalili/features/library/domain/repositories/library_repository.dart';
import 'package:dalili/features/library/presentation/cubits/scanner/scanner_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/scanner/scanner_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class _FakeRepository implements LibraryRepository {
  _FakeRepository(this._books);

  /// Books by their own id — the only key a scan may use.
  final Map<String, Book> _books;
  final List<String> askedFor = [];

  @override
  Future<Book?> getBookById(String id) async {
    askedFor.add(id);
    return _books[id];
  }

  @override
  Future<BookPage> getAllBooks({int page = 1}) async => BookPage(
    books: _books.values.toList(),
    total: _books.length,
    page: 1,
    hasMore: false,
  );

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

/// HydratedBloc insists on a storage; nothing here needs it to persist.
class _MemoryStorage implements Storage {
  final _data = <String, dynamic>{};

  @override
  dynamic read(String key) => _data[key];

  @override
  Future<void> write(String key, dynamic value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);

  @override
  Future<void> clear() async => _data.clear();

  @override
  Future<void> close() async {}
}

Book _book({required String id, required String bibid}) => BookModel.fromJson({
  'id': id,
  'bibid': bibid,
  'callNumber': '621.3',
  'title': 'A Book',
  'author': 'An Author',
  'department': {'id': 'd_electrical', 'name': 'كهرباء'},
  'location': {'nodeId': 'd_electrical', 'name': 'كهرباء'},
});

void main() {
  setUpAll(() => HydratedBloc.storage = _MemoryStorage());

  late _FakeRepository repository;
  late ScannerCubit cubit;

  setUp(() {
    repository = _FakeRepository({'BK-1': _book(id: 'BK-1', bibid: '555001')});
    cubit = ScannerCubit(repository);
  });

  tearDown(() => cubit.close());

  test('a scanned id opens that book', () async {
    await cubit.onBarcodeDetected('BK-1');

    expect(cubit.state.status, ScannerStatus.found);
    expect(cubit.state.book?.id, 'BK-1');
  });

  test('surrounding whitespace in the barcode is ignored', () async {
    await cubit.onBarcodeDetected('  BK-1\n');

    expect(cubit.state.status, ScannerStatus.found);
    expect(repository.askedFor, ['BK-1']);
  });

  test('a BibID is not a scannable id', () async {
    // 555001 is this book's catalogue number. Scanning must look at ids
    // only, so it is reported as unknown rather than matched via the BibID.
    await cubit.onBarcodeDetected('555001');

    expect(cubit.state.status, ScannerStatus.notFound);
  });

  test('an unknown barcode is reported as not found', () async {
    await cubit.onBarcodeDetected('NOPE');

    expect(cubit.state.status, ScannerStatus.notFound);
    expect(cubit.state.book, isNull);
  });

  test('a barcode that decodes to nothing is ignored, not answered', () async {
    // This used to fall back to a hardcoded test book, so a failed read
    // looked like a successful scan of the wrong title.
    await cubit.onBarcodeDetected(null);
    await cubit.onBarcodeDetected('');
    await cubit.onBarcodeDetected('   ');

    expect(cubit.state.status, ScannerStatus.scanning);
    expect(repository.askedFor, isEmpty);
  });

  test(
    'the debug sample scan finds a real book without naming an id',
    () async {
      await cubit.scanSample();

      expect(cubit.state.status, ScannerStatus.found);
      expect(cubit.state.book, isNotNull);
      expect(repository.askedFor, isEmpty);
    },
  );
}
