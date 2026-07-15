import 'package:dalili/features/library/domain/entities/article.dart';
import 'package:dalili/features/library/domain/entities/department.dart';
import 'package:equatable/equatable.dart';

class Book extends Equatable {
  const Book({
    required this.id,
    required this.callNumber,
    required this.title,
    required this.author,
    required this.edition,
    required this.publisher,
    required this.place,
    required this.year,
    required this.subjects,
    required this.location,
    required this.shelf,
    required this.department,
    required this.language,
    required this.cover,
    required this.isbn,
    required this.articles,
  });

  final String id;
  final String callNumber;
  final String title;
  final String author;
  final String edition;
  final String publisher;
  final String place;
  final String year;
  final String subjects;
  final String location;
  final String shelf;
  final Department department;
  final String language;
  final String cover;
  final String isbn;
  final List<Article> articles;

  @override
  List<Object?> get props => [
        id, callNumber, title, author, edition, publisher,
        place, year, subjects, location, shelf, department,
        language, cover, isbn, articles,
      ];
}
