import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:dalili/features/library/domain/entities/department.dart';

abstract class LibraryRepository {
  Future<List<Department>> getDepartments();
  Future<List<Book>> getAllBooks({int page = 1});
  Future<Book?> getBookById(String id);
  Future<List<Book>> searchBooks(String query);
  Future<List<Book>> getBooksByDepartment(String departmentId);
  Future<List<Book>> getBooksByAuthor(String author);
  Future<List<Book>> getBooksByIds(List<String> ids);
}
