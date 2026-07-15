import 'package:dalili/core/di/injection_container.dart';
import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:dalili/features/library/presentation/cubits/favorites/favorites_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/favorites/favorites_state.dart';
import 'package:dalili/features/library/presentation/widgets/book_card.dart';
import 'package:dalili/features/library/presentation/widgets/state_widgets/empty_widget.dart';
import 'package:dalili/features/library/presentation/widgets/state_widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(AppLocalizations.favorites),
      backgroundColor: context.colors.surface,
      elevation: 0,
    ),
    backgroundColor: context.colors.surface,
    body: BlocBuilder<FavoritesCubit, FavoritesState>(
      bloc: sl<FavoritesCubit>(),
      builder: (context, state) {
        if (state.status == FavoritesStatus.loading) {
          return const BookListSkeleton();
        }
        if (state.favorites.isEmpty) {
          return EmptyWidget(message: AppLocalizations.noFavorites);
        }
        return ListView.builder(
          itemCount: state.favorites.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final book = state.favorites[index];
            return Dismissible(
              key: ValueKey(book.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => sl<FavoritesCubit>().removeFavorite(book.id),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: BookCard(book: book, key: ValueKey(book.id)),
            );
          },
        );
      },
    ),
  );
}
