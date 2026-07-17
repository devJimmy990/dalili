import 'package:dalili/features/library/data/models/book_model.dart';
import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:dalili/features/library/presentation/cubits/book_detail/book_detail_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class BookDetailCubit extends HydratedCubit<BookDetailState> {
  BookDetailCubit() : super(const BookDetailState());

  void loadBook(Book book) =>
      emit(state.copyWith(status: BookDetailStatus.loaded, book: book));

  @override
  BookDetailState? fromJson(Map<String, dynamic> json) {
    final bookJson = json['book'] as Map<String, dynamic>?;
    if (bookJson == null) return const BookDetailState();
    return BookDetailState(
      status: BookDetailStatus.loaded,
      book: BookModel.fromJson(bookJson),
    );
  }

  @override
  Map<String, dynamic>? toJson(BookDetailState state) => {
    'book': state.book != null ? (state.book! as BookModel).toJson() : null,
  };
}
