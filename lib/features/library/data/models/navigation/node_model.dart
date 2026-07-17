class NodeModel {
  NodeModel({
    required this.id,
    required this.name,
    required this.type,
    required this.x,
    required this.y,
    this.qr,
    this.imageX,
    this.imageY,
  });

  factory NodeModel.fromJson(Map<String, dynamic> json) => NodeModel(
    id: json['id'] as String,
    qr: json['qr'] as String?,
    name: json['name'] as String,
    type: json['type'] as String,
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    imageX: (json['imageX'] as num?)?.toDouble(),
    imageY: (json['imageY'] as num?)?.toDouble(),
  );

  final String id, name, type;
  final String? qr;

  /// Position in real-world meters. Used for route-weighting math
  /// (Dijkstra) and for dead-reckoning distance accumulation. Not used
  /// for drawing.
  final double x, y;

  /// Pixel position on the library's static map image. Used only for
  /// rendering — has no effect on route calculation or distance math.
  /// Null if this node hasn't been calibrated against an image yet.
  final double? imageX, imageY;

  bool get hasImagePosition => imageX != null && imageY != null;
}
