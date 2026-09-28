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
    this.width,
    this.height,
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
    width: (json['width'] as num?)?.toDouble(),
    height: (json['height'] as num?)?.toDouble(),
  );

  final String id, name, type;
  final String? qr;

  /// Position in real-world meters. Used for route-weighting math
  /// (Dijkstra) and for dead-reckoning distance accumulation. Not used
  /// for drawing.
  final double x, y;

  /// Pixel position on the library's static map image. Left over from the
  /// removed on-screen map — has no effect on route calculation, distance
  /// math, or anything else read at runtime. Null if never calibrated.
  final double? imageX, imageY;

  bool get hasImagePosition => imageX != null && imageY != null;

  /// Real-world footprint in meters ("arrival zone"), centered on
  /// (x, y). Null if this node has no calibrated footprint, in which case
  /// [containsPoint] always returns false and arrival falls back to the
  /// walked-distance threshold.
  final double? width, height;

  /// Whether (px, py) falls inside this node's axis-aligned footprint.
  bool containsPoint(double px, double py) {
    final w = width;
    final h = height;

    if (w == null || h == null) {
      return false;
    }

    final halfWidth = w / 2;
    final halfHeight = h / 2;

    return px >= x - halfWidth &&
        px <= x + halfWidth &&
        py >= y - halfHeight &&
        py <= y + halfHeight;
  }
}
