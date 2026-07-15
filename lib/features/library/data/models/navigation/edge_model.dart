class EdgeModel {
  EdgeModel({required this.from, required this.to, this.bidirectional = true});

  factory EdgeModel.fromJson(Map<String, dynamic> json) => EdgeModel(
    to: json['to'] as String,
    from: json['from'] as String,
    bidirectional: json['bidirectional'] as bool,
  );

  final String from, to;
  final bool bidirectional;
}
