import 'package:dalili/features/library/data/models/navigation/edge_model.dart';
import 'package:dalili/features/library/data/models/navigation/node_model.dart';
import 'package:dalili/features/library/data/models/navigation/place_model.dart';

class LibraryMapModel {
  const LibraryMapModel({
    required this.name,
    required this.width,
    required this.height,
    required this.nodes,
    required this.edges,
    required this.places,
  });
  factory LibraryMapModel.fromJson(Map<String, dynamic> json) =>
      LibraryMapModel(
        name: json['mapName'] as String,
        width: json['width'] as int,
        height: json['height'] as int,
        nodes: (json['nodes'] as List<dynamic>)
            .map((e) => NodeModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        edges: (json['edges'] as List<dynamic>)
            .map((e) => EdgeModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        places: (json['places'] as List<dynamic>)
            .map((e) => PlaceModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String name;
  final int width, height;
  final List<NodeModel> nodes;
  final List<EdgeModel> edges;
  final List<PlaceModel> places;
}
