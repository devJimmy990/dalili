import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:equatable/equatable.dart';

enum FavoritesStatus { initial, loading, success, empty }

class FavoritesState extends Equatable {
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const [],
  });

  final FavoritesStatus status;
  final List<Book> favorites;

  FavoritesState copyWith({FavoritesStatus? status, List<Book>? favorites}) =>
      FavoritesState(
        status: status ?? this.status,
        favorites: favorites ?? this.favorites,
      );

  @override
  List<Object?> get props => [status, favorites];
}
