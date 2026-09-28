import 'package:dalili/features/library/data/models/navigation/edge_model.dart';
import 'package:dalili/features/library/data/models/navigation/node_model.dart';

class LibraryMapModel {
  const LibraryMapModel({
    required this.name,
    required this.imageWidth,
    required this.imageHeight,
    required this.nodes,
    required this.edges,
  });
  factory LibraryMapModel.fromJson(Map<String, dynamic> json) =>
      LibraryMapModel(
        name: json['mapName'] as String,
        imageWidth: (json['imageWidth'] as num).toDouble(),
        imageHeight: (json['imageHeight'] as num).toDouble(),
        nodes: (json['nodes'] as List<dynamic>)
            .map((e) => NodeModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        edges: (json['edges'] as List<dynamic>)
            .map((e) => EdgeModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String name;

  /// Natural pixel dimensions of the background map image.
  final double imageWidth, imageHeight;
  final List<NodeModel> nodes;
  final List<EdgeModel> edges;
}
