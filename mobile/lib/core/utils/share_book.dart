import 'package:dalili/core/utils/book_link.dart';
import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Where shared links point. This host must be the one the Android manifest
/// declares for App Links (see android/app/build.gradle.kts), or a tapped link
/// opens in the browser instead of the app.
String get shareOrigin {
  final configured = dotenv.maybeGet('SHARE_BASE_URL')?.trim();
  return (configured == null || configured.isEmpty)
      ? 'https://dalili-e0qh.onrender.com'
      : configured;
}

/// The link for [book].
Uri linkFor(Book book) => bookUri(shareOrigin, book.title, book.id);

/// The text that goes into the share sheet: the title, who wrote it, where it
/// sits in the library, and the link — enough to be useful even to someone who
/// never opens it. [intro] is the localized lead-in line.
String shareMessage(Book book, {required String intro}) {
  final lines = <String>[
    intro,
    '',
    book.title,
    if (book.author.isNotEmpty) book.author,
    if (book.locationLabel != null) book.locationLabel!,
    '',
    linkFor(book).toString(),
  ];
  return lines.join('\n');
}
