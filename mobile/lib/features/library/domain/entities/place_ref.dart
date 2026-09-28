import 'package:equatable/equatable.dart';

/// Where a book was published, already resolved to the active language.
class PlaceRef extends Equatable {
  const PlaceRef({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
