import 'package:dalili/features/library/data/models/article_model.dart';
import 'package:dalili/features/library/data/models/department_model.dart';
import 'package:dalili/features/library/domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.year,
    required super.isbn,
    required super.title,
    required super.place,
    required super.shelf,
    required super.cover,
    required super.author,
    required super.edition,
    required super.subjects,
    required super.location,
    required super.language,
    required super.articles,
    required super.publisher,
    required super.callNumber,
    required super.department,
  });

  factory BookModel.fromJson(Map<dynamic, dynamic> json) {
    String s(String key) => (json[key] as String? ?? '').trim();

    final deptRaw = json['department'];
    final department = DepartmentModel.fromJson(
      (deptRaw is Map<dynamic, dynamic> ? deptRaw : <dynamic, dynamic>{}),
    );

    final articlesList = (json['articles'] as List? ?? [])
        .map((e) => ArticleModel.fromJson(e as Map<dynamic, dynamic>))
        .toList();

    return BookModel(
      id: s('id'),
      callNumber: s('call_number'),
      title: s('title'),
      author: s('author'),
      edition: s('edition'),
      publisher: s('publisher'),
      place: s('place'),
      year: s('year'),
      subjects: s('subjects'),
      location: s('location'),
      shelf: s('shelf'),
      department: department,
      language: s('language'),
      cover: s('cover'),
      isbn: s('isbn'),
      articles: articlesList,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'call_number': callNumber,
    'title': title,
    'author': author,
    'edition': edition,
    'publisher': publisher,
    'place': place,
    'year': year,
    'subjects': subjects,
    'location': location,
    'shelf': shelf,
    'department': (department as DepartmentModel).toJson(),
    'language': language,
    'cover': cover,
    'isbn': isbn,
    'articles': articles.map((a) => (a as ArticleModel).toJson()).toList(),
  };
}
