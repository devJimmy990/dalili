import 'package:dalili/core/utils/json_reader.dart';
import 'package:dalili/features/library/domain/entities/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    required super.bookIds,
    required super.title,
    super.authors,
    super.year,
    super.type,
    super.source,
    super.sourceTitle,
    super.issn,
    super.keywords,
    super.volume,
    super.issue,
    super.pages,
    super.url,
    super.doi,
    super.score,
  });

  factory ArticleModel.fromJson(Map<dynamic, dynamic> json) => ArticleModel(
    id: json.requireString('id'),
    bookIds: json.optList('bookIds').map((e) => e.toString()).toList(),
    title: json.requireString('title'),
    authors: json.optString('authors'),
    year: json.optInt('year'),
    type: json.optString('type'),
    source: json.optString('source'),
    sourceTitle: json.optString('sourceTitle'),
    issn: json.optString('issn'),
    keywords: json.optString('keywords'),
    volume: json.optString('volume'),
    issue: json.optString('issue'),
    pages: json.optString('pages'),
    url: json.optString('url'),
    doi: json.optString('doi'),
    score: json.optDouble('score'),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookIds': bookIds,
    'title': title,
    'authors': authors,
    'year': year,
    'type': type,
    'source': source,
    'sourceTitle': sourceTitle,
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
