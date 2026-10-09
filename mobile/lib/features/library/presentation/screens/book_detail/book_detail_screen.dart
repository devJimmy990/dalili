import 'package:dalili/core/constants/app_spacing.dart';
import 'package:dalili/core/utils/display.dart';
import 'package:dalili/core/di/injection_container.dart';
import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:dalili/features/library/presentation/cubits/book_detail/book_detail_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/favorites/favorites_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/favorites/favorites_state.dart';
import 'package:dalili/features/library/presentation/screens/articles/articles_screen.dart';
import 'package:dalili/features/library/presentation/widgets/book_info_rows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dalili/features/library/presentation/screens/navigation/navigation_screen.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) => BlocProvider<BookDetailCubit>(
    create: (_) => sl<BookDetailCubit>()..loadBook(book),
    child: _BookDetailView(book: book),
  );
}

class _BookDetailView extends StatelessWidget {
  const _BookDetailView({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) => Scaffold(
    extendBodyBehindAppBar: true,
    backgroundColor: context.appTheme.hero,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        BlocBuilder<FavoritesCubit, FavoritesState>(
          bloc: sl<FavoritesCubit>(),
          builder: (context, _) {
            final isFav = sl<FavoritesCubit>().isFavorite(book.id);
            return IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
              onPressed: () {
                if (isFav) {
                  sl<FavoritesCubit>().removeFavorite(book.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.removedFromFavorites),
                    ),
                  );
                } else {
                  sl<FavoritesCubit>().addFavorite(book);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.addedToFavorites)),
                  );
                }
              },
            );
          },
        ),
      ],
    ),
    // One scrolling column, not a fixed cover above a scrolling panel: the
    // cover used to hold 40% of the screen permanently, pushing the two
    // things a visitor standing in the library actually needs — where the
    // book is, and the button that walks them there — below the fold.
    body: Stack(
      fit: StackFit.expand,
      children: [
        _BackgroundImage(book.cover),
        Container(color: Colors.black54),
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.stackMd,
                  ),
                  child: _BookCover(book.cover),
                ),
                _DetailCard(book: book),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage(this.url);

  final String? url;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    if (url == null || url.isEmpty) {
      return Container(color: context.appTheme.hero);
    }
    return Image.network(
      url,
      fit: BoxFit.fill,
      errorBuilder: (_, __, ___) => Container(color: context.appTheme.hero),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover(this.url);

  final String? url;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(context.appTheme.radiusMd),
      boxShadow: const [
        BoxShadow(color: Colors.black45, blurRadius: 24, offset: Offset(0, 10)),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(context.appTheme.radiusMd),
      child: hasText(url)
          ? Image.network(
              url!,
              height: 150,
              width: 103,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(context),
            )
          : _placeholder(context),
    ),
  );

  Widget _placeholder(BuildContext context) => Container(
    height: 150,
    width: 103,
    color: context.appTheme.surfaceContainerHigh,
    child: Icon(
      Icons.menu_book_rounded,
      size: 64,
      color: context.colors.secondary,
    ),
  );
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(context.appTheme.radiusXl),
      topRight: Radius.circular(context.appTheme.radiusXl),
    ),
    // A solid panel, not a see-through blur: the text color is chosen for
    // this color, so it must not change with the cover or camera behind it.
    child: Container(
      color: bookInfoPanelColor(context),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.stackLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              book.title,
              style: context.textStyles.displayMedium?.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.stackSm),
            Text(
              book.author,
              style: context.textStyles.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            Divider(
              color: context.appTheme.outlineVariant,
              height: AppSpacing.stackLg,
            ),
            // Where it is, then how to get there — both reachable without
            // scrolling. The publishing data follows further down.
            BookFindItRows(book: book),
            const SizedBox(height: AppSpacing.stackMd),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.directions_walk),
                label: Text(AppLocalizations.navigateToBook),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appTheme.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      context.appTheme.radiusLg,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                // Disabled when the book's section has no node on the
                // library map — there is nowhere to route to.
                onPressed: !book.location.isNavigable
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => NavigationScreen(
                            destinationNodeId: book.location.nodeId,
                            destinationShelfLabel: book.shelfLabel,
                          ),
                        ),
                      ),
              ),
            ),
            if (!book.location.isNavigable) ...[
              const SizedBox(height: AppSpacing.stackSm),
              Text(
                AppLocalizations.navDestinationUnavailable,
                style: context.textStyles.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.stackMd),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.link),
                label: Text(AppLocalizations.relatedArticles),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      context.appTheme.radiusLg,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: book.articles.isEmpty
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              ArticlesScreen(articles: book.articles),
                        ),
                      ),
              ),
            ),
            Divider(
              color: context.appTheme.outlineVariant,
              height: AppSpacing.stackLg,
            ),
            BookPublishingRows(book: book),
            const SizedBox(height: AppSpacing.stackMd),
            Text(
              AppLocalizations.scanHintBottom,
              style: context.textStyles.bodySmall?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.stackMd),
          ],
        ),
      ),
    ),
  );
}
