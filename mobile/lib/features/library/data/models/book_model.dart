import 'package:dalili/core/utils/json_reader.dart';
import 'package:dalili/features/library/data/models/article_model.dart';
import 'package:dalili/features/library/data/models/book_location_model.dart';
import 'package:dalili/features/library/data/models/department_model.dart';
import 'package:dalili/features/library/data/models/place_ref_model.dart';
import 'package:dalili/features/library/domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.callNumber,
    required super.title,
    required super.author,
    required super.department,
    required super.location,
    required super.articles,
    super.edition,
    super.editionLabel,
    super.publisher,
    super.place,
    super.year,
    super.subjects,
    super.shelf,
    super.shelfLabel,
    super.language,
    super.cover,
    super.isbn,
  });

  factory BookModel.fromJson(Map<dynamic, dynamic> json) {
    final departmentJson = json.optMap('department') ?? const {};
    final department = DepartmentModel.fromJson(departmentJson);

    final locationJson = json.optMap('location');
    final location = locationJson != null
        ? BookLocationModel.fromJson(locationJson)
        : BookLocationModel.fromDepartment(departmentJson);

    final placeJson = json.optMap('place');

    return BookModel(
      id: json.requireString('id'),
      callNumber: json.requireString('callNumber'),
      title: json.requireString('title'),
      author: json.requireString('author'),
      department: department,
      location: location,
      articles: json
          .optList('articles')
          .map((e) => ArticleModel.fromJson(e as Map<dynamic, dynamic>))
          .toList(),
      edition: json.optInt('edition'),
      editionLabel: json.optString('editionLabel'),
      publisher: json.optString('publisher'),
      place: placeJson != null ? PlaceRefModel.fromJson(placeJson) : null,
      year: json.optInt('year'),
      subjects: json.optString('subjects'),
      shelf: json.optInt('shelf'),
      shelfLabel: json.optString('shelfLabel'),
      language: json.optString('language'),
      cover: json.optString('cover'),
      isbn: json.optString('isbn'),
    );
  }

  /// Round-trips through the same keys the API uses, so a cached favorite
  /// rehydrates with [BookModel.fromJson] unchanged.
  Map<String, dynamic> toJson() => {
    'id': id,
    'callNumber': callNumber,
    'title': title,
    'author': author,
    'department': (department as DepartmentModel).toJson(),
    'location': (location as BookLocationModel).toJson(),
    'articles': articles.map((a) => (a as ArticleModel).toJson()).toList(),
    'edition': edition,
    'editionLabel': editionLabel,
    'publisher': publisher,
    'place': place == null ? null : (place! as PlaceRefModel).toJson(),
    'year': year,
    'subjects': subjects,
    'shelf': shelf,
    'shelfLabel': shelfLabel,
    'language': language,
    'cover': cover,
    'isbn': isbn,
  };
}
