class PlaceModel {
  PlaceModel({required this.id, required this.name, required this.nodeId});

  factory PlaceModel.fromJson(Map<String, dynamic> json) => PlaceModel(
    id: json['id'] as String,
    name: json['name'] as String,
    nodeId: json['nodeId'] as String,
  );

  final String id, name, nodeId;
}
