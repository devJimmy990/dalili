class NodeModel {
  NodeModel({
    required this.id,
    required this.name,
    required this.type,
    required this.x,
    required this.y,
    this.qr,
  });

  factory NodeModel.fromJson(Map<String, dynamic> json) => NodeModel(
    id: json['id'] as String,
    qr: json['qr'] as String?,
    name: json['name'] as String,
    type: json['type'] as String,
    x: json['x'] as double,
    y: json['y'] as double,
  );

  final String id, name, type;
  final String? qr;
  final double x, y;
}
