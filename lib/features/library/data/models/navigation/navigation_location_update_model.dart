// class NavigationLocationUpdateModel {
//   const NavigationLocationUpdateModel({
//     required this.walkedDistance,
//     required this.heading,
//     this.x,
//     this.y,
//     this.accuracy,
//     this.timestamp,
//   });

//   /// Distance moved since last update (meters)
//   final double walkedDistance;

//   /// Heading in degrees (0 - 360)
//   final double heading;

//   /// Current estimated position on the map
//   final double? x;
//   final double? y;

//   /// Position accuracy in meters
//   final double? accuracy;

//   final DateTime? timestamp;
// }
class NavigationLocationUpdateModel {
  const NavigationLocationUpdateModel({
    required this.heading,
    required this.walkedDistance,
    this.currentNodeId,
    this.timestamp,
  });

  final double heading;

  final double walkedDistance;

  /// QR Result
  final String? currentNodeId;

  final DateTime? timestamp;
}
