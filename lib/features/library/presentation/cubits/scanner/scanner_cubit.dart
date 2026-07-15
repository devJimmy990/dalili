import 'package:dalili/core/errors/failures.dart';
import 'package:dalili/features/library/domain/repositories/library_repository.dart';
import 'package:dalili/features/library/presentation/cubits/scanner/scanner_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ScannerCubit extends HydratedCubit<ScannerState> {
  ScannerCubit(this._repository) : super(const ScannerState());

  final LibraryRepository _repository;
  bool _isProcessing = false;

  static const String _testId = '11797998';

  Future<void> onBarcodeDetected(String? rawValue) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final id = (rawValue != null && rawValue.trim().isNotEmpty)
        ? rawValue.trim()
        : _testId;

    emit(state.copyWith(status: ScannerStatus.loading));
    try {
      final book = await _repository.getBookById(id);
      if (book == null) {
        emit(state.copyWith(status: ScannerStatus.notFound));
      } else {
        emit(state.copyWith(status: ScannerStatus.found, book: book));
      }
    } on Failure catch (f) {
      emit(state.copyWith(
          status: ScannerStatus.error, errorMessage: f.message));
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
