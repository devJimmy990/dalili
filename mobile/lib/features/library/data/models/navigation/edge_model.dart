class EdgeModel {
  EdgeModel({
    required this.from,
    required this.to,
    this.bidirectional = true,
    this.width,
  });

  factory EdgeModel.fromJson(Map<String, dynamic> json) => EdgeModel(
    to: json['to'] as String,
    from: json['from'] as String,
    bidirectional: json['bidirectional'] as bool,
    width: (json['width'] as num?)?.toDouble(),
  );

  final String from, to;
  final bool bidirectional;

  /// Corridor width in meters, if calibrated for this edge. Used as the
  /// on-route tolerance for this specific segment instead of a single
  /// tolerance shared by every corridor.
  final double? width;
}
