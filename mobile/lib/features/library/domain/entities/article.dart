import 'package:equatable/equatable.dart';

/// A journal article or conference paper linked to one or more books.
///
/// Bibliographic records are patchy by nature — a conference paper has no
/// ISSN, a preprint has no issue — so only [id], [title] and [bookIds] are
/// guaranteed.
class Article extends Equatable {
  const Article({
    required this.id,
    required this.bookIds,
    required this.title,
    this.authors,
    this.year,
    this.type,
    this.source,
    this.sourceTitle,
    this.issn,
    this.keywords,
    this.volume,
    this.issue,
    this.pages,
    this.url,
    this.doi,
    this.score,
  });

  final String id;
  final List<String> bookIds;
  final String title;
  final String? authors;
  final int? year;

  /// Free-text kind ("مقال", "بحث مؤتمر").
  final String? type;

  /// "مجلة" or "مؤتمر".
  final String? source;

  /// Journal or proceedings title.
  final String? sourceTitle;

  final String? issn;
  final String? keywords;
  final String? volume;
  final String? issue;
  final String? pages;
  final String? url;
  final String? doi;

  /// Relevance score from the catalogue, 0..1.
  final double? score;

  bool get hasUrl => url != null && url!.isNotEmpty;

  @override
  List<Object?> get props => [
    id, bookIds, title, authors, year, type, source,
    sourceTitle, issn, keywords, volume, issue, pages,
    url, doi, score,
  ];
}
