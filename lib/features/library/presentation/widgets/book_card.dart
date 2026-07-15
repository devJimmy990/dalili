import 'package:dalili/core/constants/app_spacing.dart';
import 'package:dalili/core/extensions/navigation.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:dalili/features/library/presentation/screens/book_detail/book_detail_screen.dart';
import 'package:dalili/features/library/presentation/widgets/cover_image.dart';
import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) => Card(
    color: context.appTheme.surfaceContainerLow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(context.appTheme.radiusMd),
    ),
    elevation: 1,
    margin: const EdgeInsets.symmetric(
      horizontal: AppSpacing.containerMargin,
      vertical: AppSpacing.stackSm / 2,
    ),
    child: InkWell(
      onTap: () => context.push(BookDetailScreen(book: book)),
      borderRadius: BorderRadius.circular(context.appTheme.radiusMd),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.stackMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CoverImage(
              url: book.cover,
              width: 80,
              height: 110,
              radius: context.appTheme.radiusMd,
            ),
            const SizedBox(width: AppSpacing.gutter),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: context.textStyles.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.appTheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${book.publisher} • ${book.year}',
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.appTheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: context.colors.secondary,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${book.location} - ${book.shelf}',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
