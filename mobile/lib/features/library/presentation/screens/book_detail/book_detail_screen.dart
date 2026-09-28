import 'dart:ui';

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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    backgroundColor: context.colors.primary,
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
    body: Stack(
      fit: StackFit.expand,
      children: [
        _BackgroundImage(book.cover),
        Container(color: Colors.black54),
        SafeArea(
          child: Column(
            children: [
              Expanded(flex: 2, child: Center(child: _BookCover(book.cover))),
              Expanded(flex: 3, child: _DetailCard(book: book)),
            ],
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
      return Container(color: context.colors.primary);
    }
    return Image.network(
      url,
      fit: BoxFit.fill,
      errorBuilder: (_, __, ___) => Container(color: context.colors.primary),
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
              height: 190,
              width: 130,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(context),
            )
          : _placeholder(context),
    ),
  );

  Widget _placeholder(BuildContext context) => Container(
    height: 190,
    width: 130,
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
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        decoration: BoxDecoration(
          color: context.appTheme.surfaceContainerHigh.withValues(alpha: .2),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(context.appTheme.radiusXl),
            topRight: Radius.circular(context.appTheme.radiusXl),
          ),
        ),
        child: SingleChildScrollView(
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
              _InfoRow(AppLocalizations.publisher, book.publisher),
              _InfoRow(AppLocalizations.year, book.year?.toString()),
              _InfoRow(AppLocalizations.edition, book.editionLabel),
              _InfoRow(AppLocalizations.bookLanguage, book.language),
              _InfoRow(
                AppLocalizations.classification,
                joinParts([
                  book.location.name,
                  book.shelfLabel,
                ], separator: ' - '),
                icon: Icons.location_on,
              ),
              _InfoRow(AppLocalizations.callNumber, book.callNumber),
              _InfoRow(AppLocalizations.department, book.department.name),
              _InfoRow(AppLocalizations.isbn, book.isbn),
              Divider(
                color: context.appTheme.outlineVariant,
                height: AppSpacing.stackLg,
              ),
              const SizedBox(height: AppSpacing.stackMd),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.link),
                  label: Text(AppLocalizations.relatedArticles),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.secondary,
                    foregroundColor: Colors.white,
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
    ),
  );
}

/// A label/value line that renders nothing when the catalogue has no
/// value — most book fields are optional, and a blank row reads as a bug.
class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.icon});

  final String label;
  final String? value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (!hasText(value)) return const SizedBox.shrink();
    return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      spacing: AppSpacing.stackSm,
      children: [
        Text(
          label,
          style: context.textStyles.labelLarge?.copyWith(
            color: context.appTheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value!,
              maxLines: 1,
              // softWrap: false,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
    );
  }
}
