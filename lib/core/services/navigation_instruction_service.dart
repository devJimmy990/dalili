import 'package:dalili/core/utils/angle_utils.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_instruction_model.dart';
import 'package:dalili/features/library/data/models/navigation/navigation_route.dart';

class NavigationInstructionService {
  const NavigationInstructionService._();

  static List<NavigationInstructionModel> build(NavigationRouteModel route) {
    final instructions = <NavigationInstructionModel>[];

    for (int i = 0; i < route.segments.length; i++) {
      final segment = route.segments[i];

      final type = _instruction(
        previousAngle: i == 0 ? null : route.segments[i - 1].angle,
        currentAngle: segment.angle,
      );

      instructions.add(
        NavigationInstructionModel(
          type: type,
          segment: segment,
          message: _message(type, segment.distance),
        ),
      );
    }

    return instructions;
  }

  static NavigationInstructionType _instruction({
    required double? previousAngle,
    required double currentAngle,
  }) {
    if (previousAngle == null) {
      return NavigationInstructionType.start;
    }

    final diff = AngleUtils.normalizeDegrees(currentAngle - previousAngle);

    if (diff.abs() < 20) {
      return NavigationInstructionType.forward;
    }

    if (diff.abs() > 160) {
      return NavigationInstructionType.uTurn;
    }

    if (diff > 0) {
      return NavigationInstructionType.turnLeft;
    }

    return NavigationInstructionType.turnRight;
  }

  static String _message(NavigationInstructionType type, double distance) {
    switch (type) {
      case NavigationInstructionType.start:
        return "ابدأ السير لمسافة ${distance.toStringAsFixed(1)} متر";

      case NavigationInstructionType.forward:
        return "استمر مستقيمًا ${distance.toStringAsFixed(1)} متر";

      case NavigationInstructionType.turnLeft:
        return "انعطف يسارًا ثم استمر";

      case NavigationInstructionType.turnRight:
        return "انعطف يمينًا ثم استمر";

      case NavigationInstructionType.uTurn:
        return "استدر للخلف";
    }
  }
}
