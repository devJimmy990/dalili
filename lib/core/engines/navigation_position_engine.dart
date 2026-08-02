import 'dart:math';

import 'package:dalili/features/library/data/models/navigation/navigation_location_update_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_position_model.dart';

class NavigationPositionEngine {
  const NavigationPositionEngine();

  /// Dead reckoning step: advances [previousPosition] by
  /// [update.walkedDistance] in the direction of [update.heading].
  ///
  /// `heading` is a true compass bearing from flutter_compass — 0° =
  /// North, increasing clockwise — NOT a standard math angle. In this
  /// project's coordinate system (x increases east, y increases south —
  /// same convention the calibrated image pixels use), the correct
  /// conversion is:
  ///   x (east)  += sin(heading) * distance
  ///   y (south) += -cos(heading) * distance
  ///
  /// This is the exact inverse of the bearing calculation already used in
  /// NavigationDecisionEngine (`atan2(dx, -dy)`) — the two must mirror
  /// each other, or dead reckoning drifts in the wrong direction relative
  /// to the live turn-by-turn instructions.
  NavigationPositionModel calculate({
    required NavigationPositionModel previousPosition,
    required NavigationLocationUpdateModel update,
  }) {
    final headingRad = update.heading * pi / 180;

    final x = previousPosition.x + sin(headingRad) * update.walkedDistance;
    final y = previousPosition.y - cos(headingRad) * update.walkedDistance;

    return previousPosition.copyWith(x: x, y: y);
  }
}
