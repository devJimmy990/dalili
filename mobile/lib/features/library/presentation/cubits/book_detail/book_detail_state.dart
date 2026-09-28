import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:equatable/equatable.dart';

enum BookDetailStatus { initial, loaded }

class BookDetailState extends Equatable {
  const BookDetailState({
    this.status = BookDetailStatus.initial,
    this.book,
  });

  final BookDetailStatus status;
  final Book? book;

  BookDetailState copyWith({BookDetailStatus? status, Book? book}) =>
      BookDetailState(
        status: status ?? this.status,
        book: book ?? this.book,
      );

  @override
  List<Object?> get props => [status, book];
}
