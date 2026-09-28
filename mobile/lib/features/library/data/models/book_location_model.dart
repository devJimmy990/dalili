import 'package:dalili/core/utils/json_reader.dart';
import 'package:dalili/features/library/domain/entities/book_location.dart';

class BookLocationModel extends BookLocation {
  const BookLocationModel({required super.nodeId, required super.name});

  factory BookLocationModel.fromJson(Map<dynamic, dynamic> json) =>
      BookLocationModel(
        nodeId: json.optString('nodeId'),
        name: json.requireString('name'),
      );

  /// Falls back to the department when the payload has no `location` — the
  /// two always describe the same section, so the UI still has a label.
  factory BookLocationModel.fromDepartment(Map<dynamic, dynamic> department) =>
      BookLocationModel(
        nodeId: department.optString('mapNodeId'),
        name: department.requireString('name'),
      );

  Map<String, dynamic> toJson() => {'nodeId': nodeId, 'name': name};
}
