import 'package:dalili/core/utils/json_reader.dart';
import 'package:dalili/features/library/domain/entities/place_ref.dart';

class PlaceRefModel extends PlaceRef {
  const PlaceRefModel({required super.id, required super.name});

  factory PlaceRefModel.fromJson(Map<dynamic, dynamic> json) => PlaceRefModel(
    id: json.requireString('id'),
    name: json.requireString('name'),
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
