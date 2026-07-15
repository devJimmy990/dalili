import 'dart:math';

import 'package:dalili/features/library/data/models/navigation/navigation_location_update_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_position_model.dart';

class NavigationPositionEngine {
  const NavigationPositionEngine();

  NavigationPositionModel calculate({
    required NavigationPositionModel previousPosition,
    required NavigationLocationUpdateModel update,
  }) {
    final heading = update.heading * pi / 180;

    final x = previousPosition.x + cos(heading) * update.walkedDistance;

    final y = previousPosition.y + sin(heading) * update.walkedDistance;

    return previousPosition.copyWith(x: x, y: y);
  }
}
