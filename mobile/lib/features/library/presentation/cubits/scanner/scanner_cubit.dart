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

  /// Looks a scanned barcode up by the accession number printed on the label
  /// — never by the BibID, which is a different number meant for searching.
  ///
  /// A barcode that decodes to nothing is not a scan: it is ignored rather
  /// than being answered with some default book.
  Future<void> onBarcodeDetected(String? rawValue) async {
    final number = rawValue?.trim();
    if (number == null || number.isEmpty) return;

    await _lookUp(() => _repository.getBookByAccessionNumber(number));
  }

  /// Development aid behind the scanner's debug-only button: opens the first
  /// book in the catalogue, so the found/not-found screens can be exercised
  /// without a printed barcode. Asks the catalogue instead of naming a
  /// number, so it keeps working whichever books have labels.
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
