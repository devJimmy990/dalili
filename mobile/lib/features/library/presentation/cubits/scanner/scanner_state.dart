import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:equatable/equatable.dart';

enum ScannerStatus { scanning, loading, found, notFound, error }

class ScannerState extends Equatable {
  const ScannerState({
    this.status = ScannerStatus.scanning,
    this.book,
    this.errorMessage = '',
  });

  final ScannerStatus status;
  final Book? book;
  final String errorMessage;

  ScannerState copyWith({
    ScannerStatus? status,
    Book? book,
    String? errorMessage,
  }) =>
      ScannerState(
        status: status ?? this.status,
        book: book ?? this.book,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, book, errorMessage];
}
