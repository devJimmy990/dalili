import 'package:dalili/core/constants/app_spacing.dart';
import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:dalili/core/utils/display.dart';
import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:flutter/material.dart';

/// The book's catalogue data as two labelled groups — what was published,
/// then where to find it — for the dark detail cards.
///
/// Colors come from [AppThemeExtension.onHero] over a [AppThemeExtension.hero]
/// panel (see [bookInfoPanelColor]), never from whatever sits behind the
/// card, so the text stays readable over any cover image or camera frame.
class BookInfoRows extends StatelessWidget {
  const BookInfoRows({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      BookPublishingRows(book: book),
      Divider(
        color: context.appTheme.onHero.withValues(alpha: .24),
        height: AppSpacing.stackLg,
      ),
      BookFindItRows(book: book),
    ],
  );
}

/// Where the book physically is. Split out of [BookInfoRows] so the detail
/// screen can put it first, above the publishing data — someone standing in
/// the stacks needs the shelf before they need the publisher.
class BookFindItRows extends StatelessWidget {
  const BookFindItRows({super.key, required this.book});

  final Book book;

  /// "قسم كهرباء، الرف 31". Payloads cached before the API sent the label
  /// have none, so rebuild it from the parts rather than hiding the shelf.
  static String? locationOf(Book book) =>
      book.locationLabel ??
      joinParts([book.location.name, book.shelfLabel], separator: '، ');

  @override
  Widget build(BuildContext context) => Column(
    children: [
      BookInfoRow(
        AppLocalizations.shelfLocation,
        locationOf(book),
        icon: Icons.location_on,
        emphasized: true,
      ),
      BookInfoRow(AppLocalizations.callNumber, book.callNumber, code: true),
      // Hidden by the row itself when a cached book predates the field.
      BookInfoRow(AppLocalizations.bibid, book.bibid, code: true),
      BookInfoRow(AppLocalizations.isbn, book.isbn, code: true),
    ],
  );
}

/// Publication data — useful for citing the book, not for finding it.
class BookPublishingRows extends StatelessWidget {
  const BookPublishingRows({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      BookInfoRow(AppLocalizations.publisher, book.publisher),
      BookInfoRow(AppLocalizations.placeOfPublication, book.place?.name),
      BookInfoRow(AppLocalizations.year, book.year?.toString()),
      BookInfoRow(AppLocalizations.edition, book.editionLabel),
      BookInfoRow(AppLocalizations.bookLanguage, book.language),
    ],
  );
}

/// Solid panel color for cards that hold [BookInfoRows].
Color bookInfoPanelColor(BuildContext context) => context.appTheme.hero;

/// A label/value line that renders nothing when the catalogue has no
/// value — most book fields are optional, and a blank row reads as a bug.
class BookInfoRow extends StatelessWidget {
  const BookInfoRow(
    this.label,
    this.value, {
    super.key,
    this.icon,
    this.code = false,
    this.emphasized = false,
  });

  final String label;
  final String? value;
  final IconData? icon;

  /// Call numbers and ISBNs are Latin codes: they read left-to-right even
  /// inside an Arabic layout, so "621.31042.K E" is never reordered.
  final bool code;

  /// The location line is what a visitor came for — it gets the accent color.
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    if (!hasText(value)) return const SizedBox.shrink();
    final onPanel = context.appTheme.onHero;

    final text = Text(
      value!,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: context.textStyles.bodyMedium?.copyWith(
        color: onPanel,
        fontWeight: emphasized ? FontWeight.w700 : null,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.stackSm,
        children: [
          SizedBox(
            width: 104,
            child: Row(
              spacing: 4,
              children: [
                if (icon != null) Icon(icon, size: 16, color: onPanel),
                Flexible(
                  child: Text(
                    label,
                    style: context.textStyles.labelLarge?.copyWith(
                      color: onPanel.withValues(alpha: .72),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            // Align resolves against the app's direction, so values start on
            // the reading edge; only the text itself is forced LTR for codes.
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: code
                  ? Directionality(
                      textDirection: TextDirection.ltr,
                      child: text,
                    )
                  : text,
            ),
          ),
        ],
      ),
    );
  }
}
