import 'package:equatable/equatable.dart';

/// A library section. [name] is already resolved to the active language.
class Department extends Equatable {
  const Department({
    required this.id,
    required this.name,
    this.mapNodeId,
    this.bookCount = 0,
  });

  final String id;
  final String name;

  /// Node id in `assets/map/library_map.json`. Null when the section is not
  /// on the map, which means it cannot be a navigation destination.
  final String? mapNodeId;

  /// How many books the section holds. A section can legitimately be empty
  /// and still exist on the map.
  final int bookCount;

  bool get isNavigable => mapNodeId != null && mapNodeId!.isNotEmpty;
  bool get isEmpty => bookCount == 0;

  @override
  List<Object?> get props => [id, name, mapNodeId, bookCount];
}
