import 'dart:async';

import 'package:dalili/core/errors/failures.dart';
import 'package:dalili/features/library/data/models/book_model.dart';
import 'package:dalili/features/library/domain/repositories/library_repository.dart';
import 'package:dalili/features/library/presentation/cubits/search/search_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SearchCubit extends HydratedCubit<SearchState> {
  SearchCubit(this._repository) : super(const SearchState());

  final LibraryRepository _repository;
  Timer? _debounce;

  void search(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      emit(state.copyWith(
          status: SearchStatus.initial, query: '', results: []));
      return;
    }
    emit(state.copyWith(status: SearchStatus.loading, query: query));
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await _repository.searchBooks(query);
        emit(state.copyWith(
          status:
              results.isEmpty ? SearchStatus.empty : SearchStatus.success,
          results: results,
        ));
      } on Failure catch (f) {
        emit(state.copyWith(
            status: SearchStatus.error, errorMessage: f.message));
      }
    });
  }

  void setFilter(SearchFilter filter) =>
      emit(state.copyWith(filter: filter));

  void clearSearch() {
    _debounce?.cancel();
    emit(const SearchState());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  @override
  SearchState? fromJson(Map<String, dynamic> json) {
    final list = json['results'] as List? ?? [];
    return SearchState(
      status: SearchStatus.initial,
      query: json['query'] as String? ?? '',
      results: list
          .map((e) => BookModel.fromJson(e as Map<dynamic, dynamic>))
          .toList(),
      filter: SearchFilter.values[json['filter'] as int? ?? 0],
    );
  }

  @override
  Map<String, dynamic>? toJson(SearchState state) => {
        'query': state.query,
        'results': state.results
            .map((b) => (b as BookModel).toJson())
            .toList(),
        'filter': state.filter.index,
      };
}
