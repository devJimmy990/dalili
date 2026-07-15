import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:equatable/equatable.dart';

enum SearchStatus { initial, loading, success, empty, error }

enum SearchFilter { all, books, articles }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.results = const [],
    this.filter = SearchFilter.all,
    this.errorMessage = '',
  });

  final SearchStatus status;
  final String query;
  final List<Book> results;
  final SearchFilter filter;
  final String errorMessage;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<Book>? results,
    SearchFilter? filter,
    String? errorMessage,
  }) =>
      SearchState(
        status: status ?? this.status,
        query: query ?? this.query,
        results: results ?? this.results,
        filter: filter ?? this.filter,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, query, results, filter, errorMessage];
}
