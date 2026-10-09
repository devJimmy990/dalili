import 'package:dalili/core/errors/failures.dart';
import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:dalili/features/library/domain/repositories/library_repository.dart';
import 'package:dalili/features/library/presentation/cubits/scanner/scanner_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:dalili/core/utils/safe_emit.dart';

class ScannerCubit extends HydratedCubit<ScannerState>
    with SafeEmit<ScannerState> {
  ScannerCubit(this._repository) : super(const ScannerState());

  final LibraryRepository _repository;
  bool _isProcessing = false;

  /// Looks a scanned barcode up by the book's own id — never by its BibID,
  /// which is a different identifier meant for searching.
  ///
  /// A barcode that decodes to nothing is not a scan: it is ignored rather
  /// than being answered with some default book.
  Future<void> onBarcodeDetected(String? rawValue) async {
    final id = rawValue?.trim();
    if (id == null || id.isEmpty) return;

    await _lookUp(() => _repository.getBookById(id));
  }

  /// Development aid behind the scanner's debug-only button: opens the first
  /// book in the catalogue, so the found/not-found screens can be exercised
  /// without a printed barcode. Asks the catalogue instead of naming an id,
  /// so it keeps working however the ids are issued.
  Future<void> scanSample() => _lookUp(() async {
    final page = await _repository.getAllBooks();
    return page.books.firstOrNull;
  });

  Future<void> _lookUp(Future<Book?> Function() find) async {
    if (_isProcessing) return;
    _isProcessing = true;

    emit(state.copyWith(status: ScannerStatus.loading));
    try {
      final book = await find();
      if (book == null) {
        emit(state.copyWith(status: ScannerStatus.notFound));
      } else {
        emit(state.copyWith(status: ScannerStatus.found, book: book));
      }
    } on Failure catch (f) {
      emit(
        state.copyWith(status: ScannerStatus.error, errorMessage: f.message),
      );
    } finally {
      _isProcessing = false;
    }
  }

  void reset() {
    _isProcessing = false;
    emit(const ScannerState());
  }

  @override
  ScannerState? fromJson(Map<String, dynamic> json) => null;

  @override
  Map<String, dynamic>? toJson(ScannerState state) => null;
}
