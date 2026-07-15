import 'package:dalili/features/library/domain/entities/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    required super.bookIds,
    required super.title,
    required super.authors,
    required super.year,
    required super.type,
    required super.source,
    required super.sourceTitle,
    required super.issn,
    required super.keywords,
    required super.volume,
    required super.issue,
    required super.pages,
    required super.url,
    required super.doi,
    required super.score,
  });

  factory ArticleModel.fromJson(Map<dynamic, dynamic> json) {
    final rawBookIds = json['book_ids'];
    final List<String> bookIds;
    if (rawBookIds is List) {
      bookIds = rawBookIds.map((e) => e.toString()).toList();
    } else if (rawBookIds is String && rawBookIds.isNotEmpty) {
      bookIds = rawBookIds.split('/*-*/').map((e) => e.trim()).toList();
    } else {
      bookIds = [];
    }

    String s(String key) => (json[key] as String? ?? '').trim();

    return ArticleModel(
      id: s('id'),
      bookIds: bookIds,
      title: s('title'),
      authors: s('authors'),
      year: s('year'),
      type: s('type'),
      source: s('source'),
      sourceTitle: s('source_title'),
      issn: s('issn'),
      keywords: s('keywords'),
      volume: s('volume'),
      issue: s('issue'),
      pages: s('pages'),
      url: s('url'),
      doi: s('doi'),
      score: s('score'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'book_ids': bookIds.join('/*-*/'),
        'title': title,
        'authors': authors,
        'year': year,
        'type': type,
        'source': source,
        'source_title': sourceTitle,
        'issn': issn,
        'keywords': keywords,
        'volume': volume,
        'issue': issue,
        'pages': pages,
        'url': url,
        'doi': doi,
        'score': score,
      };
}
