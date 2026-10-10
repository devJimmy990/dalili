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
  _FakeRepository(this._byAccessionNumber);

  /// Books by the number on their barcode label — the only key a scan may
  /// use. Their BibIDs (their ids) are deliberately absent from this map.
  final Map<String, Book> _byAccessionNumber;
  final List<String> askedFor = [];

  @override
  Future<Book?> getBookByAccessionNumber(String number) async {
    askedFor.add(number);
    return _byAccessionNumber[number];
  }

  @override
  Future<BookPage> getAllBooks({int page = 1}) async => BookPage(
    books: _byAccessionNumber.values.toList(),
    total: _byAccessionNumber.length,
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

Book _book({required String id}) => BookModel.fromJson({
  'id': id,
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
    // The book's id is its BibID; the label on it says 1415.
    repository = _FakeRepository({'1415': _book(id: '555001')});
    cubit = ScannerCubit(repository);
  });

  tearDown(() => cubit.close());

  test('a scanned label number opens that book', () async {
    await cubit.onBarcodeDetected('1415');

    expect(cubit.state.status, ScannerStatus.found);
    // The book comes back under its BibID, not under the number scanned.
    expect(cubit.state.book?.id, '555001');
  });

  test('surrounding whitespace in the barcode is ignored', () async {
    await cubit.onBarcodeDetected('  1415\n');

    expect(cubit.state.status, ScannerStatus.found);
    expect(repository.askedFor, ['1415']);
  });

  test('a BibID is not a scannable number', () async {
    // 555001 is this book's BibID. A scan looks at label numbers only, so it
    // is reported as unknown rather than matched through the BibID.
    await cubit.onBarcodeDetected('555001');

    expect(cubit.state.status, ScannerStatus.notFound);
  });

  test('detections are ignored while a result is on screen', () async {
    // The camera reports the same barcode for as long as it is in view. With
    // the "not found" screen showing, each report used to restart the lookup
    // and knock it back to loading.
    await cubit.onBarcodeDetected('99999');
    expect(cubit.state.status, ScannerStatus.notFound);
    final asked = repository.askedFor.length;

    await cubit.onBarcodeDetected('99999');
    await cubit.onBarcodeDetected('1415');

    expect(cubit.state.status, ScannerStatus.notFound);
    expect(cubit.state.scannedCode, '99999');
    expect(repository.askedFor, hasLength(asked));
  });

  test('scanning resumes after the screen is dismissed', () async {
    await cubit.onBarcodeDetected('99999');
    cubit.reset();

    await cubit.onBarcodeDetected('1415');

    expect(cubit.state.status, ScannerStatus.found);
  });

  test('a not-found scan keeps the number that was read', () async {
    // The not-found screen shows it, so the book can be looked up by hand.
    await cubit.onBarcodeDetected('  99999 ');

    expect(cubit.state.status, ScannerStatus.notFound);
    expect(cubit.state.scannedCode, '99999');
  });

  test('a BibID scanned as a label number is reported as read', () async {
    // The reader sees exactly what was scanned, which is how they notice a
    // BibID was scanned where a label number was expected.
    await cubit.onBarcodeDetected('555001');

    expect(cubit.state.status, ScannerStatus.notFound);
    expect(cubit.state.scannedCode, '555001');
  });

  test('a number from an earlier scan never leaks into a later one', () async {
    await cubit.onBarcodeDetected('99999');
    expect(cubit.state.scannedCode, '99999');

    cubit.reset(); // the reader taps "scan again"
    await cubit.onBarcodeDetected('1415');
    expect(cubit.state.status, ScannerStatus.found);
    expect(cubit.state.scannedCode, '1415');

    cubit.reset();
    expect(cubit.state.scannedCode, isEmpty);
  });

  test('the sample scan has no number to report', () async {
    await cubit.onBarcodeDetected('99999');
    await cubit.scanSample();

    expect(cubit.state.scannedCode, isEmpty);
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
    'the debug sample scan finds a real book without naming a number',
    () async {
      await cubit.scanSample();

      expect(cubit.state.status, ScannerStatus.found);
      expect(cubit.state.book, isNotNull);
      expect(repository.askedFor, isEmpty);
    },
  );
}
