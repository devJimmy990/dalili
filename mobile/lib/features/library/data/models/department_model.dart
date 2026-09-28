import 'package:dalili/core/utils/json_reader.dart';
import 'package:dalili/features/library/domain/entities/department.dart';

class DepartmentModel extends Department {
  const DepartmentModel({
    required super.id,
    required super.name,
    super.mapNodeId,
    super.bookCount,
  });

  factory DepartmentModel.fromJson(Map<dynamic, dynamic> json) =>
      DepartmentModel(
        id: json.requireString('id'),
        name: json.requireString('name'),
        mapNodeId: json.optString('mapNodeId'),
        bookCount: json.optInt('bookCount') ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'mapNodeId': mapNodeId,
    'bookCount': bookCount,
  };
}
