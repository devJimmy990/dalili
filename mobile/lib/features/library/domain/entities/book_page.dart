import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:equatable/equatable.dart';

/// One page of books together with the cursor the API returned, so a screen
/// can decide whether to ask for more.
class BookPage extends Equatable {
  const BookPage({
    required this.books,
    required this.total,
    required this.page,
    required this.hasMore,
  });

  const BookPage.empty()
    : books = const [],
      total = 0,
      page = 1,
      hasMore = false;

  final List<Book> books;

  /// Total matches on the server, not the length of [books].
  final int total;
  final int page;
  final bool hasMore;

  bool get isEmpty => books.isEmpty;

  @override
  List<Object?> get props => [books, total, page, hasMore];
}
