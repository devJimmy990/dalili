import 'package:dalili/features/library/domain/entities/book_page.dart';
import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:dalili/features/library/domain/entities/department.dart';

abstract class LibraryRepository {
  Future<List<Department>> getDepartments();
  Future<BookPage> getAllBooks({int page = 1});
  Future<Book?> getBookById(String id);

  /// Every match in one call — the catalogue is small enough not to page.
  Future<List<Book>> searchBooks(String query);

  Future<BookPage> getBooksByDepartment(String departmentId, {int page = 1});
  Future<BookPage> getBooksByAuthor(String author, {int page = 1});

  /// Resolves cached favorites, preserving the order of [ids].
  Future<List<Book>> getBooksByIds(List<String> ids);
}
