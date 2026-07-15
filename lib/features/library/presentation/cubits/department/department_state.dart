import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:dalili/features/library/domain/entities/department.dart';
import 'package:equatable/equatable.dart';

enum DepartmentStatus { initial, loading, success, empty, error }

class DepartmentState extends Equatable {
  const DepartmentState({
    this.status = DepartmentStatus.initial,
    this.departments = const [],
    this.books = const [],
    this.selected,
    this.errorMessage = '',
  });

  final DepartmentStatus status;
  final List<Department> departments;
  final List<Book> books;
  final Department? selected;
  final String errorMessage;

  DepartmentState copyWith({
    DepartmentStatus? status,
    List<Department>? departments,
    List<Book>? books,
    Department? selected,
    String? errorMessage,
  }) =>
      DepartmentState(
        status: status ?? this.status,
        departments: departments ?? this.departments,
        books: books ?? this.books,
        selected: selected ?? this.selected,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props =>
      [status, departments, books, selected, errorMessage];
}
