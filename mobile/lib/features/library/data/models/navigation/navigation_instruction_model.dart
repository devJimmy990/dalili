import 'package:dalili/features/library/data/models/navigation/navigation_route.dart';

enum NavigationInstructionType { start, forward, turnLeft, turnRight, uTurn }

class NavigationInstructionModel {
  const NavigationInstructionModel({
    required this.type,
    required this.segment,
    required this.message,
  });

  final NavigationInstructionType type;

  /// الـ Segment الذى تنتمى إليه هذه التعليمات
  final PathSegment segment;

  /// النص الذى سيظهر للمستخدم
  final String message;
}
