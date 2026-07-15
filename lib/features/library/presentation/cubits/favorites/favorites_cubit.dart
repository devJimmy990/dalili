import 'dart:async';

import 'package:dalili/features/library/data/models/book_model.dart';
import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:dalili/features/library/domain/repositories/library_repository.dart';
import 'package:dalili/features/library/presentation/cubits/app_settings/app_settings_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/favorites/favorites_state.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class FavoritesCubit extends HydratedCubit<FavoritesState> {
  FavoritesCubit(this._repository, this._settingsCubit)
      : super(const FavoritesState()) {
    _lastLocale = _settingsCubit.state.locale;
    _localeSubscription = _settingsCubit.stream.listen((settings) {
      if (settings.locale != _lastLocale) {
        _lastLocale = settings.locale;
        refreshFavorites();
      }
    });
  }

  final LibraryRepository _repository;
  final AppSettingsCubit _settingsCubit;
  late final StreamSubscription _localeSubscription;
  late Locale _lastLocale;

  void addFavorite(Book book) {
    if (isFavorite(book.id)) return;
    final updated = [...state.favorites, book];
    emit(state.copyWith(
      favorites: updated,
      status: FavoritesStatus.success,
    ));
  }

  void removeFavorite(String id) {
    final updated = state.favorites.where((b) => b.id != id).toList();
    emit(state.copyWith(
      favorites: updated,
      status: updated.isEmpty ? FavoritesStatus.empty : FavoritesStatus.success,
    ));
  }

  bool isFavorite(String id) => state.favorites.any((b) => b.id == id);

  Future<void> refreshFavorites() async {
    if (state.favorites.isEmpty) return;
    final ids = state.favorites.map((b) => b.id).toList();
    emit(state.copyWith(status: FavoritesStatus.loading));
    try {
      final updated = await _repository.getBooksByIds(ids);
      emit(state.copyWith(
        favorites: updated,
        status: updated.isEmpty ? FavoritesStatus.empty : FavoritesStatus.success,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: state.favorites.isEmpty ? FavoritesStatus.empty : FavoritesStatus.success,
      ));
    }
  }

  @override
  Future<void> close() {
    _localeSubscription.cancel();
    return super.close();
  }

  @override
  FavoritesState? fromJson(Map<String, dynamic> json) {
    final list = json['favorites'] as List? ?? [];
    final favorites = list
        .map((e) => BookModel.fromJson(e as Map<dynamic, dynamic>))
        .toList();
    return FavoritesState(
      status: favorites.isEmpty ? FavoritesStatus.empty : FavoritesStatus.success,
      favorites: favorites,
    );
  }

  @override
  Map<String, dynamic>? toJson(FavoritesState state) => {
        'favorites': state.favorites
            .map((b) => (b as BookModel).toJson())
            .toList(),
      };
}
