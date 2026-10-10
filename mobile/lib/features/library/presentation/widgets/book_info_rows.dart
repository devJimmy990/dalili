import 'package:dalili/core/constants/app_spacing.dart';
import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:dalili/core/utils/display.dart';
import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      BookInfoRow(
        AppLocalizations.bibid,
        book.id,
        code: true,
        trailing: _CopyButton(text: book.id),
      ),
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

/// Solid panel colour for the cards that hold book rows. Follows the theme: a
/// light card in the light theme, a dark one in the dark theme, with
/// [BookInfoRow]'s text drawn from the matching on-surface colours.
Color bookInfoPanelColor(BuildContext context) =>
    context.appTheme.surfaceContainerLow;

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
    this.trailing,
  });

  final String label;
  final String? value;
  final IconData? icon;

  /// Call numbers and ISBNs are Latin codes: they read left-to-right even
  /// inside an Arabic layout, so "621.31042.K E" is never reordered.
  final bool code;

  /// The location line is what a visitor came for — it gets the accent color.
  final bool emphasized;

  /// An action at the end of the row, such as a copy button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    if (!hasText(value)) return const SizedBox.shrink();
    final onPanel = context.colors.onSurface;
    final labelColor = context.appTheme.onSurfaceVariant;

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
                if (icon != null)
                  Icon(icon, size: 16, color: context.colors.secondary),
                Flexible(
                  child: Text(
                    label,
                    style: context.textStyles.labelLarge?.copyWith(
                      color: labelColor,
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
          ?trailing,
        ],
      ),
    );
  }
}

/// Copies [text] and says so. Compact, so it fits at the end of a row without
/// making that row taller than its neighbours.
class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 32,
    height: 24,
    child: IconButton(
      tooltip: AppLocalizations.copyBibid,
      padding: EdgeInsets.zero,
      iconSize: 18,
      visualDensity: VisualDensity.compact,
      color: context.colors.secondary,
      icon: const Icon(Icons.copy_rounded),
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        await Clipboard.setData(ClipboardData(text: text));
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.bibidCopied),
              duration: const Duration(seconds: 2),
            ),
          );
      },
    ),
  );
}
