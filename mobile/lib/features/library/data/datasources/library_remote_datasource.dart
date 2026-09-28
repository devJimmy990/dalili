import 'package:dalili/core/constants/api_constants.dart';
import 'package:dalili/core/errors/exceptions.dart';
import 'package:dalili/core/network/dio_client.dart';
import 'package:dalili/core/utils/json_reader.dart';
import 'package:dalili/features/library/data/models/book_model.dart';
import 'package:dalili/features/library/domain/entities/book_page.dart';
import 'package:dalili/features/library/data/models/department_model.dart';
import 'package:dio/dio.dart';

abstract class LibraryRemoteDataSource {
  Future<List<DepartmentModel>> getDepartments();
  Future<BookPage> getAllBooks({int page = 1});
  Future<BookModel?> getBookById(String id);
  Future<List<BookModel>> searchBooks(String query);
  Future<BookPage> getBooksByDepartment(String departmentId, {int page = 1});
  Future<BookPage> getBooksByAuthor(String author, {int page = 1});
  Future<List<BookModel>> getBooksByIds(List<String> ids);
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  const LibraryRemoteDataSourceImpl(this._client);

  final DioClient _client;

  /// Runs a GET and unwraps the envelope, translating Dio's transport
  /// errors into the app's exceptions.
  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, dynamic>? query,
  ]) async {
    try {
      final response = await _client.dio.get<dynamic>(
        path,
        queryParameters: query,
      );
      return response.payload;
    } on DioException catch (e) {
      rethrowAsAppException(e);
    }
  }

  List<BookModel> _books(Map<String, dynamic> payload) => payload
      .optList('items')
      .map((e) => BookModel.fromJson(e as Map<dynamic, dynamic>))
      .toList();

  BookPage _page(Map<String, dynamic> payload) => BookPage(
    books: _books(payload),
    total: payload.optInt('total') ?? 0,
    page: payload.optInt('page') ?? 1,
    hasMore: payload['hasMore'] == true,
  );

  @override
  Future<List<DepartmentModel>> getDepartments() async {
    final payload = await _get(ApiConstants.departments);
    return payload
        .optList('items')
        .map((e) => DepartmentModel.fromJson(e as Map<dynamic, dynamic>))
        .toList();
  }

  @override
  Future<BookPage> getAllBooks({int page = 1}) async =>
      _page(await _get(ApiConstants.books, {ApiConstants.paramPage: page}));

  @override
  Future<BookModel?> getBookById(String id) async {
    try {
      final payload = await _get(ApiConstants.book(id));
      final book = payload.optMap('book');
      return book == null ? null : BookModel.fromJson(book);
    } on NotFoundException {
      // An unknown id is an expected outcome — a QR code for a book that
      // is no longer catalogued.
      return null;
    }
  }

  @override
  Future<List<BookModel>> searchBooks(String query) async =>
      _books(await _get(ApiConstants.booksSearch, {
        ApiConstants.paramQuery: query,
      }));

  @override
  Future<BookPage> getBooksByDepartment(
    String departmentId, {
    int page = 1,
  }) async => _page(
    await _get(ApiConstants.departmentBooks(departmentId), {
      ApiConstants.paramPage: page,
    }),
  );

  @override
  Future<BookPage> getBooksByAuthor(String author, {int page = 1}) async =>
      _page(await _get(ApiConstants.books, {
        ApiConstants.paramAuthor: author,
        ApiConstants.paramPage: page,
      }));

  @override
  Future<List<BookModel>> getBooksByIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    return _books(await _get(ApiConstants.booksByIds, {
      ApiConstants.paramIds: ids.join(','),
    }));
  }
}
