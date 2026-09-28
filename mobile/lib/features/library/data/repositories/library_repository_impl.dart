import 'package:dalili/core/errors/exceptions.dart';
import 'package:dalili/core/errors/failures.dart';
import 'package:dalili/features/library/data/datasources/library_remote_datasource.dart';
import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:dalili/features/library/domain/entities/book_page.dart';
import 'package:dalili/features/library/domain/entities/department.dart';
import 'package:dalili/features/library/domain/repositories/library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  const LibraryRepositoryImpl(this._dataSource);

  final LibraryRemoteDataSource _dataSource;

  /// Single place where data-layer exceptions become domain [Failure]s, so
  /// every method below reads as the one call it actually makes.
  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on NotFoundException catch (e) {
      throw ServerFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<Department>> getDepartments() =>
      _guard(_dataSource.getDepartments);

  @override
  Future<BookPage> getAllBooks({int page = 1}) =>
      _guard(() => _dataSource.getAllBooks(page: page));

  @override
  Future<Book?> getBookById(String id) =>
      _guard(() => _dataSource.getBookById(id));

  @override
  Future<List<Book>> searchBooks(String query) =>
      _guard(() => _dataSource.searchBooks(query));

  @override
  Future<BookPage> getBooksByDepartment(String departmentId, {int page = 1}) =>
      _guard(() => _dataSource.getBooksByDepartment(departmentId, page: page));

  @override
  Future<BookPage> getBooksByAuthor(String author, {int page = 1}) =>
      _guard(() => _dataSource.getBooksByAuthor(author, page: page));

  @override
  Future<List<Book>> getBooksByIds(List<String> ids) =>
      _guard(() => _dataSource.getBooksByIds(ids));
}
