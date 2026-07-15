import 'package:equatable/equatable.dart';

class Article extends Equatable {
  const Article({
    required this.id,
    required this.bookIds,
    required this.title,
    required this.authors,
    required this.year,
    required this.type,
    required this.source,
    required this.sourceTitle,
    required this.issn,
    required this.keywords,
    required this.volume,
    required this.issue,
    required this.pages,
    required this.url,
    required this.doi,
    required this.score,
  });

  final String id;
  final List<String> bookIds;
  final String title;
  final String authors;
  final String year;
  final String type;
  final String source;
  final String sourceTitle;
  final String issn;
  final String keywords;
  final String volume;
  final String issue;
  final String pages;
  final String url;
  final String doi;
  final String score;

  @override
  List<Object?> get props => [
        id, bookIds, title, authors, year, type, source,
        sourceTitle, issn, keywords, volume, issue, pages,
        url, doi, score,
      ];
}
