import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:equatable/equatable.dart';

enum ScannerStatus { scanning, loading, found, notFound, error }

class ScannerState extends Equatable {
  const ScannerState({
    this.status = ScannerStatus.scanning,
    this.book,
    this.errorMessage = '',
    this.scannedCode = '',
  });

  final ScannerStatus status;
  final Book? book;
  final String errorMessage;

  /// The barcode that was read, kept so the not-found screen can show it —
  /// a librarian needs the number to look the book up or fix its record.
  /// Empty when the lookup did not come from a barcode.
  final String scannedCode;

  ScannerState copyWith({
    ScannerStatus? status,
    Book? book,
    String? errorMessage,
    String? scannedCode,
  }) => ScannerState(
    status: status ?? this.status,
    book: book ?? this.book,
    errorMessage: errorMessage ?? this.errorMessage,
    scannedCode: scannedCode ?? this.scannedCode,
  );

  @override
  List<Object?> get props => [status, book, errorMessage, scannedCode];
}
