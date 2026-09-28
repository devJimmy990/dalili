import 'package:equatable/equatable.dart';

/// Where a book physically sits, as the API derives it from the book's
/// department. [nodeId] is a node in `assets/map/library_map.json`, so it
/// can be handed straight to the navigation engine.
class BookLocation extends Equatable {
  const BookLocation({required this.nodeId, required this.name});

  /// Null when the section is not on the library map yet — navigation to
  /// this book has to stay disabled.
  final String? nodeId;

  /// The section's name in the active language.
  final String name;

  bool get isNavigable => nodeId != null && nodeId!.isNotEmpty;

  @override
  List<Object?> get props => [nodeId, name];
}
