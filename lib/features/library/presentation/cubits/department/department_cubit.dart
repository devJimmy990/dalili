import 'package:dalili/core/errors/failures.dart';
import 'package:dalili/features/library/data/models/department_model.dart';
import 'package:dalili/features/library/domain/entities/department.dart';
import 'package:dalili/features/library/domain/repositories/library_repository.dart';
import 'package:dalili/features/library/presentation/cubits/department/department_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class DepartmentCubit extends HydratedCubit<DepartmentState> {
  DepartmentCubit(this._repository) : super(const DepartmentState());

  final LibraryRepository _repository;

  Future<void> loadDepartments() async {
    emit(state.copyWith(status: DepartmentStatus.loading));
    try {
      final depts = await _repository.getDepartments();
      emit(
        state.copyWith(
          status: depts.isEmpty
              ? DepartmentStatus.empty
              : DepartmentStatus.success,
          departments: depts,
        ),
      );
    } on Failure catch (f) {
      emit(
        state.copyWith(status: DepartmentStatus.error, errorMessage: f.message),
      );
    }
  }

  Future<void> loadBooksByDepartment(Department dept) async {
    emit(
      state.copyWith(
        status: DepartmentStatus.loading,
        selected: dept,
        books: [],
      ),
    );
    try {
      final books = await _repository.getBooksByDepartment(dept.id);
      emit(
        state.copyWith(
          status: books.isEmpty
              ? DepartmentStatus.empty
              : DepartmentStatus.success,
          books: books,
        ),
      );
    } on Failure catch (f) {
      emit(
        state.copyWith(status: DepartmentStatus.error, errorMessage: f.message),
      );
    }
  }

  @override
  DepartmentState? fromJson(Map<String, dynamic> json) {
    final list = json['departments'] as List? ?? [];
    final departments = list
        .map((e) => DepartmentModel.fromJson(e as Map<dynamic, dynamic>))
        .toList();
    return DepartmentState(
      status: DepartmentStatus.initial,
      departments: departments,
    );
  }

  @override
  Map<String, dynamic>? toJson(DepartmentState state) => {
    'departments': state.departments
        .map((d) => (d as DepartmentModel).toJson())
        .toList(),
  };
}
