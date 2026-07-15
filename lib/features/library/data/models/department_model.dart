import 'package:dalili/features/library/domain/entities/department.dart';

class DepartmentModel extends Department {
  const DepartmentModel({required super.id, required super.name});

  factory DepartmentModel.fromJson(Map<dynamic, dynamic> json) =>
      DepartmentModel(
        id: (json['id'] as String? ?? '').trim(),
        name: (json['name'] as String? ?? '').trim(),
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
