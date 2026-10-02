import 'package:dalili/features/library/domain/entities/article.dart';
import 'package:dalili/features/library/domain/entities/book_location.dart';
import 'package:dalili/features/library/domain/entities/department.dart';
import 'package:dalili/features/library/domain/entities/place_ref.dart';
import 'package:equatable/equatable.dart';

/// A catalogued book.
///
/// Only the fields a book cannot exist without are non-null: [id],
/// [callNumber], [title], [author], [department] and [location]. Everything
/// else is optional in the catalogue and arrives as null when unknown —
/// the UI hides those rows rather than printing an empty value.
class Book extends Equatable {
  const Book({
    required this.id,
    required this.callNumber,
    required this.title,
    required this.author,
    required this.department,
    required this.location,
    required this.articles,
    this.edition,
    this.editionLabel,
    this.publisher,
    this.place,
    this.year,
    this.subjects,
    this.shelf,
    this.shelfLabel,
    this.locationLabel,
    this.language,
    this.cover,
    this.isbn,
  });

  final String id;

  /// Dewey-style code printed on the spine.
  final String callNumber;
  final String title;
  final String author;
  final Department department;
  final BookLocation location;
  final List<Article> articles;

  /// Numeric edition, for sorting. Null when the catalogue had none, or
  /// when the edition is a kind rather than a number — see [editionLabel].
  final int? edition;

  /// Display text for the edition in the active language ("الثالثة", "3rd",
  /// "طبعة عالمية"). Null when the catalogue states none.
  final String? editionLabel;

  final String? publisher;
  final PlaceRef? place;
  final int? year;
  final String? subjects;

  /// Library-wide shelf number, as printed on the stacks.
  final int? shelf;

  /// Display text for the shelf in the active language ("الرف 31", "Shelf 31").
  final String? shelfLabel;

  /// Section and shelf as one sentence ("قسم كهرباء، الرف 31"), resolved by
  /// the API. Null on payloads cached before the API sent it.
  final String? locationLabel;

  /// The book's language(s) as display text ("العربية (مترجم عن الإنجليزية)").
  final String? language;

  final String? cover;
  final String? isbn;

  @override
  List<Object?> get props => [
    id, callNumber, title, author, department, location, articles,
    edition, editionLabel, publisher, place, year, subjects,
    shelf, shelfLabel, locationLabel, language, cover, isbn,
  ];
}
