import 'package:dalili/core/errors/exceptions.dart';
import 'package:dalili/core/errors/failures.dart';
import 'package:dalili/features/library/data/datasources/library_remote_datasource.dart';
import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:dalili/features/library/domain/entities/department.dart';
import 'package:dalili/features/library/domain/repositories/library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  const LibraryRepositoryImpl(this._dataSource);

  final LibraryRemoteDataSource _dataSource;

  @override
  Future<List<Department>> getDepartments() async {
    try {
      return await _dataSource.getDepartments();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<Book>> getAllBooks({int page = 1}) async {
    try {
      return await _dataSource.getAllBooks(page: page);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<Book?> getBookById(String id) async {
    try {
      return await _dataSource.getBookById(id);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<Book>> searchBooks(String query) async {
    try {
      return await _dataSource.searchBooks(query);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<Book>> getBooksByDepartment(String departmentId) async {
    try {
      return await _dataSource.getBooksByDepartment(departmentId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<Book>> getBooksByAuthor(String author) async {
    try {
      return await _dataSource.getBooksByAuthor(author);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<Book>> getBooksByIds(List<String> ids) async {
    try {
      return await _dataSource.getBooksByIds(ids);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
