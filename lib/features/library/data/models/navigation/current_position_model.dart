import 'package:flutter/material.dart';

class CurrentPositionModel {
  const CurrentPositionModel({
    required this.x,
    required this.y,
    required this.progress,
    required this.direction,
    required this.canvasOffset,
  });

  final double x;

  final double y;

  /// 0 -> 1
  final double progress;

  /// degrees
  final double direction;

  /// ready for painter
  final Offset canvasOffset;
}
