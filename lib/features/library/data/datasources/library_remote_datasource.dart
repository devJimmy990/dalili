import 'package:dalili/core/constants/api_constants.dart';
import 'package:dalili/core/errors/exceptions.dart';
import 'package:dalili/core/network/dio_client.dart';
import 'package:dalili/core/utils/app_logger.dart';
import 'package:dalili/features/library/data/models/book_model.dart';
import 'package:dalili/features/library/data/models/department_model.dart';
import 'package:dio/dio.dart';

abstract class LibraryRemoteDataSource {
  Future<List<DepartmentModel>> getDepartments();
  Future<List<BookModel>> getAllBooks({int page = 1});
  Future<BookModel?> getBookById(String id);
  Future<List<BookModel>> searchBooks(String query);
  Future<List<BookModel>> getBooksByDepartment(String departmentId);
  Future<List<BookModel>> getBooksByAuthor(String author);
  Future<List<BookModel>> getBooksByIds(List<String> ids);
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  const LibraryRemoteDataSourceImpl(this._client);

  final DioClient _client;

  // Server wraps all payloads: { status: "success", data: { ... } }
  Map<String, dynamic> _unwrap(dynamic responseData) {
    final root = responseData as Map<String, dynamic>;
    return root['data'] as Map<String, dynamic>? ?? root;
  }

  @override
  Future<List<DepartmentModel>> getDepartments() async {
    try {
      final response = await _client.dio.get(
        '',
        queryParameters: {'action': ApiConstants.actionGetDepartments},
      );
      final data = _unwrap(response.data);
      final list = data['departments'] as List? ?? [];
      return list
          .map((e) => DepartmentModel.fromJson(e as Map<dynamic, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.error('getDepartments: ${e.message}');
      throw ServerException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<List<BookModel>> getAllBooks({int page = 1}) async {
    try {
      final response = await _client.dio.get(
        '',
        queryParameters: {
          'action': ApiConstants.actionGetAllBooks,
          'page': page,
        },
      );
      final data = _unwrap(response.data);
      final list = data['books'] as List? ?? [];
      return list
          .map((e) => BookModel.fromJson(e as Map<dynamic, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.error('getAllBooks: ${e.message}');
      throw ServerException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<BookModel?> getBookById(String id) async {
    try {
      final response = await _client.dio.get(
        '',
        queryParameters: {'action': ApiConstants.actionSearchById, 'id': id},
      );
      final data = _unwrap(response.data);
      final bookJson = data['book'];
      if (bookJson == null) return null;
      return BookModel.fromJson(bookJson as Map<dynamic, dynamic>);
    } on DioException catch (e) {
      AppLogger.error('getBookById: ${e.message}');
      throw ServerException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<List<BookModel>> searchBooks(String query) async {
    try {
      final response = await _client.dio.get(
        '',
        queryParameters: {'action': ApiConstants.actionSearch, 'query': query},
      );
      final data = _unwrap(response.data);
      final list = data['books'] as List? ?? [];
      return list
          .map((e) => BookModel.fromJson(e as Map<dynamic, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.error('searchBooks: ${e.message}');
      throw ServerException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<List<BookModel>> getBooksByDepartment(String departmentId) async {
    try {
      print("debug-getBooksByDepartment: id = $departmentId");
      final response = await _client.dio.get(
        '',
        queryParameters: {
          'action': ApiConstants.actionGetBooksByDepartment,
          'department': departmentId,
        },
      );
      final data = _unwrap(response.data);
      print("debug-getBooksByDepartment: data = $data");
      final list = data['books'] as List? ?? [];
      return list
          .map((e) => BookModel.fromJson(e as Map<dynamic, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.error('getBooksByDepartment: ${e.message}');
      throw ServerException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<List<BookModel>> getBooksByAuthor(String author) async {
    try {
      final response = await _client.dio.get(
        '',
        queryParameters: {
          'action': ApiConstants.actionGetBooksByAuthor,
          'author': author,
        },
      );
      final data = _unwrap(response.data);
      final list = data['books'] as List? ?? [];
      return list
          .map((e) => BookModel.fromJson(e as Map<dynamic, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.error('getBooksByAuthor: ${e.message}');
      throw ServerException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<List<BookModel>> getBooksByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      final response = await _client.dio.get(
        '',
        queryParameters: {
          'action': ApiConstants.actionGetBooksByIds,
          'ids': ids.join(','),
        },
      );
      final data = _unwrap(response.data);
      final list = data['books'] as List? ?? [];
      return list
          .map((e) => BookModel.fromJson(e as Map<dynamic, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.error('getBooksByIds: ${e.message}');
      throw ServerException(e.message ?? 'Unknown error');
    }
  }
}
